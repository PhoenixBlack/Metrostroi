--------------------------------------------------------------------------------
-- Пневматическая система 81-717
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("81_717_Pneumatic")

function TRAIN_SYSTEM:Initialize()
	-- Position of the train drivers valve
	-- 1 Accelerated charge
	-- 2 Normal charge (brake release)
	-- 3 Closed
	-- 4 Service application
	-- 5 Emergency application
	self.DriverValvePosition = 3
	

	-- Pressure in reservoir
	self.ReservoirPressure = 0.0 -- atm
	-- Pressure in trains feed line
	self.TrainLinePressure = 7.0 -- atm
	-- Pressure in trains brake line
	self.BrakeLinePressure = 0.0 -- atm
	-- Pressure in brake cylinder
	self.BrakeCylinderPressure = 0.0 -- atm
	
	


	-- Rate of brake line filling from train line
	--[[self.BrakeLineFillRate			= 0.500 -- atm/sec
	-- Rate of equalizing reservoir filling from train line
	self.ReservoirFillRate			= 1.500 -- atm/sec
	-- Replenish rate for brake line
	self.BrakeLineReplenishRate 	= 0.100 -- atm/sec
	-- Replenish rate for reservoir
	self.ReservoirReplenishRate 	= 1.000 -- atm/sec
	-- Release to atmosphere rate
	self.ReservoirReleaseRate	 	= 1.500 -- atm/sec

	-- Rate of pressure leak from reservoir
	self.ReservoirLeakRate			= 1e-3	-- atm/sec
	-- Rate of pressure leak from brake line
	self.BrakeLineLeakRate			= 1e-4	-- atm/sec
	-- Rate of release to reservoir
	self.BrakeLineReleaseRate	 	= 0.350 -- atm/sec

	-- Emergency release rate
	self.BrakeLineEmergencyRate 	= 0.800 -- atm/sec]]--
	
	
	-- Valve #1
	self.Train:LoadSystem("PneumaticNo1","Relay")
	-- Valve #2
	self.Train:LoadSystem("PneumaticNo2","Relay")
	
	
	-- Isolation valves
	self.Train:LoadSystem("FrontBrakeLineIsolation","Relay","Switch", { normally_closed = true })
	self.Train:LoadSystem("RearBrakeLineIsolation","Relay","Switch", { normally_closed = true })

	-- Brake cylinder atmospheric valve open
	self.BrakeCylinderValve = 0
end

function TRAIN_SYSTEM:Inputs()
	return { "BrakeUp", "BrakeDown", "BrakeSet"}
end

function TRAIN_SYSTEM:Outputs()
	return { "BrakeLinePressure", "BrakeCylinderPressure", "DriverValvePosition", 
			 "ReservoirPressure", "TrainLinePressure" }
end

function TRAIN_SYSTEM:TriggerInput(name,value)
	if name == "BrakeSet" then
		self.DriverValvePosition = math.floor(value)
		if self.DriverValvePosition < 1 then self.DriverValvePosition = 1 end
		if self.DriverValvePosition > 5 then self.DriverValvePosition = 5 end
		
		self.Train:PlayOnce("switch",true)
	elseif (name == "BrakeUp") and (value > 0.5) then
		self:TriggerInput("BrakeSet",self.DriverValvePosition+1)
	elseif (name == "BrakeDown") and (value > 0.5) then
		self:TriggerInput("BrakeSet",self.DriverValvePosition-1)
	end
end




-------------------------------------------------------------------------------
function TRAIN_SYSTEM:GetPressures(Train)
	local frontBrakeOpen = Train.FrontBrakeLineIsolation.Value == 0
	local rearBrakeOpen = Train.RearBrakeLineIsolation.Value == 0
	
	-- If open into atmosphere, relieve pressure
	if frontBrakeOpen and (not Train.FrontTrain) then
		self.BrakeLinePressure = 0
		return
	end
	if rearBrakeOpen and (not Train.RearTrain) then
		self.BrakeLinePressure = 0
		return
	end
	
	-- If other end is closed, this one must be closed too
	if Train.FrontTrain then
		frontBrakeOpen = frontBrakeOpen and (Train.FrontTrain.FrontBrakeLineIsolation.Value == 0)
	end
	if Train.RearTrain then
		rearBrakeOpen = rearBrakeOpen and (Train.RearTrain.FrontBrakeLineIsolation.Value == 0)
	end
	
	-- Equalize pressure
	if Train.FrontTrain and Train.RearTrain and	frontBrakeOpen and rearBrakeOpen then
		self.BrakeLinePressure = 
			(Train.FrontTrain.Pneumatic.BrakeLinePressure +
			 Train.RearTrain.Pneumatic.BrakeLinePressure) / 2
		-- Not realistic to share this, but helps pneumatic system to react faster
		self.ReservoirPressure = 
			(Train.FrontTrain.Pneumatic.ReservoirPressure +
			 Train.RearTrain.Pneumatic.ReservoirPressure) / 2
	elseif Train.FrontTrain and	frontBrakeOpen then
		self.BrakeLinePressure = Train.FrontTrain.Pneumatic.BrakeLinePressure
		self.ReservoirPressure = Train.FrontTrain.Pneumatic.ReservoirPressure
	elseif Train.RearTrain and rearBrakeOpen then
		self.BrakeLinePressure = Train.RearTrain.Pneumatic.BrakeLinePressure
		self.ReservoirPressure = Train.RearTrain.Pneumatic.ReservoirPressure
	end
end

function TRAIN_SYSTEM:SetPressures(Train)
	local frontBrakeOpen = Train.FrontBrakeLineIsolation.Value == 0
	local rearBrakeOpen = Train.RearBrakeLineIsolation.Value == 0
	
	-- If other end is closed, this one must be closed too
	if Train.FrontTrain then 
		if Train.FrontTrain.FrontTrain == Train then -- Nose to nose
			frontBrakeOpen = frontBrakeOpen and (Train.FrontTrain.FrontBrakeLineIsolation.Value == 0)
		else -- Rear to nose
			rearBrakeOpen = rearBrakeOpen and (Train.FrontTrain.FrontBrakeLineIsolation.Value == 0)
		end
	end
	if Train.RearTrain then
		if Train.RearTrain.FrontTrain == Train then -- Back to back
			rearBrakeOpen = rearBrakeOpen and (Train.RearTrain.FrontBrakeLineIsolation.Value == 0)
		else
			frontBrakeOpen = frontBrakeOpen and (Train.RearTrain.FrontBrakeLineIsolation.Value == 0)		
		end
	end

	-- Equalize pressure
	if Train.FrontTrain and Train.RearTrain and frontBrakeOpen and rearBrakeOpen then
		Train.FrontTrain.Pneumatic.BrakeLinePressure = self.BrakeLinePressure
		Train.RearTrain.Pneumatic.BrakeLinePressure = self.BrakeLinePressure
		Train.FrontTrain.Pneumatic.ReservoirPressure = self.ReservoirPressure
		Train.RearTrain.Pneumatic.ReservoirPressure = self.ReservoirPressure
	elseif Train.FrontTrain and frontBrakeOpen then
		Train.FrontTrain.Pneumatic.BrakeLinePressure = self.BrakeLinePressure
		Train.FrontTrain.Pneumatic.ReservoirPressure = self.ReservoirPressure
	elseif Train.RearTrain and rearBrakeOpen then
		Train.RearTrain.Pneumatic.BrakeLinePressure = self.BrakeLinePressure
		Train.RearTrain.Pneumatic.ReservoirPressure = self.ReservoirPressure
	end
end




-------------------------------------------------------------------------------
function TRAIN_SYSTEM:Think(dT)
	local Train = self.Train
	
	-- Apply specific rate to equalize pressure
	local function equalizePressure(pressure,target,rate,fill_rate)
		if fill_rate and (target > self[pressure]) then rate = fill_rate end
		
		-- Calculate derivative
		local dPdT = rate
		if target < self[pressure] then dPdT = -dPdT end
		local dPdTramp = math.min(1.0,math.abs(target - self[pressure])*0.5)
		dPdT = dPdT*dPdTramp

		-- Update pressure
		self[pressure] = self[pressure] + dT * dPdT
		self[pressure] = math.max(0.0,math.min(12.0,self[pressure]))
		self[pressure.."_dPdT"] = (self[pressure.."_dPdT"] or 0) + dPdT
		if self[pressure] == 0.0  then self[pressure.."_dPdT"] = 0 end
		if self[pressure] == 12.0 then self[pressure.."_dPdT"] = 0 end
		return dPdT
	end
	
	-- Get pressures (if isolation valves are open, this connects it to next wagon)
	self:GetPressures(Train)
	
	
	----------------------------------------------------------------------------
	-- Accumulate derivatives
	self.TrainLinePressure_dPdT = 0.0
	self.BrakeLinePressure_dPdT = 0.0
	self.ReservoirPressure_dPdT = 0.0
	self.BrakeCylinderPressure_dPdT = 0.0
	
	-- Reduce pressure for brake line
	self.TrainToBrakeReducedPressure = self.TrainLinePressure * 0.70
	
	-- 1 Fill reservoir from train line, fill brake line from train line
	if self.DriverValvePosition == 1 then
		equalizePressure("BrakeLinePressure", self.TrainLinePressure, 1.00)
		equalizePressure("ReservoirPressure", self.TrainLinePressure, 1.70)
	end
	-- 2 Brake line, reservoir replenished from brake line reductor
	if self.DriverValvePosition == 2 then
		equalizePressure("BrakeLinePressure", self.ReservoirPressure, 1.00)
		equalizePressure("ReservoirPressure", self.BrakeLinePressure, 1.00)
		equalizePressure("ReservoirPressure", self.TrainToBrakeReducedPressure*1.01, 2.00)
	end
	-- 3 Close all valves
	if self.DriverValvePosition == 3 then
		equalizePressure("ReservoirPressure", self.BrakeLinePressure, 0.30)
		equalizePressure("BrakeLinePressure", self.ReservoirPressure, 0.30)
	end
	-- 4 Reservoir open to atmosphere, brake line equalizes with reservoir
	if self.DriverValvePosition == 4 then
		equalizePressure("ReservoirPressure", 0.0,					  0.50)
		equalizePressure("BrakeLinePressure", self.ReservoirPressure, 1.00)
	end
	-- 5 Reservoir and brake line open to atmosphere
	if self.DriverValvePosition == 5 then
		equalizePressure("ReservoirPressure", 0.0, 1.70)
		equalizePressure("BrakeLinePressure", 0.0, 1.00)
	end
	
	
	----------------------------------------------------------------------------
	-- Fill brake cylinders
	local targetPressure = math.max(0,math.min(4.5,
		2*(self.TrainToBrakeReducedPressure - self.BrakeLinePressure)))
	if math.abs(self.BrakeCylinderPressure - targetPressure) > 0.150 then
		self.BrakeCylinderValve = 1
	end
	if math.abs(self.BrakeCylinderPressure - targetPressure) < 0.025 then
		self.BrakeCylinderValve = 0
	end
	if self.BrakeCylinderValve == 1 then
		equalizePressure("BrakeCylinderPressure", targetPressure, 1.00, 1.50) --0.75, 1.25)
	end
	
	-- Valve #1
	if self.Train.PneumaticNo1.Value == 1.0 then
		equalizePressure("BrakeCylinderPressure", self.TrainLinePressure * 0.30, 1.00, 1.50)
		--equalizePressure("BrakeLinePressure", self.TrainToBrakeReducedPressure * 0.70, 0.50)
	end
	-- Valve #2
	if self.Train.PneumaticNo2.Value == 1.0 then
		equalizePressure("BrakeCylinderPressure", self.TrainLinePressure * 0.45, 1.00, 1.50)
	end
	

	-- Apply brakes
	self.PneumaticBrakeForce = 100000.0
	self.Train.FrontBogey.PneumaticBrakeForce = self.PneumaticBrakeForce 
	self.Train.FrontBogey.BrakeCylinderPressure = self.BrakeCylinderPressure
	self.Train.FrontBogey.BrakeCylinderPressure_dPdT = -self.BrakeCylinderPressure_dPdT ---self.BrakeCylinderPressure_dPdT
	self.Train.RearBogey.PneumaticBrakeForce = self.PneumaticBrakeForce
	self.Train.RearBogey.BrakeCylinderPressure = self.BrakeCylinderPressure
	self.Train.RearBogey.BrakeCylinderPressure_dPdT = -self.BrakeCylinderPressure_dPdT ---self.BrakeCylinderPressure_dPdT
	
	-- Output
	self:TriggerOutput("DriverValvePosition", 		self.DriverValvePosition)
	self:TriggerOutput("BrakeLinePressure", 		self.BrakeLinePressure)
	self:TriggerOutput("BrakeCylinderPressure",  	self.BrakeCylinderPressure)
	self:TriggerOutput("ReservoirPressure", 		self.ReservoirPressure)
	self:TriggerOutput("TrainLinePressure",			self.TrainLinePressure)
	
	-- Set pressures (if isolation valves are open, propagate pressure to next wagon)
	self:SetPressures(Train)
	
	-- FIXME
	Train:SetNWBool("FI",Train.FrontBrakeLineIsolation.Value ~= 0)
	Train:SetNWBool("RI",Train.RearBrakeLineIsolation.Value ~= 0)
end
