--------------------------------------------------------------------------------
-- Ящик с реле (ЯР-13A)
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("YAR_13A")

function TRAIN_SYSTEM:Initialize()
	print("INIT")
	
	-- Реле перегрузки (РПЛ)
	self.Train:LoadSystem("RPL","Relay", { normally_open = true })
	-- Групповое реле перегрузки 1-3 (РП1-3)
	self.Train:LoadSystem("RP1_3","Relay", { normally_open = true })
	-- Групповое реле перегрузки 2-4 (РП2-4)
	self.Train:LoadSystem("RP2_4","Relay", { normally_open = true })
	
	-- Реле времени РВ2 (задерживает отключение ЛК2)
	self.Train:LoadSystem("RV2","Relay", { close_time = 0.7 })
end