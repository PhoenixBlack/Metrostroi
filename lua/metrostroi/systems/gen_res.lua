--------------------------------------------------------------------------------
-- Simplify circuit (one step - series)
--------------------------------------------------------------------------------
function SimplifySeries()
	-- Count number of nodes with only two resistances in it
	ResistanceCounts = {}
	for k,v in pairs(Network) do
		ResistanceCounts[v[1]] = (ResistanceCounts[v[1]] or 0) + 1
		ResistanceCounts[v[2]] = (ResistanceCounts[v[2]] or 0) + 1
	end
	ResistanceCounts[Start] = (ResistanceCounts[Start] or 0) + 1
	ResistanceCounts[End] = (ResistanceCounts[End] or 0) + 1

	-- Collapse two resistors into one
	for k,v in pairs(ResistanceCounts) do
		if v == 2 then
			local R1,R2,kR1,kR2
			for k2,v2 in pairs(Network) do
				if (v2[1] == k) or (v2[2] == k) then
					if not R1 then R1 = v2 kR1 = k2 else R2 = v2 kR2 = k2 end
				end
			end

			-- Simplify resistances
			if R1 and R2 then
				local N1,N2

				N1 = R1[1]
				N2 = R2[1]
				if (N1 == k) then N1 = R1[2] end
				if (N2 == k) then N2 = R2[2] end

				table.insert(Network,{ N1,N2,R1[3].."+"..R2[3] })
				Network[kR1] = nil
				Network[kR2] = nil
				Simplified = true
				return true
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Simplify parallel
--------------------------------------------------------------------------------
function SimplifyParallel()
	-- Find two resistances which share nodes
	for k1,v1 in pairs(Network) do
		for k2,v2 in pairs(Network) do
			if k2 > k1 then
				local m = 0
				if (v1[1] == v2[1]) or (v1[1] == v2[2]) then m = m + 1 end
				if (v1[2] == v2[1]) or (v1[2] == v2[2]) then m = m + 1 end
				if m == 2 then
					Network[k1] = nil
					Network[k2] = nil

					table.insert(ExtraStatements,"(("..v1[3]..")^-1 + ("..v2[3]..")^-1)^-1")
					table.insert(Network,{ v1[1],v1[2],"R["..(#ExtraStatements).."]" })
					Simplified = true
					return true
				end
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Transform Y to Delta
--------------------------------------------------------------------------------
function TransformYDelta()
	-- Find three resistances looking into a single point
	ResistanceCounts = {}
	for k,v in pairs(Network) do
		ResistanceCounts[v[1]] = (ResistanceCounts[v[1]] or 0) + 1
		ResistanceCounts[v[2]] = (ResistanceCounts[v[2]] or 0) + 1
	end
	ResistanceCounts[Start] = (ResistanceCounts[Start] or 0) + 1
	ResistanceCounts[End] = (ResistanceCounts[End] or 0) + 1

	-- Replace them with new resistors
	for k,v in pairs(ResistanceCounts) do
		if v == 3 then
			local R1,R2,R3,kR1,kR2,kR3
			for k2,v2 in pairs(Network) do
				if (v2[1] == k) or (v2[2] == k) then
					if not R1 then
						R1 = v2 kR1 = k2
					elseif not R2 then
						R2 = v2 kR2 = k2
					else
						R3 = v2 kR3 = k2
					end
				end
			end

			-- Simplify resistances
			if R1 and R2 and R3 then
				local N1,N2,N3

				N1 = R1[1]
				N2 = R2[1]
				N3 = R3[1]
				if (N1 == k) then N1 = R1[2] end
				if (N2 == k) then N2 = R2[2] end
				if (N3 == k) then N3 = R3[2] end

				local Ra = "(("..R1[3]..")*("..R2[3]..")+("..R1[3]..")*("..R3[3]..")+("..R2[3]..")*("..R3[3].."))/("..R1[3]..")"
				local Rb = "(("..R1[3]..")*("..R2[3]..")+("..R1[3]..")*("..R3[3]..")+("..R2[3]..")*("..R3[3].."))/("..R2[3]..")"
				local Rc = "(("..R1[3]..")*("..R2[3]..")+("..R1[3]..")*("..R3[3]..")+("..R2[3]..")*("..R3[3].."))/("..R3[3]..")"

				table.insert(ExtraStatements,Ra)
				Ra = "R["..(#ExtraStatements).."]"
				table.insert(ExtraStatements,Rb)
				Rb = "R["..(#ExtraStatements).."]"
				table.insert(ExtraStatements,Rc)
				Rc = "R["..(#ExtraStatements).."]"

				Network[kR1] = nil
				Network[kR2] = nil
				Network[kR3] = nil
				table.insert(Network, { N1,N2,Rc })
				table.insert(Network, { N1,N3,Rb })
				table.insert(Network, { N2,N3,Ra })

				Simplified = true
				return true
			end
		end
	end

end

--------------------------------------------------------------------------------
-- Simplify network and return string
--------------------------------------------------------------------------------
function Simplify(name)
	local function copy(t) 
		local t2 = {}
		for k,v in pairs(t) do
			if type(v) ~= "table" then
				t2[k] = v
			else
				t2[k] = copy(v)
			end
		end
		return t2
	end
	Network = copy(BaseNetwork)	
	ExtraStatements = {}

	-- Start simplifying
	Simplified = true
	while Simplified do
		Simplified = false
		if not SimplifyParallel() then
			if not SimplifySeries() then
				TransformYDelta()
			end
		end
	end

	--for k,v in pairs(Network) do
		--print(v[1],v[2],v[3])
	--end
	S =    "function RESISTOR_BLOCKS."..name.."(Train)\n"
	S = S.."\tlocal RK = Train.RheostatController\n"
	S = S.."\tlocal T = Train.PositionSwitch\n"
	for k,v in pairs(ExtraStatements) do
		S = S.."\tR["..k.."] = "..v.."\n"
	end
	for k,v in pairs(Network) do
		S = S.."\treturn "..v[3].."\n"
	end
	S = S.."end\n\n"
	return S
end




--------------------------------------------------------------------------------
-- Run tests
--------------------------------------------------------------------------------
function Test()
	RheostatConfiguration = {
	--   ##      1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27
		[ 1] = { 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0 },
		[ 2] = { 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0 },
		[ 3] = { 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0 },
		[ 4] = { 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0 },
		[ 5] = { 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0 },
		[ 6] = { 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0 },
		[ 7] = { 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0 },
		[ 8] = { 0, 0, 0, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0 },
		[ 9] = { 0, 0, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0 },
		[10] = { 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0 },
		[11] = { 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0 },
		[12] = { 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0 },
		[13] = { 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0 },
		[14] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0 },
		[15] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0 },
		[16] = { 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0 },
		[17] = { 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0 },
		[18] = { 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0, 1 },
	}
	PositionConfiguration = {
	--   ##      1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 
		[ 1] = { 0, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 1, 0, 0, 0, 1, 0, 1 },-- PS
		[ 2] = { 1, 0, 1, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0, 0 },-- PP
		[ 3] = { 0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 0 },-- PT1
		[ 4] = { 0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 0 },-- PT2 (not used)
	}
	Resistors = {
		["L12-L13"]	= 1.730,
		["P3-P4"]	= 0.144,
		["P4-P5"]	= 0.223,
		["P5-P6"]	= 0.190,
		["P6-P7"]	= 0.223,
		["P7-P8"]	= 0.223,
		["P8-P9"]	= 0.190,
		["P9-P10"]	= 0.144,
		["P10-P11"]	= 0.144,
		["P11-P12"]	= 1.070,
		["P12-P13"]	= 0.485,
		["P1-P3"]	= 0.715,
		["P3-P14"]	= 1.620,
		["P13-P42"]	= 0.285,
		
		["P16-P17"]	= 0.485,
		["P17-P18"]	= 0.120,
		["P18-P19"]	= 0.223,
		["P19-P20"]	= 0.190,
		["P20-P21"]	= 0.223,
		["P21-P22"]	= 0.223,
		["P22-P23"]	= 0.190,
		["P23-P24"]	= 0.144,
		["P24-P25"]	= 0.144,
		["P25-P26"]	= 0.716,
		["P17-P76"]	= 0.246,
		["P76-P27"]	= 1.710,
		
		["L2-L4"]	= 1.140,
		["L24-L39"]	= 1.000,
		["L40-L63"]	= 1.000,
		
		["L74-P37"]	= 0.296,
		["P37-P36"]	= 0.063,
		["P36-P35"]	= 0.028,
		
		["P35-K2"]	= 0.042,
		["L76-P31"]	= 0.296,
		["P31-P30"]	= 0.063,
		["P30-P29"]	= 0.028,
		["P29-P28"]	= 0.042,
		
		["P13-P33"]	= 51,
		["MK1-MK2"]	= 18.75,
		["P33-P42"]	= 300,
	}

	-- Load source code
	RESISTOR_BLOCKS = {}
	loadstring(SRC)()
	
	-- Create 'train'
	Train = {}
	Train.RheostatController = {}
	Train.PositionSwitch = {}
	Train.KF_47A = {}
	Train.KF_50A = {}
	Train.YAS_44V = {}
	for k,v in pairs(Resistors)  do
		Train.KF_47A[k] = v
		Train.KF_50A[k] = v
		Train.YAS_44V[k] = v
	end
	Train.TR1 = { Value = 0 }
	Train.TR2 = { Value = 0 }
	
	-- Run tests
	ANS = {}
	for i=1,18 do
		ANS[i] = ANS[i] or {}
		for k,v in pairs(RheostatConfiguration[i]) do
			Train.RheostatController[k] = 1e-9 + 1e9 * (1-v)
		end

		RESISTOR_BLOCKS.InitializeResistances_81_705(Train)
		
		for k,v in pairs(PositionConfiguration[1]) do
			Train.PositionSwitch[k] = 1e-9 + 1e9 * (1-v)
		end
		Train.TR1 = { Value = 0 }
		Train.TR2 = { Value = 0 }
		ANS[i][1] = RESISTOR_BLOCKS.R1C1(Train)
		ANS[i][2] = RESISTOR_BLOCKS.R2C1(Train)
		
		for k,v in pairs(PositionConfiguration[2]) do
			Train.PositionSwitch[k] = 1e-9 + 1e9 * (1-v)
		end
		ANS[i][3] = RESISTOR_BLOCKS.R1C2(Train)
		ANS[i][4] = RESISTOR_BLOCKS.R2C2(Train)
		
		for k,v in pairs(PositionConfiguration[3]) do
			Train.PositionSwitch[k] = 1e-9 + 1e9 * (1-v)
		end
		Train.TR1 = { Value = 1 }
		Train.TR2 = { Value = 1 }
		ANS[i][5] = RESISTOR_BLOCKS.R1C1(Train)
		ANS[i][6] = RESISTOR_BLOCKS.R2C1(Train)
		ANS[i][7] = RESISTOR_BLOCKS.R3(Train)
		
		
		ANS[i][8] = ANS[i][1]+ANS[i][2]
		ANS[i][9] = ANS[i][5]+ANS[i][6]+ANS[i][7]
		
		ANS[i][10] = RESISTOR_BLOCKS.S1(Train)
		ANS[i][11] = RESISTOR_BLOCKS.S1(Train)
	end
	
	PrintAnswers()
end

function PrintAnswers()
	local INFO = "Rxx   PS1   PS2   PP1   PP2   PT2   PT2   T3    PS    PT     S1     S2 \n"
	for i=1,18 do
		local S = ""
		for idx=1,#ANS[i] do
			S = S.." "..string.format("%.3f",ANS[i][idx])
		end
		INFO = INFO..string.format("R%02d =",i)..S.."\n"
	end
	print(INFO)
	SRC = "--[[\n"..INFO.."]]--\n\n"..SRC
end




--------------------------------------------------------------------------------
-- Define electric systems
--------------------------------------------------------------------------------
SRC = 
[[-- Auto-generated by gen.lua
local R = {}

local P12_13
local P11_12
local P10_11
local P9_10
local P8_9
local P7_8
local P6_7
local P5_6
local P4_5
local P3_4
local P1_3

local P25_26
local P24_25
local P23_24
local P22_23
local P21_22
local P20_21
local P19_20
local P18_19
local P17_18
local P16_17

local P3_P14
local P17_P76
local P76_P27

local P29_P28
local P30_P29
local P31_P30
local L76_P31

local P35_K2
local P36_P35
local P37_P36
local L74_P37

local P33_P42
local P13_P33
local P13_P42

function RESISTOR_BLOCKS.InitializeResistances_81_705(Train)
	P12_13		= Train.KF_47A["P12-P13"]
	P11_12		= Train.KF_47A["P11-P12"]
	P10_11		= Train.KF_47A["P10-P11"]
	P9_10		= Train.KF_47A["P9-P10"]
	P8_9		= Train.KF_47A["P8-P9"]
	P7_8		= Train.KF_47A["P7-P8"]
	P6_7		= Train.KF_47A["P6-P7"]
	P5_6		= Train.KF_47A["P5-P6"]
	P4_5		= Train.KF_47A["P4-P5"]
	P3_4		= Train.KF_47A["P3-P4"]
	P1_3		= Train.KF_47A["P1-P3"]

	P25_26		= Train.KF_47A["P25-P26"]
	P24_25		= Train.KF_47A["P24-P25"]
	P23_24		= Train.KF_47A["P23-P24"]
	P22_23		= Train.KF_47A["P22-P23"]
	P21_22		= Train.KF_47A["P21-P22"]
	P20_21		= Train.KF_47A["P20-P21"]
	P19_20		= Train.KF_47A["P19-P20"]
	P18_19		= Train.KF_47A["P18-P19"]
	P17_18		= Train.KF_47A["P17-P18"]
	P16_17		= Train.KF_47A["P16-P17"]

	P3_P14		= Train.KF_47A["P3-P14"]
	P17_P76		= Train.KF_47A["P17-P76"]
	P76_P27		= Train.KF_47A["P76-P27"]

	P29_P28		= Train.KF_50A["P29-P28"]
	P30_P29		= Train.KF_50A["P30-P29"]
	P31_P30		= Train.KF_50A["P31-P30"]
	L76_P31		= Train.KF_50A["L76-P31"]

	P35_K2		= Train.KF_50A["P35-K2"]
	P36_P35		= Train.KF_50A["P36-P35"]
	P37_P36		= Train.KF_50A["P37-P36"]
	L74_P37		= Train.KF_50A["L74-P37"]

	P33_P42		= Train.YAS_44V["P33-P42"]
	P13_P33		= Train.YAS_44V["P13-P33"]
	P13_P42		= Train.KF_47A["P13-P42"]
end

]]



--------------------------------------------------------------------------------
-- Rheostat 1
--------------------------------------------------------------------------------
BaseNetwork = {
	{ "L8",   "P11",   "RK[15]+T[20]"},
	{ "P11",  "P13", "RK[19]"},
	{ "P11",  "P12", "RK[17]"},
	{ "P11",  "P10", "T[22]"},	

	{ "L8",   "P9",  "RK[13]"},
	{ "L8",   "P8",  "RK[11]"},
	{ "L8",   "P7",  "RK[9]"},
	{ "L8",   "P6",  "RK[7]"},
	{ "L8",   "P5",  "RK[5]"},
	{ "L8",   "P4",  "RK[5]+T[1]"},

	{ "L8",   "P3",  "RK[3]"},
	{ "L8",   "P3",  "1e-9+1e9*(1.0-Train.TR2.Value)"},
	
	{ "P1",   "P14", "RK[1]"},
	{ "P3",   "P14", "P3_P14"},
	{ "P13",  "P14", "T[19]"},

	{ "P13",  "P12", "P12_13"},
	{ "P12",  "P11", "P11_12"},
	{ "P11",  "P10", "P10_11"},
	{ "P10",  "P9",  "P9_10"},
	{ "P9",   "P8",  "P8_9"},
	{ "P8",   "P7",  "P7_8"},
	{ "P7",   "P6",  "P6_7"},
	{ "P6",   "P5",  "P5_6"},
	{ "P5",   "P4",  "P4_5"},
	{ "P4",   "P3",  "P3_4"},
	{ "P3",   "P1",  "P1_3"},
}
Start = "L8"
End = "P13"
SRC = SRC..Simplify("R1C1")

Start = "L8"
End = "P3"
SRC = SRC..Simplify("R1C2")


--------------------------------------------------------------------------------
-- Rheostat 2
--------------------------------------------------------------------------------
BaseNetwork = {
	{ "L12",  "P25", "RK[16]+T[14]"},
	{ "P25",  "P24", "T[16]"},
	{ "P25",  "P26", "RK[18]"},

	{ "L12",  "P23", "RK[14]"},
	{ "L12",  "P22", "RK[12]"},
	{ "L12",  "P21", "RK[10]"},
	{ "L12",  "P20", "RK[8]"},
	{ "L12",  "P19", "RK[6]"},
	{ "L12",  "P18", "RK[6]+T[15]"},

	{ "L12",  "P17", "RK[4]"},
	{ "L12",  "P17", "1e-9+1e9*(1.0-Train.TR2.Value)"},
	
	{ "P17",  "P76", "P17_P76"},
	{ "P76",  "P27", "P76_P27"},
	{ "P27",  "P26", "T[21]"},
	{ "P16",  "P27", "RK[2]"},
	{ "P76",  "P27", "RK[27]"},

	{ "P26",  "P25", "P25_26"},
	{ "P25",  "P24", "P24_25"},
	{ "P24",  "P23", "P23_24"},
	{ "P23",  "P22", "P22_23"},
	{ "P22",  "P21", "P21_22"},
	{ "P21",  "P20", "P20_21"},
	{ "P20",  "P19", "P19_20"},
	{ "P19",  "P18", "P18_19"},
	{ "P18",  "P17", "P17_18"},
	{ "P17",  "P16", "P16_17"},
}
Start = "L12"
End = "P26"
SRC = SRC..Simplify("R2C1")

Start = "L12"
End = "P17"
SRC = SRC..Simplify("R2C2")


--------------------------------------------------------------------------------
-- Extra circuits
--------------------------------------------------------------------------------
BaseNetwork = {
	{ "P13",  "P42", "P13_P42"},
	{ "P13",  "P42", "RK[20]"},
	{ "P13",  "P33", "P13_P33"},
	{ "P33",  "P42", "P33_P42"},
}
Start = "P13"
End = "P42"
SRC = SRC..Simplify("R3")


BaseNetwork = {
	{ "P28",   "P29",   "P29_P28"},
	{ "P29",   "P30",   "P30_P29"},
	{ "P30",   "P31",   "P31_P30"},
	{ "P31",   "L76",   "L76_P31"},

	{ "L76",   "P29",   "RK[25]"},
	{ "L76",   "P30",   "RK[23]"},
	{ "L76",   "P31",   "RK[21]"},
}
Start = "P28"
End = "L26"
SRC = SRC..Simplify("S1")


BaseNetwork = {
	{ "K2",    "P35",   "P35_K2"},
	{ "P35",   "P36",   "P36_P35"},
	{ "P36",   "P37",   "P37_P36"},
	{ "P37",   "L74",   "L74_P37"},

	{ "L74",   "P35",   "RK[26]"},
	{ "L74",   "P36",   "RK[24]"},
	{ "L74",   "P37",   "RK[22]"},
}
Start = "K2"
End = "L74"
SRC = SRC..Simplify("S2")


--------------------------------------------------------------------------------
Test()
local f = io.open("gen_resblocks.lua","w+")
f:write(SRC)
f:close()