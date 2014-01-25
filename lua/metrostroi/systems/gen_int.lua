--------------------------------------------------------------------------------
function split(inputstr, sep)
		if sep == nil then sep = "%s" end
		t={} i=1
		for str in string.gmatch(inputstr, "([^"..sep.."]+)") do 
			t[i] = str
			i = i + 1
		end return t
end

function PSwitch(v,inverted)
	if inverted then
		if v == "PS" then				
			return "(P ~= 1)"
		elseif v == "PP" then
			return "(P ~= 2)"
		elseif v == "PT" then
			return "(P ~= 3)"
		elseif v == "PT1" then
			return "(P ~= 3)"
		elseif v == "PT2" then
			return "(P ~= 4)"
		end	
	else
		if v == "PS" then				
			return "(P == 1)"
		elseif v == "PP" then
			return "(P == 2)"
		elseif v == "PT" then
			return "(P == 3)"
		elseif v == "PT1" then
			return "(P == 3)"
		elseif v == "PT2" then
			return "(P == 4)"
		end
	end
	return nil
end

function ParseName(str)
	local inverted = false
	if string.sub(str,1,1) == "!" then inverted = true str = string.sub(str,2) end
	
	-- See if a position switch is specified
	if PSwitch(str) or PSwitch(string.sub(str,1,2)) then
		local f = "C("
		for k,v in pairs(split(str,",")) do
			if inverted then
				if f ~= "C(" then f = f.." or " end
			else
				if f ~= "C(" then f = f.." or " end
			end
			f = f..PSwitch(v)--,inverted)
		end
		f = f..")"
		return f
	end
	
	-- See if rheostat is specified
	if (string.sub(str,1,2) == "RK") and not string.find(str,"RKR") then

		local d = split(string.sub(str,3),"-")
		--[[if inverted then
			if d[2] then
				return "C((RK < "..d[1]..") or (RK > "..d[2].."))"
			else
				return "C(RK ~= "..d[1]..")"
			end
		else]]--
			if d[2] then
				return "C((RK >= "..d[1]..") and (RK <= "..d[2].."))"
			else
				return "C(RK == "..d[1]..")"
			end
		--end
	end
	
	-- Contactor
	if (string.sub(str,1,1) == "A") and (tonumber(string.sub(str,2))) then
		return "A["..string.sub(str,2).."]"
	end
	
	-- See if relay is specified
	if tonumber(str) then return str end
	if str == "RP" then 
		if inverted then
			return "(1.0-"..str..")"
		else
			return str 
		end
	end
	if inverted then
		return "(1.0-Train."..str..".Value)"	
	else
		return "Train."..str..".Value"	
	end
end

function Simplify()
	-- List of final statements
	Statements = {}
	NodeStatements = {}
	Triggers = {}
	
	-- Parse names
	for k,v in pairs(Network) do
		if string.sub(v[1],1,2) == "TW" then
			table.insert(Sources,v[1])
		end
		if string.sub(v[2],1,2) == "TW" then
			table.insert(Sources,v[2])
		end
	end
	
	-- Parse triggers
	for k,v in pairs(Network) do
		if string.sub(v[3],1,1) == "#" then
			local name = string.sub(v[3],2)
			Triggers[name] = v[1]
			
			table.insert(Drains,v[1])
			table.insert(Drains,v[2])
			Network[k] = nil
		end
	end
	
	-- Parse names
	for k,v in pairs(Network) do
		v[3] = ParseName(v[3])
	end

	-- Simplify
	local simplified = true
	while simplified do
		simplified = false
		
		-- Simplify objects in parallel
		for k1,v1 in pairs(Network) do
			for k2,v2 in pairs(Network) do
				if k2 > k1 then
					local m = 0
					if (v1[1] == v2[1]) or (v1[1] == v2[2]) then m = m + 1 end
					if (v1[2] == v2[1]) or (v1[2] == v2[2]) then m = m + 1 end
					if m == 2 then
						Network[k1] = nil
						Network[k2] = nil

						table.insert(Statements,{v1[3].."+"..v2[3],v1[1].."-"..v1[2]})
						table.insert(Network,{ v1[1],v1[2],"S[\""..Statements[#Statements][2].."\"]" })
						simplified = true
						break
					end
				end
			end
		end
		
		-- Simplify objects in series
		-- Count number of nodes with only two objects in it
		NodeCounts = {}
		for k,v in pairs(Network) do
			NodeCounts[v[1]] = (NodeCounts[v[1]] or 0) + 1
			NodeCounts[v[2]] = (NodeCounts[v[2]] or 0) + 1
		end
		for k,v in pairs(Sources) do NodeCounts[v] = (NodeCounts[v] or 0) + 1 end
		for k,v in pairs(Drains) do NodeCounts[v] = (NodeCounts[v] or 0) + 1 end

		-- Collapse two resistors into one
		for k,v in pairs(NodeCounts) do
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

					table.insert(Network,{ N1,N2,R1[3].."*"..R2[3] })
					Network[kR1] = nil
					Network[kR2] = nil
					simplified = true
					break
				end
			end
		end
		
		
		-- Turn more nodes into source nodes
		--[[for k,v in pairs(Network) do
			if srcs[v[1] ] then
				Network[k] = nil
				Statements[v[2] ] = "("..(Statements[v[1] ] or v[1])..")*("..v[3]..")"
				--table.insert(Network,{ v[1],v[2],"S[\""..v[2].."\"]" })				
				simplified = true
			elseif srcs[v[2] ] then
				Network[k] = nil
				Statements[v[1] ] = "("..(Statements[v[1] ] or v[2])..")*("..v[3]..")"
				--table.insert(Network,{ v[2],v[1],"S[\""..v[1].."\"]" })
				simplified = true
			end
		end]]--
	end
	
	-- Add the remaining network into statements
	local simplified = true
	while simplified do
		simplified = false
		
		for k,v in pairs(Network) do
			local src1,src2,dst1,dst2
			for k2,v2 in pairs(Sources) do 
				if v2 == v[1] then src1 = true end
				if v2 == v[2] then src2 = true end
			end
			--for k2,v2 in pairs(Drains) do 
				--if v2 == v[1] then dst1 = true end
				--if v2 == v[2] then dst2 = true end
			--end
			if src1 then
				local stat = ""..v[3].."*"..v[1]..""
				if NodeStatements[v[2]] then
					Statements[NodeStatements[v[2]]][1] = 
						Statements[NodeStatements[v[2]]][1] .. "+"..stat
					--table.insert(Statements,{ Statements[NodeStatements[v[2]]][1] .. "+"..stat, v[2] })
					--Statements[NodeStatements[v[2]]][1] = "0"
					--Statements[NodeStatements[v[2]]][2] = "SKIP"
					--NodeStatements[v[2]] = #Statements
				else
					table.insert(Statements,{ stat, v[2] })
					NodeStatements[v[2]] = #Statements
				end
				simplified = true
				Network[k] = nil
			elseif src2 then
				local stat = ""..v[3].."*"..v[2]..""
				if NodeStatements[v[1]] then
					--table.insert(Statements,{ Statements[NodeStatements[v[1]]][1] .. "+"..stat, v[1] })
					--Statements[NodeStatements[v[1]]][1] = "0"
					--Statements[NodeStatements[v[1]]][2] = "SKIP"
					--NodeStatements[v[1]] = #Statements
					Statements[NodeStatements[v[1]]][1] = 
						Statements[NodeStatements[v[1]]][1] .. "+"..stat
				else
					table.insert(Statements,{ stat, v[1] })
					NodeStatements[v[1]] = #Statements
				end
				simplified = true
				Network[k] = nil
			elseif NodeStatements[v[1]] and (not src2) then
				local stat = "S[\""..Statements[NodeStatements[v[1]]][2].."\"]*"..v[3]
				if NodeStatements[v[2]] then
					--table.insert(Statements,{ Statements[NodeStatements[v[2]]][1] .. "+"..stat, v[2] })
					--Statements[NodeStatements[v[2]]][1] = "0"
					--Statements[NodeStatements[v[2]]][2] = "SKIP"
					--NodeStatements[v[2]] = #Statements
					Statements[NodeStatements[v[2]]][1] = 
						Statements[NodeStatements[v[2]]][1] .. "+"..stat
				else
					table.insert(Statements,{ stat, v[2] })
					NodeStatements[v[2]] = #Statements
				end
				simplified = true
				Network[k] = nil
			elseif NodeStatements[v[2]] and (not src1) then
				local stat = "S[\""..Statements[NodeStatements[v[2]]][2].."\"]*"..v[3]..""
				if NodeStatements[v[1]] then
					Statements[NodeStatements[v[1]]][1] = 
						Statements[NodeStatements[v[1]]][1].."+"..stat
					--table.insert(Statements,{ Statements[NodeStatements[v[1]]][1] .. "+"..stat, v[1] })
					--Statements[NodeStatements[v[1]]][1] = "0"
					--Statements[NodeStatements[v[1]]][2] = "SKIP"
					--NodeStatements[v[1]] = #Statements
				else
					table.insert(Statements,{ stat, v[1] })
					NodeStatements[v[1]] = #Statements
				end
				simplified = true
				Network[k] = nil
			end
		end
	end
	
	-- Merge nodes as specified by user
	for k,v in pairs(MergeNodes) do
		Statements[NodeStatements[v[1]]][1] = 
			Statements[NodeStatements[v[1]]][1].."+S[\""..v[2].."\"]"
	end
	
	-- Reorder properly
	for k1,v1 in pairs(Statements) do
		local name = v1[2]
		for k2,v2 in pairs(Statements) do
			if (k2 < k1) and string.find(v2[1],"\""..name.."\"") then
				print("OUT OF ORDER",v2[1],name,k1,k2)
				table.insert(Statements,{v2[1],v2[2]})
				NodeStatements[v2[2]] = #Statements
				v2[2] = "SKIP"
			end
		end
	end	
end

--------------------------------------------------------------------------------
Network = {
	----------------------------------------------------------------------------
	-- Train wire 1
	{	"TW1",	"1A",	"A1" },
	{	"1A",	"1T",	"!PS,PP" },
	{	"1T",	"1P",	"NR" },
	{	"1T",	"1P",	"0" }, -- RPU
		
	{	"1P",	"1B",	"1" }, -- AVT
	{	"1B",	"1G",	"!RP" },
		
	{	"1G",	"1E",	"!RK1" },
	{	"1E",	"1Yu",	"KSH2" },
	{	"1E",	"1Ya",	"KSB2" },
	{	"1Ya",	"1Yu",	"KSB1" },
	{	"1Yu",	"1L",	"!PS,PT1" },
	{	"1L",	"1Zh",	"LK2" }, -- Usually LK5
	{	"1G",	"1Zh",	"LK3" },
		
	{	"1Zh",	"1K",	"!PS,PP" },
	{	"1Zh",	"1N",	"!PS,PT1" },
		
	{	"1Zh",	"0",	"#LK3" },
	{	"1K",	"0",	"#LK1" },
	{	"1N",	"0",	"#RR" },
	
	{	"1A",	"1V",	"!RV1" },
	{	"1V",	"1R",	"!PS" },
	{	"1A",	"1M",	"!RK1-5" },
	{	"1M",	"1R",	"PP" },
	
	{	"1R",	"0",	"#KSH1" },
	{	"1R",	"0",	"#KSH2" },
	
	
	----------------------------------------------------------------------------
	-- Train wire 2
	{	"TW2",	"2Zh",	"A2" },
	{	"2Zh",	"2A",	"!KSB1" },
	{	"2Zh",	"2A",	"!TR1" },
	
	{	"2A",	"2B",	"!PS,PT1" },
	{	"2B",	"2G",	"!RK1-17" },
	
	{	"2A",	"2V",	"PP,PT2" },
	{	"2V",	"2G",	"RK5-18" },
	{	"2V",	"2R",	"RK2-4" },
	{	"2R",	"2G",	"KSH1" },
	
	{	"2G",	"2Ye",	"LK4" },
	{	"2Ye",	"0",	"#SR1" },
	{	"2Ye",	"0",	"#RV1" },
	
	
	----------------------------------------------------------------------------
	-- Train wire 3
	{	"TW3",	"3A",	"A3" },
	{	"3A",	"0",	"#Rper" },
	

	----------------------------------------------------------------------------
	-- Train wires 4, 5
	{	"TW4",	"4B",	"!RKR" },
	{	"4B",	"0",	"#ReverserBackward" },
	{	"TW5",	"5B",	"RKR" },
	{	"5B",	"0",	"#ReverserForward" },
	
	{	"TW4",	"5V",	"RKR" },
	{	"TW5",	"5V",	"!RKR" },
	{	"5V",	"5B'",	"LK3" },
	{	"5B'",	"0",	"#LK4" },
	
	
	----------------------------------------------------------------------------
	-- Train wire 9/10
	{	"TW10",		"10AYa",	"A80" },
	{	"10AYa",	"10AB",		"!LK3" },
	{	"10AB",		"10AV",		"RK2-18" },
	{	"10AV",		"2Ye_p",	"!LK4" },
	
	-- SDPP movement triggers
	{	"10AYa",	"10E",		"!LK3" },
	--{	"10AYa",	"10E",		"PM,PS3" }, --FIXME
	{	"10AYa",	"10E",		"Rper" },
	
	-- SDPP step logic
	{	"10E",		"10Yu",		"LK3" },
	{	"10Yu",		"10Ya",		"RK18" },
	{	"10Ya",		"10AG",		"!PS" },
	
	{	"10E",		"10AP",		"!LK1" },
	{	"10AP",		"10AD",		"LK2" },
	{	"10AP",		"10AD",		"PT1,PT2" },
	
	{	"10AD",		"10AR'",	"!TR2" },
	{	"10AR'",	"10AR",		"!TR1" },
	{	"10AR",		"10AG",		"PP,PT1,PT2" },
	
	{	"10AD",		"10AT'",	"TR2" },
	{	"10AT'",	"10AT",		"TR1" },
	{	"10AT",		"10AG",		"!PS,PP,PT2" },
	
	{	"10AG",		"0",		"#SDPP" },
	
	-- SDRK coil circuit
	{	"TW10",		"10AE",		"A30" },
	{	"10AE",		"10B",		"TR1" },
	{	"10AE",		"10B",		"RV1" },
	{	"10AE",		"10B",		"RV1" },
	{	"10B",		"0",		"#SDRK_Coil" },
	
	-- SDRK motor circuit
	{	"10AE",		"10M",		"SR1" },
	--{	"10M",		"10MA",		"!RRT" },
	--{	"10M",		"10N",		"RUT" },
	{	"10M",		"10N",		"!RUT" },
	{	"10N",		"0",		"#SDRK" },
	
	
	----------------------------------------------------------------------------
	-- Train wire 20
	{	"TW20",	"20A",	"A17" },
	{	"20A",	"20B",	"!RP" },
	{	"20B",	"0",	"#LK2" },
	{	"20B",	"0",	"#LK5" },
}
Sources = {}
Drains = { "0", "2Ye_p" }
MergeNodes = {
	{ "2Ye", "2Ye_p" } -- Merge 2Ye from train wire 10 and train wire 6
}

Simplify()
for k,v in pairs(Network) do
	print(k,v[1],v[2],v[3])
end
print("Result:")
for k,v in pairs(Statements) do
	print("S[\""..v[2].."\"] = "..v[1])
end
for k,v in pairs(Triggers) do
	if not Statements[NodeStatements[v] ] then error("NO NODE "..v) end
	print("Trigger(\""..k.."\",S[\""..Statements[NodeStatements[v] ][2].."\"])")
end
SRC = 
[[-- Auto-generated by gen.lua

local S = {}
local function C(x) return x and 1 or 0 end

function INTERNAL_CIRCUITS.Solve(Train,Triggers)
	local A = {}
	for i=1,100 do A[i] = 1 end

	local P		= Train.PositionSwitch.SelectedPosition
	local RK	= Train.RheostatController.SelectedPosition
	local TW1	= Train:ReadTrainWire(1)  -- X1
	local TW2	= Train:ReadTrainWire(2)  -- X2
	local TW3	= Train:ReadTrainWire(3)  -- X3
	local TW6	= Train:ReadTrainWire(6)  -- T
	local TW4	= Train:ReadTrainWire(4)  -- R
	local TW5	= Train:ReadTrainWire(5)  -- F
	local TW20	= Train:ReadTrainWire(20) -- X
	local TW10	= Train:ReadTrainWire(9) + Train:ReadTrainWire(10)

	local RP = Train.RPL.Value + Train.RP1_3.Value + Train.RP2_4.Value
	
	-- Solve all circuits
]]
for k,v in pairs(Statements) do
	if v[2] ~= "SKIP" then
		SRC = SRC.."\tS[\""..v[2].."\"] = "..v[1].."\n"
	end	
end
SRC = SRC..
[[

	-- Call all triggers
]]
for k,v in pairs(Triggers) do
	if not Statements[NodeStatements[v] ] then error("NO NODE "..v) end
	SRC = SRC.."\tTriggers[\""..k.."\"](S[\""..Statements[NodeStatements[v] ][2].."\"])\n"
end
SRC = SRC..
[[
	return S
end]]


--------------------------------------------------------------------------------
--print(SRC)
local f = io.open("gen_int_81_705.lua","w+")
f:write(SRC)
f:close()