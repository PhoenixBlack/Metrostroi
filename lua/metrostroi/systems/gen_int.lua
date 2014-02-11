--------------------------------------------------------------------------------
function split(inputstr, sep)
		if sep == nil then sep = "%s" end
		t={} i=1
		for str in string.gmatch(inputstr, "([^"..sep.."]+)") do 
			t[i] = str
			i = i + 1
		end return t
end


--------------------------------------------------------------------------------
-- Turn switch name into a statement
--------------------------------------------------------------------------------
function ProcessSwitchName(v,inverted)
	if inverted then
		if v == "PS" then		return "(P ~= 1)"
		elseif v == "PP" then	return "(P ~= 2)"
		elseif v == "PT" then	return "(P ~= 3)"
		elseif v == "PT1" then	return "(P ~= 3)"
		elseif v == "PT2" then	return "(P ~= 4)"
		end	
	else
		if v == "PS" then		return "(P == 1)"
		elseif v == "PP" then	return "(P == 2)"
		elseif v == "PT" then	return "(P == 3)"
		elseif v == "PT1" then	return "(P == 3)"
		elseif v == "PT2" then	return "(P == 4)"
		end
	end
	return nil
end


--------------------------------------------------------------------------------
-- Turn element name into element code
--------------------------------------------------------------------------------
function ParseName(str)
	if string.sub(str,1,1) == "#" then return str end
	local inverted = false
	if string.sub(str,1,1) == "!" then inverted = true str = string.sub(str,2) end
	
	-- See if a position switch is specified
	if ProcessSwitchName(str) or ProcessSwitchName(string.sub(str,1,2)) then
		local f = "C("
		for k,v in pairs(split(str,",")) do
			if f ~= "C(" then f = f.." or " end
			f = f..ProcessSwitchName(v)--,inverted)
		end
		f = f..")"
		return f
	end
	
	-- See if rheostat is specified
	if str == "RKM1" then
		return "Train.RheostatController.RKM"
	end	
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
	--if (string.sub(str,1,1) == "A") and (tonumber(string.sub(str,2))) then
	--	return "A["..string.sub(str,2).."]"
	--end
	if string.sub(str,1,2) == "T[" then
		return str
	end
	if string.sub(str,1,5) == "KV70[" then
		return "Train.KV[\""..string.sub(str,6,#str-1).."\"]"
	end
	if string.sub(str,1,3) == "TW[" then
		local twNo = string.sub(str,4,#str-1)
		if not tonumber(twNo) then twNo = "\""..twNo.."\"" end
		return "Train:ReadTrainWire("..twNo..")"
	end

	
	-- See if relay is specified
	if tonumber(str) then return str end
	if str == "RP" then str = "RPvozvrat" end
	if str == "_" then return "COIL" end
	if str == "B" then return "B" end

	-- Train variable
	if inverted then	return "(1.0-Train."..str..".Value)"	
	else				return "Train."..str..".Value"	
	end
end


--------------------------------------------------------------------------------
-- Simplify two elements in parallel
--------------------------------------------------------------------------------
function SimplifyParallel()
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

					--local node_name = v1[1].."-"..v1[2]
					--NodeValues[node_name] = v1[3].."+"..v2[3]
					table.insert(Statements,{v1[3].."+"..v2[3],v1[1].."-"..v1[2]})
					table.insert(Network,{ v1[1],v1[2],"S[\""..Statements[#Statements][2].."\"]" })
					--table.insert(Network,{ v1[1],v1[2],"S[\""..node_name.."\"]" })
					return true
				end
			end
		end
	end
end


--------------------------------------------------------------------------------
-- Simplify elements in series
--------------------------------------------------------------------------------
function SimplifySeries()
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

				table.insert(Network,{ N1,N2, R1[3].."*"..R2[3] })
				Network[kR1] = nil
				Network[kR2] = nil
				return true
			end
		end
	end
end


--------------------------------------------------------------------------------
-- Finish up the network
--------------------------------------------------------------------------------
function FinishNetwork()
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

			-- This will merge network together
			if src1 then
				local stat = ""..v[3].."*"..ParseName(v[1])..""
				if NodeStatements[v[2]] then
					Statements[NodeStatements[v[2]]][1] = 
						Statements[NodeStatements[v[2]]][1] .. "+"..stat
				else
					table.insert(Statements,{ stat, v[2] })
					NodeStatements[v[2]] = #Statements
				end
				simplified = true
				Network[k] = nil
			elseif src2 then
				local stat = ""..v[3].."*"..ParseName(v[2])..""
				if NodeStatements[v[1]] then
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
	--[[for k,v in pairs(MergeNodes) do
		if not NodeStatements[v[1] ] then error("Not found for merge [1]: "..v[1]) end
		if not Statements[NodeStatements[v[1] ] ] then error("Not found for merge [2]: "..v[1]) end
		Statements[NodeStatements[v[1] ] ][1] = 
			Statements[NodeStatements[v[1] ] ][1].."+S[\""..v[2].."\"]"
	end]]--
	for k,v in pairs(AddToNodes) do
		if not IsSource[v[1] ] then
			if not NodeStatements[v[1] ] then error("Not found [1]: "..v[1]) end
			if not Statements[NodeStatements[v[1] ] ] then error("Not found [2]: "..v[1]) end
			Statements[NodeStatements[v[1] ] ][1] = 
				Statements[NodeStatements[v[1] ] ][1].."+"..v[2]
		end
	end
	
	-- Reorder properly
	for k1,v1 in pairs(Statements) do
		local name = v1[2]
		for k2,v2 in pairs(Statements) do
			if (k2 < k1) and string.find(v2[1],"\""..name.."\"") then
				print("Statement out of order",v2[1],name,k1,k2)
				table.insert(Statements,{v2[1],v2[2]})
				NodeStatements[v2[2]] = #Statements
				v2[2] = "SKIP"
			end
		end
	end
end


--------------------------------------------------------------------------------
-- Simplify network
--------------------------------------------------------------------------------
function Simplify()
	-- List of final statements
	Statements = {}
	-- ID of statement for given node
	NodeStatements = {}
	-- List of triggers
	Triggers = {}
	-- Number of temp variables
	TempVariables = 0
	-- Number of temp nodes
	TempNodes = 0
	
	-- Add all special nodes to sources (train wires, etc)
	local sources = {}
	for k,v in pairs(Network) do
		if string.sub(v[1],1,2) == "TW" then sources[v[1]] = true end
		if string.sub(v[2],1,2) == "TW" then sources[v[2]] = true end
	end
	for k,v in pairs(sources) do table.insert(Sources,k) end
	
	-- Parse names of all the elements
	for k,v in pairs(Network) do v[3] = ParseName(v[3]) end
	
	-- Find if there are any diodes that must split the network
	for k,v in pairs(Network) do
		for k2,v2 in pairs(Diodes) do
			if (v[1] == v2[1]) and (v[2] == v2[2]) then
				print("Split network with diode "..v[1].." |-> "..v[2])
				
				TempVariables = TempVariables + 1
				local temp = "T["..TempVariables.."]"
				
				-- Make a diode
				Network[k] = nil
				table.insert(Network,{ v[1], "0", "#"..temp })
				table.insert(AddToNodes,{ v[2], temp.."*"..v[3] })
				
				-- Make sure the node doesn't get simplified
				table.insert(Drains,v[2])
			elseif (v[2] == v2[1]) and (v[1] == v2[2]) then
				print("Split network with diode "..v[2].." |-> "..v[1])
				
				TempVariables = TempVariables + 1
				local temp = "T["..TempVariables.."]"
				
				-- Make a diode
				Network[k] = nil
				table.insert(Network,{ v[2], "0", "#"..temp })
				table.insert(AddToNodes,{ v[1], temp.."*"..v[3] })
				
				-- Make sure the node doesn't get simplified
				table.insert(Drains,v[1])
			end
		end
	end
	
	-- Make sure all nodes that will be added to will be retained in the end
	for k,v in pairs(AddToNodes) do table.insert(Drains,v[1]) end
	
	-- Quick check for sources
	IsSource = {}
	for k,v in pairs(Sources) do IsSource[v] = true end
	IsDrain = {}
	for k,v in pairs(Drains) do IsDrain[v] = true end
	
	-- Find if there are nodes that belong to more than one source, replace them with temp variables
	NodeSource = {}
	for k,v in pairs(Sources) do NodeSource[v] = v end
	for k,v in pairs(Network) do
		if NodeSource[v[1]] and not NodeSource[v[2]] then
			NodeSource[v[2]] = NodeSource[v[1]]
		elseif NodeSource[v[2]] and not NodeSource[v[1]] then
			NodeSource[v[1]] = NodeSource[v[2]]
		elseif NodeSource[v[1]] and NodeSource[v[2]] then
			if (NodeSource[v[1]] ~= NodeSource[v[2]]) and (v[1] ~= "0") and (v[2] ~= "0") then
				local split_node,second_node = v[1],v[2]
				if IsSource[split_node] then split_node,second_node = v[2],v[1] end
				if IsSource[split_node] then error("Cannot connect two source nodes directly") end
				local expr = v[3]

				-- Create new temporary variable
				TempVariables = TempVariables + 1
				local temp1 = "T["..TempVariables.."]"
				TempVariables = TempVariables + 1
				local temp2 = "T["..TempVariables.."]"
	
				-- Add more sections to network
				Network[k] = nil
				table.insert(Network,{ split_node,  "0", "#"..temp1 })
				table.insert(Network,{ second_node, "0", "#"..temp2 })

				table.insert(AddToNodes,{ split_node,  temp2.."*"..expr })
				table.insert(AddToNodes,{ second_node, temp1.."*"..expr })
				
				-- Make sure the node doesn't get simplified
				table.insert(Drains,split_node)
				table.insert(Drains,second_node)
	
				print("Found split in network at "..split_node.." - "..second_node)
			end
		end
	end
	
	-- Parse triggers
	for k,v in pairs(Network) do
		if string.sub(v[3],1,1) == "#" then
			local name = string.sub(v[3],2)
			Triggers[name] = v[1]
			
			-- Remove relays facing the grounding
			if IsDrain[v[1]] or IsDrain[v[2]] then
				-- Make both ends drains  (drain nodes are not consumed during simplification)
				table.insert(Drains,v[1])
				table.insert(Drains,v[2])
				
				-- Remove this element
				Network[k] = nil			
			else
				-- Make both ends drains  (drain nodes are not consumed during simplification)
				table.insert(Drains,v[1])
				table.insert(Drains,v[2])
			
				-- Replace the trigger from network with a logical one
				v[3] = "COIL"
			end
		end
	end

	-- Simplify the circuit down as much as possible
	local simplified = true
	while simplified do
		simplified = false
		
		-- Simplify objects in parallel
		simplified = simplified or SimplifyParallel()
		-- Simplify objects in series
		simplified = simplified or SimplifySeries()
	end
	
	-- Finish up the network
	FinishNetwork()
	

	--[[-- Print the remaining result
	print("Simplified network:")
	for k,v in pairs(Network) do
		print(k,v[1],v[2],v[3])
	end	
	-- Print the node values
	print("Statements:")
	for k,v in pairs(Statements) do
		print("S[\""..v[2].."\"] =\t"..v[1])
	end
	-- Print triggers
	print("Triggers:")
	for k,v in pairs(Triggers) do
		print("Trigger[\""..k.."\"] =\tS[\""..v.."\"]")
	end]]--
end


--------------------------------------------------------------------------------
-- Generate source code
--------------------------------------------------------------------------------
function GenerateSource()
	local isSpecialTrigger = {}
	for k,v in pairs(SpecialTriggers) do isSpecialTrigger[v] = true end
	
	SRC = 
[[-- Auto-generated by gen.lua

local TW = {}

local S = {}
local T = {}
for i=1,]]..TempVariables..[[ do T[i] = 0 end
local function C(x) return x and 1 or 0 end

local min = math.min

function INTERNAL_CIRCUITS.Solve(Train,Triggers)
	local P		= Train.PositionSwitch.SelectedPosition
	local RK	= Train.RheostatController.SelectedPosition
	local B		= (Train.Battery.Voltage > 55) and 1 or 0
	
	-- Solve all circuits
]]
	for k,v in pairs(ExtraStatements) do
		SRC = SRC.."\t"..v.."\n"
	end
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
		-- Find statement for trigger
		local statement = v
		if NodeStatements[v] then
			statement = "S[\""..Statements[NodeStatements[v] ][2].."\"]"
		else
			statement = ParseName(statement)
		end

		-- Generate trigger
		if string.sub(k,1,2) == "I[" then
			local iID = string.sub(k,3,#k-1)
			SRC = SRC.."\tTrain.Panel[\""..iID.."\"] = "..statement.."\n"
		elseif string.sub(k,1,2) == "T[" then
			SRC = SRC.."\t"..k.." = min(1,"..statement..")\n"
		elseif string.sub(k,1,3) == "TW[" then
			local twNo = string.sub(k,4,#k-1)
			if not tonumber(twNo) then twNo = "\""..twNo.."\"" end
			SRC = SRC.."\tTrain:WriteTrainWire("..twNo..","..statement..")\n"
		else
			if isSpecialTrigger[k] then
				SRC = SRC.."\tTriggers[\""..k.."\"]("..statement..")\n"
			else
				SRC = SRC.."\tTrain."..k..":TriggerInput(\"Set\","..statement..")\n"
			end
		end
	end
	SRC = SRC..
[[
	return S
end]]
end




--------------------------------------------------------------------------------
Network = {
	----------------------------------------------------------------------------
	-- Battery circuits
	{	"B",		"B1",		"1" }, -- P1
	{	"B",		"B9",		"1" }, -- P2
	{	"B1",		"B12",		"VB" },
	{	"B9",		"B2",		"VB" },
	
	{	"B2",		"B8",		"A53" },
	{	"B8",		"B22",		"A75" },
	{	"B22",		"0",		"#KUP" },
	{	"B8",		"0",		"#KVC" },
	
	{	"B8",		"B28",		"KUP" },
	{	"B28",		"0",		"#I[KUP]" },	
	{	"B8",		"36Ya",		"KVC" },
	{	"36Ya",		"0",		"#XR3.4" },
	{	"36Ya",		"0",		"#XR3.6" },
	{	"36Ya",		"0",		"#XR3.7" },
	
	{	"B12",		"0",		"#I[EmergencyLight]" },
	
	{	"B12",		"B16",		"VB" },
	{	"B16",		"10/4",		"A56" },
	{	"10/4",		"0",		"#TW[10]" },
	{	"10/4",		"0",		"#TW[9]" },
	{	"TW[10]",	"10",		"1" },
	
	{	"B12",		"B13",		"A24" },
	{	"B13",		"0",		"#XT3.1" },
	
	{	"B2",		"B3",		"A44" },
	{	"B3",		"1-7R-29",	"RezMK" },
	{	"1-7R-29",	"0",		"#TW[23]" },
	
	
	----------------------------------------------------------------------------
	-- Panel circuits
	{	"10/4",		"22K",		"A10" },
	{	"10/4",		"22E",		"VMK" },
	{	"22E",		"22E'",		"AK" },
	{	"22E'",		"0",		"#TW[22]" },
	
	{	"10/4",		"0",		"#I[V1]" },
	
	{	"10/4",		"U0",		"A27" },
	{	"U0",		"U0a",		"1" },
	{	"U0a",		"0",		"#I[GreenRP]" }, -- Simulate 10AH wire properly (see addtonodes)

	{	"U0",		"s3",		"DIPon" },
	{	"U0",		"s10",		"DIPoff" },
	{	"s3",		"0",		"#TW[27]" },
	{	"s10",		"0",		"#TW[28]" },
	
	
	----------------------------------------------------------------------------
	-- KV-70 reverser section
	{	"10/4",		"D",		"A21" },
	{	"D",		"D1",		"KV70[D-D1]" },
	
	{	"10/4",		"C3",		"KV70[10/4-C3]" },
	
	{	"10/4",		"F1",		"KV70[10/4-F1]" },
	
	--{	"10/4",		"D4",		"A13" },
	--{	"D4",		"15",		"KV70[D4-15]" }, -- FIXME
	--{	"15",		"0",		"#TW[15]" },
	
	{	"10AK",		"4",		"KV70[10AK-4]" },
	{	"4",		"0",		"#TW[4]" },
	
	{	"10AK",		"5",		"KV70[10AK-5]" },
	{	"5",		"0",		"#TW[5]" },
	
	{	"10",		"FR1",		"KV70[FR1-10]" },
	{	"10",		"FR1/2",	"KV70[FR1-10]" },
	
	{	"10",		"F7",		"KV70[F7-10]" },
	{	"10",		"F7/1",		"KV70[F7-10]" },
	
	{	"F7/1",		"F8",		"VUS" },
	
	
	----------------------------------------------------------------------------
	-- KV-70 controller section
	{	"10",		"8",		"KV70[10-8]" },
	{	"8",		"0",		"#TW[8]" },
	
	{	"10AS",		"U2",		"KV70[U2-10AS]" },
	{	"U2",		"24",		"KSN" },
	{	"24",		"0",		"#TW[24]" },
	{	"U2",		"2-7R-21",	"1" },
	{	"2-7R-21",	"0",		"#I[RedRP]" },
	
	{	"10AK",		"2",		"KV70[10AK-2]" },
	{	"2",		"0",		"#TW[2]" },
	
	{	"U2",		"3",		"KV70[U2-3]" },
	{	"3",		"0",		"#TW[3]" },
	
	{	"10AS",		"33",		"KV70[10AS-33]" },
	{	"33",		"33Aa",		"KD" },
	{	"33",		"33Aa",		"1" }, -- FIXME: KD bypass
	{	"33",		"33Aa",		"VAD" },
	{	"33Aa",		"0",		"#RV2" },
	
	{	"10AS",		"33D",		"KV70[10AS-33D]" },
	{	"33D",		"1",		"R1_5" },
	{	"1",		"0",		"#TW[1]" },
	
	{	"U2",		"33G",		"KV70[U2-33G]" },
	{	"33G",		"0",		"#RVT" },
	
	{	"U2",		"20",		"KV70[U2-20a]" },
	{	"20",		"0",		"#TW[20]" },
	
	{	"U2",		"25B",		"KV70[U2-25]" },
	{	"25B",		"25",		"1" }, -- K25 FIXME
	{	"25",		"0",		"#TW[25]" },
	
	{	"10AS",		"U4",		"KV70[10AS-U4]" },
	{	"U4",		"1-7R-8",	"VozvratRP" },
	{	"1-7R-8",	"0",		"#TW[17]" },
	
	{	"U2",		"20",		"KV70[U2-20b]" },
	
	
	----------------------------------------------------------------------------
	-- Door control (D1) circuit)
	{	"D1",		"D3",		"VUD1" },
	{	"D3",		"16",		"VUD2" },
	{	"16",		"0",		"#TW[16]" },
	
	{	"D1",		"31V",		"KDL" },
	{	"D1",		"31V",		"VDL" },
	{	"31V",		"0",		"#TW[31]" },
	
	{	"D1",		"12",		"KRZD" },
	{	"12",		"0",		"#TW[12]" },
	
	{	"D1",		"32V",		"KDP" },
	{	"32V",		"0",		"#TW[32]" },
	
	
	----------------------------------------------------------------------------
	-- Train control (VU) circuit
	{	"10",		"10AL",		"VU" },
	{	"10AL",		"10ALa",	"A64" },
	{	"10ALa",	"0",		"#I[CabinLight]" },
	
	{	"10AL",		"Sh1-43",	"A45" }, -- FIXME: this should lead to ARS
	{	"10AL",		"10AS",		"A55" },
	{	"10AL",		"10AK",		"A54" },
	{	"10AL",		"10ALb",	"A61" },
	{	"10ALb",	"6",		"RVT" },
	{	"6",		"0",		"#TW[6]" },
	
	{	"10AK",		"VAH1",		"VAH" },
	{	"10AK",		"VAH1",		"RPB" },
	{	"VAH1",		"33B",		"RV2" },
	{	"33B",		"33AVU",	"AVU" },
	{	"33B",		"33AVU",	"OtklAVU" },
	{	"33AVU",	"33V",		"1" }, -- UAVA
	{	"33V",		"0",		"#R1_5" },

	
	----------------------------------------------------------------------------
	-- Lighting circuits
	{	"F1",		"F2a",		"A7" },
	{	"F1",		"F1a",		"A9" },
	{	"F2a",		"0",		"#I[RedLightRight]" },
	{	"F1a",		"0",		"#I[RedLightLeft]" },
	
	{	"F8",		"F10",		"A47" },
	{	"F10",		"0",		"#I[HeadLights1]" },
	{	"F7",		"F13",		"A46" },
	{	"F13",		"0",		"#I[HeadLights2]" },
	{	"F13",		"0",		"#I[HeadLights3]" },
	
	{	"TW[23]",	"23A",		"A23" },
	{	"23A",		"22A",		"1" },
	{	"TW[22]",	"22A",		"A22" },
	{	"22A",		"22V",		"!TRK" },
	{	"22V",		"0",		"#KK" },


	----------------------------------------------------------------------------
	-- Train wire 1
	{	"TW[1]","1A",	"A1" },
	{	"1A",	"1T",	"!PS,PP" },
	{	"1T",	"1P",	"NR" },
	{	"1T",	"1P",	"RPU" },
	{	"1P",	"6A",	"PT1,PT2" },
	
	{	"1P",	"1B",	"AVT" },
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
	{	"TW[2]","2Zh",	"A2" },
	{	"2Zh",	"2A",	"!KSB1" },
	{	"2Zh",	"2A",	"!TR1" },
	
	{	"2Zh",	"2A",	"KSB2" },	-- HACK: not in original schematics, but
									-- for purely rheostat braking the rheostat must be powered by circuitry
									-- which otherwise indicates ready state of thyristor controller
	
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
	{	"TW[3]","3A",	"A3" },
	{	"3A",	"0",	"#Rper" },
	

	----------------------------------------------------------------------------
	-- Train wires 4, 5
	{	"TW[4]","4B",	"!RKR" },
	{	"4B",	"0",	"#ReverserBackward" },
	{	"TW[5]","5B",	"RKR" },
	{	"5B",	"0",	"#ReverserForward" },
	
	{	"TW[4]","5V",	"RKR" },
	{	"TW[5]","5V",	"!RKR" },
	{	"5V",	"5B'",	"LK3" },
	{	"5B'",	"0",	"#LK4" },
	

	----------------------------------------------------------------------------
	-- Train wire 6
	{	"TW[6]","6A",	"A6" },
	{	"6A",	"0",	"#TR1" },
	{	"6A",	"0",	"#TR2" },
	{	"6A",	"6G",	"PT1,PT2" },
	{	"6G",	"6Yu",	"!RK1-5" },
	--{	"6G",	"6Yu",	"!RK1-2" }, 	-- HACK: not in original schematics, but
										-- the circuit defines pure rheostat braking instead of
										-- thyristor braking. The KSB relay triggers KSH instead.
										-- The relays must be on for more RK positions to allow for gradual
										-- field control
	{	"6Yu",	"0",	"#RUP" },
	{	"6Yu",	"0",	"#KSB1" },
	{	"6Yu",	"0",	"#KSB2" },
	
	

	----------------------------------------------------------------------------
	-- Train wire 8
	{	"TW[8]","8A",	"A8" },
	{	"8A",	"8Zh",	"RK17-18" },
	{	"8Zh",	"0",	"#PneumaticNo1" },
	
	{	"8A",	"8Ye",	"RK1" },
	{	"8A",	"8Ye",	"!LK4" },
	{	"8Ye",	"8G",	"!RT2" },
	{	"8G",	"0",	"#PneumaticNo2" },
	
	
	----------------------------------------------------------------------------
	-- Train wire 17
	{	"TW[17]",	"17A",	"A17" },
	{	"17A",		"0",	"#RPvozvrat" },
	
	
	----------------------------------------------------------------------------
	-- Train wire 18
	{	"B2",		"18s1",	"!RP" }, 	-- This is not how it's implemented on circuit,
	{	"18s1",		"18s2",	"LK4" },	-- but an equivalent circuit instead
	{	"18s2",		"18A",	"A14" },	-- Value of 1.0 on TW18 would indicated 'not grounded'
	{	"18A",		"0",	"#TW[18]" },
	
	{	"B2",		"18s3",	"!RP" },
	{	"18s3",		"18Aa",	"A14" },
	--{	"18Aa",		"0",	"#TW[10AH]" },
	{	"18Aa",		"10AH",	"1" },
	
	
	----------------------------------------------------------------------------
	-- Train wire 20
	{	"TW[20]",	"20A",	"A20" },
	{	"20A",		"20B",	"!RP" },
	{	"20B",		"0",	"#LK2" },
	{	"20B",		"0",	"#LK5" },
	
	
	----------------------------------------------------------------------------
	-- Train wire 24
	{	"TW[24]",	"24V",	"!LK4" },
	{	"24V",		"0",	"#RZ_2" },

	
	----------------------------------------------------------------------------
	-- Train wire 25
	{	"TW[25]",	"25A",	"A25" },
	{	"25A",		"0",	"#RRTuderzh" },
	
	
	----------------------------------------------------------------------------
	-- Train wire 27
	{	"TW[27]",	"27A",	"A50" },
	{	"27A",		"0",	"#XR3.2" },
	{	"27A",		"0",	"#RPU" },
	{	"27A",		"0",	"#KPP" },
	
	----------------------------------------------------------------------------
	-- Train wire 28
	{	"TW[28]",	"28A",	"A51" },
	{	"28A",		"0",	"#XR3.3" },
	
	
	----------------------------------------------------------------------------
	-- Battery B2 output
	{	"B2",		"10AYa",	"A80" },
	{	"10AYa",	"10AB",		"!LK3" },
	{	"10AB",		"10AV",		"RK2-18" },
	{	"10AV",		"2Ye",		"!LK4" },
	
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
	{	"B2",		"10AE",		"A30" },
	{	"10AE",		"10B",		"TR1" },
	{	"10AE",		"10B",		"RV1" },
	{	"10AE",		"10B",		"RV1" },
	{	"10B",		"0",		"#SDRK_Coil" },
	{	"10AE",		"10Zh",		"1" }, -- Temp[2] blocks circuit when it's grounded
	
	{	"10AE",		"10I",		"RKM1" }, -- Marked as RKM2 on schematics...
	{	"10I",		"10AH",		"!LK1" },
	{	"10AH",		"0",		"#RRTpod" },
	{	"10I",		"10H",		"LK4" },
	{	"10H",		"0",		"#RUTpod" },
	
	-- SDRK motor circuit
	{	"10Zh",		"10M",		"SR1" },
	{	"10M",		"10MA",		"!RRT" },
	{	"10MA",		"10N",		"!RUT" },
	{	"10Zh",		"10N",		"RKM1" },

	{	"10N",		"0",		"#SDRK" },
}
Sources = { "B" }
Drains = { "0" }
AddToNodes = {
	{ "10N", "T[\"SDRK_ShortCircuit\"]"},
	{ "U0a", "(-10*S[\"10AH\"])" },
	{ "2-7R-21", "(-10*Train:ReadTrainWire(18))" },
	{ "10AH", "0" },
}
Diodes = {
	{ "6A", "1P" }, -- Add a diode between these two nodes
	{ "10AV", "2Ye" },
	{ "TW4", "5V" },
}
SpecialTriggers = {
	"LK5",
	"KSH1",
	"KSH2",
	"KSB1",
	"KSB2",
	"KPP",
	"RPvozvrat",
	"RRTuderzh",
	"RRTpod",
	"RUTpod",
	"SDPP",
	"SDRK_Coil",
	"SDRK",	
	"XR3.2",
	"XR3.3",
	"XR3.4",
	"XR3.6",
	"XR3.7",
	"XT3.1",
	"ReverserForward",
	"ReverserBackward",
}
ExtraStatements = {
[[T["SDRK_ShortCircuit"] = -10*Train.RheostatController.RKP*(Train.RUT.Value+Train.RRT.Value+(1.0-Train.SR1.Value))]],
}

Simplify()
GenerateSource()

--------------------------------------------------------------------------------
print("Result:\n"..SRC)
local f = io.open("gen_int_81_705.lua","w+")
f:write(SRC)
f:close()