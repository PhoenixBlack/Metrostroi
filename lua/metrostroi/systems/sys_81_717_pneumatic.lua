--------------------------------------------------------------------------------
-- Пневматическая система 81-717
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("81_717_Pneumatic")
TRAIN_SYSTEM.DontAccelerateSimulation = true

function TRAIN_SYSTEM:Initialize()
	self.ValveType = 1
	
	-- Position of the train drivers valve 
	--  Type 1 (334)
	-- 1 Accelerated charge
	-- 2 Normal charge (brake release)
	-- 3 Closed
	-- 4 Service application
	-- 5 Emergency application
	--
	-- Type 2 (013)
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
	
	self.PlayOpen = 1e9
	self.PlayClosed = 1e9
end

function TRAIN_SYSTEM:Inputs()
	return { "BrakeUp", "BrakeDown", "BrakeSet", "ValveType" }
end

function TRAIN_SYSTEM:Outputs()
	return { "BrakeLinePressure", "BrakeCylinderPressure", "DriverValvePosition", 
			 "ReservoirPressure", "TrainLinePressure", "DoorLinePressure" }
end

function TRAIN_SYSTEM:TriggerInput(name,value)
	if name == "BrakeSet" then
		self.DriverValvePosition = math.floor(value)
		if self.ValveType == 1 then
			if self.DriverValvePosition < 1 then self.DriverValvePosition = 1 end
			if self.DriverValvePosition > 5 then self.DriverValvePosition = 5 end
		else
			if self.DriverValvePosition < 1 then self.DriverValvePosition = 1 end
			if self.DriverValvePosition > 7 then self.DriverValvePosition = 7 end
		end
		
		self.Train:PlayOnce("switch",true)
	elseif (name == "BrakeUp") and (value > 0.5) then
		self:TriggerInput("BrakeSet",self.DriverValvePosition+1)
	elseif (name == "BrakeDown") and (value > 0.5) then
		self:TriggerInput("BrakeSet",self.DriverValvePosition-1)
	elseif name == "ValveType" then
		self.ValveType = math.floor(value)
	end
end




-------------------------------------------------------------------------------
function TRAIN_SYSTEM:UpdatePressures(Train,dT)
	local frontBrakeOpen = Train.FrontBrakeLineIsolation.Value == 0
	local rearBrakeOpen = Train.RearBrakeLineIsolation.Value == 0

	-- Check if both valve on this train and connected train are open
	if Train.FrontTrain then
		Train.FrontTrain.FrontBrakeLineIsolation = Train.FrontTrain.FrontBrakeLineIsolation or
			{ Value = 1 }
		Train.FrontTrain.RearBrakeLineIsolation = Train.FrontTrain.RearBrakeLineIsolation or
			{ Value = 1 }
		if Train.FrontTrain.FrontTrain == Train then -- Nose to nose
			frontBrakeOpen = frontBrakeOpen and (Train.FrontTrain.FrontBrakeLineIsolation.Value == 0)
		else -- Rear to nose
			rearBrakeOpen = rearBrakeOpen and (Train.FrontTrain.RearBrakeLineIsolation.Value == 0)
		end
	end
	if Train.RearTrain then
		Train.RearTrain.FrontBrakeLineIsolation = Train.RearTrain.FrontBrakeLineIsolation or
			{ Value = 1 }
		Train.RearTrain.RearBrakeLineIsolation = Train.RearTrain.RearBrakeLineIsolation or
			{ Value = 1 }
		if Train.RearTrain.FrontTrain == Train then -- Back to back
			rearBrakeOpen = rearBrakeOpen and (Train.RearTrain.FrontBrakeLineIsolation.Value == 0)
		else -- Back to nose
			frontBrakeOpen = frontBrakeOpen and (Train.RearTrain.RearBrakeLineIsolation.Value == 0)
		end
	end
	
	-- Calculate derivatives
	local function equalizePressure(pressure,train,valve_status,rate)
		if not valve_status then return end
		local other
		if train then other = train.Pneumatic end
		
		-- Get second pressure
		local P2 = 0
		if other then P2 = other[pressure] end
		
		-- Calculate rate
		local dPdT = rate * (P2 - self[pressure])
		-- Calculate delta
		local dP = dPdT*dT
		
		-- Equalized pressure
		local P0 = (P2 + self[pressure]) / 2
		
		-- Update pressures
		if dP > 0 then
			self[pressure] = math.min(P0,self[pressure] + dP)
			if other then
				other[pressure] = math.max(P0,other[pressure] - dP)
			end
		else
			self[pressure] = math.max(P0,self[pressure] + dP)
			if other then
				other[pressure] = math.min(P0,other[pressure] - dP)
			end
		end
	end
	
	-- Equalize pressure
	equalizePressure("BrakeLinePressure",Train.FrontTrain,frontBrakeOpen,200.0)
	equalizePressure("BrakeLinePressure",Train.RearTrain,rearBrakeOpen,200.0)
	equalizePressure("TrainLinePressure",Train.FrontTrain,frontBrakeOpen,200.0)
	equalizePressure("TrainLinePressure",Train.RearTrain,rearBrakeOpen,200.0)
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
	
	local trainLineConsumption_dPdT = 0.0
	if self.ValveType == 1 then
		-- 334: 1 Fill reservoir from train line, fill brake line from train line
		if (self.DriverValvePosition == 1) and (Train.DriverValveDisconnect.Value == 1.0) then
			equalizePressure("ReservoirPressure", self.TrainLinePressure, 1.50)
			
			self.BrakeLinePressure = self.ReservoirPressure
			self.BrakeLinePressure_dPdT = self.ReservoirPressure_dPdT
			trainLineConsumption_dPdT = trainLineConsumption_dPdT + math.max(0,self.BrakeLinePressure_dPdT)
		end
		
		-- 334: 2 Brake line, reservoir replenished from brake line reductor
		if (self.DriverValvePosition == 2) and (Train.DriverValveDisconnect.Value == 1.0) then
			equalizePressure("ReservoirPressure", self.TrainToBrakeReducedPressure*1.05, 1.30)

			self.BrakeLinePressure = self.ReservoirPressure
			self.BrakeLinePressure_dPdT = self.ReservoirPressure_dPdT
			trainLineConsumption_dPdT = trainLineConsumption_dPdT + math.max(0,self.BrakeLinePressure_dPdT)
		end
		
		-- 334: 3 Close all valves
		if (self.DriverValvePosition == 3) and (Train.DriverValveDisconnect.Value == 1.0) then
			equalizePressure("ReservoirPressure", self.BrakeLinePressure, 3.00)
			equalizePressure("BrakeLinePressure", self.ReservoirPressure, 3.00)
		end
		
		-- 334: 4 Reservoir open to atmosphere, brake line equalizes with reservoir
		if (self.DriverValvePosition == 4) and (Train.DriverValveDisconnect.Value == 1.0) then
			equalizePressure("ReservoirPressure", 0.0,0.55)--0.35)
			self.BrakeLinePressure = self.ReservoirPressure
			self.BrakeLinePressure_dPdT = self.ReservoirPressure_dPdT
		end
		
		-- 334: 5 Reservoir and brake line open to atmosphere
		if (self.DriverValvePosition == 5) and (Train.DriverValveDisconnect.Value == 1.0) then
			equalizePressure("ReservoirPressure", 0.0, 1.70)
			self.BrakeLinePressure = self.ReservoirPressure
			self.BrakeLinePressure_dPdT = self.ReservoirPressure_dPdT
		end
	else
		-- 013: 1 Overcharge
		if (self.DriverValvePosition == 1) and (Train.DriverValveDisconnect.Value == 1.0) then
			equalizePressure("BrakeLinePressure", self.TrainLinePressure, 1.20)
			trainLineConsumption_dPdT = trainLineConsumption_dPdT + math.max(0,self.BrakeLinePressure_dPdT)
		end
		
		-- 013: 2 Normal pressure
		if (self.DriverValvePosition == 2) and (Train.DriverValveDisconnect.Value == 1.0) then
			equalizePressure("BrakeLinePressure", self.TrainToBrakeReducedPressure*1.05, 1.20)
			trainLineConsumption_dPdT = trainLineConsumption_dPdT + math.max(0,self.BrakeLinePressure_dPdT)
		end
		
		-- 013: 3 4.3 Atm
		if (self.DriverValvePosition == 3) and (Train.DriverValveDisconnect.Value == 1.0) then
			equalizePressure("BrakeLinePressure", self.TrainToBrakeReducedPressure*0.86, 3.50)
			trainLineConsumption_dPdT = trainLineConsumption_dPdT + math.max(0,self.BrakeLinePressure_dPdT)
		end
		
		-- 013: 4 4.0 Atm
		if (self.DriverValvePosition == 4) and (Train.DriverValveDisconnect.Value == 1.0) then
			equalizePressure("BrakeLinePressure", self.TrainToBrakeReducedPressure*0.80, 3.50)
			trainLineConsumption_dPdT = trainLineConsumption_dPdT + math.max(0,self.BrakeLinePressure_dPdT)
		end
		
		-- 013: 5 3.7 Atm
		if (self.DriverValvePosition == 5) and (Train.DriverValveDisconnect.Value == 1.0) then
			equalizePressure("BrakeLinePressure", self.TrainToBrakeReducedPressure*0.74, 3.50)
			trainLineConsumption_dPdT = trainLineConsumption_dPdT + math.max(0,self.BrakeLinePressure_dPdT)
		end
		
		-- 013: 6 3.0 Atm
		if (self.DriverValvePosition == 6) and (Train.DriverValveDisconnect.Value == 1.0) then
			equalizePressure("BrakeLinePressure", self.TrainToBrakeReducedPressure*0.60, 3.50)
			trainLineConsumption_dPdT = trainLineConsumption_dPdT + math.max(0,self.BrakeLinePressure_dPdT)
		end
		
		-- 013: 7 0.0 Atm
		if (self.DriverValvePosition == 7) and (Train.DriverValveDisconnect.Value == 1.0) then
			equalizePressure("BrakeLinePressure", 0.0, 3.50)
			trainLineConsumption_dPdT = trainLineConsumption_dPdT + math.max(0,self.BrakeLinePressure_dPdT)
		end
	end
	
	
	----------------------------------------------------------------------------
	-- Fill brake cylinders
	--local targetPressure = math.max(0,math.min(5.2,
	--	1.5*(math.min(5.1,self.TrainToBrakeReducedPressure) - self.BrakeLinePressure)))
	local targetPressure = math.max(0,math.min(5.2,
		2.0*(self.TrainToBrakeReducedPressure - self.BrakeLinePressure)))

	if math.abs(self.BrakeCylinderPressure - targetPressure) > 0.150 then
		self.BrakeCylinderValve = 1
	end
	if math.abs(self.BrakeCylinderPressure - targetPressure) < 0.025 then
		self.BrakeCylinderValve = 0
	end
	if self.BrakeCylinderValve == 1 then
		equalizePressure("BrakeCylinderPressure", targetPressure, 2.00, 3.50) --0.75, 1.25)
	end
	
	-- Valve #1
	self.BrakeCylinderRegulationError = self.BrakeCylinderRegulationError or (math.random()*0.10 - 0.05)
	local error = self.BrakeCylinderRegulationError
	local pneumaticValveConsumption_dPdT = 0
	if (self.Train.PneumaticNo1.Value == 1.0) and (self.Train.PneumaticNo2.Value == 0.0) then
		equalizePressure("BrakeCylinderPressure", self.TrainLinePressure * 0.26 + error, 1.00, 5.50)
		pneumaticValveConsumption_dPdT = pneumaticValveConsumption_dPdT + self.BrakeCylinderPressure_dPdT
	end
	-- Valve #2
	if self.Train.PneumaticNo2.Value == 1.0 then
		equalizePressure("BrakeCylinderPressure", self.TrainLinePressure * 0.39 + error, 1.00, 5.50)
		pneumaticValveConsumption_dPdT = pneumaticValveConsumption_dPdT + self.BrakeCylinderPressure_dPdT
	end
	trainLineConsumption_dPdT = trainLineConsumption_dPdT + math.max(0,pneumaticValveConsumption_dPdT)

	
	-- Simulate cross-feed between different wagons
	self:UpdatePressures(Train,dT)
	
	
	----------------------------------------------------------------------------
	-- Simulate compressor operation and train line depletion
	self.Compressor = Train.KK.Value
	self.TrainLinePressure = self.TrainLinePressure - 0.190*trainLineConsumption_dPdT*dT
	if self.Compressor == 1 then equalizePressure("TrainLinePressure", 10.0, 0.05) end
	
	----------------------------------------------------------------------------
	-- Pressure triggered relays
	Train.AVT:TriggerInput("Open", self.BrakeCylinderPressure > 2.0) -- 1.8 - 2.0
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
				self.PlayOpen = CurTime()
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
				self.PlayOpen = CurTime()
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
				self.PlayClose = CurTime()
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
		
	-- Play sounds
	local play_open 		= (CurTime() - (self.PlayOpen or 1e9)) > 0.3
	local play_close 		= (CurTime() - (self.PlayClose or 1e9)) > 0.3
	local play_open_early 	= (CurTime() - (self.PlayOpen or 1e9)) > 0.0
	local play_close_early 	= (CurTime() - (self.PlayClose or 1e9)) > 0.0
	if play_open_early and play_close_early then
		Train:PlayOnce("door_fail1")
		Train:PlayOnce("switch3")
		self.PlayOpen = 1e9
		self.PlayClose = 1e9
		play_open = false
		play_close = false
		self.TrainLinePressure = self.TrainLinePressure - 0.01
	end
 	if play_open then
		self.PlayOpen = 1e9
		Train:PlayOnce("door_open1")
		Train:PlayOnce("switch3")
		self.TrainLinePressure = self.TrainLinePressure - 0.04
	end
	if play_close then
		self.PlayClose = 1e9
		Train:PlayOnce("door_close1")
		self.TrainLinePressure = self.TrainLinePressure - 0.04
	end

	----------------------------------------------------------------------------	
	-- FIXME
	Train:SetNWBool("FI",Train.FrontBrakeLineIsolation.Value ~= 0)
	Train:SetNWBool("RI",Train.RearBrakeLineIsolation.Value ~= 0)
end
