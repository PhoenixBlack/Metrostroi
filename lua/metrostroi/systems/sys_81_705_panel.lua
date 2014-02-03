--------------------------------------------------------------------------------
-- Панель управления Ем, Ем508, Ем509
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("81_705_Panel")

function TRAIN_SYSTEM:Initialize()
	self.Train:LoadSystem("DIPon","Relay","Switch")
	self.Train:LoadSystem("DIPoff","Relay","Switch")
	self.Train:LoadSystem("VozvratRP","Relay","Switch")
end