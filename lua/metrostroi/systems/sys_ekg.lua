--------------------------------------------------------------------------------
-- Групповой переключатель контакторов (ЕКГ)
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("EKG")

function TRAIN_SYSTEM:Initialize()
	-- Controller configuration
	self.Configuration = self.Configuration or {
		[ 1] = { 0, 0 },
		[ 2] = { 1, 1 },
	}
	
	-- Resistance value of all contactors
	for k,v in ipairs(self.Configuration[1]) do self[k] = 1e15 end
	for k,v in ipairs(self.Configuration[1]) do self[k.."_v"] = 0 end
	
	-- Rate of rotation (positions per second
	self.RotationRate = self.RotationRate or 6
	self.OverrideRate = self.OverrideRate or {}
	
	-- Initialize motor state and position
	self.Moving = 0
	self.Position = 1
	self.SelectedPosition = 1
	self.MotorState = 0
	
	-- Max position
	self.MaxPosition = #self.Configuration
end

function TRAIN_SYSTEM:Inputs()
	return { "MotorState", "TargetPosition" }
end

function TRAIN_SYSTEM:Outputs()
	return { "Position", "MotorState", "Moving" }
end

function TRAIN_SYSTEM:TriggerInput(name,value)
	if name == "MotorState" then
		if value > 0.5 then 
			self.MotorState =  1.0
		elseif value < -0.5 then 
			self.MotorState = -1.0 
		else
			self.MotorState = 0.0
		end
	elseif name == "TargetPosition" then
		--if self.Position 
	end
end

function TRAIN_SYSTEM:Think(dT)
	local Train = self.Train

	-- Get currently selected position
	local position = math.floor(self.Position+0.5)
	if position < 1 then position = 1 end
	if position > self.MaxPosition then position = self.MaxPosition end
	self.SelectedPosition = position
	
	-- Lock contacts as defined in the configuration
	for k,v in ipairs(self.Configuration[position]) do 
		self[k] = 1e-15 + 1e15 * (1-v)
		self[k.."_v"] = v
	end
	
	-- Start motor rotation
	if (self.MotorState > 0.0) and (self.Moving == 0.0) then
		self.Moving =  1.0
	end
	if (self.MotorState < 0.0) and (self.Moving == 0.0) then
		self.Moving = -1.0
	end
	
	-- Threshold for motor stopping
	local threshold = 0.3 
	
	-- Stop motor rotation
	local delta = self.Position - math.floor(self.Position)
	if delta > 0.5 then delta = 1.0 - delta end
	
	if (self.MotorState == 0.0) and (self.Moving ~= 0.0) and (delta < threshold) then
		self.Moving = 0.0
	end
	
	-- Move motor
	local rate = self.OverrideRate[position] or self.RotationRate
	self.Position = self.Position + self.Moving * math.min(threshold*0.5,rate * dT)
	
	-- Limit motor from moving too far
	if self.Position > 18.4 then self.Position = 18.4 	self.MotorState = 0.0 self.Moving = 0.0 end
	if self.Position < 0.6  then self.Position = 0.6 	self.MotorState = 0.0 self.Moving = 0.0 end

	self:TriggerOutput("Position",self.Position)
	self:TriggerOutput("MotorState",self.MotorState)
	self:TriggerOutput("Moving",self.Moving)
end
