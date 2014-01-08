--------------------------------------------------------------------------------
-- Электрические цепи 81-717/81-714
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("81_717_Electric")


function TRAIN_SYSTEM:Initialize()
	self.Main750V = 0.0
	self.Aux750V = 0.0
end

function TRAIN_SYSTEM:Inputs()
	return { }
end

function TRAIN_SYSTEM:Outputs()
	return { }
end

function TRAIN_SYSTEM:TriggerInput(name,value)	
	
end

function TRAIN_SYSTEM:Think()
	local Train = self.Train
	
	-- Вспомагательные цепи
	self.Aux750V = Train.TR.Main750V * self.Train.PNB_1250_1.Value * self.Train.PNB_1250_2.Value * Train.KVC.Value	
	-- Главные электрические цепи
	self.Main750V = Train.TR.Main750V * self.Train.PNB_1250_1.Value
	
	-- Питание вспомагательных цепей 80V
	self.Aux80V = math.max(Train.BPSN.Output80V * self.Train.VB.Value, Train.Battery.Voltage)
	
	-- Питание реле КВЦ
	self.KVC_PowerSupply = self.Aux80V * self.Train.A53.Value * self.Train.VB.Value
end