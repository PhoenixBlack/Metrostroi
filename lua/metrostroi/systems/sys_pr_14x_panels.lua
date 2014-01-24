--------------------------------------------------------------------------------
-- Панели с реле и контакторами (ПР-143, ПР-144)
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("PR_14X_Panels")

function TRAIN_SYSTEM:Initialize()
	-- 
	--self.Train:LoadSystem("RPB","Relay","REV_813T")
	-- Реле времени торможения (РВТ)
	self.Train:LoadSystem("RVT","Relay","REV_811T")
	--
	--self.Train:LoadSystem("KD","Relay","KPD-110E")
	-- Контактор включения провода 1 (Р1-Р5)
	self.Train:LoadSystem("R1_5","Relay","KPD-110E")
	
	-- Контактор 25ого провода (К25)
	self.Train:LoadSystem("K25","Relay","PR-143")
	-- Реле-повторитель провода 8 (РП8)
	self.Train:LoadSystem("Rp8","Relay","REV_811T")
	-- Контактор дверей (КД)
	self.Train:LoadSystem("KD","Relay","REV_811T")
	-- Реле освещения (РО)
	self.Train:LoadSystem("RO","Relay","KPD-110E")	
end
