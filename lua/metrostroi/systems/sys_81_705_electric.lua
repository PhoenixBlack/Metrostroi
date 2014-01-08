--------------------------------------------------------------------------------
-- Электрические цепи 81-704/705 (Е, Еж, Ем)
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("81_705_Electric")


function TRAIN_SYSTEM:Initialize()
	self.Main750V = 0.0
	self.Aux750V = 0.0
	self.Power750V = 0.0
	self.Aux80V = 0.0
	
	-- Линейный контактор (ЛК1)
	self.Train:LoadSystem("LK1","Relay")
	-- Линейный контактор (ЛК2)
	self.Train:LoadSystem("LK2","Relay")
	-- Линейный контактор (ЛК3)
	self.Train:LoadSystem("LK3","Relay")
	-- Линейный контактор (ЛК4)
	self.Train:LoadSystem("LK4","Relay")
	
	-- Контактор шунта (КШ1)
	self.Train:LoadSystem("KSH1","Relay")
	-- Контактор шунта (КШ2)
	self.Train:LoadSystem("KSH2","Relay")
	-- Контактор шунта (КШ3)
	self.Train:LoadSystem("KSH3","Relay")
	-- Контактор шунта (КШ4)
	self.Train:LoadSystem("KSH4","Relay")
	
	-- (ТШ)
	self.Train:LoadSystem("TSH","Relay")
	-- Реле перегрузки (РПЛ)
	self.Train:LoadSystem("RPL","Fuse")
	
	self.Train.LK1.Value = 1
	self.Train.LK2.Value = 1
	self.Train.LK3.Value = 1
	self.Train.LK4.Value = 1
end

-- Temporary variables
local R = {}

-- Engines connected in series
function TRAIN_SYSTEM:Solve_PS(Train)
	local P13_12 	= Train.RheostatResistors["R13-R14"]
	local P12_11 	= Train.RheostatResistors["R12-R11"]
	local P11_10 	= Train.RheostatResistors["R10-R11"]
	local P10_9 	= Train.RheostatResistors["R10-R9"]
	local P9_8 		= Train.RheostatResistors["R9-R8"]
	local P8_7 		= Train.RheostatResistors["R8-R7"]
	local P7_6 		= Train.RheostatResistors["R6-R7"]
	local P6_5 		= Train.RheostatResistors["R4-R6"]/2
	local P5_4 		= Train.RheostatResistors["R4-R6"]/2
	local P4_3 		= Train.RheostatResistors["R3-R4"]
	local P3_2 		= Train.RheostatResistors["L8-R1"]
	local P2_1 		= Train.RheostatResistors["L8-R1"]
	
	local P27		= Train.RheostatResistors["R27"]
	local P26_25 	= Train.RheostatResistors["R25-R26"]
	local P25_24 	= Train.RheostatResistors["R24-R25"]
	local P24_23 	= Train.RheostatResistors["R23-R24"]
	local P23_22	= Train.RheostatResistors["R22-R23"]
	local P22_21	= Train.RheostatResistors["R21-R22"]
	local P21_20	= Train.RheostatResistors["R20-R21"]
	local P20_19	= Train.RheostatResistors["R18-R20"]/3
	local P19_18	= Train.RheostatResistors["R18-R20"]/3
	local P18_17	= Train.RheostatResistors["R18-R20"]/3
	local P17_16	= Train.RheostatResistors["L12-R26"]
	local P16_15	= Train.RheostatResistors["L12-R26"]
	
	-- Get rheostat controller positions
	local RK = Train.RheostatController
	
	-- Calculate rheostat 1 resistance
	R[1] = ((RK[11])*(P9_8)+(RK[11])*(P8_7)+(P9_8)*(P8_7))/(RK[11])
	R[2] = ((RK[11])*(P9_8)+(RK[11])*(P8_7)+(P9_8)*(P8_7))/(P9_8)
	R[3] = ((RK[11])*(P9_8)+(RK[11])*(P8_7)+(P9_8)*(P8_7))/(P8_7)
	R[4] = ((RK[13])^-1 + (R[3])^-1)^-1
	R[5] = ((RK[9])^-1 + (R[2])^-1)^-1
	R[6] = ((1e-9)*(P10_9)+(1e-9)*(P12_11+P11_10)+(P10_9)*(P12_11+P11_10))/(1e-9)
	R[7] = ((1e-9)*(P10_9)+(1e-9)*(P12_11+P11_10)+(P10_9)*(P12_11+P11_10))/(P10_9)
	R[8] = ((1e-9)*(P10_9)+(1e-9)*(P12_11+P11_10)+(P10_9)*(P12_11+P11_10))/(P12_11+P11_10)
	R[9] = ((RK[17])^-1 + (R[7])^-1)^-1
	R[10] = ((RK[3])*(1e-9)+(RK[3])*(RK[1])+(1e-9)*(RK[1]))/(RK[3])
	R[11] = ((RK[3])*(1e-9)+(RK[3])*(RK[1])+(1e-9)*(RK[1]))/(1e-9)
	R[12] = ((RK[3])*(1e-9)+(RK[3])*(RK[1])+(1e-9)*(RK[1]))/(RK[1])
	R[13] = ((P3_2)^-1 + (R[10])^-1)^-1
	R[14] = ((P7_6)*(R[5])+(P7_6)*(R[1])+(R[5])*(R[1]))/(P7_6)
	R[15] = ((P7_6)*(R[5])+(P7_6)*(R[1])+(R[5])*(R[1]))/(R[5])
	R[16] = ((P7_6)*(R[5])+(P7_6)*(R[1])+(R[5])*(R[1]))/(R[1])
	R[17] = ((RK[7])^-1 + (R[16])^-1)^-1
	R[18] = ((R[14])^-1 + (R[4])^-1)^-1
	R[19] = ((R[15])*(P6_5)+(R[15])*(R[17])+(P6_5)*(R[17]))/(R[15])
	R[20] = ((R[15])*(P6_5)+(R[15])*(R[17])+(P6_5)*(R[17]))/(P6_5)
	R[21] = ((R[15])*(P6_5)+(R[15])*(R[17])+(P6_5)*(R[17]))/(R[17])
	R[22] = ((R[18])^-1 + (R[20])^-1)^-1
	R[23] = ((RK[5])*(1e-9)+(RK[5])*(1e-9)+(1e-9)*(1e-9))/(RK[5])
	R[24] = ((RK[5])*(1e-9)+(RK[5])*(1e-9)+(1e-9)*(1e-9))/(1e-9)
	R[25] = ((RK[5])*(1e-9)+(RK[5])*(1e-9)+(1e-9)*(1e-9))/(1e-9)
	R[26] = ((P5_4)^-1 + (R[23])^-1)^-1
	R[27] = ((R[19])^-1 + (R[25])^-1)^-1
	R[28] = ((P13_12)*(R[9])+(P13_12)*(R[6])+(R[9])*(R[6]))/(P13_12)
	R[29] = ((P13_12)*(R[9])+(P13_12)*(R[6])+(R[9])*(R[6]))/(R[9])
	R[30] = ((P13_12)*(R[9])+(P13_12)*(R[6])+(R[9])*(R[6]))/(R[6])
	R[31] = ((RK[19])^-1 + (R[30])^-1)^-1
	R[32] = ((R[8])^-1 + (R[28])^-1)^-1
	R[33] = ((R[21])*(R[26])+(R[21])*(R[27])+(R[26])*(R[27]))/(R[21])
	R[34] = ((R[21])*(R[26])+(R[21])*(R[27])+(R[26])*(R[27]))/(R[26])
	R[35] = ((R[21])*(R[26])+(R[21])*(R[27])+(R[26])*(R[27]))/(R[27])
	R[36] = ((R[24])^-1 + (R[33])^-1)^-1
	R[37] = ((R[22])^-1 + (R[34])^-1)^-1
	R[38] = ((R[11])*(R[13])+(R[11])*(P2_1)+(R[13])*(P2_1))/(R[11])
	R[39] = ((R[11])*(R[13])+(R[11])*(P2_1)+(R[13])*(P2_1))/(R[13])
	R[40] = ((R[11])*(R[13])+(R[11])*(P2_1)+(R[13])*(P2_1))/(P2_1)
	R[41] = ((R[40])^-1 + (R[12])^-1)^-1
	R[42] = ((R[41])^-1 + (R[39]+R[38])^-1)^-1
	R[43] = ((R[42]+P4_3)^-1 + (R[36])^-1)^-1
	R[44] = ((R[37])^-1 + (R[35]+R[43])^-1)^-1
	R[45] = ((R[44])*(R[32])+(R[44])*(R[29])+(R[32])*(R[29]))/(R[44])
	R[46] = ((R[44])*(R[32])+(R[44])*(R[29])+(R[32])*(R[29]))/(R[32])
	R[47] = ((R[44])*(R[32])+(R[44])*(R[29])+(R[32])*(R[29]))/(R[29])
	R[48] = ((RK[15])^-1 + (R[47])^-1)^-1
	R[49] = ((R[31])^-1 + (R[45])^-1)^-1
	R[50] = ((R[49]+R[48])^-1 + (R[46])^-1)^-1
	local R1 = R[50]
	
	-- Calculate rheostat 2 resistance
	R[1] = ((RK[12])*(P23_22)+(RK[12])*(P22_21)+(P23_22)*(P22_21))/(RK[12])
	R[2] = ((RK[12])*(P23_22)+(RK[12])*(P22_21)+(P23_22)*(P22_21))/(P23_22)
	R[3] = ((RK[12])*(P23_22)+(RK[12])*(P22_21)+(P23_22)*(P22_21))/(P22_21)
	R[4] = ((RK[14])^-1 + (R[3])^-1)^-1
	R[5] = ((RK[10])^-1 + (R[2])^-1)^-1
	R[6] = ((P21_20)*(R[1])+(P21_20)*(R[5])+(R[1])*(R[5]))/(P21_20)
	R[7] = ((P21_20)*(R[1])+(P21_20)*(R[5])+(R[1])*(R[5]))/(R[1])
	R[8] = ((P21_20)*(R[1])+(P21_20)*(R[5])+(R[1])*(R[5]))/(R[5])
	R[9] = ((RK[8])^-1 + (R[7])^-1)^-1
	R[10] = ((R[4])^-1 + (R[6])^-1)^-1
	R[11] = ((RK[2])*(P17_16)+(RK[2])*(P27+RK[20]+P16_15)+(P17_16)*(P27+RK[20]+P16_15))/(RK[2])
	R[12] = ((RK[2])*(P17_16)+(RK[2])*(P27+RK[20]+P16_15)+(P17_16)*(P27+RK[20]+P16_15))/(P17_16)
	R[13] = ((RK[2])*(P17_16)+(RK[2])*(P27+RK[20]+P16_15)+(P17_16)*(P27+RK[20]+P16_15))/(P27+RK[20]+P16_15)
	R[14] = ((1e-9)^-1 + (R[13])^-1)^-1
	R[15] = ((RK[16])*(RK[18])+(RK[16])*(1e-9)+(RK[18])*(1e-9))/(RK[16])
	R[16] = ((RK[16])*(RK[18])+(RK[16])*(1e-9)+(RK[18])*(1e-9))/(RK[18])
	R[17] = ((RK[16])*(RK[18])+(RK[16])*(1e-9)+(RK[18])*(1e-9))/(1e-9)
	R[18] = ((P26_25)^-1 + (R[15])^-1)^-1
	R[19] = ((1e-9)*(P19_18)+(1e-9)*(P18_17)+(P19_18)*(P18_17))/(1e-9)
	R[20] = ((1e-9)*(P19_18)+(1e-9)*(P18_17)+(P19_18)*(P18_17))/(P19_18)
	R[21] = ((1e-9)*(P19_18)+(1e-9)*(P18_17)+(P19_18)*(P18_17))/(P18_17)
	R[22] = ((1e-9)^-1 + (R[21])^-1)^-1
	R[23] = ((P25_24+P24_23)*(R[10])+(P25_24+P24_23)*(R[8])+(R[10])*(R[8]))/(P25_24+P24_23)
	R[24] = ((P25_24+P24_23)*(R[10])+(P25_24+P24_23)*(R[8])+(R[10])*(R[8]))/(R[10])
	R[25] = ((P25_24+P24_23)*(R[10])+(P25_24+P24_23)*(R[8])+(R[10])*(R[8]))/(R[8])
	R[26] = ((R[25])^-1 + (R[16])^-1)^-1
	R[27] = ((R[23])^-1 + (R[9])^-1)^-1
	R[28] = ((RK[4])*(R[12])+(RK[4])*(R[14])+(R[12])*(R[14]))/(RK[4])
	R[29] = ((RK[4])*(R[12])+(RK[4])*(R[14])+(R[12])*(R[14]))/(R[12])
	R[30] = ((RK[4])*(R[12])+(RK[4])*(R[14])+(R[12])*(R[14]))/(R[14])
	R[31] = ((R[26])^-1 + (R[30])^-1)^-1
	R[32] = ((R[28])^-1 + (R[11])^-1)^-1
	R[33] = ((R[20])*(R[22])+(R[20])*(RK[6])+(R[22])*(RK[6]))/(R[20])
	R[34] = ((R[20])*(R[22])+(R[20])*(RK[6])+(R[22])*(RK[6]))/(R[22])
	R[35] = ((R[20])*(R[22])+(R[20])*(RK[6])+(R[22])*(RK[6]))/(RK[6])
	R[36] = ((R[19])^-1 + (R[35])^-1)^-1
	R[37] = ((R[29])^-1 + (R[34])^-1)^-1
	R[38] = ((R[24])*(R[27])+(R[24])*(P20_19)+(R[27])*(P20_19))/(R[24])
	R[39] = ((R[24])*(R[27])+(R[24])*(P20_19)+(R[27])*(P20_19))/(R[27])
	R[40] = ((R[24])*(R[27])+(R[24])*(P20_19)+(R[27])*(P20_19))/(P20_19)
	R[41] = ((R[40])^-1 + (R[31])^-1)^-1
	R[42] = ((R[38])^-1 + (R[33])^-1)^-1
	R[43] = ((R[37])*(R[36])+(R[37])*(R[32])+(R[36])*(R[32]))/(R[37])
	R[44] = ((R[37])*(R[36])+(R[37])*(R[32])+(R[36])*(R[32]))/(R[36])
	R[45] = ((R[37])*(R[36])+(R[37])*(R[32])+(R[36])*(R[32]))/(R[32])
	R[46] = ((R[42])^-1 + (R[45])^-1)^-1
	R[47] = ((R[39])^-1 + (R[43])^-1)^-1
	R[48] = ((R[41])^-1 + (R[44])^-1)^-1
	R[49] = ((R[48])^-1 + (R[46]+R[47])^-1)^-1
	R[50] = ((R[49]+R[18])^-1 + (R[17])^-1)^-1
	local R2 = R[50]
	
	-- Store resistances of two blocks
	self.Block1Resistance = 1.2*R1
	self.Block2Resistance = 1.2*R2
	
	-- РУТ (реле управления тягой) operation
	if (Train.Engine.RUTCurrent < 300) and (Train.FrontBogey.Speed > 2) then
		if not Train.RheostatController.Moving then
			if Train.RheostatController.Position < 3 then
				Train.RheostatController:TriggerInput("Up",1.0)
			end
			--print("NEXT",Train.Engine.RUTCurrent)
		end	
	end
	
	-- Trigger close
	if Train.Engine.RUTCurrent > 600 then
		--Train.RPL:TriggerInput("Open",1.0)
		Train.RPL.Value = 0.0
	end
	
	--if Train.Engine.RUTCurrent > 1000 then
		--Train.RheostatController.Position = 1
		--Train.RheostatController.TargetPosition = nil
	--end
	
	--print("ELECTRIC",RK.Position,Train.Engine.RUTCurrent)
end

function TRAIN_SYSTEM:Think()
	local Train = self.Train
	
	----------------------------------------------------------------------------
	-- Вспомагательные цепи
	self.Aux750V = 750--Train.TR.Main750V * self.Train.PNB_1250_1.Value * self.Train.PNB_1250_2.Value * Train.KVC.Value		
	
	-- Питание вспомагательных цепей 80V
	self.Aux80V = 80 --math.max(Train.BPSN.Output80V * self.Train.VB.Value, Train.Battery.Voltage)
	
	----------------------------------------------------------------------------
	-- Главные электрические цепи
	self.Main750V = Train.TR.Main750V * Train.PNB_1250_1.Value
	
	----------------------------------------------------------------------------
	-- Силовые цепи
	self.Power750V = self.Main750V * Train.GV.Value * Train.LK1.Value	
	-- Ослабление резистором Л1-Л2
	self.Power750V = (1.0-Train.LK2.Value)*self.Power750V*0.80 + Train.LK2.Value*self.Power750V
	-- Реле РПЛ
	self.Power750V = self.Power750V * Train.RPL.Value
	
	-- Сопротивления в резисторах реостатного контроллера
	self:Solve_PS(Train)
	
	-- Напряжения на группах моторов
	
	
	-- Питание реле КВЦ
	--self.KVC_PowerSupply = self.Aux80V * self.Train.A53.Value * self.Train.VB.Value
end