--------------------------------------------------------------------------------
-- Ящик с реле (ЯР-27)
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("YAК_27")

function TRAIN_SYSTEM:Initialize()
	-- Реле реверсировки (РР)
	self.Train:LoadSystem("RR","Relay","RPU-116T")
	-- 
	self.Train:LoadSystem("RVZ","Relay","REV-813T")
	-- Реле включения освещения (РВО)
	self.Train:LoadSystem("RVO","Relay","REV-814T")
	-- 
	self.Train:LoadSystem("KORD","Relay","REV-821")
	-- Реле тока (РТ2)
	self.Train:LoadSystem("RT2","Relay","REV-830")
	-- Реле контроля тормозного тока (РКТТ)
	self.Train:LoadSystem("RKTT","Relay","R-52B")
end