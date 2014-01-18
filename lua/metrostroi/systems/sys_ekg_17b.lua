--------------------------------------------------------------------------------
-- Реостатный контроллер (ЕКГ-17Б)
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("EKG_17B")

function TRAIN_SYSTEM:Initialize()
	-- Rheostat controller position
	self.Position = 1
	
	-- Rheostat configuration
	self.RheostatConfiguration = {
	--   ##      1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26
		[ 1] = { 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1 },
		[ 2] = { 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1 },
		[ 3] = { 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 1, 1, 0, 0 },
		[ 4] = { 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 1, 0, 0, 0, 0 },
		[ 5] = { 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0 },
		[ 6] = { 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0 },
		[ 7] = { 1, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0 },
		[ 8] = { 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0 },
		[ 9] = { 1, 1, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0 },
		[10] = { 1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0 },
		[11] = { 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0 },
		[12] = { 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0 },
		[13] = { 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0 },
		[14] = { 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0 },
		[15] = { 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0 },
		[16] = { 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0 },
		[17] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0 },
		[18] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0 },
	}
	
	-- Value of all contactors
	for i=1,26 do self[i] = 1e9 end
	
	-- Rate of rotation
	self.RotationRate = 6 -- Positions per second
	self.Moving = false
end

function TRAIN_SYSTEM:Inputs()
	return { "Up", "Down" }
end

function TRAIN_SYSTEM:Outputs()
	return { "Position" }
end

function TRAIN_SYSTEM:TriggerInput(name,value)	
	if (name == "Up") and (value > 0.5) then
		self.TargetPosition = math.floor(self.Position+0.5) + 1
		if self.TargetPosition > 18 then self.TargetPosition = 18 end
	elseif (name == "Down") and (value > 0.5) then
		self.TargetPosition = math.floor(self.Position+0.5) - 1
		if self.TargetPosition < 1 then self.TargetPosition = 1 end
	end
end

function TRAIN_SYSTEM:Think(dT)
	local Train = self.Train
	
	-- Get proper position
	local position = math.floor(self.Position+0.5)
	if position < 1 then position = 1 end
	if position > 18 then position = 18 end
	
	-- Update motion of the rheostat controller
	for k,v in ipairs(self.RheostatConfiguration[position]) do 
		self[k] = 1e-15 + 1e15 * (1-v)
	end
	
	-- Move to target position
	if self.TargetPosition then
		if self.TargetPosition < self.Position then
			self.Position = self.Position - self.RotationRate * dT
			self.Moving = true
		end
		if self.TargetPosition > self.Position then
			self.Position = self.Position + self.RotationRate * dT
			self.Moving = true
		end
		if math.abs(self.TargetPosition - self.Position) < 0.2 then
			self.TargetPosition = nil
			self.Moving = false
		end
	else
		self.Moving = false
	end
	if self.Position > 18.4 then self.Position = 18.4 	self.Moving = false end
	if self.Position < 0.6  then self.Position = 0.6 	self.Moving = false end

	self:TriggerOutput("Position",self.Position)
end
