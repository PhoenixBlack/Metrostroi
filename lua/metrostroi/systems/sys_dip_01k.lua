--------------------------------------------------------------------------------
-- Источник питания ДИП-01К
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("DIP_01K")

function TRAIN_SYSTEM:Initialize()
	self.XR3 = {
		[2] = 0,
		[3] = 0,
		[4] = 0,
		[5] = 0, -- Out only
		[6] = 0,
		[7] = 0,
	}
	self.XT3 = {
		[1] = 0, -- General (battery) output
		[4] = 0, -- Output for passenger lights
	}
	self.Active = 0
	self.LightsActive = 0
end

function TRAIN_SYSTEM:Inputs()
	local inputs = {}
	for k,v in pairs(self.XR3) do 
		if k ~= 5 then table.insert(inputs,"XR3."..k) end
	end
	return inputs
end

function TRAIN_SYSTEM:Outputs()
	return { "XT3.1", "XT3.4", "XT1.2" }
end


function TRAIN_SYSTEM:TriggerInput(name,value)
	local idx = tonumber(string.sub(name,5,6)) or 0
	if self.XR3[idx] then
		if value > 0.5 
		then self.XR3[idx] = 1.0
		else self.XR3[idx] = 0.0
		end
	end
end

function TRAIN_SYSTEM:Think()
	local Train = self.Train
	
	-- Get high-voltage input
	local XT1_2 = Train.Electric.Main750V
	
	-- Check if enable signal is present
	if self.XR3[2] > 0 then self.Active = 1 end
	if self.XR3[3] > 0 then self.Active = 0 self.LightsActive = 0 end
	if self.XR3[4] > 0 then self.LightsActive = 1 end
	if self.XR3[6] > 0 then self.Active = 1 end
	if self.XR3[7] > 0 then self.LightsActive = 1 end
	
	-- Undervoltage/overvoltage
	if XT1_2 < 550 then self.Active = 0 self.LightsActive = 0 end
	if XT1_2 > 975 then self.Active = 0 self.LightsActive = 0 end
	
	-- Generate output
	self.XT3[1] = 75 * self.Active
	self.XT3[4] = 75 * self.Active
	
	self:TriggerOutput("XT3.1", self.XT3[1])
	self:TriggerOutput("XT3.4", self.XT3[4])
	self:TriggerOutput("XT1.2", XT1_2)
end