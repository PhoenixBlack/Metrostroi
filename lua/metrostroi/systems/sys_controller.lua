--------------------------------------------------------------------------------
-- Default contrller
--------------------------------------------------------------------------------

Metrostroi.DefineSystem("Motor")

function TRAIN_SYSTEM:Initialize()
	self.Reverser = 0
	self.Position = 0
	self.RheostatContactors = 32
end

function TRAIN_SYSTEM:WireInputs()
	return { "SetController", "ControllerUp", "ControllerDown",
			 "SetReverser" }
end

function TRAIN_SYSTEM:WireOutputs()
	return { "Controller", "Reverser", "Speed" }
end

function TRAIN_SYSTEM:TriggerInput(name,value)
	if name == "SetController" then
		self.Position = math.floor(value)
	elseif name == "SetReverser" then
		self.Reverser = math.floor(value)
	elseif (name == "ControllerUp") and (value > 0.5) then
		if self.Train.MotorSettings[self.Position+1] then
			self.Position = self.Position + 1
		end		
	elseif (name == "ControllerDown") and (value > 0.5) then
		if self.Train.MotorSettings[self.Position-1] then
			self.Position = self.Position - 1
		end
	end
end

function TRAIN_SYSTEM:Think()
	if not self.Train.FrontBogey then return end
	if not self.Train.RearBogey then return end
	if not self.Train.FrontBogey:IsValid() then return end
	if not self.Train.RearBogey:IsValid() then return end
	
	-- Bogeys
	local front = self.Train.FrontBogey
	local rear  = self.Train.RearBogey
	local speed = (front.Speed + rear.Speed) / 2
	
	-- Simulate controller
	local motorSetting = 0.0
	if (self.Reverser ~= 0) and self.Train.MotorSettings[self.Position] then
		local limitSpeed = self.Train.MotorSettings[self.Position][2]
		local enginePower = self.Train.MotorSettings[self.Position][1]    
		
		if enginePower > 0.0 then
			local velocityRamp = 1.0 - math.max(0.0,math.min(1,(speed-(limitSpeed-15))/10))
			motorSetting = enginePower * velocityRamp
		elseif enginePower < 0.0 then
			local velocityRamp = math.min(1.0,speed/limitSpeed)
			motorSetting = enginePower * velocityRamp
		end
	end
	
	-- Finite number positions available
	motorSetting = math.floor(motorSetting * self.RheostatContactors + 0.5) / self.RheostatContactors
	
	-- Apply controller
	if self.Reverser == 1 
	then front.Reversed = false
	else front.Reversed = true
	end
	front.MotorForce = self.Train.MotorForce
	front.MotorPower = motorSetting
	
	rear.Reversed = not front.Reversed
	rear.MotorForce = self.Train.MotorForce
	rear.MotorPower = motorSetting
	
	-- Write outputs
	self.Train:TriggerOutput("Controller",self.Position)
	self.Train:TriggerOutput("Reverser",self.Reverser)
	self.Train:TriggerOutput("Speed",speed)
end
