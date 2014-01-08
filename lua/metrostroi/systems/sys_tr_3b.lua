--------------------------------------------------------------------------------
-- Токоприёмник контактного рельса (ТР-3Б)
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("TR_3B")

function TRAIN_SYSTEM:Initialize()
	-- Output voltage from contact rail
	self.Main750V = 0.0
end

function TRAIN_SYSTEM:Inputs()
	return { }
end

function TRAIN_SYSTEM:Outputs()
	return { "750V" }
end

function TRAIN_SYSTEM:Think()
	self.Main750V = 750
	self:TriggerOutput("750V",self.Main750V)
end
