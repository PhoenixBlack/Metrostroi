--------------------------------------------------------------------------------
-- Generic relay with configureable parameters
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("Relay")

function TRAIN_SYSTEM:Initialize(parameters,power_supply)
	if not parameters then parameters = {} end
	if type(parameters) ~= "table" then
		if parameters == "KPP-113" then
			parameters = {
				working_voltage 	= 750, -- V
				control_voltage		= 75,  -- V
				nominal_current 	= 160, -- A
				power_supply 		= power_supply or "AB",
			}
		elseif parameters == "KPD-110" then
			parameters = {
				working_voltage 	= 220, -- V
				control_voltage		= 75,  -- V
				nominal_current 	= 10, -- A
				power_supply 		= power_supply or "AB",
			}
		elseif parameters == "RPUZ-114-T-UHLZA" then
			parameters = {
				control_voltage		= 75,  -- V
				power_supply 		= power_supply or "AB",
				MTBF				= 20000,
			}
		else
			print("Invalid relay type: "..parameters)
		end
	end
	
	-- Is relay normally open or closed
	self.NormallyOpen = parameters.normally_open or false
	self.PowerSupply = parameters.power_supply or power_supply or "None"
	self.WorkingVoltage = parameters.working_voltage or 750

	-- Relay parameters
	FailSim.AddParameter(self,		"CloseTime",
		{ value =  parameters.on_time or 0.050, min = 0.010, varies = true })
	FailSim.AddParameter(self,		"OpenTime", 
		{ value = parameters.off_time or 0.050, min = 0.010, varies = true })
		
	-- Did relay short-circuit?
	FailSim.AddParameter(self,		"ShortCircuit",		{ value = 0.000, precision = 0.00 })
	-- Was there a spurious trip?
	FailSim.AddParameter(self,		"SpuriousTrip",   	{ value = 0.000, precision = 0.00 })

	local MTBF = parameters.MTBF or 1000000 -- cycles, mean time between failures
	local MFR = 1/MTBF   -- cycles^-1, total failure rate
	if self.Contactor then
		FailSim.AddFailurePoint(self,	"CloseTime", "Mechanical problem in contactor", 
			{ type = "precision", 	value = 0.5,	mfr = MFR*0.65*0.25, recurring = true } )
		FailSim.AddFailurePoint(self,	"OpenTime", "Mechanical problem in contactor", 
			{ type = "precision", 	value = 0.5,	mfr = MFR*0.65*0.25, recurring = true } )
		FailSim.AddFailurePoint(self,	"CloseTime", "Contactor stuck closed",
			{ type = "value", 		value = 1e9,	mfr = MFR*0.65*0.25, dmtbf = 0.2 } )
		FailSim.AddFailurePoint(self,	"OpenTime", "Contactor stuck open",
			{ type = "value", 		value = 1e9,	mfr = MFR*0.65*0.25, dmtbf = 0.4 } )
	elseif self.NormallyOpen then
		FailSim.AddFailurePoint(self,	"CloseTime", "Mechanical problem in relay", 
			{ type = "precision", 	value = 0.5,	mfr = MFR*0.65*0.4, recurring = true } )
		FailSim.AddFailurePoint(self,	"OpenTime", "Mechanical problem in relay", 
			{ type = "precision", 	value = 0.5,	mfr = MFR*0.65*0.1, recurring = true } )
		FailSim.AddFailurePoint(self,	"CloseTime", "Relay stuck closed",
			{ type = "value", 		value = 1e9,	mfr = MFR*0.65*0.4, dmtbf = 0.2 } )
		FailSim.AddFailurePoint(self,	"OpenTime", "Relay stuck open",
			{ type = "value", 		value = 1e9,	mfr = MFR*0.65*0.1, dmtbf = 0.4 } )
	else
		FailSim.AddFailurePoint(self,	"CloseTime", "Mechanical problem in relay", 
			{ type = "precision", 	value = 0.5,	mfr = MFR*0.65*0.1, recurring = true } )
		FailSim.AddFailurePoint(self,	"OpenTime", "Mechanical problem in relay", 
			{ type = "precision", 	value = 0.5,	mfr = MFR*0.65*0.4, recurring = true } )
		FailSim.AddFailurePoint(self,	"CloseTime", "Relay stuck closed",
			{ type = "value", 		value = 1e9,	mfr = MFR*0.65*0.1, dmtbf = 0.2 } )
		FailSim.AddFailurePoint(self,	"OpenTime", "Relay stuck open",
			{ type = "value", 		value = 1e9,	mfr = MFR*0.65*0.4, dmtbf = 0.4 } )
	end
	FailSim.AddFailurePoint(self,	"SpuriousTrip", "Spurious trip",
		{ type = "on",							mfr = MFR*0.20, dmtbf = 0.4 } )
	FailSim.AddFailurePoint(self,	"ShortCircuit", "Short-circuit",
		{ type = "on",							mfr = MFR*0.15, dmtbf = 0.2 } )

	-- Initial relay parameters
	self.ChangeTime = nil
	if self.NormallyOpen then
		self.TargetValue = 1.0
		self.Value = 1.0
	else
		self.TargetValue = 0.0
		self.Value = 0.0
	end
end

function TRAIN_SYSTEM:Inputs()
	return { "Open", "Close" }
end

function TRAIN_SYSTEM:Outputs()
	return { "State" }
end

function TRAIN_SYSTEM:TriggerInput(name,value)	
	if (name == "Close") and (value > 0.5) then
		self.TargetValue = 1.0
		self.ChangeTime = CurTime() + FailSim.Value(self,"CloseTime")
	elseif (name == "Open") and (value > 0.5) then
		self.TargetValue = 0.0
		self.ChangeTime = CurTime() + FailSim.Value(self,"OpenTime")
	end
end

function TRAIN_SYSTEM:Think()
	-- Check if power to relays dissapeared
	local voltage,target = 12,0
	if self.PowerSupply == "80V" then
		voltage = self.Train.BPSN.Power80V
		target = 55.0
	elseif self.PowerSupply == "AB" then
		voltage = self.Train.Battery.Voltage
		target = 55.0
	elseif self.PowerSupply == "KPP" then -- KVP receives power from KPP
		voltage = self.Train.BPSN.Power80V * self.Train.KPP
		target = 55.0
	end
	
	-- If no power supply specified, the relay will act as a contactor	
	if voltage < target then
		self.ChangeTime = nil
		if self.NormallyOpen then
			self.Value = 1.0
		else
			self.Value = 0.0
		end
		return
	end
		
	
	-- Short-circuited relay
	if FailSim.Value(self,"ShortCircuit") > 0.5 then
		self.Value = 0.0
		return
	end
	
	-- Spurious trip
	if FailSim.Value(self,"SpuriousTrip") > 0.5 then
		self.Value = 1.0 - self.Value
		FailSim.ResetParameter(self,"SpuriousTrip",0.0)
		
		FailSim.Age(self,1)
	end

	-- Switch relay
	if self.ChangeTime and (CurTime() > self.ChangeTime) then		
		self.Value = self.TargetValue
		self.ChangeTime = nil
		
		FailSim.Age(self,1)
	end
end
