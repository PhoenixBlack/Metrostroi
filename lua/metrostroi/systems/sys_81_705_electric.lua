--------------------------------------------------------------------------------
-- Электрические цепи 81-704/705 (Е, Еж, Ем)
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("81_705_Electric")


function TRAIN_SYSTEM:Initialize()
	self.Main750V = 0.0
	self.Aux750V = 0.0
	self.Power750V = 0.0
	self.Aux80V = 0.0
	
	-- Контакторы переключения
	self.Train:LoadSystem("Tp","Relay",{ open_time = 0.10 })
	self.Train:LoadSystem("Tpb","Relay",{ open_time = 0.10 })
	self.Train:LoadSystem("Ts","Relay",{ close_time = 0.10 })
	self.Train:LoadSystem("Tb","Relay",{ close_time = 0.10 })
	
	-- Resistances
	self.Block1Resistance = 0.0
	self.Block2Resistance = 0.0
	self.Shunt1Resistance = 0.0
	self.Shunt2Resistance = 0.0
	
	-- Electric network info
	self.Vs 	= 0.0
	self.U13 	= 0.0
	self.U24 	= 0.0
	self.VR1 	= 0.0
	self.VR2 	= 0.0
	self.I13 	= 0.0
	self.I24 	= 0.0
	self.Itotal	= 0.0
end


function TRAIN_SYSTEM:Inputs()
	return { }
end

function TRAIN_SYSTEM:Outputs()
	return { "Vs", "U13", "U24", "VR1", "VR2", "I13", "I24", "Itotal" }
end


function TRAIN_SYSTEM:TriggerInput(name,value)
	--[[if name == "ResetRPL" then
		self.Train:PlayOnce("switch",true)
		self.Train.RPL:TriggerInput("Close",1.0)
		self.Train.RP1_3:TriggerInput("Close",1.0)
		self.Train.RP2_4:TriggerInput("Close",1.0)
	end]]--
end



--------------------------------------------------------------------------------
function TRAIN_SYSTEM:Think()
	local Train = self.Train
	
	----------------------------------------------------------------------------
	-- Вспомагательные цепи
	self.Aux750V = 750--Train.TR.Main750V * self.Train.PNB_1250_1.Value * self.Train.PNB_1250_2.Value * Train.KVC.Value		
	-- Питание вспомагательных цепей 80V
	self.Aux80V = 80 --math.max(Train.BPSN.Output80V * self.Train.VB.Value, Train.Battery.Voltage)
	-- Вывод питания на вагоны
	if self.Aux80V > 70.0 
	then Train:WriteTrainWire(9,1)
	else Train:WriteTrainWire(9,0)
	end
	
	
	
	----------------------------------------------------------------------------
	-- Главные электрические цепи
	self.Main750V = Train.TR.Main750V * Train.PNB_1250_1.Value
	
	
	
	
	----------------------------------------------------------------------------
	-- Внешнее напряжение силовых цепей
	self.Power750V = self.Main750V * Train.GV.Value * Train.LK1.Value	
	-- Реле РПЛ
	self.Power750V = self.Power750V * Train.RPL.Value
	
	-- Ослабление резистором Л1-Л2
	self.ExtraResistance = (1-Train.LK2.Value) * Train.RheostatResistors["L4-L2"]
	
	-- Вычисление сопротивления в резисторах реостатного контроллера (calculate rheostat resistances)
	self:InitializeResistances(Train)
	self:Solve_Shunt(Train)
	if (Train.Ts.Value == 1.0) or (Train.Tb.Value == 1.0)
	then self:Solve_PS(Train)
	else self:Solve_PP(Train)
	end
	
	-- Вычисление электросети (calculate electric power network)
	local V = self:Solve_PowerNetwork(Train)
	
	-- Output interesting variables
	self.Vs 	= V[1] - V[2]
	self.U13 	= V[2] - V[4]
	self.U24 	= V[6] - V[8]
	self.VR1 	= V[4] - V[5]
	self.VR2 	= V[8] - V[0]
	self.I13 	= (V[3] - V[4])/Train.Engines.Rw
	self.I24 	= (V[7] - V[8])/Train.Engines.Rw
	self.Itotal	= (V[1] - V[2])/(1e-9 + self.ExtraResistance)--self.I13 + self.I24
	self:TriggerOutput("Vs", 	self.Vs)
	self:TriggerOutput("U13",	self.U13)
	self:TriggerOutput("U24",	self.U24)
	self:TriggerOutput("VR1",	self.VR1)
	self:TriggerOutput("VR2",	self.VR2)
	self:TriggerOutput("I13",	self.I13)
	self:TriggerOutput("I24",	self.I24)
	self:TriggerOutput("Itotal",self.Itotal)
	
	self:TriggerOutput("Rs1",self.Shunt1Resistance)
	self:TriggerOutput("Rs2",self.Shunt2Resistance)
	self:TriggerOutput("R1",self.Block1Resistance)
	self:TriggerOutput("R2",self.Block2Resistance)
	
	
	
	
	----------------------------------------------------------------------------
	-- Комутация напряжения между поездными проводами и реле
	local X1 = Train:ReadTrainWire(1)
	local X2 = Train:ReadTrainWire(3)
	local X3 = Train:ReadTrainWire(2)
	local T = Train:ReadTrainWire(6)
	local F = Train:ReadTrainWire(4)
	local R = Train:ReadTrainWire(5)
	local X = Train:ReadTrainWire(20)
	
	-- Reverser
	if F > 0.5 then Train.RR:TriggerInput("Open",1.0) end
	if R > 0.5 then Train.RR:TriggerInput("Close",1.0) end
	
	-- Разбор
	if (X < 0.5) and ((Train.LK3.Value == 1.0) or (Train.LK4.Value == 1.0)) then
		Train.PneumaticNo1:TriggerInput("Open",1.0)
		Train.PneumaticNo2:TriggerInput("Open",1.0)
		
		Train.LK2:TriggerInput("Open",1.0)
		Train.KSH1:TriggerInput("Open",1.0)
		Train.KSH2:TriggerInput("Open",1.0)
		Train.KSH3:TriggerInput("Open",1.0)
		Train.KSH4:TriggerInput("Open",1.0)		
		
		-- Timed closing of the LK2 relay
		Train.RV2:TriggerInput("Close",1.0)	
	end
	if (Train.RV2.Value == 1.0) then
		Train.LK1:TriggerInput("Open",1.0)
		Train.LK3:TriggerInput("Open",1.0)
		Train.LK4:TriggerInput("Open",1.0)
		Train.RV2:TriggerInput("Open",1.0)	
	end
	
	-- Сбор на ход
	if (T < 0.5) and (X > 0.5) then
		Train.PneumaticNo1:TriggerInput("Open",1.0)
		Train.PneumaticNo2:TriggerInput("Open",1.0)
		
		Train.LK1:TriggerInput("Close",1.0)
		Train.LK2:TriggerInput("Close",1.0)
		Train.LK3:TriggerInput("Close",1.0)
		Train.LK4:TriggerInput("Close",1.0)
		Train.KSH1:TriggerInput("Close",1.0)
		Train.KSH2:TriggerInput("Close",1.0)
		Train.KSH3:TriggerInput("Close",1.0)
		Train.KSH4:TriggerInput("Close",1.0)

		-- Сбор последовательной схемы
		if (Train.Tp.Value == 0.0) or (X3 < 0.5) then
			Train.Tp:TriggerInput("Open",1.0)
			Train.Tpb:TriggerInput("Open",1.0)
			Train.Tb:TriggerInput("Open",1.0)
			Train.Ts:TriggerInput("Close",1.0)
		end
	end
	
	-- Сбор паралельной схемы
	if (Train.RheostatController.Position > 17.5) and (X3 > 0.5) and (T < 0.5) then
		Train.Tp:TriggerInput("Close",1.0)
		Train.Tpb:TriggerInput("Close",1.0)
		Train.Tb:TriggerInput("Open",1.0)
		Train.Ts:TriggerInput("Open",1.0)
	end
	
	-- Сбор на тормоз
	if (T > 0.5) and (X > 0.5) then
		Train.LK1:TriggerInput("Open",1.0)
		Train.LK2:TriggerInput("Close",1.0)
		Train.LK3:TriggerInput("Close",1.0)
		Train.LK4:TriggerInput("Close",1.0)

		Train.KSH1:TriggerInput("Open",1.0)
		Train.KSH2:TriggerInput("Open",1.0)
		Train.KSH3:TriggerInput("Open",1.0)
		Train.KSH4:TriggerInput("Open",1.0)

		-- Сбор последовательной схемы
		Train.Tp:TriggerInput("Close",1.0)
		Train.Tpb:TriggerInput("Close",1.0)
		Train.Tb:TriggerInput("Close",1.0)
		Train.Ts:TriggerInput("Open",1.0)
	end
	
	
	
	
	----------------------------------------------------------------------------
	-- РУТ (реле управления тягой) operation
	self.RUTCurrent = self.I13 + self.I24
	self.RUTTarget = 260
	if math.abs(self.RUTCurrent) < self.RUTTarget then
		Train.RUT:TriggerInput("Close",1.0)
	else
		Train.RUT:TriggerInput("Open",1.0)
	end
	
	-- Rheostat controller operation
	if Train.RUT.Value == 1.0 then
		if (X < 0.5) then
			Train.RheostatController:TriggerInput("Down",1.0)
		elseif (X > 0.5) and (X1 < 0.5) then
			if (T < 0.5) then -- Drive
				if Train.Ts.Value == 1.0 then
					Train.RheostatController:TriggerInput("Up",1.0)
				else
					Train.RheostatController:TriggerInput("Down",1.0)
				end
			else -- Brake
				if (X2 > 0.5) then
					-- Вывод реостата
					if (self.PreviousT1A ~= true) and (T > 0.5) and (X2 > 0.5) then
						Train.RheostatController:TriggerInput("Up",1.0)
					end
				elseif (X3 > 0.5) then
					Train.RheostatController:TriggerInput("Up",1.0)
					if Train.RheostatController.Position > 12.5 then
						Train.PneumaticNo1:TriggerInput("Close",1.0)
					end
				end
			end
		end
	end
	self.PreviousT1A = (T > 0.5) and (X2 > 0.5)
	
	
	
	
	
	
	
	--[[if Train.LK1.Value == 0 then
		Train.RheostatController:TriggerInput("Down",1.0)
	elseif Train.KV.ControllerPosition == 2 then	
		if Train.Engine.RUTCurrent < 260 then
			Train.RheostatController:TriggerInput("Up",1.0)
		end	
	elseif Train.KV.ControllerPosition == 3 then
		if Train.RheostatController.Position > 17.5 then
			Train.T_Parallel:TriggerInput("Close",1.0)
		end
		if Train.Engine.RUTCurrent < 260 then
			if Train.T_Parallel.Value == 1.0 then
				Train.RheostatController:TriggerInput("Down",1.0)
			else
				Train.RheostatController:TriggerInput("Up",1.0)
			end
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
	end]]--
end









--------------------------------------------------------------------------------
-- Temporary variables for rheostat controller and shunting resistor calculations
--------------------------------------------------------------------------------
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


--------------------------------------------------------------------------------
-- Initialize all resistances
--------------------------------------------------------------------------------
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


--------------------------------------------------------------------------------
-- [MODEL] Engines connected in series
--------------------------------------------------------------------------------
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
	--[[R[1] = ((RK[12])*(P23_22)+(RK[12])*(P22_21)+(P23_22)*(P22_21))/(RK[12])
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
	R[35] = ((R[28])^-1 + (R[25]+R[34])^-1)^-1]]--
	local R2 = R1 --R[35]
	
	-- Store resistances of two blocks
	self.Block1Resistance = R1
	self.Block2Resistance = R2
end


--------------------------------------------------------------------------------
-- [MODEL] Engines connected in parallel
--------------------------------------------------------------------------------
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
	--[[R[1] = ((1e-9)^-1 + (RK[16])^-1)^-1
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
	R[17] = ((R[16])^-1 + (R[14]+R[13])^-1)^-1]]--
	local R2 = R1--R[17]
	
	-- Store resistances of two blocks
	self.Block1Resistance = R1
	self.Block2Resistance = R2
end


--------------------------------------------------------------------------------
-- Shunt resistances
--------------------------------------------------------------------------------
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





--------------------------------------------------------------------------------
-- [MODEL] Model of the power circuits of E-type trains
--------------------------------------------------------------------------------
local V = {}
function TRAIN_SYSTEM:Solve_PowerNetwork(Train)
	local U13 = -Train.Engines.E13
	local U24 = -Train.Engines.E24
	local Vp  = self.Power750V
	local Tp  = 1e-9 + 1e9*(1 - Train.Tp.Value)
	local Tpb = 1e-9 + 1e9*(1 - Train.Tpb.Value)
	local Tb  = 1e-9 + 1e9*(1 - Train.Tb.Value)
	local Ts  = 1e-9 + 1e9*(1 - Train.Ts.Value)
	local R1  = self.Block1Resistance + 1e9*(1-Train.LK3.Value) + 1e9*(1-Train.RP1_3.Value)
	local R2  = self.Block2Resistance + 1e9*(1-Train.LK4.Value) + 1e9*(1-Train.RP2_4.Value)
	local Rw  = Train.Engines.Rw
	local Rs  = 1e-9 + self.ExtraResistance

	-- Pre-calculate some things to speed it up
	local Rw2 = Rw^2
	local TpTpb = Tp * Tpb
	local TbTpb = Tb * Tpb
	local TpTs = Tp * Ts
	local TbTs = Tb * Ts
	local R1R2 = R1 * R2
	local RsRw2 = Rs * Rw2
	local RsRw = Rs * Rw

	-- Calculate potentials in the power network
	V[0] = 0
	V[1] = Vp
	V[2] = -((R1R2*Rs*Tp*U13 + R1*RsRw*Tp*U13 + R2*RsRw*Tp*U13 + R2*Rs*Tb*Tp*U13 + 
				RsRw*Tb*Tp*U13 + R1*RsRw*Tpb*U13 + R1*Rs*TpTpb*U13 + 
				RsRw*TpTpb*U13 + Rs*Tb*TpTpb*U13 + R1*RsRw*Ts*U13 + R2*RsRw*Ts*U13 + 
				R2*Rs*TbTs*U13 + RsRw*TbTs*U13 + R1*Rs*TpTs*U13 + R2*Rs*TpTs*U13 + 
				Rs*Tb*TpTs*U13 + RsRw*Tpb*Ts*U13 + Rs*TpTpb*Ts*U13 - R1R2*Rs*Tp*U24 + 
				R1*RsRw*Tpb*U24 + R1*Rs*TbTpb*U24 + RsRw*TbTpb*U24 + 
				Rs*Tb*TpTpb*U24 + R1*RsRw*Ts*U24 + R2*RsRw*Ts*U24 + R1*Rs*TbTs*U24 + 
				RsRw*TbTs*U24 + RsRw*Tpb*Ts*U24 + Rs*TbTpb*Ts*U24 - 
				2*R1R2*Rw*Tp*Vp - R1*Rw2*Tp*Vp - R2*Rw2*Tp*Vp - 
				R1R2*Tb*Tp*Vp - R1*Rw*Tb*Tp*Vp - R2*Rw*Tb*Tp*Vp - Rw2*Tb*Tp*Vp - 
				2*R1R2*Rw*Tpb*Vp - R1*Rw2*Tpb*Vp - R2*Rw2*Tpb*Vp - 
				R1R2*TbTpb*Vp - R1*Rw*TbTpb*Vp - R2*Rw*TbTpb*Vp - 
				Rw2*TbTpb*Vp - R1R2*TpTpb*Vp - R1*Rw*TpTpb*Vp - 
				R2*Rw*TpTpb*Vp - Rw2*TpTpb*Vp - R1*Tb*TpTpb*Vp - 
				R2*Tb*TpTpb*Vp - 2*Rw*Tb*TpTpb*Vp - 2*R1R2*Rw*Ts*Vp - 
				R1*Rw2*Ts*Vp - R2*Rw2*Ts*Vp - R1R2*TbTs*Vp - 
				R1*Rw*TbTs*Vp - R2*Rw*TbTs*Vp - Rw2*TbTs*Vp - R1R2*TpTs*Vp - 
				R1*Rw*TpTs*Vp - R2*Rw*TpTs*Vp - R1*Tb*TpTs*Vp - Rw*Tb*TpTs*Vp - 
				2*R2*Rw*Tpb*Ts*Vp - Rw2*Tpb*Ts*Vp - R2*TbTpb*Ts*Vp - 
				Rw*TbTpb*Ts*Vp - R2*TpTpb*Ts*Vp - Rw*TpTpb*Ts*Vp - Tb*TpTpb*Ts*Vp)/
			(2*R1R2*RsRw + R1*RsRw2 + R2*RsRw2 + R1R2*Rs*Tb + 
				R1*RsRw*Tb + R2*RsRw*Tb + RsRw2*Tb + R1R2*Rs*Tp + 
				2*R1R2*Rw*Tp + R1*RsRw*Tp + R2*RsRw*Tp + R1*Rw2*Tp + 
				R2*Rw2*Tp + R1R2*Tb*Tp + R2*Rs*Tb*Tp + R1*Rw*Tb*Tp + 
				R2*Rw*Tb*Tp + RsRw*Tb*Tp + Rw2*Tb*Tp + 2*R1R2*Rw*Tpb + 
				2*R1*RsRw*Tpb + R1*Rw2*Tpb + R2*Rw2*Tpb + 
				RsRw2*Tpb + R1R2*TbTpb + R1*Rs*TbTpb + R1*Rw*TbTpb + 
				R2*Rw*TbTpb + RsRw*TbTpb + Rw2*TbTpb + R1R2*TpTpb + 
				R1*Rs*TpTpb + R1*Rw*TpTpb + R2*Rw*TpTpb + RsRw*TpTpb + 
				Rw2*TpTpb + R1*Tb*TpTpb + R2*Tb*TpTpb + Rs*Tb*TpTpb + 
				2*Rw*Tb*TpTpb + 2*R1R2*Rw*Ts + 2*R1*RsRw*Ts + 2*R2*RsRw*Ts + 
				R1*Rw2*Ts + R2*Rw2*Ts + R1R2*TbTs + R1*Rs*TbTs + 
				R2*Rs*TbTs + R1*Rw*TbTs + R2*Rw*TbTs + 2*RsRw*TbTs + 
				Rw2*TbTs + R1R2*TpTs + R1*Rs*TpTs + R2*Rs*TpTs + 
				R1*Rw*TpTs + R2*Rw*TpTs + R1*Tb*TpTs + Rs*Tb*TpTs + Rw*Tb*TpTs + 
				2*R2*Rw*Tpb*Ts + 2*RsRw*Tpb*Ts + Rw2*Tpb*Ts + R2*TbTpb*Ts + 
				Rs*TbTpb*Ts + Rw*TbTpb*Ts + R2*TpTpb*Ts + Rs*TpTpb*Ts + 
				Rw*TpTpb*Ts + Tb*TpTpb*Ts))
				
	V[3] = -((-2*R1R2*RsRw*U13 - R1*RsRw2*U13 - R2*RsRw2*U13 - 
				R1R2*Rs*Tb*U13 - R1*RsRw*Tb*U13 - R2*RsRw*Tb*U13 - 
				RsRw2*Tb*U13 - 2*R1R2*Rw*Tp*U13 - R1*Rw2*Tp*U13 - 
				R2*Rw2*Tp*U13 - R1R2*Tb*Tp*U13 - R1*Rw*Tb*Tp*U13 - 
				R2*Rw*Tb*Tp*U13 - Rw2*Tb*Tp*U13 - 2*R1R2*Rw*Tpb*U13 - 
				R1*RsRw*Tpb*U13 - R1*Rw2*Tpb*U13 - R2*Rw2*Tpb*U13 - 
				RsRw2*Tpb*U13 - R1R2*TbTpb*U13 - R1*Rs*TbTpb*U13 - 
				R1*Rw*TbTpb*U13 - R2*Rw*TbTpb*U13 - RsRw*TbTpb*U13 - 
				Rw2*TbTpb*U13 - R1R2*TpTpb*U13 - R1*Rw*TpTpb*U13 - 
				R2*Rw*TpTpb*U13 - Rw2*TpTpb*U13 - R1*Tb*TpTpb*U13 - 
				R2*Tb*TpTpb*U13 - 2*Rw*Tb*TpTpb*U13 - 2*R1R2*Rw*Ts*U13 - 
				R1*RsRw*Ts*U13 - R2*RsRw*Ts*U13 - R1*Rw2*Ts*U13 - 
				R2*Rw2*Ts*U13 - R1R2*TbTs*U13 - R1*Rs*TbTs*U13 - 
				R1*Rw*TbTs*U13 - R2*Rw*TbTs*U13 - RsRw*TbTs*U13 - 
				Rw2*TbTs*U13 - R1R2*TpTs*U13 - R1*Rw*TpTs*U13 - 
				R2*Rw*TpTs*U13 - R1*Tb*TpTs*U13 - Rw*Tb*TpTs*U13 - 
				2*R2*Rw*Tpb*Ts*U13 - RsRw*Tpb*Ts*U13 - Rw2*Tpb*Ts*U13 - 
				R2*TbTpb*Ts*U13 - Rs*TbTpb*Ts*U13 - Rw*TbTpb*Ts*U13 - 
				R2*TpTpb*Ts*U13 - Rw*TpTpb*Ts*U13 - Tb*TpTpb*Ts*U13 - 
				R1R2*Rs*Tp*U24 + R1*RsRw*Tpb*U24 + R1*Rs*TbTpb*U24 + 
				RsRw*TbTpb*U24 + Rs*Tb*TpTpb*U24 + R1*RsRw*Ts*U24 + R2*RsRw*Ts*U24 + 
				R1*Rs*TbTs*U24 + RsRw*TbTs*U24 + RsRw*Tpb*Ts*U24 + Rs*TbTpb*Ts*U24 - 
				2*R1R2*Rw*Tp*Vp - R1*Rw2*Tp*Vp - R2*Rw2*Tp*Vp - 
				R1R2*Tb*Tp*Vp - R1*Rw*Tb*Tp*Vp - R2*Rw*Tb*Tp*Vp - Rw2*Tb*Tp*Vp - 
				2*R1R2*Rw*Tpb*Vp - R1*Rw2*Tpb*Vp - R2*Rw2*Tpb*Vp - 
				R1R2*TbTpb*Vp - R1*Rw*TbTpb*Vp - R2*Rw*TbTpb*Vp - 
				Rw2*TbTpb*Vp - R1R2*TpTpb*Vp - R1*Rw*TpTpb*Vp - 
				R2*Rw*TpTpb*Vp - Rw2*TpTpb*Vp - R1*Tb*TpTpb*Vp - 
				R2*Tb*TpTpb*Vp - 2*Rw*Tb*TpTpb*Vp - 2*R1R2*Rw*Ts*Vp - 
				R1*Rw2*Ts*Vp - R2*Rw2*Ts*Vp - R1R2*TbTs*Vp - 
				R1*Rw*TbTs*Vp - R2*Rw*TbTs*Vp - Rw2*TbTs*Vp - R1R2*TpTs*Vp - 
				R1*Rw*TpTs*Vp - R2*Rw*TpTs*Vp - R1*Tb*TpTs*Vp - Rw*Tb*TpTs*Vp - 
				2*R2*Rw*Tpb*Ts*Vp - Rw2*Tpb*Ts*Vp - R2*TbTpb*Ts*Vp - 
				Rw*TbTpb*Ts*Vp - R2*TpTpb*Ts*Vp - Rw*TpTpb*Ts*Vp - Tb*TpTpb*Ts*Vp)/
			(2*R1R2*RsRw + R1*RsRw2 + R2*RsRw2 + R1R2*Rs*Tb + 
				R1*RsRw*Tb + R2*RsRw*Tb + RsRw2*Tb + R1R2*Rs*Tp + 
				2*R1R2*Rw*Tp + R1*RsRw*Tp + R2*RsRw*Tp + R1*Rw2*Tp + 
				R2*Rw2*Tp + R1R2*Tb*Tp + R2*Rs*Tb*Tp + R1*Rw*Tb*Tp + 
				R2*Rw*Tb*Tp + RsRw*Tb*Tp + Rw2*Tb*Tp + 2*R1R2*Rw*Tpb + 
				2*R1*RsRw*Tpb + R1*Rw2*Tpb + R2*Rw2*Tpb + 
				RsRw2*Tpb + R1R2*TbTpb + R1*Rs*TbTpb + R1*Rw*TbTpb + 
				R2*Rw*TbTpb + RsRw*TbTpb + Rw2*TbTpb + R1R2*TpTpb + 
				R1*Rs*TpTpb + R1*Rw*TpTpb + R2*Rw*TpTpb + RsRw*TpTpb + 
				Rw2*TpTpb + R1*Tb*TpTpb + R2*Tb*TpTpb + Rs*Tb*TpTpb + 
				2*Rw*Tb*TpTpb + 2*R1R2*Rw*Ts + 2*R1*RsRw*Ts + 2*R2*RsRw*Ts + 
				R1*Rw2*Ts + R2*Rw2*Ts + R1R2*TbTs + R1*Rs*TbTs + 
				R2*Rs*TbTs + R1*Rw*TbTs + R2*Rw*TbTs + 2*RsRw*TbTs + 
				Rw2*TbTs + R1R2*TpTs + R1*Rs*TpTs + R2*Rs*TpTs + 
				R1*Rw*TpTs + R2*Rw*TpTs + R1*Tb*TpTs + Rs*Tb*TpTs + Rw*Tb*TpTs + 
				2*R2*Rw*Tpb*Ts + 2*RsRw*Tpb*Ts + Rw2*Tpb*Ts + R2*TbTpb*Ts + 
				Rs*TbTpb*Ts + Rw*TbTpb*Ts + R2*TpTpb*Ts + Rs*TpTpb*Ts + 
				Rw*TpTpb*Ts + Tb*TpTpb*Ts))
				
	V[4] = -((-(R1R2*RsRw*U13) - R1R2*Rs*Tb*U13 - R1*RsRw*Tb*U13 - 
				R1R2*Rw*Tp*U13 - R1R2*Tb*Tp*U13 - R1*Rw*Tb*Tp*U13 - R1R2*Rw*Tpb*U13 - 
				R1R2*TbTpb*U13 - R1*Rs*TbTpb*U13 - R1*Rw*TbTpb*U13 - 
				R1R2*TpTpb*U13 - R2*Rw*TpTpb*U13 - R1*Tb*TpTpb*U13 - 
				R2*Tb*TpTpb*U13 - Rw*Tb*TpTpb*U13 - R1R2*Rw*Ts*U13 - R1R2*TbTs*U13 - 
				R1*Rs*TbTs*U13 - R1*Rw*TbTs*U13 - R1R2*TpTs*U13 - R1*Tb*TpTs*U13 - 
				R2*Rw*Tpb*Ts*U13 - R2*TbTpb*Ts*U13 - Rs*TbTpb*Ts*U13 - 
				Rw*TbTpb*Ts*U13 - R2*TpTpb*Ts*U13 - Tb*TpTpb*Ts*U13 - 
				R1R2*RsRw*U24 - R1R2*Rs*Tp*U24 - R1R2*Rw*Tp*U24 - R1R2*Rw*Tpb*U24 + 
				R1*Rs*TbTpb*U24 + RsRw*TbTpb*U24 + Rs*Tb*TpTpb*U24 + 
				Rw*Tb*TpTpb*U24 - R1R2*Rw*Ts*U24 + R1*Rs*TbTs*U24 - R2*Rw*Tpb*Ts*U24 + 
				Rs*TbTpb*Ts*U24 - R1R2*Rw*Tp*Vp - R1R2*Tb*Tp*Vp - R1*Rw*Tb*Tp*Vp - 
				2*R1R2*Rw*Tpb*Vp - R2*Rw2*Tpb*Vp - R1R2*TbTpb*Vp - 
				R1*Rw*TbTpb*Vp - R2*Rw*TbTpb*Vp - Rw2*TbTpb*Vp - 
				R1R2*TpTpb*Vp - R2*Rw*TpTpb*Vp - R1*Tb*TpTpb*Vp - R2*Tb*TpTpb*Vp - 
				Rw*Tb*TpTpb*Vp - 2*R1R2*Rw*Ts*Vp - R1R2*TbTs*Vp - R1*Rw*TbTs*Vp - 
				R1R2*TpTs*Vp - R1*Tb*TpTs*Vp - 2*R2*Rw*Tpb*Ts*Vp - R2*TbTpb*Ts*Vp - 
				Rw*TbTpb*Ts*Vp - R2*TpTpb*Ts*Vp - Tb*TpTpb*Ts*Vp)/
			(2*R1R2*RsRw + R1*RsRw2 + R2*RsRw2 + R1R2*Rs*Tb + 
				R1*RsRw*Tb + R2*RsRw*Tb + RsRw2*Tb + R1R2*Rs*Tp + 
				2*R1R2*Rw*Tp + R1*RsRw*Tp + R2*RsRw*Tp + R1*Rw2*Tp + 
				R2*Rw2*Tp + R1R2*Tb*Tp + R2*Rs*Tb*Tp + R1*Rw*Tb*Tp + 
				R2*Rw*Tb*Tp + RsRw*Tb*Tp + Rw2*Tb*Tp + 2*R1R2*Rw*Tpb + 
				2*R1*RsRw*Tpb + R1*Rw2*Tpb + R2*Rw2*Tpb + 
				RsRw2*Tpb + R1R2*TbTpb + R1*Rs*TbTpb + R1*Rw*TbTpb + 
				R2*Rw*TbTpb + RsRw*TbTpb + Rw2*TbTpb + R1R2*TpTpb + 
				R1*Rs*TpTpb + R1*Rw*TpTpb + R2*Rw*TpTpb + RsRw*TpTpb + 
				Rw2*TpTpb + R1*Tb*TpTpb + R2*Tb*TpTpb + Rs*Tb*TpTpb + 
				2*Rw*Tb*TpTpb + 2*R1R2*Rw*Ts + 2*R1*RsRw*Ts + 2*R2*RsRw*Ts + 
				R1*Rw2*Ts + R2*Rw2*Ts + R1R2*TbTs + R1*Rs*TbTs + 
				R2*Rs*TbTs + R1*Rw*TbTs + R2*Rw*TbTs + 2*RsRw*TbTs + 
				Rw2*TbTs + R1R2*TpTs + R1*Rs*TpTs + R2*Rs*TpTs + 
				R1*Rw*TpTs + R2*Rw*TpTs + R1*Tb*TpTs + Rs*Tb*TpTs + Rw*Tb*TpTs + 
				2*R2*Rw*Tpb*Ts + 2*RsRw*Tpb*Ts + Rw2*Tpb*Ts + R2*TbTpb*Ts + 
				Rs*TbTpb*Ts + Rw*TbTpb*Ts + R2*TpTpb*Ts + Rs*TpTpb*Ts + 
				Rw*TpTpb*Ts + Tb*TpTpb*Ts))
				
	V[5] = -((R1*RsRw*Tpb*U13 - R1R2*TpTpb*U13 - R2*Rw*TpTpb*U13 - 
				R2*Tb*TpTpb*U13 - Rw*Tb*TpTpb*U13 - R2*Rw*Tpb*Ts*U13 - 
				R2*TbTpb*Ts*U13 - Rs*TbTpb*Ts*U13 - Rw*TbTpb*Ts*U13 - 
				R2*TpTpb*Ts*U13 - Tb*TpTpb*Ts*U13 + R1*RsRw*Tpb*U24 + 
				R1*Rs*TbTpb*U24 + RsRw*TbTpb*U24 + R1R2*TpTpb*U24 + 
				R1*Rs*TpTpb*U24 + R1*Rw*TpTpb*U24 + R1*Tb*TpTpb*U24 + 
				Rs*Tb*TpTpb*U24 + Rw*Tb*TpTpb*U24 - R2*Rw*Tpb*Ts*U24 + 
				Rs*TbTpb*Ts*U24 - 2*R1R2*Rw*Tpb*Vp - R1*Rw2*Tpb*Vp - 
				R2*Rw2*Tpb*Vp - R1R2*TbTpb*Vp - R1*Rw*TbTpb*Vp - 
				R2*Rw*TbTpb*Vp - Rw2*TbTpb*Vp - R1R2*TpTpb*Vp - 
				R2*Rw*TpTpb*Vp - R2*Tb*TpTpb*Vp - Rw*Tb*TpTpb*Vp - 2*R2*Rw*Tpb*Ts*Vp - 
				R2*TbTpb*Ts*Vp - Rw*TbTpb*Ts*Vp - R2*TpTpb*Ts*Vp - Tb*TpTpb*Ts*Vp)/
			(2*R1R2*RsRw + R1*RsRw2 + R2*RsRw2 + R1R2*Rs*Tb + 
				R1*RsRw*Tb + R2*RsRw*Tb + RsRw2*Tb + R1R2*Rs*Tp + 
				2*R1R2*Rw*Tp + R1*RsRw*Tp + R2*RsRw*Tp + R1*Rw2*Tp + 
				R2*Rw2*Tp + R1R2*Tb*Tp + R2*Rs*Tb*Tp + R1*Rw*Tb*Tp + 
				R2*Rw*Tb*Tp + RsRw*Tb*Tp + Rw2*Tb*Tp + 2*R1R2*Rw*Tpb + 
				2*R1*RsRw*Tpb + R1*Rw2*Tpb + R2*Rw2*Tpb + 
				RsRw2*Tpb + R1R2*TbTpb + R1*Rs*TbTpb + R1*Rw*TbTpb + 
				R2*Rw*TbTpb + RsRw*TbTpb + Rw2*TbTpb + R1R2*TpTpb + 
				R1*Rs*TpTpb + R1*Rw*TpTpb + R2*Rw*TpTpb + RsRw*TpTpb + 
				Rw2*TpTpb + R1*Tb*TpTpb + R2*Tb*TpTpb + Rs*Tb*TpTpb + 
				2*Rw*Tb*TpTpb + 2*R1R2*Rw*Ts + 2*R1*RsRw*Ts + 2*R2*RsRw*Ts + 
				R1*Rw2*Ts + R2*Rw2*Ts + R1R2*TbTs + R1*Rs*TbTs + 
				R2*Rs*TbTs + R1*Rw*TbTs + R2*Rw*TbTs + 2*RsRw*TbTs + 
				Rw2*TbTs + R1R2*TpTs + R1*Rs*TpTs + R2*Rs*TpTs + 
				R1*Rw*TpTs + R2*Rw*TpTs + R1*Tb*TpTs + Rs*Tb*TpTs + Rw*Tb*TpTs + 
				2*R2*Rw*Tpb*Ts + 2*RsRw*Tpb*Ts + Rw2*Tpb*Ts + R2*TbTpb*Ts + 
				Rs*TbTpb*Ts + Rw*TbTpb*Ts + R2*TpTpb*Ts + Rs*TpTpb*Ts + 
				Rw*TpTpb*Ts + Tb*TpTpb*Ts))
				
	V[6] = -((R1*RsRw*Tpb*U13 - R1R2*TpTpb*U13 - R2*Rw*TpTpb*U13 - 
				R2*Tb*TpTpb*U13 - Rw*Tb*TpTpb*U13 + R1*RsRw*Ts*U13 + R2*RsRw*Ts*U13 + 
				R2*Rs*TbTs*U13 + RsRw*TbTs*U13 - R1R2*TpTs*U13 + RsRw*Tpb*Ts*U13 - 
				R2*TpTpb*Ts*U13 + R1*RsRw*Tpb*U24 + R1*Rs*TbTpb*U24 + 
				RsRw*TbTpb*U24 + R1R2*TpTpb*U24 + R1*Rs*TpTpb*U24 + 
				R1*Rw*TpTpb*U24 + R1*Tb*TpTpb*U24 + Rs*Tb*TpTpb*U24 + 
				Rw*Tb*TpTpb*U24 + R1*RsRw*Ts*U24 + R2*RsRw*Ts*U24 + R1*Rs*TbTs*U24 + 
				RsRw*TbTs*U24 + R1R2*TpTs*U24 + R1*Rs*TpTs*U24 + R2*Rs*TpTs*U24 + 
				R1*Rw*TpTs*U24 + R2*Rw*TpTs*U24 + R1*Tb*TpTs*U24 + Rs*Tb*TpTs*U24 + 
				Rw*Tb*TpTs*U24 + RsRw*Tpb*Ts*U24 + Rs*TbTpb*Ts*U24 + 
				R2*TpTpb*Ts*U24 + Rs*TpTpb*Ts*U24 + Rw*TpTpb*Ts*U24 + 
				Tb*TpTpb*Ts*U24 - 2*R1R2*Rw*Tpb*Vp - R1*Rw2*Tpb*Vp - 
				R2*Rw2*Tpb*Vp - R1R2*TbTpb*Vp - R1*Rw*TbTpb*Vp - 
				R2*Rw*TbTpb*Vp - Rw2*TbTpb*Vp - R1R2*TpTpb*Vp - 
				R2*Rw*TpTpb*Vp - R2*Tb*TpTpb*Vp - Rw*Tb*TpTpb*Vp - 2*R1R2*Rw*Ts*Vp - 
				R1*Rw2*Ts*Vp - R2*Rw2*Ts*Vp - R1R2*TbTs*Vp - 
				R1*Rw*TbTs*Vp - R2*Rw*TbTs*Vp - Rw2*TbTs*Vp - R1R2*TpTs*Vp - 
				2*R2*Rw*Tpb*Ts*Vp - Rw2*Tpb*Ts*Vp - R2*TbTpb*Ts*Vp - 
				Rw*TbTpb*Ts*Vp - R2*TpTpb*Ts*Vp)/
			(2*R1R2*RsRw + R1*RsRw2 + R2*RsRw2 + R1R2*Rs*Tb + 
				R1*RsRw*Tb + R2*RsRw*Tb + RsRw2*Tb + R1R2*Rs*Tp + 
				2*R1R2*Rw*Tp + R1*RsRw*Tp + R2*RsRw*Tp + R1*Rw2*Tp + 
				R2*Rw2*Tp + R1R2*Tb*Tp + R2*Rs*Tb*Tp + R1*Rw*Tb*Tp + 
				R2*Rw*Tb*Tp + RsRw*Tb*Tp + Rw2*Tb*Tp + 2*R1R2*Rw*Tpb + 
				2*R1*RsRw*Tpb + R1*Rw2*Tpb + R2*Rw2*Tpb + 
				RsRw2*Tpb + R1R2*TbTpb + R1*Rs*TbTpb + R1*Rw*TbTpb + 
				R2*Rw*TbTpb + RsRw*TbTpb + Rw2*TbTpb + R1R2*TpTpb + 
				R1*Rs*TpTpb + R1*Rw*TpTpb + R2*Rw*TpTpb + RsRw*TpTpb + 
				Rw2*TpTpb + R1*Tb*TpTpb + R2*Tb*TpTpb + Rs*Tb*TpTpb + 
				2*Rw*Tb*TpTpb + 2*R1R2*Rw*Ts + 2*R1*RsRw*Ts + 2*R2*RsRw*Ts + 
				R1*Rw2*Ts + R2*Rw2*Ts + R1R2*TbTs + R1*Rs*TbTs + 
				R2*Rs*TbTs + R1*Rw*TbTs + R2*Rw*TbTs + 2*RsRw*TbTs + 
				Rw2*TbTs + R1R2*TpTs + R1*Rs*TpTs + R2*Rs*TpTs + 
				R1*Rw*TpTs + R2*Rw*TpTs + R1*Tb*TpTs + Rs*Tb*TpTs + Rw*Tb*TpTs + 
				2*R2*Rw*Tpb*Ts + 2*RsRw*Tpb*Ts + Rw2*Tpb*Ts + R2*TbTpb*Ts + 
				Rs*TbTpb*Ts + Rw*TbTpb*Ts + R2*TpTpb*Ts + Rs*TpTpb*Ts + 
				Rw*TpTpb*Ts + Tb*TpTpb*Ts))
				
	V[7] = -((R1*RsRw*Tpb*U13 - R1R2*TpTpb*U13 - R2*Rw*TpTpb*U13 - 
				R2*Tb*TpTpb*U13 - Rw*Tb*TpTpb*U13 + R1*RsRw*Ts*U13 + R2*RsRw*Ts*U13 + 
				R2*Rs*TbTs*U13 + RsRw*TbTs*U13 - R1R2*TpTs*U13 + RsRw*Tpb*Ts*U13 - 
				R2*TpTpb*Ts*U13 - 2*R1R2*RsRw*U24 - R1*RsRw2*U24 - 
				R2*RsRw2*U24 - R1R2*Rs*Tb*U24 - R1*RsRw*Tb*U24 - 
				R2*RsRw*Tb*U24 - RsRw2*Tb*U24 - R1R2*Rs*Tp*U24 - 
				2*R1R2*Rw*Tp*U24 - R1*RsRw*Tp*U24 - R2*RsRw*Tp*U24 - 
				R1*Rw2*Tp*U24 - R2*Rw2*Tp*U24 - R1R2*Tb*Tp*U24 - 
				R2*Rs*Tb*Tp*U24 - R1*Rw*Tb*Tp*U24 - R2*Rw*Tb*Tp*U24 - RsRw*Tb*Tp*U24 - 
				Rw2*Tb*Tp*U24 - 2*R1R2*Rw*Tpb*U24 - R1*RsRw*Tpb*U24 - 
				R1*Rw2*Tpb*U24 - R2*Rw2*Tpb*U24 - 
				RsRw2*Tpb*U24 - R1R2*TbTpb*U24 - R1*Rw*TbTpb*U24 - 
				R2*Rw*TbTpb*U24 - Rw2*TbTpb*U24 - R2*Rw*TpTpb*U24 - 
				RsRw*TpTpb*U24 - Rw2*TpTpb*U24 - R2*Tb*TpTpb*U24 - 
				Rw*Tb*TpTpb*U24 - 2*R1R2*Rw*Ts*U24 - R1*RsRw*Ts*U24 - 
				R2*RsRw*Ts*U24 - R1*Rw2*Ts*U24 - R2*Rw2*Ts*U24 - 
				R1R2*TbTs*U24 - R2*Rs*TbTs*U24 - R1*Rw*TbTs*U24 - R2*Rw*TbTs*U24 - 
				RsRw*TbTs*U24 - Rw2*TbTs*U24 - 2*R2*Rw*Tpb*Ts*U24 - 
				RsRw*Tpb*Ts*U24 - Rw2*Tpb*Ts*U24 - R2*TbTpb*Ts*U24 - 
				Rw*TbTpb*Ts*U24 - 2*R1R2*Rw*Tpb*Vp - R1*Rw2*Tpb*Vp - 
				R2*Rw2*Tpb*Vp - R1R2*TbTpb*Vp - R1*Rw*TbTpb*Vp - 
				R2*Rw*TbTpb*Vp - Rw2*TbTpb*Vp - R1R2*TpTpb*Vp - 
				R2*Rw*TpTpb*Vp - R2*Tb*TpTpb*Vp - Rw*Tb*TpTpb*Vp - 2*R1R2*Rw*Ts*Vp - 
				R1*Rw2*Ts*Vp - R2*Rw2*Ts*Vp - R1R2*TbTs*Vp - 
				R1*Rw*TbTs*Vp - R2*Rw*TbTs*Vp - Rw2*TbTs*Vp - R1R2*TpTs*Vp - 
				2*R2*Rw*Tpb*Ts*Vp - Rw2*Tpb*Ts*Vp - R2*TbTpb*Ts*Vp - 
				Rw*TbTpb*Ts*Vp - R2*TpTpb*Ts*Vp)/
			(2*R1R2*RsRw + R1*RsRw2 + R2*RsRw2 + R1R2*Rs*Tb + 
				R1*RsRw*Tb + R2*RsRw*Tb + RsRw2*Tb + R1R2*Rs*Tp + 
				2*R1R2*Rw*Tp + R1*RsRw*Tp + R2*RsRw*Tp + R1*Rw2*Tp + 
				R2*Rw2*Tp + R1R2*Tb*Tp + R2*Rs*Tb*Tp + R1*Rw*Tb*Tp + 
				R2*Rw*Tb*Tp + RsRw*Tb*Tp + Rw2*Tb*Tp + 2*R1R2*Rw*Tpb + 
				2*R1*RsRw*Tpb + R1*Rw2*Tpb + R2*Rw2*Tpb + 
				RsRw2*Tpb + R1R2*TbTpb + R1*Rs*TbTpb + R1*Rw*TbTpb + 
				R2*Rw*TbTpb + RsRw*TbTpb + Rw2*TbTpb + R1R2*TpTpb + 
				R1*Rs*TpTpb + R1*Rw*TpTpb + R2*Rw*TpTpb + RsRw*TpTpb + 
				Rw2*TpTpb + R1*Tb*TpTpb + R2*Tb*TpTpb + Rs*Tb*TpTpb + 
				2*Rw*Tb*TpTpb + 2*R1R2*Rw*Ts + 2*R1*RsRw*Ts + 2*R2*RsRw*Ts + 
				R1*Rw2*Ts + R2*Rw2*Ts + R1R2*TbTs + R1*Rs*TbTs + 
				R2*Rs*TbTs + R1*Rw*TbTs + R2*Rw*TbTs + 2*RsRw*TbTs + 
				Rw2*TbTs + R1R2*TpTs + R1*Rs*TpTs + R2*Rs*TpTs + 
				R1*Rw*TpTs + R2*Rw*TpTs + R1*Tb*TpTs + Rs*Tb*TpTs + Rw*Tb*TpTs + 
				2*R2*Rw*Tpb*Ts + 2*RsRw*Tpb*Ts + Rw2*Tpb*Ts + R2*TbTpb*Ts + 
				Rs*TbTpb*Ts + Rw*TbTpb*Ts + R2*TpTpb*Ts + Rs*TpTpb*Ts + 
				Rw*TpTpb*Ts + Tb*TpTpb*Ts))
				
	V[8] = -((-(R1R2*RsRw*U13) - R1R2*Rw*Tp*U13 - R1R2*Rw*Tpb*U13 - 
				R1R2*TpTpb*U13 - R2*Rw*TpTpb*U13 - R2*Tb*TpTpb*U13 - 
				R1R2*Rw*Ts*U13 + R2*Rs*TbTs*U13 - R1R2*TpTs*U13 - R2*Rw*Tpb*Ts*U13 - 
				R2*TpTpb*Ts*U13 - R1R2*RsRw*U24 - R1R2*Rs*Tb*U24 - R2*RsRw*Tb*U24 - 
				R1R2*Rs*Tp*U24 - R1R2*Rw*Tp*U24 - R1R2*Tb*Tp*U24 - R2*Rs*Tb*Tp*U24 - 
				R2*Rw*Tb*Tp*U24 - R1R2*Rw*Tpb*U24 - R1R2*TbTpb*U24 - 
				R2*Rw*TbTpb*U24 - R2*Tb*TpTpb*U24 - R1R2*Rw*Ts*U24 - R1R2*TbTs*U24 - 
				R2*Rs*TbTs*U24 - R2*Rw*TbTs*U24 - R2*Rw*Tpb*Ts*U24 - R2*TbTpb*Ts*U24 - 
				R1R2*Rw*Tp*Vp - 2*R1R2*Rw*Tpb*Vp - R2*Rw2*Tpb*Vp - 
				R1R2*TbTpb*Vp - R2*Rw*TbTpb*Vp - R1R2*TpTpb*Vp - R2*Rw*TpTpb*Vp - 
				R2*Tb*TpTpb*Vp - 2*R1R2*Rw*Ts*Vp - R1R2*TbTs*Vp - R2*Rw*TbTs*Vp - 
				R1R2*TpTs*Vp - 2*R2*Rw*Tpb*Ts*Vp - R2*TbTpb*Ts*Vp - R2*TpTpb*Ts*Vp)/
			(2*R1R2*RsRw + R1*RsRw2 + R2*RsRw2 + R1R2*Rs*Tb + 
				R1*RsRw*Tb + R2*RsRw*Tb + RsRw2*Tb + R1R2*Rs*Tp + 
				2*R1R2*Rw*Tp + R1*RsRw*Tp + R2*RsRw*Tp + R1*Rw2*Tp + 
				R2*Rw2*Tp + R1R2*Tb*Tp + R2*Rs*Tb*Tp + R1*Rw*Tb*Tp + 
				R2*Rw*Tb*Tp + RsRw*Tb*Tp + Rw2*Tb*Tp + 2*R1R2*Rw*Tpb + 
				2*R1*RsRw*Tpb + R1*Rw2*Tpb + R2*Rw2*Tpb + 
				RsRw2*Tpb + R1R2*TbTpb + R1*Rs*TbTpb + R1*Rw*TbTpb + 
				R2*Rw*TbTpb + RsRw*TbTpb + Rw2*TbTpb + R1R2*TpTpb + 
				R1*Rs*TpTpb + R1*Rw*TpTpb + R2*Rw*TpTpb + RsRw*TpTpb + 
				Rw2*TpTpb + R1*Tb*TpTpb + R2*Tb*TpTpb + Rs*Tb*TpTpb + 
				2*Rw*Tb*TpTpb + 2*R1R2*Rw*Ts + 2*R1*RsRw*Ts + 2*R2*RsRw*Ts + 
				R1*Rw2*Ts + R2*Rw2*Ts + R1R2*TbTs + R1*Rs*TbTs + 
				R2*Rs*TbTs + R1*Rw*TbTs + R2*Rw*TbTs + 2*RsRw*TbTs + 
				Rw2*TbTs + R1R2*TpTs + R1*Rs*TpTs + R2*Rs*TpTs + 
				R1*Rw*TpTs + R2*Rw*TpTs + R1*Tb*TpTs + Rs*Tb*TpTs + Rw*Tb*TpTs + 
				2*R2*Rw*Tpb*Ts + 2*RsRw*Tpb*Ts + Rw2*Tpb*Ts + R2*TbTpb*Ts + 
				Rs*TbTpb*Ts + Rw*TbTpb*Ts + R2*TpTpb*Ts + Rs*TpTpb*Ts + 
				Rw*TpTpb*Ts + Tb*TpTpb*Ts))
				
	return V
end