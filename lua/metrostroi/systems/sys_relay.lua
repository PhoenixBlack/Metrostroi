--------------------------------------------------------------------------------
-- Generic relay with configureable parameters
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("Relay")

local relay_types = {
	["PK-162"] = {
		power_supply 		= "Train line",
		contactor			= true,
	},
	
	["Switch"] = {
		power_supply		= "Mechanical",
		contactor			= true,
	}
}

function TRAIN_SYSTEM:Initialize(parameters,extra_parameters)
	----------------------------------------------------------------------------
	-- Initialize parameters
	if not parameters then parameters = {} end
	if type(parameters) ~= "table" then
		relay_type = parameters
		if relay_types[relay_type] then
			parameters = relay_types[relay_type]
		else
			--print("[sys_relay.lua] Unknown relay type: "..parameters)
			parameters = {}
		end
		parameters.relay_type = relay_type
	end
	
	-- Create new table
	local old_param = parameters
	parameters = {} for k,v in pairs(old_param) do parameters[k] = v end
	
	-- Add extra parameters
	if type(extra_parameters) == "table" then
		for k,v in pairs(extra_parameters) do
			parameters[k] = v
		end
	end	
	
	-- Contactors have different failure modes
	parameters.contactor		= parameters.contactor or false
	-- Should the relay be initialized in 'closed' state
	parameters.normally_closed 	= parameters.normally_closed or false
	-- Default power supply for the relay coils
	parameters.power_supply 	= parameters.power_supply or "None"
	-- Power supply to the Open coil
	parameters.power_open 		= parameters.power_open or parameters.power_supply
	-- Power supply to the Close coil
	parameters.power_close 		= parameters.power_close or parameters.power_supply
	-- Time in which relay will close (seconds)
	parameters.close_time 		= parameters.close_time or 0.050
	-- Time in which relay will open (seconds)
	parameters.open_time 		= parameters.open_time or 0.050
	-- Is relay latched (stays in its position even without voltage)
	parameters.latched			= parameters.latched or false
	-- Should relay be spring-returned to initial position
	parameters.returns			= parameters.returns or (not parameters.latched)
	-- Trigger level for the relay
	parameters.trigger_level	= parameters.trigger_level or 0.5
	for k,v in pairs(parameters) do
		self[k] = v
	end



	----------------------------------------------------------------------------
	-- Relay parameters
	FailSim.AddParameter(self,"CloseTime", 		{ value = parameters.close_time, min = 0.010, varies = true })
	FailSim.AddParameter(self,"OpenTime", 		{ value = parameters.open_time, min = 0.010, varies = true })
	-- Did relay short-circuit?
	FailSim.AddParameter(self,"ShortCircuit",	{ value = 0.000, precision = 0.00 })
	-- Was there a spurious trip?
	FailSim.AddParameter(self,"SpuriousTrip",	{ value = 0.000, precision = 0.00 })

	-- Calculate failure parameters
	local MTBF = parameters.MTBF or 1000000 -- cycles, mean time between failures
	local MFR = 1/MTBF   -- cycles^-1, total failure rate
	local openWeight,closeWeight	
	-- FIXME
	openWeight = 0.25
	closeWeight = 0.25
	--[[if self.Contactor then
		openWeight = 0.25
		closeWeight = 0.25
	elseif self.NormallyOpen then
		openWeight = 0.4
		closeWeight = 0.1
	else
		openWeight = 0.1
		closeWeight = 0.4
	end]]--

	-- Add failure points
	FailSim.AddFailurePoint(self,	"CloseTime", "Mechanical problem in relay", 
		{ type = "precision", 	value = 0.5,	mfr = MFR*0.65*openWeight, recurring = true } )
	FailSim.AddFailurePoint(self,	"OpenTime", "Mechanical problem in relay", 
		{ type = "precision", 	value = 0.5,	mfr = MFR*0.65*closeWeight , recurring = true } )
	FailSim.AddFailurePoint(self,	"CloseTime", "Relay stuck closed",
		{ type = "value", 		value = 1e9,	mfr = MFR*0.65*openWeight, dmtbf = 0.2 } )
	FailSim.AddFailurePoint(self,	"OpenTime", "Relay stuck open",
		{ type = "value", 		value = 1e9,	mfr = MFR*0.65*closeWeight , dmtbf = 0.4 } )
	FailSim.AddFailurePoint(self,	"SpuriousTrip", "Spurious trip",
		{ type = "on",							mfr = MFR*0.20, dmtbf = 0.4 } )
	FailSim.AddFailurePoint(self,	"ShortCircuit", "Short-circuit",
		{ type = "on",							mfr = MFR*0.15, dmtbf = 0.2 } )



	----------------------------------------------------------------------------
	-- Initial relay state
	if self.normally_closed then
		self.TargetValue = 1.0
		self.Value = 1.0
	else
		self.TargetValue = 0.0
		self.Value = 0.0
	end
	
	-- Time when relay should change its value
	self.ChangeTime = nil
end

function TRAIN_SYSTEM:Inputs()
	return { "Open","Close","Set","Toggle" }
end

function TRAIN_SYSTEM:Outputs()
	return { "State" }
end

function TRAIN_SYSTEM:TriggerInput(name,value)	
	-- Boolean values accepted
	if type(value) == "boolean" then value = value and 1 or 0 end
	
	-- Open/close coils of the relay
	if (name == "Close") and (value > self.trigger_level) and (self.Value ~= 1.0) then
		if (not self.ChangeTime) and (self.TargetValue ~= 1.0) then
			self.ChangeTime = CurTime() + FailSim.Value(self,"CloseTime")
		end
		self.TargetValue = 1.0
	elseif (name == "Open") and (value > self.trigger_level) and (self.Value ~= 0.0) then
		if (not self.ChangeTime) and (self.TargetValue ~= 0.0) then
			self.ChangeTime = CurTime() + FailSim.Value(self,"OpenTime")
		end
		self.TargetValue = 0.0
	elseif name == "Set" then
		if value > self.trigger_level
		then self:TriggerInput("Close",self.trigger_level+1)
		else self:TriggerInput("Open",self.trigger_level+1)
		end	
	elseif (name == "Toggle") and (value > 0.5) then
		self:TriggerInput("Set",(1.0 - self.Value)*(self.trigger_level+1))
	end
end

function TRAIN_SYSTEM:Think()
	-- Get voltage and target voltage in coils
	local open_voltage, open_target  = 1,0
	local close_voltage,close_target = 1,0
	--[[if self.PowerSupply == "80V" then
		voltage = self.Train.BPSN.Power80V
		target = 55.0
	elseif self.PowerSupply == "AB" then
		voltage = self.Train.Battery.Voltage
		target = 55.0
	elseif self.PowerSupply == "KPP" then -- KVP receives power from KPP
		voltage = self.Train.BPSN.Power80V * self.Train.KPP
		target = 55.0
	elseif self.PowerSupply == "Train Line" then
		voltage = self.Train.Pneumatic.TrainLinePressure
		target = 1.0
	end]]--
	
	-- Check if power dissapears and relay must return to its original state
	if (open_voltage < open_target) or (close_voltage < close_target) then
		if self.returns then 
			self.ChangeTime = nil
			if self.normally_closed 
			then self.Value = 1.0
			else self.Value = 0.0
			end
			self.TargetValue = self.Value
			self:TriggerOutput("State",self.Value)
			return
		end
	end
	
	-- Short-circuited relay
	if FailSim.Value(self,"ShortCircuit") > 0.5 then
		self.Value = 0.0
		self:TriggerOutput("State",self.Value)
		return
	end
	
	-- Spurious trip
	if FailSim.Value(self,"SpuriousTrip") > 0.5 then
		self:TriggerOutput("Toggle",1.0)
		FailSim.ResetParameter(self,"SpuriousTrip",0.0)
		FailSim.Age(self,1)
	end

	-- Switch relay
	if self.ChangeTime and (CurTime() > self.ChangeTime) then		
		self.Value = self.TargetValue
		self:TriggerOutput("State",self.Value)
		self.ChangeTime = nil

		-- Age relay a little
		FailSim.Age(self,1)

		-- Electropneumatic relays make this sound
		if (self.power_supply == "Train line") and (self.Value == 0.0) then
			self.Train:PlayOnce("pneumo_switch",nil,0.6)
		end
	end
end
