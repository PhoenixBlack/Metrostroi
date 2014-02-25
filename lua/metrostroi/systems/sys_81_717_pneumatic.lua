--------------------------------------------------------------------------------
-- Пневматическая система 81-717
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("81_717_Pneumatic")
TRAIN_SYSTEM.DontAccelerateSimulation = true

function TRAIN_SYSTEM:Initialize()
	-- Position of the train drivers valve
	-- 1 Accelerated charge
	-- 2 Normal charge (brake release)
	-- 3 Closed
	-- 4 Service application
	-- 5 Emergency application
	self.DriverValvePosition = 2
	

	-- Pressure in reservoir
	self.ReservoirPressure = 0.0 -- atm
	-- Pressure in trains feed line
	self.TrainLinePressure = 7.0 -- atm
	-- Pressure in trains brake line
	self.BrakeLinePressure = 0.0 -- atm
	-- Pressure in brake cylinder
	self.BrakeCylinderPressure = 0.0 -- atm
	-- Pressure in the door line
	self.DoorLinePressure = 0.0 -- atm


	-- Valve #1
	self.Train:LoadSystem("PneumaticNo1","Relay")
	-- Valve #2
	self.Train:LoadSystem("PneumaticNo2","Relay")
	-- Автоматический выключатель торможения (АВТ)
	self.Train:LoadSystem("AVT","Relay","AVT-325")
	-- Регулятор давления (АК)
	self.Train:LoadSystem("AK","Relay","AK-11B")	
	-- Автоматический выключатель управления (АВУ)
	self.Train:LoadSystem("AVU","Relay","AVU-045")
	-- Блокировка тормозов
	self.Train:LoadSystem("BPT","Relay","")
	-- Блокировка дверей
	self.Train:LoadSystem("BD","Relay","")
	-- Вентили дверного воздухораспределителя (ВДОЛ, ВДОП, ВДЗ)
	self.Train:LoadSystem("VDOL","Relay","")
	self.Train:LoadSystem("VDOP","Relay","")
	self.Train:LoadSystem("VDZ","Relay","")
	
	
	-- Разобщение клапана машиниста
	self.Train:LoadSystem("DriverValveDisconnect","Relay","Switch")
	-- Isolation valves
	self.Train:LoadSystem("FrontBrakeLineIsolation","Relay","Switch", { normally_closed = true })
	self.Train:LoadSystem("RearBrakeLineIsolation","Relay","Switch", { normally_closed = true })
	--self.Train:LoadSystem("FrontTrainLineIsolation","Relay","Switch", { normally_closed = true })
	--self.Train:LoadSystem("RearTrainLineIsolation","Relay","Switch", { normally_closed = true })

	-- Brake cylinder atmospheric valve open
	self.BrakeCylinderValve = 0
	
	-- Compressor simulation
	self.Compressor = 0 --Simulate overheat with TRK FIXME
	
	-- Doors state
	--[[self.Train:LoadSystem("LeftDoor1","Relay",{ open_time = 0.5, close_time = 0.5 })
	self.Train:LoadSystem("LeftDoor2","Relay",{ open_time = 0.5, close_time = 0.5 })
	self.Train:LoadSystem("LeftDoor3","Relay",{ open_time = 0.5, close_time = 0.5 })
	self.Train:LoadSystem("LeftDoor4","Relay",{ open_time = 0.5, close_time = 0.5 })
	self.Train:LoadSystem("RightDoor1","Relay",{ open_time = 0.5, close_time = 0.5 })
	self.Train:LoadSystem("RightDoor2","Relay",{ open_time = 0.5, close_time = 0.5 })
	self.Train:LoadSystem("RightDoor3","Relay",{ open_time = 0.5, close_time = 0.5 })
	self.Train:LoadSystem("RightDoor4","Relay",{ open_time = 0.5, close_time = 0.5 })]]--
	self.LeftDoorState = { 0,0,0,0 }
	self.RightDoorState = { 0,0,0,0 }
end

function TRAIN_SYSTEM:Inputs()
	return { "BrakeUp", "BrakeDown", "BrakeSet"}
end

function TRAIN_SYSTEM:Outputs()
	return { "BrakeLinePressure", "BrakeCylinderPressure", "DriverValvePosition", 
			 "ReservoirPressure", "TrainLinePressure", "DoorLinePressure" }
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
		self.TrainLinePressure = 0
		return
	end
	if rearBrakeOpen and (not Train.RearTrain) then
		self.BrakeLinePressure = 0
		self.TrainLinePressure = 0
		return
	end

	-- If other end is closed, this one must be closed too
	if Train.FrontTrain then 
		if Train.FrontTrain.FrontTrain == Train then -- Nose to nose
			frontBrakeOpen = frontBrakeOpen and (Train.FrontTrain.FrontBrakeLineIsolation.Value == 0)
		else -- Rear to nose
			rearBrakeOpen = rearBrakeOpen and (Train.FrontTrain.RearBrakeLineIsolation.Value == 0)
		end
	end
	if Train.RearTrain then
		if Train.RearTrain.FrontTrain == Train then -- Back to back
			rearBrakeOpen = rearBrakeOpen and (Train.RearTrain.FrontBrakeLineIsolation.Value == 0)
		else
			frontBrakeOpen = frontBrakeOpen and (Train.RearTrain.RearBrakeLineIsolation.Value == 0)
		end
	end
	
	-- Pressure in this wagon = pressure in this wagon with leaks from other wagons
	local t1 = 0.50
	local t2 = 0.10
	if Train.FrontTrain and Train.RearTrain and	frontBrakeOpen and rearBrakeOpen then
		self.TrainLinePressure = 
			(Train.FrontTrain.Pneumatic.TrainLinePressure +
			 Train.RearTrain.Pneumatic.TrainLinePressure) / 2
			 
		self.BrakeLinePressure = 
			self.BrakeLinePressure*t2 + 
			(1-t2)*0.5*Train.FrontTrain.Pneumatic.BrakeLinePressure +
			(1-t2)*0.5*Train.RearTrain.Pneumatic.BrakeLinePressure
			 
		-- Not realistic to share this, but helps pneumatic system to react faster
		self.ReservoirPressure = 
			self.ReservoirPressure*t2 + 
			(1-t2)*0.5*Train.FrontTrain.Pneumatic.ReservoirPressure +
			(1-t2)*0.5*Train.RearTrain.Pneumatic.ReservoirPressure
	elseif Train.FrontTrain and	frontBrakeOpen then
		self.TrainLinePressure = Train.FrontTrain.Pneumatic.TrainLinePressure
		self.BrakeLinePressure =
			self.BrakeLinePressure*(1-t1) + (t1)*Train.FrontTrain.Pneumatic.BrakeLinePressure
		self.ReservoirPressure =
			self.ReservoirPressure*(1-t1) + (t1)*Train.FrontTrain.Pneumatic.ReservoirPressure
	elseif Train.RearTrain and rearBrakeOpen then
		self.TrainLinePressure = Train.RearTrain.Pneumatic.TrainLinePressure
		self.BrakeLinePressure =
			self.BrakeLinePressure*(1-t1) + (t1)*Train.RearTrain.Pneumatic.BrakeLinePressure
		self.ReservoirPressure =
			self.ReservoirPressure*(1-t1) + (t1)*Train.RearTrain.Pneumatic.ReservoirPressure
	end
	--print(self,"AFTER",self.BrakeLinePressure)
end

function TRAIN_SYSTEM:SetPressures(Train)
	--[[local frontBrakeOpen = Train.FrontBrakeLineIsolation.Value == 0
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
	end]]--

	-- Equalize pressure
	--[[if Train.FrontTrain and Train.RearTrain and frontBrakeOpen and rearBrakeOpen then
		Train.FrontTrain.Pneumatic.TrainLinePressure = self.TrainLinePressure
		Train.RearTrain.Pneumatic.TrainLinePressure = self.TrainLinePressure
		
		Train.FrontTrain.Pneumatic.BrakeLinePressure = self.BrakeLinePressure		
		Train.RearTrain.Pneumatic.BrakeLinePressure = self.BrakeLinePressure
		Train.FrontTrain.Pneumatic.ReservoirPressure = self.ReservoirPressure
		Train.RearTrain.Pneumatic.ReservoirPressure = self.ReservoirPressure
	elseif Train.FrontTrain and frontBrakeOpen then
		Train.FrontTrain.Pneumatic.TrainLinePressure = self.TrainLinePressure
		
		Train.FrontTrain.Pneumatic.BrakeLinePressure = self.BrakeLinePressure
		Train.FrontTrain.Pneumatic.ReservoirPressure = self.ReservoirPressure
	elseif Train.RearTrain and rearBrakeOpen then
		Train.RearTrain.Pneumatic.TrainLinePressure = self.TrainLinePressure
		
		Train.RearTrain.Pneumatic.BrakeLinePressure = self.BrakeLinePressure
		Train.RearTrain.Pneumatic.ReservoirPressure = self.ReservoirPressure
	end]]--
end




-------------------------------------------------------------------------------
function TRAIN_SYSTEM:Think(dT)
	local Train = self.Train
	
	-- Apply specific rate to equalize pressure
	local function equalizePressure(pressure,target,rate,fill_rate,no_limit)
		if fill_rate and (target > self[pressure]) then rate = fill_rate end
		
		-- Calculate derivative
		local dPdT = rate
		if target < self[pressure] then dPdT = -dPdT end
		local dPdTramp = math.min(1.0,math.abs(target - self[pressure])*0.5)
		dPdT = dPdT*dPdTramp

		-- Update pressure
		self[pressure] = self[pressure] + dT * dPdT
		self[pressure] = math.max(0.0,math.min(16.0,self[pressure]))
		self[pressure.."_dPdT"] = (self[pressure.."_dPdT"] or 0) + dPdT
		if no_limit ~= true then
			if self[pressure] == 0.0  then self[pressure.."_dPdT"] = 0 end
			if self[pressure] == 16.0 then self[pressure.."_dPdT"] = 0 end
		end
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
	self.TrainToBrakeReducedPressure = self.TrainLinePressure * 0.725
	-- Feed pressure to door line
	self.DoorLinePressure = self.TrainToBrakeReducedPressure * 0.90
	
	-- 1 Fill reservoir from train line, fill brake line from train line
	local trainLineConsumption_dPdT = 0.0
	if (self.DriverValvePosition == 1) and (Train.DriverValveDisconnect.Value == 1.0) then
		equalizePressure("BrakeLinePressure", self.TrainLinePressure, 1.00)
		equalizePressure("ReservoirPressure", self.TrainLinePressure, 1.70)
		trainLineConsumption_dPdT = trainLineConsumption_dPdT + math.max(0,self.BrakeLinePressure_dPdT)
	end
	-- 2 Brake line, reservoir replenished from brake line reductor
	if (self.DriverValvePosition == 2) and (Train.DriverValveDisconnect.Value == 1.0) then
		equalizePressure("BrakeLinePressure", self.ReservoirPressure, 1.40)
		equalizePressure("ReservoirPressure", self.BrakeLinePressure, 1.40)
		equalizePressure("ReservoirPressure", self.TrainToBrakeReducedPressure*1.01, 2.00)
		trainLineConsumption_dPdT = trainLineConsumption_dPdT + math.max(0,self.BrakeLinePressure_dPdT)
	end
	-- 3 Close all valves
	if (self.DriverValvePosition == 3) or (Train.DriverValveDisconnect.Value == 0.0) then
		equalizePressure("ReservoirPressure", self.BrakeLinePressure, 0.90)
		equalizePressure("BrakeLinePressure", self.ReservoirPressure, 0.90)
	end
	-- 4 Reservoir open to atmosphere, brake line equalizes with reservoir
	if (self.DriverValvePosition == 4) and (Train.DriverValveDisconnect.Value == 1.0) then
		equalizePressure("ReservoirPressure", 0.0,0.60)
		equalizePressure("BrakeLinePressure", self.ReservoirPressure, 1.50)
	end
	-- 5 Reservoir and brake line open to atmosphere
	if (self.DriverValvePosition == 5) and (Train.DriverValveDisconnect.Value == 1.0) then
		equalizePressure("ReservoirPressure", 0.0, 1.70)
		equalizePressure("BrakeLinePressure", 0.0, 1.00)
	end
	
	
	----------------------------------------------------------------------------
	-- Fill brake cylinders
	local targetPressure = math.max(0,math.min(5.2,
		2*(self.TrainToBrakeReducedPressure - self.BrakeLinePressure)))
	if math.abs(self.BrakeCylinderPressure - targetPressure) > 0.150 then
		self.BrakeCylinderValve = 1
	end
	if math.abs(self.BrakeCylinderPressure - targetPressure) < 0.025 then
		self.BrakeCylinderValve = 0
	end
	if self.BrakeCylinderValve == 1 then
		equalizePressure("BrakeCylinderPressure", targetPressure, 2.00, 2.50) --0.75, 1.25)
	end
	
	-- Valve #1
	if self.Train.PneumaticNo1.Value == 1.0 then
		equalizePressure("BrakeCylinderPressure", self.TrainLinePressure * 0.30, 1.00, 1.50)
		--equalizePressure("BrakeLinePressure", self.TrainToBrakeReducedPressure * 0.70, 0.50)
		trainLineConsumption_dPdT = trainLineConsumption_dPdT + math.max(0,self.BrakeCylinderPressure_dPdT)
	end
	-- Valve #2
	if self.Train.PneumaticNo2.Value == 1.0 then
		equalizePressure("BrakeCylinderPressure", self.TrainLinePressure * 0.45, 1.00, 1.50)
		trainLineConsumption_dPdT = trainLineConsumption_dPdT + math.max(0,self.BrakeCylinderPressure_dPdT)
	end
	
	
	----------------------------------------------------------------------------
	-- Simulate compressor operation and train line depletion
	self.Compressor = Train.KK.Value
	self.TrainLinePressure = self.TrainLinePressure - 0.05*trainLineConsumption_dPdT*dT
	if self.Compressor == 1 then equalizePressure("TrainLinePressure", 10.0, 0.05) end
	
	----------------------------------------------------------------------------
	-- Pressure triggered relays
	Train.AVT:TriggerInput("Open", self.BrakeCylinderPressure > 1.8) -- 1.8 - 2.0
	Train.AVT:TriggerInput("Close",self.BrakeCylinderPressure < 1.2) -- 0.9 - 1.5
	Train.AK:TriggerInput( "Open", self.TrainLinePressure > 8.2)
	Train.AK:TriggerInput( "Close",self.TrainLinePressure < 6.3)
	Train.AVU:TriggerInput("Open", self.BrakeLinePressure < 2.7) -- 2.7 - 2.9
	Train.AVU:TriggerInput("Close",self.BrakeLinePressure > 3.5) -- 3.5 - 3.7
	Train.BPT:TriggerInput("Set",  self.BrakeCylinderPressure > 0.4)
	
	----------------------------------------------------------------------------
	-- Simulate doors opening, closing
	if self.DoorLinePressure > 3.5 then
		if (Train.VDOL.Value == 1.0) and (Train.VDOP.Value == 0.0) then
			if (self.LeftDoorState[1] == 0) or
			   (self.LeftDoorState[2] == 0) or
			   (self.LeftDoorState[3] == 0) or
			   (self.LeftDoorState[4] == 0) then
				Train:PlayOnce("door_open1")
			end
			   
			self.LeftDoorState[1] = 1
			self.LeftDoorState[2] = 1
			self.LeftDoorState[3] = 1
			self.LeftDoorState[4] = 1
		end
		if (Train.VDOL.Value == 0.0) and (Train.VDOP.Value == 1.0) then
			if (self.RightDoorState[1] == 0) or
			   (self.RightDoorState[2] == 0) or
			   (self.RightDoorState[3] == 0) or
			   (self.RightDoorState[4] == 0) then
				Train:PlayOnce("door_open1")
			end

			self.RightDoorState[1] = 1
			self.RightDoorState[2] = 1
			self.RightDoorState[3] = 1
			self.RightDoorState[4] = 1
		end
		if (Train.VDZ.Value == 1.0) or
		   ((Train.VDOL.Value == 1.0) and (Train.VDOP.Value == 1.0)) then
			if (self.LeftDoorState[1] == 1) or
			   (self.LeftDoorState[2] == 1) or
			   (self.LeftDoorState[3] == 1) or
			   (self.LeftDoorState[4] == 1) or
			   (self.RightDoorState[1] == 1) or
			   (self.RightDoorState[2] == 1) or
			   (self.RightDoorState[3] == 1) or
			   (self.RightDoorState[4] == 1) then
				Train:PlayOnce("door_close1")
			end
			
			self.LeftDoorState[1] = 0
			self.LeftDoorState[2] = 0
			self.LeftDoorState[3] = 0
			self.LeftDoorState[4] = 0
			
			self.RightDoorState[1] = 0
			self.RightDoorState[2] = 0
			self.RightDoorState[3] = 0
			self.RightDoorState[4] = 0
		end
	end
	Train.BD:TriggerInput("Set",
		(self.LeftDoorState[1] == 0) and
		(self.LeftDoorState[2] == 0) and
		(self.LeftDoorState[3] == 0) and
		(self.LeftDoorState[4] == 0) and
		(self.RightDoorState[1] == 0) and
		(self.RightDoorState[2] == 0) and
		(self.RightDoorState[3] == 0) and
		(self.RightDoorState[4] == 0))

	----------------------------------------------------------------------------
	-- Set pressures (if isolation valves are open, propagate pressure to next wagon)
	self:SetPressures(Train)
	
	-- FIXME
	Train:SetNWBool("FI",Train.FrontBrakeLineIsolation.Value ~= 0)
	Train:SetNWBool("RI",Train.RearBrakeLineIsolation.Value ~= 0)

end
