--------------------------------------------------------------------------------
-- БПСН-5У2М
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("BPSN_5U2M")

function TRAIN_SYSTEM:Initialize()
	-- КК/РЗ (реле защиты БПС)
	self.Train:LoadSystem("RZ","Relay","TRTP-112U3")

	-- BPSN status
	self.Power80V = 0.0
	self.Power220V = 0.0
end

function TRAIN_SYSTEM:Inputs()
	return { }
end

function TRAIN_SYSTEM:Outputs()
	return { "Output80V", "Output220V" }
end

function TRAIN_SYSTEM:TriggerInput(name,value)	
	
end

function TRAIN_SYSTEM:Think()
	local Train = self.Train
	--local drainBattery = false

	-- Напряжение вспомагательной цепи
	local auxVoltage = Train.Electric.Aux750V
	
	-- Основной инвертор
	self.Internal80V = auxVoltage * (80 / 750) * Train.KPP.Value
	-- Питание воспомагательных цепей
	self.Output80V = self.Internal80V * Train.A22.Value
	-- Вторичный инвертор
	self.Output220V = self.Power80V * (220 / 80) * Train.KVP.Value * Train.A65.Value	
end
