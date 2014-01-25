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
	
	-- Load internal circuits
	INTERNAL_CIRCUITS = {}
	include("metrostroi/systems/gen_int_81_705.lua")
	self.InternalCircuits = INTERNAL_CIRCUITS
	INTERNAL_CIRCUITS = nil
	
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
	self.T1 = 25
	self.T2 = 25
	self.P1 = 0
	self.P2 = 0
end


function TRAIN_SYSTEM:Inputs()
	return { }
end

function TRAIN_SYSTEM:Outputs()
	return { "R1","R2","R3","Rs1","Rs2","Itotal","I13","I24",
			 "Ustator13","Ustator24","Ishunt13","Istator13","Ishunt24","Istator24",
			 "T1", "T2", "P1", "P2",
			 "Main750V", "Power750V", "Aux750V", "Aux80V" }
end


function TRAIN_SYSTEM:TriggerInput(name,value)
end



--------------------------------------------------------------------------------
function TRAIN_SYSTEM:Think(dT)
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
	elseif Train.PositionSwitch.SelectedPosition == 2 then -- PS
		self:SolvePP(Train)
	else
		self:SolvePS(Train)
	end
	
	----------------------------------------------------------------------------
	-- Calculate current through stator and shunt
	self.Ustator13 = self.I13 * self.Rstator13
	self.Ustator24 = self.I24 * self.Rstator24	
	
	self.Ishunt13  = self.Ustator13 / self.Rs1
	self.Istator13 = self.Ustator13 / self.Ranchor13 -- FIXME: use stators own resistance
	self.Ishunt24  = self.Ustator24 / self.Rs2
	self.Istator24 = self.Ustator24 / self.Ranchor24
	
	-- Calculate current through rheostats 1, 2
	self.IR1 = self.I13
	self.IR2 = self.I24
	
	-- Calculate power and heating
	self.P1 = (self.IR1^2) * self.R1
	self.P2 = (self.IR2^2) * self.R2
	self.T1 = self.T1 + self.P1 * 5e-4 * dT - (self.T1 - 25)*0.0001
	self.T2 = self.T2 + self.P2 * 5e-4 * dT - (self.T2 - 25)*0.0001
	
	-- Output interesting variables
	local outputs = self:Outputs()
	for k,v in pairs(outputs) do
		self:TriggerOutput(v,self[v])
	end
	
	
	
	
	----------------------------------------------------------------------------
	-- Calculate internal circuits
	local Triggers = {
		["LK1"] 	= function(V) Train.LK1:TriggerInput("Close",V) end,
		["LK2"]		= function(V) Train.LK2:TriggerInput("Set",V) 
								  Train.RV2:TriggerInput("Close",(1.0-V) * Train.LK2.Value) end,
		["LK3"]		= function(V) Train.LK3:TriggerInput("Close",V) end,
		["LK4"]		= function(V) Train.LK4:TriggerInput("Close",V) end,
		["LK5"]		= function(V) end,
		
		["KSH1"]	= function(V) Train.KSH1:TriggerInput("Set",V) end,
		["KSH2"]	= function(V) Train.KSH2:TriggerInput("Set",V) end,

		["RR"]		= function(V) Train.RR:TriggerInput("Set",V) end,
		["SR1"]		= function(V) Train.SR1:TriggerInput("Set",V) end,
		["RV1"]		= function(V) Train.RV1:TriggerInput("Set",V) end,
		["Rper"]	= function(V) Train.Rper:TriggerInput("Set",V) end,
		
		["SDPP"]		= function(V) Train.PositionSwitch:TriggerInput("MotorState",V) end,
		["SDRK_Coil"]	= function(V) Train.RheostatController:TriggerInput("MotorCoilState",V*(-1.0 + 2.0*Train.RR.Value)) end,
		["SDRK"]		= function(V) Train.RheostatController:TriggerInput("MotorState",V) end,
		
		["ReverserForward"]	= function(V) Train.RKR:TriggerInput("Open",V) end,
		["ReverserBackward"]	= function(V) Train.RKR:TriggerInput("Close",V) end,
	}
	local S = self.InternalCircuits.Solve(Train,Triggers)
	--print("---------------------")
	for k,v in SortedPairs(S) do 
		--print(k,v)
	end
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
end



function TRAIN_SYSTEM:SolvePP(Train)
	-- Calculate total resistance of each branch
	local Rtotal13 = self.Ranchor13 + self.Rstator13 + self.R1
	local Rtotal24 = self.Ranchor24 + self.Rstator24 + self.R2
	
	-- Calculate current through engines 13, 24
	self.I13 = (self.Power750V - Train.Engines.E13) / Rtotal13
	self.I24 = (self.Power750V - Train.Engines.E24) / Rtotal24
	
		-- Calculate total current
	self.Itotal = self.I13 + self.I24
	
	
	
	
	
	--self.Vs 	= V[1] - V[2]
	--self.U13 	= V[2] - V[4]
	--self.U24 	= V[6] - V[8]
	--self.VR1 	= V[4] - V[5]
	--self.VR2 	= V[8] - V[0]
	--self.I13 	= (V[3] - V[4])/self.Rw13
	--self.I24 	= (V[7] - V[8])/self.Rw24
	--self.Itotal	= (V[1] - V[2])/(1e-9 + self.ExtraResistance)
end