--------------------------------------------------------------------------------
-- Электрические цепи 81-704/705 (Е, Еж, Ем)
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("81_705_Electric")


function TRAIN_SYSTEM:Initialize()
	-- General power output
	self.Main750V = 0.0
	self.Aux750V = 0.0
	self.Power750V = 0.0
	self.Aux80V = 0.0
	self.Lights80V = 0.0
	
	-- Resistances
	self.R1 = 1e9
	self.R2 = 1e9
	self.R3 = 1e9
	self.Rs1 = 1e9
	self.Rs2 = 1e9
	
	self.Rstator13 = 1e9
	self.Rstator24 = 1e9
	self.Ranchor13	= 1e9
	self.Ranchor24	= 1e9
	
	-- Load resistor blocks
	RESISTOR_BLOCKS = {}
	if TURBOSTROI then
		dofile("garrysmod/addons/metrostroi/lua/metrostroi/systems/gen_resblocks.lua")
	else
		include("metrostroi/systems/gen_resblocks.lua")
	end
	self.ResistorBlocks = RESISTOR_BLOCKS
	RESISTOR_BLOCKS = nil
	
	-- Load internal circuits
	INTERNAL_CIRCUITS = {}
	if TURBOSTROI then
		dofile("garrysmod/addons/metrostroi/lua/metrostroi/systems/gen_int_81_705.lua")
	else
		include("metrostroi/systems/gen_int_81_705.lua")
	end
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
	self.IRT2 = self.Itotal
	self.T1 = 25
	self.T2 = 25
	self.P1 = 0
	self.P2 = 0
	
	-- Need many iterations for engine simulation to converge
	self.SubIterations = 16
	
	-- Главный выключатель
	self.Train:LoadSystem("GV","Relay","GV_10ZH")
end


function TRAIN_SYSTEM:Inputs()
	return { }
end

function TRAIN_SYSTEM:Outputs()
	return { "R1","R2","R3","Rs1","Rs2","Itotal","I13","I24","IRT2",
			 "Ustator13","Ustator24","Ishunt13","Istator13","Ishunt24","Istator24",
			 "T1", "T2", "P1", "P2",
			 "Main750V", "Power750V", "Aux750V", "Aux80V", "Lights80V" }
end


function TRAIN_SYSTEM:TriggerInput(name,value)
end



--------------------------------------------------------------------------------
function TRAIN_SYSTEM:Think(dT)
	local Train = self.Train

	----------------------------------------------------------------------------
	-- Voltages from the third rail
	----------------------------------------------------------------------------
	-- Напряжение в главных высоковольных цепях
	self.Main750V = Train.TR.Main750V * Train.PNB_1250_1.Value
	-- Напряжение в спомагательных высоковольных цепях
	self.Aux750V  = Train.TR.Main750V * Train.PNB_1250_2.Value * Train.KVC.Value
	-- Внешнее напряжение силовых цепей
	self.Power750V = self.Main750V * Train.GV.Value
	
	
	----------------------------------------------------------------------------
	-- Information only
	----------------------------------------------------------------------------
	-- Питание вспомагательных цепей 80V
	self.Aux80V = Train.PowerSupply.XT3_1
	-- Питание освещения 80V
	self.Lights80V = Train.PowerSupply.XT3_4

	
	----------------------------------------------------------------------------
	-- Solve circuits
	----------------------------------------------------------------------------
	self:SolvePowerCircuits(Train,dT)
	self:SolveInternalCircuits(Train,dT)

	
	----------------------------------------------------------------------------
	-- Calculate current flow out of the battery
	----------------------------------------------------------------------------
	--local totalCurrent = 5*A30 + 63*A24 + 16*A44 + 5*A39 + 10*A80
	--local totalCurrent = 20 + 60*DIP
end



--------------------------------------------------------------------------------
function TRAIN_SYSTEM:SolveInternalCircuits(Train,dT)
	local KSH1,KSH2 = 0,0
	local SDRK_Shunt = 1.0
	self.Triggers = { -- FIXME
		["LK5"]			= function(V) end,
		["KSH1"]		= function(V) KSH1 = KSH1 + V end,
		["KSH2"]		= function(V) KSH2 = KSH2 + V end,
		["KSB1"]		= function(V) Train.KSB1:TriggerInput("Set",V) KSH1 = KSH1 + V end,
		["KSB2"]		= function(V) Train.KSB2:TriggerInput("Set",V) KSH2 = KSH2 + V end,
		["KPP"]			= function(V) Train.KPP:TriggerInput("Close",V) end,

		["RPvozvrat"]	= function(V) Train.RPvozvrat:TriggerInput("Open",V) end,
		["RRTuderzh"]	= function(V) Train.RRTuderzh = V end,
		["RRTpod"]		= function(V) Train.RRTpod = V end,
		["RUTpod"]		= function(V) Train.RUTpod = V end,
		
		["SDPP"]		= function(V) Train.PositionSwitch:TriggerInput("MotorState",-1.0 + 2.0*math.max(0,V)) end,
		["SDRK_Shunt"]	= function(V) SDRK_Shunt = V end,
		["SDRK_Coil"]	= function(V) Train.RheostatController:TriggerInput("MotorCoilState",SDRK_Shunt*math.min(1,math.max(0,V))*(-1.0 + 2.0*Train.RR.Value)) end,
		["SDRK"]		= function(V) Train.RheostatController:TriggerInput("MotorState",V) end,
		
		["XR3.2"]		= function(V) Train.PowerSupply:TriggerInput("XR3.2",V) end,
		["XR3.3"]		= function(V) Train.PowerSupply:TriggerInput("XR3.3",V) end,
		["XR3.4"]		= function(V) end, --Train.PowerSupply:TriggerInput("XR3.4",V) end,
		["XR3.6"]		= function(V) end, --Train.PowerSupply:TriggerInput("XR3.6",V) end,
		["XR3.7"]		= function(V) end, --Train.PowerSupply:TriggerInput("XR3.7",V) end,
		["XT3.1"]		= function(V) Train.PowerSupply:TriggerInput("XT3.1",Train.Battery.Voltage*V) end,
		
		["ReverserForward"]		= function(V) Train.RKR:TriggerInput("Open",V) end,
		["ReverserBackward"]	= function(V) Train.RKR:TriggerInput("Close",V) end,
	}
	local S = self.InternalCircuits.Solve(Train,self.Triggers)
	--if true then
	--print(S["31V"],S["D1"],S["D1-31V"])
	if false then
		print("---------------------")
		for k,v in SortedPairs(S) do 
			print(k,v)
		end
	end
	Train.KSH1:TriggerInput("Set",KSH1)
	Train.KSH2:TriggerInput("Set",KSH2)
end



--------------------------------------------------------------------------------
function TRAIN_SYSTEM:SolvePowerCircuits(Train,dT)
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
	local RwAnchor = Train.Engines.Rw*2 -- Double because each set includes two engines
	local RwStator = Train.Engines.Rw*2
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
		self:SolvePT(Train)
	end
	

	
	----------------------------------------------------------------------------
	-- Calculate current through stator and shunt
	self.Ustator13 = self.I13 * self.Rstator13
	self.Ustator24 = self.I24 * self.Rstator24	
	
	self.Ishunt13  = self.Ustator13 / self.Rs1
	self.Istator13 = self.Ustator13 / self.Ranchor13 -- FIXME: use stators own resistance
	self.Ishunt24  = self.Ustator24 / self.Rs2
	self.Istator24 = self.Ustator24 / self.Ranchor24
	
	if Train.PositionSwitch.SelectedPosition >= 3 then
		local I1,I2 = self.Ishunt13,self.Ishunt24
		self.Ishunt13 = -I2
		self.Ishunt24 = -I1
		
		I1,I2 = self.Istator13,self.Istator24
		self.Istator13 = -I2
		self.Istator24 = -I1
	end
	
	-- Calculate current through rheostats 1, 2
	self.IR1 = self.I13
	self.IR2 = self.I24
	
	-- Calculate current through RT2 relay
	self.IRT2 = math.abs(self.Itotal * Train.PositionSwitch["10_v"])
	
	-- Calculate power and heating
	self.P1 = (self.IR1^2) * self.R1
	self.P2 = (self.IR2^2) * self.R2
	self.T1 = self.T1 + self.P1 * 5e-4 * dT - (self.T1 - 25)*0.0001
	self.T2 = self.T2 + self.P2 * 5e-4 * dT - (self.T2 - 25)*0.0001
end




--------------------------------------------------------------------------------
function TRAIN_SYSTEM:SolvePS(Train)
	-- Calculate total resistance of the entire series circuit
	local Rtotal = self.Ranchor13 + self.Ranchor24 + self.Rstator13 + self.Rstator24 +
		self.R1 + self.R2 + self.R3
		
	-- Calculate total current
	self.Itotal = (self.Power750V - Train.Engines.E13 - Train.Engines.E24) / Rtotal
	
	-- Circuit must be closed
	if Train.LK1.Value == 0.0 then self.Itotal = 0 end
	
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
	
	-- Circuit must be closed
	if Train.LK1.Value == 0.0 then self.I13,self.I24 = 0,0 end
	
	-- Calculate total current
	self.Itotal = self.I13 + self.I24
end

function TRAIN_SYSTEM:SolvePT(Train)
	-- Calculate total resistance of the entire braking circuit
	local Rtotal = self.Ranchor13 + self.Ranchor24 + self.Rstator13 + self.Rstator24 +
		self.R1 + self.R2 + self.R3
	
	-- Calculate total current
	self.Itotal = (self.Power750V*Train.LK1.Value - 0.5*(Train.Engines.E13+Train.Engines.E24)) / Rtotal
	
	-- Calculate current through engines 13, 24
	self.I13 = self.Itotal / 2
	self.I24 = self.Itotal / 2
end