--------------------------------------------------------------------------------
-- Панель управления Еж3, Ем508Т, Ема
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("81_705_Panel")

function TRAIN_SYSTEM:Initialize()
	-- Выключатель батареи (ВБ)
	self.Train:LoadSystem("VB","Relay","VB-11")

	-- Buttons on the panel
	self.Train:LoadSystem("DIPon","Relay","Switch")
	self.Train:LoadSystem("DIPoff","Relay","Switch")
	self.Train:LoadSystem("VozvratRP","Relay","Switch")
	self.Train:LoadSystem("RezMK","Relay","Switch")
	self.Train:LoadSystem("VMK","Relay","Switch")
	self.Train:LoadSystem("VAH","Relay","Switch",{ normally_closed = true })
	self.Train:LoadSystem("VAD","Relay","Switch")
	self.Train:LoadSystem("VUS","Relay","Switch")
	self.Train:LoadSystem("VUD1","Relay","Switch")
	self.Train:LoadSystem("VUD2","Relay","Switch",{ normally_closed = true }) -- Doors close
	self.Train:LoadSystem("VDL","Relay","Switch") -- Doors left open
	self.Train:LoadSystem("KDL","Relay","Switch")
	self.Train:LoadSystem("KDP","Relay","Switch")
	self.Train:LoadSystem("KRZD","Relay","Switch")
	self.Train:LoadSystem("KSN","Relay","Switch")
	self.Train:LoadSystem("OtklAVU","Relay","Switch")
	self.Train:LoadSystem("ARS","Relay","Switch")
	self.Train:LoadSystem("ALS","Relay","Switch",{ normally_closed = true })
	
	-- Автоматические выключатели (АВ)
	self.Train:LoadSystem("A1","Relay","VA21-29")
	self.Train:LoadSystem("A2","Relay","VA21-29")
	self.Train:LoadSystem("A3","Relay","VA21-29")
	self.Train:LoadSystem("A5","Relay","VA21-29")
	self.Train:LoadSystem("A6","Relay","VA21-29")
	self.Train:LoadSystem("A7","Relay","VA21-29")
	self.Train:LoadSystem("A8","Relay","VA21-29")
	self.Train:LoadSystem("A9","Relay","VA21-29")
	self.Train:LoadSystem("A10","Relay","VA21-29")
	self.Train:LoadSystem("A12","Relay","VA21-29")
	self.Train:LoadSystem("A13","Relay","VA21-29")
	self.Train:LoadSystem("A14","Relay","VA21-29")
	self.Train:LoadSystem("A16","Relay","VA21-29")
	self.Train:LoadSystem("A17","Relay","VA21-29")
	self.Train:LoadSystem("A20","Relay","VA21-29")
	self.Train:LoadSystem("A21","Relay","VA21-29")
	self.Train:LoadSystem("A22","Relay","VA21-29")
	self.Train:LoadSystem("A23","Relay","VA21-29")
	self.Train:LoadSystem("A24","Relay","VA21-29")
	self.Train:LoadSystem("A25","Relay","VA21-29")
	self.Train:LoadSystem("A27","Relay","VA21-29")
	self.Train:LoadSystem("A29","Relay","VA21-29")
	self.Train:LoadSystem("A30","Relay","VA21-29")
	self.Train:LoadSystem("A31","Relay","VA21-29")
	self.Train:LoadSystem("A32","Relay","VA21-29")
	self.Train:LoadSystem("A39","Relay","VA21-29")
	self.Train:LoadSystem("A41","Relay","VA21-29")
	self.Train:LoadSystem("A42","Relay","VA21-29")
	self.Train:LoadSystem("A43","Relay","VA21-29")
	self.Train:LoadSystem("A44","Relay","VA21-29")
	self.Train:LoadSystem("A45","Relay","VA21-29")
	self.Train:LoadSystem("A46","Relay","VA21-29")
	self.Train:LoadSystem("A47","Relay","VA21-29")
	self.Train:LoadSystem("A50","Relay","VA21-29")
	self.Train:LoadSystem("A51","Relay","VA21-29")
	self.Train:LoadSystem("A53","Relay","VA21-29")
	self.Train:LoadSystem("A54","Relay","VA21-29")
	self.Train:LoadSystem("A55","Relay","VA21-29")
	self.Train:LoadSystem("A56","Relay","VA21-29")
	self.Train:LoadSystem("A61","Relay","VA21-29")
	self.Train:LoadSystem("A62","Relay","VA21-29")
	self.Train:LoadSystem("A63","Relay","VA21-29")
	self.Train:LoadSystem("A64","Relay","VA21-29")
	self.Train:LoadSystem("A65","Relay","VA21-29")
	self.Train:LoadSystem("A75","Relay","VA21-29",{ normally_closed = false })
	self.Train:LoadSystem("A80","Relay","VA21-29")
	self.Train:LoadSystem("VU","Relay","VA21-29")
	
	-- Map of AV switches to indexes on panel
	self:InitializeAVMap()
end

function TRAIN_SYSTEM:ClientInitialize()
	self:InitializeAVMap()
end

function TRAIN_SYSTEM:Outputs()
	return { "CabinLight", "HeadLights1", "HeadLights2", "HeadLights3",
			 "RedLightLeft", "RedLightRight", "EmergencyLight",
			 "GreenRP", "RedRP", "KUP", "V1", "AVU", "Ring", "SD",
			 "TrainBrakes", "TrainRP", "TrainDoors" }
end

function TRAIN_SYSTEM:InitializeAVMap()
	self.AVMap = {
		  61,55,54,56,27,21,10,53,43,45,42,41,
		"VU",64,63,50,51,23,14,75, 1, 2, 3,17,
		  62,29, 5, 6, 8,20,25,22,30,39,44,80,
		  65,65,24,32,31,16,13,12, 7, 9,46,47
	}
end