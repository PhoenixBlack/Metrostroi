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
	self.Train:LoadSystem("LK1","Relay",{ contactor = true, open_time = 0.7 })
	-- Линейный контактор (ЛК2)
	self.Train:LoadSystem("LK2","Relay",{ contactor = true })
	-- Линейный контактор (ЛК3)
	self.Train:LoadSystem("LK3","Relay",{ contactor = true, open_time = 0.7 })
	-- Линейный контактор (ЛК4)
	self.Train:LoadSystem("LK4","Relay",{ contactor = true, open_time = 0.7 })
	
	-- Контактор шунта (КШ1)
	self.Train:LoadSystem("KSH1","Relay",{ contactor = true })
	-- Контактор шунта (КШ2)
	self.Train:LoadSystem("KSH2","Relay",{ contactor = true })
	-- Контактор шунта (КШ3)
	self.Train:LoadSystem("KSH3","Relay",{ contactor = true })
	-- Контактор шунта (КШ4)
	self.Train:LoadSystem("KSH4","Relay",{ contactor = true })
	
	-- Реле перегрузки (РПЛ)
	self.Train:LoadSystem("RPL","Relay", { normally_open = true })
	-- Групповое реле перегрузки 1-3 (РП1-3)
	self.Train:LoadSystem("RP1_3","Relay", { normally_open = true })
	-- Групповое реле перегрузки 2-4 (РП2-4)
	self.Train:LoadSystem("RP2_4","Relay", { normally_open = true })
	
	-- Реверсор (ПР-772)
	self.Train:LoadSystem("PR_772","Relay",{ contactor = true })
	-- Набор реле переключения между последовательным и паралельным включением
	self.Train:LoadSystem("T_Parallel","Relay",{ close_time = 0.3 })
	-- Набор реле переключения между тормозной и ходовой схемой
	self.Train:LoadSystem("T_Brake","Relay")
end


function TRAIN_SYSTEM:Inputs()
	return { "ResetRPL" }
end

function TRAIN_SYSTEM:TriggerInput(name,value)
	if name == "ResetRPL" then
		self.Train:PlayOnce("switch",true)
		self.Train.RPL:TriggerInput("Close",1.0)
		self.Train.RP1_3:TriggerInput("Close",1.0)
		self.Train.RP2_4:TriggerInput("Close",1.0)
	end
end



--------------------------------------------------------------------------------
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
	self.ExtraResistance = (1-Train.LK2.Value) * Train.RheostatResistors["L4-L2"]
	-- Реле РПЛ
	self.Power750V = self.Power750V * Train.RPL.Value
	
	-- Сопротивления в резисторах реостатного контроллера
	self:InitializeResistances(Train)
	self:Solve_Shunt(Train)
	if Train.T_Parallel.Value == 0.0 then
		self:Solve_PS(Train)
	else
		self:Solve_PP(Train)
	end
	
	-- РУТ (реле управления тягой) operation
	if Train.LK1.Value == 0 then
		Train.RheostatController:TriggerInput("Down",1.0)
	elseif Train.KV.ControllerPosition == 2 then	
		if Train.Engine.RUTCurrent < 260 then
			Train.RheostatController:TriggerInput("Up",1.0)
		end	
	elseif Train.KV.ControllerPosition == 3 then
		if Train.Engine.RUTCurrent < 300 then
			Train.RheostatController:TriggerInput("Down",1.0)
			Train.LK2:TriggerInput("Close",1.0)
		end
	end
	
	
	-- Trigger close
	--print("VALUE",Train.LK2.Value)
	if Train.KV.ControllerPosition == 3 then
		if Train.Engine.RUTCurrent > 1500 then
			Train.RPL:TriggerInput("Open",1.0)
			Train.RP1_3:TriggerInput("Open",1.0)
			Train.RP2_4:TriggerInput("Open",1.0)
		end
	else
		if Train.Engine.RUTCurrent > 750 then
			Train.RPL:TriggerInput("Open",1.0)
			Train.RP1_3:TriggerInput("Open",1.0)
			Train.RP2_4:TriggerInput("Open",1.0)
		end
	end
end




--------------------------------------------------------------------------------
-- Temporary variables
local R = {}
local P14	
local P13_12
local P12_11
local P11_10
local P10_9 
local P9_8 	
local P8_7 	
local P7_6 	
local P6_5 	
local P5_4 	
local P4_3 	
local P3_2 	
local P2_1 	

local P27	
local P26_25
local P25_24
local P24_23
local P23_22
local P22_21
local P21_20
local P20_19
local P19_18
local P18_17
local P17_16
local P16_15

local P28_29
local P29_30
local P30_31
local P31_L26
local P34_35
local P35_36
local P36_37
local P37_L24

function TRAIN_SYSTEM:InitializeResistances(Train)
	P14		= Train.RheostatResistors["R14"]
	P13_12 	= Train.RheostatResistors["R13-R14"]
	P12_11 	= Train.RheostatResistors["R12-R11"]
	P11_10 	= Train.RheostatResistors["R10-R11"]
	P10_9 	= Train.RheostatResistors["R10-R9"]
	P9_8 	= Train.RheostatResistors["R9-R8"]
	P8_7 	= Train.RheostatResistors["R8-R7"]
	P7_6 	= Train.RheostatResistors["R6-R7"]
	P6_5 	= Train.RheostatResistors["R4-R6"]/2
	P5_4 	= Train.RheostatResistors["R4-R6"]/2
	P4_3 	= Train.RheostatResistors["R3-R4"]
	P3_2 	= Train.RheostatResistors["L8-R1"]
	P2_1 	= Train.RheostatResistors["L8-R1"]
	
	P27		= Train.RheostatResistors["R27"]
	P26_25 	= Train.RheostatResistors["R25-R26"]
	P25_24 	= Train.RheostatResistors["R24-R25"]
	P24_23 	= Train.RheostatResistors["R23-R24"]
	P23_22	= Train.RheostatResistors["R22-R23"]
	P22_21	= Train.RheostatResistors["R21-R22"]
	P21_20	= Train.RheostatResistors["R20-R21"]
	P20_19	= Train.RheostatResistors["R18-R20"]/3
	P19_18	= Train.RheostatResistors["R18-R20"]/3
	P18_17	= Train.RheostatResistors["R18-R20"]/3
	P17_16	= Train.RheostatResistors["L12-R26"]
	P16_15	= Train.RheostatResistors["L12-R26"]
	
	-- FIXME
	P28_29  = 0.10
	P29_30  = 0.50
	P30_31  = 0.50
	P31_L26 = 0.50
	
	P34_35	= 0.10
	P35_36	= 0.50
	P36_37	= 0.50
	P37_L24 = 0.50
end


-- Engines connected in series
function TRAIN_SYSTEM:Solve_PS(Train)
	-- Get rheostat controller positions
	local RK = Train.RheostatController
	
	-- Calculate rheostat 1 resistance
	R[1] = ((1e-9)*(P4_3)+(1e-9)*(P3_2)+(P4_3)*(P3_2))/(1e-9)
	R[2] = ((1e-9)*(P4_3)+(1e-9)*(P3_2)+(P4_3)*(P3_2))/(P4_3)
	R[3] = ((1e-9)*(P4_3)+(1e-9)*(P3_2)+(P4_3)*(P3_2))/(P3_2)
	R[4] = ((RK[1])^-1 + (R[2])^-1)^-1
	R[5] = ((R[4])*(P2_1)+(R[4])*(R[1])+(P2_1)*(R[1]))/(R[4])
	R[6] = ((R[4])*(P2_1)+(R[4])*(R[1])+(P2_1)*(R[1]))/(P2_1)
	R[7] = ((R[4])*(P2_1)+(R[4])*(R[1])+(P2_1)*(R[1]))/(R[1])
	R[8] = ((R[3])^-1 + (R[6])^-1)^-1
	R[9] = ((R[8])^-1 + (R[7]+R[5])^-1)^-1
	R[10] = ((RK[5])*(1e-9)+(RK[5])*(1e-9)+(1e-9)*(1e-9))/(RK[5])
	R[11] = ((RK[5])*(1e-9)+(RK[5])*(1e-9)+(1e-9)*(1e-9))/(1e-9)
	R[12] = ((RK[5])*(1e-9)+(RK[5])*(1e-9)+(1e-9)*(1e-9))/(1e-9)
	R[13] = ((R[11])^-1 + (RK[3]+R[9])^-1)^-1
	R[14] = ((R[10])^-1 + (P5_4)^-1)^-1
	R[15] = ((R[12])^-1 + (R[13]+R[14])^-1)^-1
	R[16] = ((RK[7])^-1 + (R[15]+P6_5)^-1)^-1
	R[17] = ((RK[9])^-1 + (R[16]+P7_6)^-1)^-1
	R[18] = ((RK[11])^-1 + (R[17]+P8_7)^-1)^-1
	R[19] = ((RK[13])^-1 + (R[18]+P9_8)^-1)^-1
	R[20] = ((RK[17])*(P13_12)+(RK[17])*(P12_11+P11_10)+(P13_12)*(P12_11+P11_10))/(RK[17])
	R[21] = ((RK[17])*(P13_12)+(RK[17])*(P12_11+P11_10)+(P13_12)*(P12_11+P11_10))/(P13_12)
	R[22] = ((RK[17])*(P13_12)+(RK[17])*(P12_11+P11_10)+(P13_12)*(P12_11+P11_10))/(P12_11+P11_10)
	R[23] = ((RK[19])^-1 + (R[22])^-1)^-1
	R[24] = ((1e-9)^-1 + (R[21])^-1)^-1
	R[25] = ((RK[15])*(R[24])+(RK[15])*(R[23])+(R[24])*(R[23]))/(RK[15])
	R[26] = ((RK[15])*(R[24])+(RK[15])*(R[23])+(R[24])*(R[23]))/(R[24])
	R[27] = ((RK[15])*(R[24])+(RK[15])*(R[23])+(R[24])*(R[23]))/(R[23])
	R[28] = ((R[27])^-1 + (R[19]+P10_9)^-1)^-1
	R[29] = ((R[25])^-1 + (R[20])^-1)^-1
	R[30] = ((R[26])^-1 + (R[28]+R[29])^-1)^-1
	local R1 = R[30]
	
	-- Calculate rheostat 2 resistance
	R[1] = ((RK[12])*(P23_22)+(RK[12])*(P22_21)+(P23_22)*(P22_21))/(RK[12])
	R[2] = ((RK[12])*(P23_22)+(RK[12])*(P22_21)+(P23_22)*(P22_21))/(P23_22)
	R[3] = ((RK[12])*(P23_22)+(RK[12])*(P22_21)+(P23_22)*(P22_21))/(P22_21)
	R[4] = ((RK[14])^-1 + (R[3])^-1)^-1
	R[5] = ((RK[10])^-1 + (R[2])^-1)^-1
	R[6] = ((R[1])*(R[5])+(R[1])*(P21_20)+(R[5])*(P21_20))/(R[1])
	R[7] = ((R[1])*(R[5])+(R[1])*(P21_20)+(R[5])*(P21_20))/(R[5])
	R[8] = ((R[1])*(R[5])+(R[1])*(P21_20)+(R[5])*(P21_20))/(P21_20)
	R[9] = ((RK[8])^-1 + (R[6])^-1)^-1
	R[10] = ((R[8])^-1 + (R[4])^-1)^-1
	R[11] = ((RK[6])*(1e-9)+(RK[6])*(1e-9)+(1e-9)*(1e-9))/(RK[6])
	R[12] = ((RK[6])*(1e-9)+(RK[6])*(1e-9)+(1e-9)*(1e-9))/(1e-9)
	R[13] = ((RK[6])*(1e-9)+(RK[6])*(1e-9)+(1e-9)*(1e-9))/(1e-9)
	R[14] = ((R[11])^-1 + (P19_18)^-1)^-1
	R[15] = ((R[7])*(R[10])+(R[7])*(P26_25+P25_24+P24_23)+(R[10])*(P26_25+P25_24+P24_23))/(R[7])
	R[16] = ((R[7])*(R[10])+(R[7])*(P26_25+P25_24+P24_23)+(R[10])*(P26_25+P25_24+P24_23))/(R[10])
	R[17] = ((R[7])*(R[10])+(R[7])*(P26_25+P25_24+P24_23)+(R[10])*(P26_25+P25_24+P24_23))/(P26_25+P25_24+P24_23)
	R[18] = ((R[17])^-1 + (R[9])^-1)^-1
	R[19] = ((R[15])^-1 + (RK[16]+RK[18])^-1)^-1
	R[20] = ((R[12])*(R[14])+(R[12])*(P18_17+P17_16)+(R[14])*(P18_17+P17_16))/(R[12])
	R[21] = ((R[12])*(R[14])+(R[12])*(P18_17+P17_16)+(R[14])*(P18_17+P17_16))/(R[14])
	R[22] = ((R[12])*(R[14])+(R[12])*(P18_17+P17_16)+(R[14])*(P18_17+P17_16))/(P18_17+P17_16)
	R[23] = ((R[13])^-1 + (R[22])^-1)^-1
	R[24] = ((R[21])^-1 + (RK[4]+RK[2])^-1)^-1
	R[25] = ((R[18])*(R[16])+(R[18])*(P20_19)+(R[16])*(P20_19))/(R[18])
	R[26] = ((R[18])*(R[16])+(R[18])*(P20_19)+(R[16])*(P20_19))/(R[16])
	R[27] = ((R[18])*(R[16])+(R[18])*(P20_19)+(R[16])*(P20_19))/(P20_19)
	R[28] = ((R[27])^-1 + (R[19])^-1)^-1
	R[29] = ((R[26])^-1 + (R[23])^-1)^-1
	R[30] = ((R[24])*(R[20])+(R[24])*(P16_15)+(R[20])*(P16_15))/(R[24])
	R[31] = ((R[24])*(R[20])+(R[24])*(P16_15)+(R[20])*(P16_15))/(R[20])
	R[32] = ((R[24])*(R[20])+(R[24])*(P16_15)+(R[20])*(P16_15))/(P16_15)
	R[33] = ((R[29])^-1 + (R[32])^-1)^-1
	R[34] = ((R[33])^-1 + (R[31]+R[30])^-1)^-1
	R[35] = ((R[28])^-1 + (R[25]+R[34])^-1)^-1
	local R2 = R1 --R[35]
	
	-- Store resistances of two blocks
	self.Block1Resistance = R1
	self.Block2Resistance = R2
end



-- Engines connected in parallel
function TRAIN_SYSTEM:Solve_PP(Train)
	-- Get rheostat controller positions
	local RK = Train.RheostatController
	
	-- Calculate rheostat 1 resistance
	R[1] = ((1e-9)^-1 + (RK[15])^-1)^-1
	R[2] = ((RK[17])^-1 + (RK[19]+P13_12)^-1)^-1
	R[3] = ((1e-9)^-1 + (R[2]+P12_11+P11_10)^-1)^-1
	R[4] = ((RK[13])^-1 + (R[3]+P10_9+R[1])^-1)^-1
	R[5] = ((RK[11])^-1 + (R[4]+P9_8)^-1)^-1
	R[6] = ((RK[9])^-1 + (R[5]+P8_7)^-1)^-1
	R[7] = ((R[6]+P7_6)^-1 + (RK[7])^-1)^-1
	R[8] = ((RK[1])*(P3_2)+(RK[1])*(P2_1+P14)+(P3_2)*(P2_1+P14))/(RK[1])
	R[9] = ((RK[1])*(P3_2)+(RK[1])*(P2_1+P14)+(P3_2)*(P2_1+P14))/(P3_2)
	R[10] = ((RK[1])*(P3_2)+(RK[1])*(P2_1+P14)+(P3_2)*(P2_1+P14))/(P2_1+P14)
	R[11] = ((R[10])^-1 + (1e-9)^-1)^-1
	R[12] = ((R[7]+P6_5)*(1e-9)+(R[7]+P6_5)*(P5_4)+(1e-9)*(P5_4))/(R[7]+P6_5)
	R[13] = ((R[7]+P6_5)*(1e-9)+(R[7]+P6_5)*(P5_4)+(1e-9)*(P5_4))/(1e-9)
	R[14] = ((R[7]+P6_5)*(1e-9)+(R[7]+P6_5)*(P5_4)+(1e-9)*(P5_4))/(P5_4)
	R[15] = ((R[14])^-1 + (RK[5])^-1)^-1
	R[16] = ((1e-9)^-1 + (R[12])^-1)^-1
	R[17] = ((R[9])*(R[11])+(R[9])*(RK[3])+(R[11])*(RK[3]))/(R[9])
	R[18] = ((R[9])*(R[11])+(R[9])*(RK[3])+(R[11])*(RK[3]))/(R[11])
	R[19] = ((R[9])*(R[11])+(R[9])*(RK[3])+(R[11])*(RK[3]))/(RK[3])
	R[20] = ((R[8])^-1 + (R[19])^-1)^-1
	R[21] = ((R[18])^-1 + (R[15])^-1)^-1
	R[22] = ((R[16])*(R[20])+(R[16])*(R[21])+(R[20])*(R[21]))/(R[16])
	R[23] = ((R[16])*(R[20])+(R[16])*(R[21])+(R[20])*(R[21]))/(R[20])
	R[24] = ((R[16])*(R[20])+(R[16])*(R[21])+(R[20])*(R[21]))/(R[21])
	R[25] = ((R[13])^-1 + (R[23])^-1)^-1
	R[26] = ((R[17])^-1 + (R[22])^-1)^-1
	R[27] = ((R[24])^-1 + (P4_3)^-1)^-1
	R[28] = ((R[26])^-1 + (R[25]+R[27])^-1)^-1
	local R1 = R[28]
	
	-- Calculate rheostat 2 resistance
	R[1] = ((1e-9)^-1 + (RK[16])^-1)^-1
	R[2] = ((1e-9)^-1 + (RK[18]+P26_25+P25_24)^-1)^-1
	R[3] = ((RK[14])^-1 + (R[1]+P24_23+R[2])^-1)^-1
	R[4] = ((RK[12])^-1 + (R[3]+P23_22)^-1)^-1
	R[5] = ((RK[10])^-1 + (R[4]+P22_21)^-1)^-1
	R[6] = ((RK[8])^-1 + (R[5]+P21_20)^-1)^-1
	R[7] = ((RK[6])*(1e-9)+(RK[6])*(1e-9)+(1e-9)*(1e-9))/(RK[6])
	R[8] = ((RK[6])*(1e-9)+(RK[6])*(1e-9)+(1e-9)*(1e-9))/(1e-9)
	R[9] = ((RK[6])*(1e-9)+(RK[6])*(1e-9)+(1e-9)*(1e-9))/(1e-9)
	R[10] = ((R[6]+P20_19)^-1 + (R[9])^-1)^-1
	R[11] = ((R[7])^-1 + (P19_18)^-1)^-1
	R[12] = ((R[8])^-1 + (R[10]+R[11])^-1)^-1
	R[13] = ((R[12]+P18_17+P17_16)*(RK[2])+(R[12]+P18_17+P17_16)*(P16_15)+(RK[2])*(P16_15))/(R[12]+P18_17+P17_16)
	R[14] = ((R[12]+P18_17+P17_16)*(RK[2])+(R[12]+P18_17+P17_16)*(P16_15)+(RK[2])*(P16_15))/(RK[2])
	R[15] = ((R[12]+P18_17+P17_16)*(RK[2])+(R[12]+P18_17+P17_16)*(P16_15)+(RK[2])*(P16_15))/(P16_15)
	R[16] = ((R[15])^-1 + (RK[4])^-1)^-1
	R[17] = ((R[16])^-1 + (R[14]+R[13])^-1)^-1
	local R2 = R1--R[17]
	
	-- Store resistances of two blocks
	self.Block1Resistance = R1
	self.Block2Resistance = R2
end



-- Shunt resistances
function TRAIN_SYSTEM:Solve_Shunt(Train)
	-- Get rheostat controller positions
	local RK = Train.RheostatController
	
	-- Calculate rheostat 1 resistance
	R[1] = ((P31_L26)^-1 + (RK[21])^-1)^-1
	R[2] = ((RK[23])^-1 + (P30_31+R[1])^-1)^-1
	R[3] = ((P29_30+R[2])^-1 + (RK[25])^-1)^-1
	local R1 = P28_29+R[3]
	
	-- Calculate rheostat 2 resistance
	local R = {}
	R[1] = ((P31_L26)^-1 + (RK[22])^-1)^-1
	R[2] = ((RK[24])^-1 + (P30_31+R[1])^-1)^-1
	R[3] = ((P29_30+R[2])^-1 + (RK[26])^-1)^-1
	local R2 = P28_29+R[3]
	
	-- Store resistances of two blocks
	self.Shunt1Resistance = R1
	self.Shunt2Resistance = R2
end