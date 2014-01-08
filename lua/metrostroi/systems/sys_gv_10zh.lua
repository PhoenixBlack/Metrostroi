--------------------------------------------------------------------------------
-- Главный выключатель (ГВ-10Ж)
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("GV_10ZH")

function TRAIN_SYSTEM:Initialize()
	self.Value = 1
end

function TRAIN_SYSTEM:Inputs()
	return { "Open", "Close" }
end

function TRAIN_SYSTEM:Outputs()
	return { "State" }
end

function TRAIN_SYSTEM:Think()

end
