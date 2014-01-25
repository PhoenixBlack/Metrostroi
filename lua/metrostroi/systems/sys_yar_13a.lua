--------------------------------------------------------------------------------
-- Ящик с реле (ЯР-13A)
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("YAR_13A")

function TRAIN_SYSTEM:Initialize()
	-- Реле перегрузки (РПЛ)
	self.Train:LoadSystem("RPL","Relay")
	-- Групповое реле перегрузки 1-3 (РП1-3)
	self.Train:LoadSystem("RP1_3","Relay")
	-- Групповое реле перегрузки 2-4 (РП2-4)
	self.Train:LoadSystem("RP2_4","Relay")
	
	-- Реле заземления (РЗ-1, РЗ-2, РЗ-3)
	self.Train:LoadSystem("RZ_1","Relay")
	self.Train:LoadSystem("RZ_2","Relay")
	self.Train:LoadSystem("RZ_3","Relay")
	
	-- Стоп-реле (СР1)
	self.Train:LoadSystem("SR1","Relay")
	-- Реле контроля реверсоров
	self.Train:LoadSystem("RKR","Relay")
	-- Реле ручного тормоза
	self.Train:LoadSystem("RRT","Relay")
	
	-- Возврат реле перегрузки
	self.Train:LoadSystem("RP_Vozvrat","Relay")
	-- Реле системы управления
	self.Train:LoadSystem("RSU","Relay")
	
	-- Реле времени РВ1
	self.Train:LoadSystem("RV1","Relay", { open_time = 0.7 })
	-- Реле времени РВ2 (задерживает отключение ЛК2)
	self.Train:LoadSystem("RV2","Relay", { close_time = 0.7 })
	
	-- Реле ускорения, торможения (РУТ)
	self.Train:LoadSystem("RUT","Relay")
	
	-- Only in Ezh
	-- Реле перехода (Рпер)
	self.Train:LoadSystem("Rper","Relay")
end
