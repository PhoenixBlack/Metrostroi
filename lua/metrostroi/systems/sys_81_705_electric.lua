--------------------------------------------------------------------------------
-- Электрические цепи 81-704/705 (Е, Еж, Ем)
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("81_705_Electric")


function TRAIN_SYSTEM:Initialize()
	self.Main750V = 0.0
	self.Aux750V = 0.0
	self.Power750V = 0.0
	self.Aux80V = 0.0
	
	-- Resistances
	self.R1 = 0.0
	self.R2 = 0.0
	self.R3 = 0.0
	self.Rs1 = 0.0
	self.Rs2 = 0.0
	
	-- Load resistor blocks
	RESISTOR_BLOCKS = {}
	include("metrostroi/systems/gen_resblocks.lua")
	self.ResistorBlocks = RESISTOR_BLOCKS
	RESISTOR_BLOCKS = nil
	
	-- Electric network info
	self.Itotal = 0.0
	self.I13 = 0.0
	self.I24 = 0.0
	self.Ustator13 = 0.0
	self.Ustator24 = 0.0
	self.Ishunt13  = 0.0
	self.Istator13 = 0.0
	self.Ishunt24  = 0.0
	self.Istator24 = 0.0
	
	-- Calculate current through rheostats 1, 2
	self.IR1 = self.Itotal
	self.IR2 = self.Itotal
	
	-- Реверсор (ПР-772)
	self.Train:LoadSystem("Reverser","Relay","PR-772")
	
	-- Other relays
	self.Train:LoadSystem("NR","Relay",{ normally_open = true })
end


function TRAIN_SYSTEM:Inputs()
	return { }
end

function TRAIN_SYSTEM:Outputs()
	return { "R1","R2","R3","Rs1","Rs2","Itotal","I13","I24",
			 "Ustator13","Ustator24","Ishunt13","Istator13","Ishunt24","Istator24" }
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
local function b(x) return x and 1 or 0 end
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
	self.Power750V = self.Power750V
	
	-- Ослабление резистором Л1-Л2
	self.ExtraResistance = (1-Train.LK2.Value) * Train.KF_47A["L2-L4"]
	
	-- Вычисление сопротивления в резисторах реостатного контроллера
	self.ResistorBlocks.InitializeResistances_81_705(Train)
	if Train.PositionSwitch.SelectedPosition == 1 then -- PS
		self.R1 = self.ResistorBlocks.R1C1(Train)
		self.R2 = self.ResistorBlocks.R2C1(Train)
		self.R3 = 0.0
	elseif Train.PositionSwitch.SelectedPosition == 2 then -- PP
		self.R1 = self.ResistorBlocks.R1C2(Train)
		self.R2 = self.ResistorBlocks.R2C2(Train)
		self.R3 = 0.0
	elseif Train.PositionSwitch.SelectedPosition >= 3 then -- PT
		self.R1 = self.ResistorBlocks.R1C1(Train)
		self.R2 = self.ResistorBlocks.R2C1(Train)
		self.R3 = self.ResistorBlocks.R3(Train)
	end
	-- Apply LK3, LK4 contactors
	self.R1 = self.R1 + 1e9*(1 - Train.LK3.Value)
	self.R2 = self.R2 + 1e9*(1 - Train.LK4.Value)

	-- Shunt resistance
	self.Rs1 = self.ResistorBlocks.S1(Train) + 1e9*(1 - Train.KSH1.Value)
	self.Rs2 = self.ResistorBlocks.S2(Train) + 1e9*(1 - Train.KSH2.Value)
	
	-- Calculate total resistance of engines winding
	local RwAnchor = Train.Engines.Rw/2
	local RwStator = Train.Engines.Rw/2
	-- Total resistance of the stator + shunt
	self.Rstator13	= (RwStator^-1 + self.Rs1^-1)^-1
	self.Rstator24	= (RwStator^-1 + self.Rs2^-1)^-1
	-- Total resistance of entire motor
	self.Ranchor13	= RwAnchor
	self.Ranchor24	= RwAnchor
	
	-- Вычисление электросети (calculate electric power network)
	if Train.PositionSwitch.SelectedPosition == 1 then -- PS
		self:SolvePS(Train)
	else
	
	end
	
	-- Output interesting variables
	local outputs = self:Outputs()
	for k,v in pairs(outputs) do
		self:TriggerOutput(v,self[v])
	end
	self:TriggerOutput("U13",	self.U13)
	self:TriggerOutput("U24",	self.U24)
	self:TriggerOutput("VR1",	self.VR1)
	self:TriggerOutput("VR2",	self.VR2)
	self:TriggerOutput("I13",	self.I13)
	self:TriggerOutput("I24",	self.I24)
	self:TriggerOutput("Itotal",self.Itotal)
	
	
	
	
	----------------------------------------------------------------------------
	-- Комутация напряжения между поездными проводами и реле
	local P = Train.PositionSwitch.SelectedPosition
	local RK = Train.RheostatController.SelectedPosition
	local TW1  = Train:ReadTrainWire(1)  -- X1
	local TW2  = Train:ReadTrainWire(2)  -- X2
	local TW3  = Train:ReadTrainWire(3)  -- X3
	local TW6  = Train:ReadTrainWire(6)  -- T
	local TW4  = Train:ReadTrainWire(4)  -- R
	local TW5  = Train:ReadTrainWire(5)  -- F
	local TW20 = Train:ReadTrainWire(20) -- X
	local B2   = Train:ReadTrainWire(9) + Train:ReadTrainWire(10)
	local A = {}
	for i=1,100 do A[i] = 1 end
	
	-- Value of the overload relay
	local RP = (1.0 - Train.RPL.Value) * (1.0 - Train.RP1_3.Value) * (1.0 - Train.RP2_4.Value)
	
	----------------------------------------------------------------------------
	-- Train wire 4, 5
	if (TW4 > 0.5) and (Train.Reverser.Value == 0.0) then -- 4B
		Train.Reverser:TriggerInput("Close",1.0)
	end
	if (TW5 > 0.5) and (Train.Reverser.Value == 1.0) then -- 5B
		Train.Reverser:TriggerInput("Open",1.0)
	end
	local _5V = TW4 * Train.Reverser.Value + TW5 * (1.0 - Train.Reverser.Value)
	local _5D = _5V * RP * Train.LK3.Value
	Train.LK4:TriggerInput("Close",_5D)
	
	
	----------------------------------------------------------------------------
	-- Train wire 20
	local _20B = X * A[20] * RP
	Train.LK2:TriggerInput("Set",_20B)
	Train.RV2:TriggerInput("Close",(1.0 - _20B) * Train.LK2.Value)
	
	
	----------------------------------------------------------------------------
	-- Train wire 9, 10
	local _10AYa = B2 * A[80]
	local _10AB  = _10Aya * (1.0-Train.LK3.Value)
	local _10AV  = _10AYa * b((RK >= 2) and (RK <= 18))
	local _10E   = _10Aya * ((1.0-Train.LK3.Value) + Train.Rper.Value + 0) -- PM? PS3?
	local _10Ya  = _10E * Train.LK3.Value * b(RK == 18) * b(P ~= 1)
	local _10Ap  = _10E * (1.0 - Train.LK1.Value)
	local _10Ad  = _10Ap * (Train.LK2.Value + b((P == 3) or (P == 4)))
	local _10At  = _10Ad * (Train.TP2.Value * Train.TP1.Value * b(P ~= 3))
	local _10Ar  = _10Ad * (1.0-Train.TP2.Value) * (1.0-Train.TP1.Value) * b(P == 1)
	local _10Ag  = _10Ya + _10At + _10Ar
	local _10AYe = math.max(1.0,_10Ag) -- Power to SDDP
	
	local _10AE = B2 * A[30]
	local _10B = _10AE * (Train.RV1.Value + Train.TR1.Value)
	
	
	----------------------------------------------------------------------------
	-- Train wire 1
	local _1A  = TW1 * A[1]
	local _1T  = _1A * b((P ~= 1) and (P ~= 2)) -- PS, PP
	local _1P  = _1T * (Train.RPU.Value + Train.NR.Value) -- RPU or NR
	local _1G  = _1P * RP -- FIXME: AVT
	
	local _1E  = _1G * b(RK == 1)
	local _1Yu = _1E * (Train.KSB1.Value*Train.KSB2.Value + Train.KSH2.Value)
	local _1L  = _1Yu * b((P == 1) or (P == 3)) -- PS, PT	
	
	local _1Zh = _1G * Train.LK3.Value + _1L * Train.LK2.Value
	local _1K = _1Zh * b((P == 1) or (P == 2)) -- PP, PS
	local _1N = _1Zh * b((P == 1) or (P == 3)) -- PP, PT
	
	Train.LK3:TriggerInput("Close",_1Zh)
	Train.LK1:TriggerInput("Close",_1K)
	Train.RR:TriggerInput("Set", _1N)
	
	local _1V = _1A * Train.RV1.Value * b(P ~= 1)
	local _1M = _1A * b(RK > 5) * b(P == 2)
	local _1R = _1V + _1M
	Train.KSH1:TriggerInput("Set",_1R)
	Train.KSH2:TriggerInput("Set",_1R)
	
	
	----------------------------------------------------------------------------
	-- Train wire 2
	local _2Zh = TW2 * A[2]
	local _2A  = _2Zh * ((1.0-Train.KSB1.Value) + b(P ~= 3))
	local _2B  = _2A * b((P ~= 1) and (P ~= 3)) -- PS, PT1
	local _2V  = _2A * b((P == 2) or (P == 4)) -- PP, PT2
	local _2R  = _2V * b((RK >= 2) and (RK <= 4)) * Train.KSH1.Value
	local _2G  = _2B * b((RK < 1) or (RK > 17)) + 
	             _2V * (b((RK >= 5) and (RK <= 18)) + _2R)
				 
	local _2E  = _2G * Train.LK4.Value + _10AV * (1.0 - Train.LK4.Value)
	
	Train.SR1:TriggerInput("Set",_2E)
	Train.RV1:TriggerInput("Set",_2E)
	
	
	----------------------------------------------------------------------------
	-- Train wire 3
	local _3A = TW3 * A[3]
	Train.Rper:TriggerInput("Set",_3A)

	
	----------------------------------------------------------------------------
	-- РУТ (реле управления тягой) operation
	self.RUTCurrent = self.I13 + self.I24
	self.RUTTarget = 260
	Train.RUT:TriggerInput("Set",(math.abs(self.RUTCurrent) > self.RUTTarget) and 1 or 0)
	
	-- Overload relays
	Train.RP1_3:TriggerInput("Close",b(self.I13 > 300))
	Train.RP2_4:TriggerInput("Close",b(self.I13 > 300))
	Train.RPL:TriggerInput("Close",b(self.Itotal > 600))
	
	-- Grounding relays
	Train.RZ_3:TriggerInput("Set",0) -- FIXME
	
	
	----------------------------------------------------------------------------
	-- Anchor of the rheostat controller
	local SDRK = SR1 * (1.0 - Train.RUT.Value)
	Train.RheostatController:TriggerInput("MotorState",SDRK * (-1.0 + 2.0*Train.RR.Value))
	
	
	----------------------------------------------------------------------------
	-- Time relay for LK1, LK3, LK4
	if Train.RV2.Value == 1.0 then
		Train.LK1:TriggerInput("Open",1.0)
		Train.LK3:TriggerInput("Open",1.0)
		Train.LK4:TriggerInput("Open",1.0)
		Train.RV2:TriggerInput("Open",1.0)	
	end
	--Train.RV2:TriggerInput("Close",(1.0 - X1 - X2 - X3) * Train.LK2.Value)	
		
	-- Разбор
	--[[if ((X < 0.5) and ((Train.LK3.Value == 1.0) or (Train.LK4.Value == 1.0))) or
	   ((X > 0.5) and (T < 0.5) and (Train.Tb.Value == 1.0)) then
		Train.LK2:TriggerInput("Open",1.0)
		Train.KSH1:TriggerInput("Open",1.0)
		Train.KSH2:TriggerInput("Open",1.0)
		
		-- Timed closing of the LK2 relay
		Train.RV2:TriggerInput("Close",1.0)	
		
		-- Razbor of the circuit
		Train.Tp:TriggerInput("Open",1.0)
		Train.Tpb:TriggerInput("Open",1.0)
		Train.Tb:TriggerInput("Open",1.0)
		Train.Ts:TriggerInput("Open",1.0)
	end

	
	-- Сбор на ход
	if (T < 0.5) and (X > 0.5) then
		Train.PneumaticNo1:TriggerInput("Open",1.0)
		Train.PneumaticNo2:TriggerInput("Open",1.0)
	end
	--if Train.Pneumatic.BrakeCylinderPressure > 0.5 then X1 = 0 X2 = 0 X3 = 0 X = 0 end
	if (T < 0.5) and (X1 > 0.5) and (Train.RheostatController.Position < 1.5) then
		Train.LK1:TriggerInput("Close",1.0)
		Train.LK2:TriggerInput("Close",1.0)
		Train.LK3:TriggerInput("Close",1.0)
		Train.LK4:TriggerInput("Close",1.0)
		Train.KSH1:TriggerInput("Close",1.0)
		Train.KSH2:TriggerInput("Close",1.0)

		-- Сбор последовательной схемы
		Train.Tp:TriggerInput("Open",1.0)
		Train.Tpb:TriggerInput("Open",1.0)
		Train.Tb:TriggerInput("Open",1.0)
		Train.Ts:TriggerInput("Close",1.0)
	end
	if (T < 0.5) and ((X2 > 0.5) or ((Train.Tp.Value == 0.0) and (X3 > 0.5))) and (Train.RheostatController.Position < 1.5) then
		Train.LK1:TriggerInput("Close",1.0)
		Train.LK2:TriggerInput("Close",1.0)
		Train.LK3:TriggerInput("Close",1.0)
		Train.LK4:TriggerInput("Close",1.0)
		Train.KSH1:TriggerInput("Close",1.0)
		Train.KSH2:TriggerInput("Close",1.0)

		-- Сбор последовательной схемы
		Train.Tp:TriggerInput("Open",1.0)
		Train.Tpb:TriggerInput("Open",1.0)
		Train.Tb:TriggerInput("Open",1.0)
		Train.Ts:TriggerInput("Close",1.0)
	end
	if (T < 0.5) and (X3 > 0.5) and (Train.RheostatController.Position > 17.5) then
		Train.LK1:TriggerInput("Close",1.0)
		Train.LK2:TriggerInput("Close",1.0)
		Train.LK3:TriggerInput("Close",1.0)
		Train.LK4:TriggerInput("Close",1.0)
		Train.KSH1:TriggerInput("Close",1.0)
		Train.KSH2:TriggerInput("Close",1.0)

		-- Сбор паралельной схемы
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

		-- Сбор последовательной схемы
		--Train.Tp:TriggerInput("Close",1.0)
		--Train.Tpb:TriggerInput("Close",1.0)
		--Train.Tb:TriggerInput("Close",1.0)
		--Train.Ts:TriggerInput("Open",1.0)
		
		Train.Tp:TriggerInput("Open",1.0)
		Train.Tpb:TriggerInput("Open",1.0)
		Train.Tb:TriggerInput("Close",1.0)
		Train.Ts:TriggerInput("Close",1.0)
	end
	
	
	
	
	----------------------------------------------------------------------------
	-- РУТ (реле управления тягой) operation
	self.RUTCurrent = self.I13 + self.I24
	self.RUTTarget = 260
	if Train.Tb.Value == 1.0 then
		self.RUTCurrent = self.RUTCurrent*0.50
	end
	if math.abs(self.RUTCurrent) < self.RUTTarget then
		Train.RUT:TriggerInput("Close",1.0)
	else
		Train.RUT:TriggerInput("Open",1.0)
	end
	
	-- Rheostat controller operation
	if (Train.LK3.Value == 0.0) and (Train.LK4.Value == 0.0) then
		Train.RheostatController:TriggerInput("Down",1.0)
	elseif Train.RUT.Value == 1.0 then
		if (X1 < 0.5) then
			if (T < 0.5) then -- Drive
				if Train.Tp.Value == 0.0 
				then Train.RheostatController:TriggerInput("Up",1.0)
				else Train.RheostatController:TriggerInput("Down",1.0)
				end
			else -- Brake
				if (X3 > 0.5) then
					Train.RheostatController:TriggerInput("Up",1.0)
					if Train.RheostatController.Position > 12.5 then
						Train.PneumaticNo1:TriggerInput("Close",1.0)
					end
				end
			end
		end
	end
	if (X2 > 0.5) then
		-- Вывод реостата
		if (self.PreviousT1A ~= true) and (T > 0.5) and (X2 > 0.5) then
			Train.RheostatController:TriggerInput("Up",1.0)
		end
	end
	self.PreviousT1A = (T > 0.5) and ((X2 > 0.5) or (X3 > 0.5))]]--
	
	--[[
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
function TRAIN_SYSTEM:SolvePS(Train)
	-- Calculate total resistance of the entire series circuit
	local Rtotal = self.Ranchor13 + self.Ranchor24 + self.Rstator13 + self.Rstator24 +
		self.R1 + self.R2 + self.R3
		
	--print(Rtotal)
		
	-- Calculate total current
	self.Itotal = (self.Power750V - Train.Engines.E13 - Train.Engines.E24) / Rtotal
	
	-- Calculate current through engines 13, 24
	self.I13 = self.Itotal
	self.I24 = self.Itotal
	
	-- Calculate current through stator and shunt
	self.Ustator13 = self.I13 * self.Rstator13
	self.Ustator24 = self.I24 * self.Rstator24	
	
	self.Ishunt13  = self.Ustator13 / self.Rs1
	self.Istator13 = self.Ustator13 / self.Ranchor13 -- FIXME: use stators own resistance
	self.Ishunt24  = self.Ustator24 / self.Rs2
	self.Istator24 = self.Ustator24 / self.Ranchor24
	
	-- Calculate current through rheostats 1, 2
	self.IR1 = self.Itotal
	self.IR2 = self.Itotal
	
	
	
	--self.Vs 	= V[1] - V[2]
	--self.U13 	= V[2] - V[4]
	--self.U24 	= V[6] - V[8]
	--self.VR1 	= V[4] - V[5]
	--self.VR2 	= V[8] - V[0]
	--self.I13 	= (V[3] - V[4])/self.Rw13
	--self.I24 	= (V[7] - V[8])/self.Rw24
	--self.Itotal	= (V[1] - V[2])/(1e-9 + self.ExtraResistance)
end