--------------------------------------------------------------------------------
-- Ящик с реле (ЯР-13A)
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("YAR_13A")

function TRAIN_SYSTEM:Initialize()
	-- Реле перегрузки (РПЛ)
	self.Train:LoadSystem("RPL","Relay","RM3001")
	-- Групповое реле перегрузки 1-3 (РП1-3)
	self.Train:LoadSystem("RP1_3","Relay","RM3001",{ trigger_level = 630 })
	-- Групповое реле перегрузки 2-4 (РП2-4)
	self.Train:LoadSystem("RP2_4","Relay","RM3001",{ trigger_level = 630 })
	
	-- Нулевое реле (НР)
	--   Does not use any power source defined, as the operation is calculated from bus voltage
	self.Train:LoadSystem("NR","Relay","R3150", { power_source = "None" })
	-- Реле системы управления
	self.Train:LoadSystem("RSU","Relay","R3100")
	
	-- Реле заземления (РЗ-1, РЗ-2, РЗ-3)
	self.Train:LoadSystem("RZ_1","Relay","RM3001")
	self.Train:LoadSystem("RZ_2","Relay","RM3001")
	self.Train:LoadSystem("RZ_3","Relay","RM3001")
	-- Возврат реле перегрузки (РПвозврат)
	self.Train:LoadSystem("RPvozvrat","Relay","RM3001",{
		latched = true, 			-- RPvozvrat latches into place
		power_open = "None",		-- Power source for the open signal
		power_close = "Mechanical",	-- Power source for the close signal
	})
	
	-- Реле времени РВ1
	self.Train:LoadSystem("RV1","Relay","RM3100",{ open_time = 0.7 })
	-- Реле времени РВ2 (задерживает отключение ЛК2)
	self.Train:LoadSystem("RV2","Relay","RM3100",{ open_time = 0.7 })
	
	-- Реле ручного тормоза (РРТ)
	self.Train:LoadSystem("RRT","Relay")
	-- Реле резервного пуска (РРП1)
	self.Train:LoadSystem("RRP1","Relay")
	-- Стоп-реле (СР1)
	self.Train:LoadSystem("SR1","Relay","RM3000")
	-- Реле контроля реверсоров
	self.Train:LoadSystem("RKR","Relay","RM3000")
	-- Реле ускорения, торможения (РУТ)
	self.Train:LoadSystem("RUT","Relay","R-52B")
	

	-- Only in Ezh
	-- Реле перехода (Рпер)
	self.Train:LoadSystem("Rper","Relay")
	self.Train:LoadSystem("RUP","Relay")
	
	
	-- Extra coils for some relays
	self.Train.RUTtest = 0
	self.Train.RUTpod = 0
	self.Train.RRTuderzh = 0
	self.Train.RRTpod = 0
end

function TRAIN_SYSTEM:Think()
	local Train = self.Train
	
	-- Zero relay operation
	Train.NR:TriggerInput("Close",Train.Electric.Power750V > 360) -- 360 - 380 V 
	Train.NR:TriggerInput("Open", Train.Electric.Power750V < 150) -- 120 - 190 V
	
	-- Overload relays operation
	Train.RP1_3:TriggerInput("Set",Train.Electric.I13)
	Train.RP2_4:TriggerInput("Set",Train.Electric.I24)
	
	-- RUT operation
	self.RUTCurrent = math.abs(Train.Electric.I13) + math.abs(Train.Electric.I24)
	self.RUTTarget = 260 + self.Train.RUTtest
	-- HACK: increase RUT current on slopes
	--if math.abs(Train:GetAngles().pitch) > 2.5 then self.RUTTarget = self.RUTTarget + 75 end	
	if Train.PositionSwitch.SelectedPosition >= 3 then self.RUTTarget = 180 end
	
	if Train.RUTpod > 0.5 
	then Train.RUT:TriggerInput("Close",1.0)
	else Train.RUT:TriggerInput("Set",self.RUTCurrent > self.RUTTarget)
	end
	
	-- RRT operation
	Train.RRT:TriggerInput("Close",(Train.RRT.Value == 0.0) and (Train.RRTpod > 0.5) and (Train.RRTuderzh > 0.5))
	Train.RRT:TriggerInput("Open",(Train.RRTuderzh < 0.5))

	-- RPvozvrat operation
	Train.RPvozvrat:TriggerInput("Close",
		(Train.RPL.Value == 1.0) or
		(Train.RP1_3.Value == 1.0) or
		(Train.RP2_4.Value == 1.0) or
		(Train.RZ_1.Value == 1.0) or
		(Train.RZ_2.Value == 1.0) or
		(Train.RZ_3.Value == 1.0))
		
	-- RV2 time relay for LK1, LK3, LK4
	--[[Train.LK1:TriggerInput("Open",Train.RV2.Value)
	Train.LK3:TriggerInput("Open",Train.RV2.Value)
	Train.LK4:TriggerInput("Open",Train.RV2.Value)
	Train.RV2:TriggerInput("Open",Train.RV2.Value)]]--
end
