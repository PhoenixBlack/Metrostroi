--------------------------------------------------------------------------------
-- Предохранитель
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("Fuse")

function TRAIN_SYSTEM:Initialize(parameters)
	self.Value = 1.0
end

function TRAIN_SYSTEM:Inputs()
	return { "Trip" }
end

function TRAIN_SYSTEM:Outputs()
	return { "State" }
end

function TRAIN_SYSTEM:TriggerInput(name,value)	
	if (name == "Trip") and (value > 0.5) then
		self.TargetValue = 0.0
	end
end

function TRAIN_SYSTEM:Think()
	
end
