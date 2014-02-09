-- Auto-generated by gen.lua

local A = {}
local TW = {}

local S = {}
local T = {}
for i=1,4 do T[i] = 0 end
local function C(x) return x and 1 or 0 end

local min = math.min

function INTERNAL_CIRCUITS.Solve(Train,Triggers)
	-- Read all automatic switches
	for i=1,100 do A[i] = 1 end
	-- Read all train wires
	for i=1,32 do TW[i] = Train:ReadTrainWire(i) end
	
	local P		= Train.PositionSwitch.SelectedPosition
	local RK	= Train.RheostatController.SelectedPosition
	local B2	= 1
	
	-- Solve all circuits
	T["SDRK_ShortCircuit"] = -10*Train.RheostatController.RKP*(Train.RUT.Value+Train.RRT.Value+(1.0-Train.SR1.Value))
	S["1T-1P"] = Train.NR.Value+Train.RPU.Value
	S["2Zh-2A"] = (1.0-Train.KSB1.Value)+(1.0-Train.TR1.Value)
	S["2Zh-2A"] = Train.KSB2.Value+S["2Zh-2A"]
	S["8A-8Ye"] = C(RK == 1)+(1.0-Train.LK4.Value)
	S["10AYa-10E"] = (1.0-Train.LK3.Value)+Train.Rper.Value
	S["10AP-10AD"] = Train.LK2.Value+C((P == 3) or (P == 4))
	S["10AE-10B"] = Train.TR1.Value+Train.RV1.Value
	S["10AE-10B"] = Train.RV1.Value+S["10AE-10B"]
	S["2V-2G"] = C((RK >= 5) and (RK <= 18))+C((RK >= 2) and (RK <= 4))*Train.KSH1.Value
	S["2A-2G"] = C((P == 1) or (P == 3))*C((RK >= 1) and (RK <= 17))+C((P == 2) or (P == 4))*S["2V-2G"]
	S["1E-1Yu"] = Train.KSH2.Value+Train.KSB2.Value*Train.KSB1.Value
	S["10N-10Zh"] = (1.0-Train.RUT.Value)*Train.SR1.Value*(1.0-Train.RRT.Value)+Train.RheostatController.RKM
	S["1A-1R"] = C((RK >= 1) and (RK <= 5))*C((P == 2))+(1.0-Train.RV1.Value)*C((P == 1))
	S["10AD-10AG"] = Train.TR2.Value*Train.TR1.Value*C((P == 1) or (P == 2) or (P == 4))+C((P == 2) or (P == 3) or (P == 4))*(1.0-Train.TR2.Value)*(1.0-Train.TR1.Value)
	S["1G-1Zh"] = Train.LK3.Value+Train.LK2.Value*C(RK == 1)*C((P == 1) or (P == 3))*S["1E-1Yu"]
	S["10AG-10E"] = C(RK == 18)*C((P == 1))*Train.LK3.Value+S["10AD-10AG"]*(1.0-Train.LK1.Value)*S["10AP-10AD"]
	S["1A"] = A[1]*TW[1]
	S["18A"] = (1.0-Train.RPvozvrat.Value)*Train.LK4.Value*A[14]*B2
	S["1R"] = S["1A"]*S["1A-1R"]
	S["1P"] = S["1A"]*C((P == 1) or (P == 2))*S["1T-1P"]+T[1]*C((P == 3) or (P == 4))
	S["2Ye"] = A[2]*S["2A-2G"]*S["2Zh-2A"]*Train.LK4.Value*TW[2]+T[2]*(1.0-Train.LK4.Value)
	S["1-7R-8"] = Train.VozvratRP.Value*B2
	S["25A"] = A[25]*TW[25]
	S["5V"] = Train.RKR.Value*TW[4]+T[4]*(1.0-Train.RKR.Value)
	S["27A"] = A[50]*TW[27]
	S["3A"] = A[3]*TW[3]
	S["5B'"] = S["5V"]*Train.LK3.Value
	S["28A"] = A[51]*TW[28]
	S["17A"] = A[17]*TW[17]
	S["10AYa"] = A[80]*B2
	S["4B"] = (1.0-Train.RKR.Value)*TW[4]
	S["6A"] = A[6]*TW[6]
	S["8A"] = A[8]*TW[8]
	S["10AE"] = A[30]*B2
	S["8Zh"] = S["8A"]*C((RK >= 17) and (RK <= 18))
	S["5B"] = Train.RKR.Value*TW[5]
	S["8G"] = S["8A"]*(1.0-Train.RT2.Value)*S["8A-8Ye"]
	S["20B"] = A[20]*(1.0-Train.RPvozvrat.Value)*TW[20]
	S["U0"] = A[27]*B2
	S["1Zh"] = S["1P"]*S["1G-1Zh"]*1*(1.0-Train.RPvozvrat.Value)
	S["10AV"] = S["10AYa"]*C((RK >= 2) and (RK <= 18))*(1.0-Train.LK3.Value)
	S["10AG"] = S["10AYa"]*S["10AG-10E"]*S["10AYa-10E"]
	S["10N"] = S["10AE"]*S["10N-10Zh"]*1+T["SDRK_ShortCircuit"]
	S["10I"] = S["10AE"]*Train.RheostatController.RKM
	S["10AH"] = S["10I"]*(1.0-Train.LK1.Value)
	S["10H"] = S["10I"]*Train.LK4.Value
	S["10B"] = S["10AE"]*S["10AE-10B"]
	S["6Yu"] = S["6A"]*C((P == 3) or (P == 4))*C((RK >= 1) and (RK <= 5))
	S["s3"] = S["U0"]*Train.DIPon.Value
	S["s10"] = S["U0"]*Train.DIPoff.Value
	S["1K"] = S["1Zh"]*C((P == 1) or (P == 2))
	S["1N"] = S["1Zh"]*C((P == 1) or (P == 3))

	-- Call all triggers
	Triggers["PneumaticNo2"](S["8G"])
	Triggers["LK2"](S["20B"])
	Triggers["ReverserForward"](S["5B"])
	Triggers["LK5"](S["20B"])
	Triggers["LK1"](S["1K"])
	Triggers["RPU"](S["27A"])
	Triggers["PneumaticNo1"](S["8Zh"])
	Train:WriteTrainWire(18,S["18A"])
	Triggers["LK4"](S["5B'"])
	Triggers["ReverserBackward"](S["4B"])
	Triggers["RUP"](S["6Yu"])
	Triggers["LK3"](S["1Zh"])
	Triggers["KSH2"](S["1R"])
	Triggers["RRTpod"](S["10AH"])
	T[2] = min(1,S["10AV"])
	Triggers["XR3.2"](S["27A"])
	Triggers["SDRK"](S["10N"])
	Triggers["KSB1"](S["6Yu"])
	Triggers["TR1"](S["6A"])
	Triggers["SR1"](S["2Ye"])
	Triggers["RPvozvrat"](S["17A"])
	Triggers["SDRK_Coil"](S["10B"])
	Triggers["TR2"](S["6A"])
	T[4] = min(1,TW[5])
	T[3] = min(1,S["5V"])
	T[1] = min(1,S["6A"])
	Triggers["KSH1"](S["1R"])
	Triggers["SDPP"](S["10AG"])
	Train:WriteTrainWire(17,S["1-7R-8"])
	Triggers["RRTuderzh"](S["25A"])
	Triggers["Rper"](S["3A"])
	Train:WriteTrainWire(28,S["s10"])
	Train:WriteTrainWire(27,S["s3"])
	Triggers["XR3.3"](S["28A"])
	Triggers["RUTpod"](S["10H"])
	Triggers["RV1"](S["2Ye"])
	Triggers["RR"](S["1N"])
	Triggers["KSB2"](S["6Yu"])
	return S
end