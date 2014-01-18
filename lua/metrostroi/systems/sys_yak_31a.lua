--------------------------------------------------------------------------------
-- Ящик с контакторами (ЯК-31А)
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("YAK_31A")

function TRAIN_SYSTEM:Initialize()
	-- Контактор шунта (КШ1)
	self.Train:LoadSystem("KSH1","Relay",{ contactor = true })
	-- Контактор шунта (КШ2)
	self.Train:LoadSystem("KSH2","Relay",{ contactor = true })
	-- Контактор шунта (КШ3)
	--self.Train:LoadSystem("KSH3","Relay",{ contactor = true })
	-- Контактор шунта (КШ4)
	--self.Train:LoadSystem("KSH4","Relay",{ contactor = true })
	
	-- Реле реверсировки (РР)
	self.Train:LoadSystem("RR","Relay","RM-3000")
end