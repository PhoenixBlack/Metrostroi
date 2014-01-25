--------------------------------------------------------------------------------
-- Ящик с реле (ЯР-27)
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("YAR_27")

function TRAIN_SYSTEM:Initialize()
	-- Реле дверей (РД)
	self.Train:LoadSystem("RD","Relay","REV-821")
	-- Реле включения освещения (РВО)
	self.Train:LoadSystem("RVO","Relay","REV-814T",{ open_time = 4.0 })
	-- Реле времени торможения (РВ3)
	self.Train:LoadSystem("RVZ","Relay","REV-813T",{ open_time = 2.3 })
	-- Реле тока (РТ2)
	self.Train:LoadSystem("RT2","Relay","REV-830",{ trigger_level = 120 }) -- A
	-- Реле контроля тормозного тока (РКТТ) FIXME: see konspekt page 55
	self.Train:LoadSystem("RKTT","Relay","R-52B")
	-- Реле реверсировки (РР)
	self.Train:LoadSystem("RR","Relay","RPU-116T")
end