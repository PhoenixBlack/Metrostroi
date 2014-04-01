--------------------------------------------------------------------------------
-- Электрические цепи 81-717/714
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("81_714_Electric")

function TRAIN_SYSTEM:Initialize(...)
	return Metrostroi.BaseSystems["81_717_Electric"].Initialize(self,...)
end
function TRAIN_SYSTEM:Inputs(...)
	return Metrostroi.BaseSystems["81_717_Electric"].Inputs(self,...)
end
function TRAIN_SYSTEM:Outputs(...)
	return Metrostroi.BaseSystems["81_717_Electric"].Outputs(self,...)
end
function TRAIN_SYSTEM:TriggerInput(...)
	return Metrostroi.BaseSystems["81_717_Electric"].TriggerInput(self,...)
end
function TRAIN_SYSTEM:Think(...)
	return Metrostroi.BaseSystems["81_717_Electric"].Think(self,...)
end

function TRAIN_SYSTEM:SolveInternalCircuits(Train,dT)
	local KSH1,KSH2 = 0,0
	local SDRK_Shunt = 1.0
	self.Triggers = { -- FIXME
		["LK5"]			= function(V) end,
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
	Train.InternalCircuits.Solve81_714(Train,self.Triggers)
end

function TRAIN_SYSTEM:SolveThyristorController(...)
	return Metrostroi.BaseSystems["81_717_Electric"].SolveThyristorController(self,...)
end
function TRAIN_SYSTEM:SolvePowerCircuits(...)
	return Metrostroi.BaseSystems["81_717_Electric"].SolveThyristorController(self,...)
end
function TRAIN_SYSTEM:SolvePS(...)
	return Metrostroi.BaseSystems["81_717_Electric"].SolveThyristorController(self,...)
end
function TRAIN_SYSTEM:SolvePP(...)
	return Metrostroi.BaseSystems["81_717_Electric"].SolveThyristorController(self,...)
end
function TRAIN_SYSTEM:SolvePT(...)
	return Metrostroi.BaseSystems["81_717_Electric"].SolveThyristorController(self,...)
end