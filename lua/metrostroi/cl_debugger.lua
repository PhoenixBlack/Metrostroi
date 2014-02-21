--[[
Server keeps track of entities and sends their ent:GetDebugVars() return table to all clients
Clients receive and store this data based on entID
Clients loop over displaygroups and read relevant vars from the stored data

To lower net usage, an array to map variable names to indexes is send to the client when 
the length of the table changes. Regular data packages only contain a nameless list of data.
-]]

local Debugger = {}
Debugger.DisplayGroups = {}
Debugger.EntData = {}
Debugger.EntDataTime = {}
Debugger.EntNameMap = {}

CreateClientConVar("metrostroi_drawdebug",0,true)
CreateClientConVar("metrostroi_debugger_data_timeout",2,true,false)

local Colors = {
	{120,255,255},
	{255,255,0},
	{255,0,0},
	{255,0,255}
}

local currentcolor = 1
local function advancecolor()
	currentcolor = currentcolor%(#Colors)+1
end


--group.Ents is a list of entities to show the group for, # is baseclass prefix
Debugger.DisplayGroups["Train State"] = {
	Data = {
		{"Speed","%.1f","km/h"},
		{"Acceleration","%6.3f","m/s2"},
		
		{"KVControllerPosition","%.0f","X/T"},
		{"KVReverserPosition",  "%.0f","fwd/rev"},
	},
	
	Ents = {"#gmod_subway_base"}
	
}

Debugger.DisplayGroups["Power Relays"] = {
	Data = {
		{"RKRValue","%.0f","0-fwd/1-rev"},

		{"LK1Value","%.0f","on/off"},
		{"LK2Value","%.0f","on/off"},
		{"LK3Value","%.0f","on/off"},
		{"LK4Value","%.0f","on/off"},
		{"KSH1Value","%.0f","on/off"},
		{"KSH2Value","%.0f","on/off"},
		{"TR1Value","%.0f","on/off"},
		{"TR2Value","%.0f","on/off"},
		
		{"RKTTValue","%.0f","on/off"},
		{"RUTValue","%.0f","on/off"},
		{"DR1Value","%.0f","on/off"},
		{"DR2Value","%.0f","on/off"},
		
		{"RPLValue","%.0f","on/off"},
		{"RP1_3Value","%.0f","on/off"},
		{"RP2_4Value","%.0f","on/off"},
		{"RPvozvratValue","%.0f","on/off"},
		
		{"RZ_1Value","%.0f","on/off"},
		{"RZ_2Value","%.0f","on/off"},
		{"RZ_3Value","%.0f","on/off"},
	},

	Ents = {"#gmod_subway_base"}
	
}

Debugger.DisplayGroups["Control Relays"] = {
	Data = {
		{"RDValue","%.0f","on/off"},
		{"RVOValue","%.0f","on/off"},
		{"RVZValue","%.0f","on/off"},
		{"RT2Value","%.0f","on/off"},
		{"RRValue","%.0f","on/off"},
		
		{"NRValue","%.0f","on/off"},
		{"RSUValue","%.0f","on/off"},
		
		{"RPLValue","%.0f","on/off"},
		{"RP1_3Value","%.0f","on/off"},
		{"RP2_4Value","%.0f","on/off"},
		{"RPvozvratValue","%.0f","on/off"},
		
		{"RV1Value","%.0f","on/off"},
		{"RV2Value","%.0f","on/off"},
		
		{"RRTValue","%.0f","on/off"},
		{"RRP1Value","%.0f","on/off"},
		{"SR1Value","%.0f","on/off"},
		{"RKRValue","%.0f","on/off"},
		
		{"RperValue","%.0f","on/off"},
	},
	Ents = {"#gmod_subway_base"}
	
}

Debugger.DisplayGroups["Train Wires"] = {
	Data = {
		{"TW1", "%d", "level"},
		{"TW2", "%d", "level"},
		{"TW3", "%d", "level"},
		{"TW4", "%d", "level"},
		{"TW5", "%d", "level"},
		{"TW6", "%d", "level"},
		{"TW7", "%d", "level"},
		{"TW8", "%d", "level"},
		{"TW9", "%d", "level"},
		{"TW10", "%d", "level"},
		{"TW11", "%d", "level"},
		{"TW12", "%d", "level"},
		{"TW13", "%d", "level"},
		{"TW14", "%d", "level"},
		{"TW15", "%d", "level"},
		{"TW16", "%d", "level"},
		
		{"TW17", "%d", "level"},
		{"TW18", "%d", "level"},
		{"TW19", "%d", "level"},
		{"TW20", "%d", "level"},
		{"TW21", "%d", "level"},
		{"TW22", "%d", "level"},
		{"TW23", "%d", "level"},
		{"TW24", "%d", "level"},
		{"TW25", "%d", "level"},
		{"TW26", "%d", "level"},
		{"TW27", "%d", "level"},
		{"TW28", "%d", "level"},
		{"TW29", "%d", "level"},
		{"TW30", "%d", "level"},
		{"TW31", "%d", "level"},
		{"TW32", "%d", "level"},
	},
	
	Ents = {"#gmod_subway_base"}
	
}

Debugger.DisplayGroups["Pneumatic System"] = {
	Data = {
		{"PneumaticDriverValvePosition",	"%d", "position"},
		{"PneumaticBrakeLinePressure",		"%.3f", "atm"},
		{"PneumaticBrakeCylinderPressure",	"%.3f", "atm"},
		{"PneumaticReservoirPressure",		"%.3f", "atm"},
		{"PneumaticTrainLinePressure",		"%.3f", "atm"},
		{"PneumaticNo1Value","%.0f","on/off"},
		{"PneumaticNo2Value","%.0f","on/off"},
	},
	
	
	ignore_prefix = "Pneumatic",
	Ents = {"#gmod_subway_base"}
	
}

Debugger.DisplayGroups["Electric System"] = {
	Data = {
		{"ElectricMain750V","%.2f","V"},
		{"ElectricPower750V","%.2f","V"},
		{"ElectricAux750V","%.2f","V"},
		{"ElectricAux80V","%.2f","V"},
		
		{"ElectricI13","%.2f","A"},
		{"ElectricI24","%.2f","A"},
		{"ElectricItotal","%.2f","A"},
		{"ElectricIRT2","%.2f","A"},
		
		{"ElectricUstator13","%.3f","V"},
		{"ElectricUstator24","%.3f","V"},
		{"ElectricIshunt13","%.2f","A"},
		{"ElectricIshunt24","%.2f","A"},
		{"ElectricIstator13","%.2f","A"},
		{"ElectricIstator24","%.2f","A"},
		
		{"ElectricR1","%.3g","Ohm"},
		{"ElectricR2","%.3g","Ohm"},
		{"ElectricR3","%.3g","Ohm"},
		{"ElectricRs1","%.3g","Ohm"},
		{"ElectricRs2","%.3g","Ohm"},
		
		{"ElectricP1","%.1f","W"},
		{"ElectricP2","%.1f","W"},
		{"ElectricT1","%.2f","degC"},
		{"ElectricT2","%.2f","degC"},
	},
	
	
	ignore_prefix = "Electric",
	Ents = {"#gmod_subway_base"}
	
}

Debugger.DisplayGroups["DIP-01K"] = {
	Data = {
		{"PowerSupplyDIP-01K","",""},

		{"PowerSupplyXT3.1","%.2f","V"},
		{"PowerSupplyXT3.4","%.2f","V"},
		{"PowerSupplyXT1.2","%.2f","V"},
	},
	
	ignore_prefix = "PowerSupply",
	Ents = {"#gmod_subway_base"}
	
}

Debugger.DisplayGroups["Engines"] = {
	Data = {
		{"EnginesMagneticFlux13","%.3f",""},
		{"EnginesMagneticFlux24","%.3f",""},
		{"EnginesE13","%.3f","V"},
		{"EnginesE24","%.3f","V"},
		{"EnginesRotationRate","%.1f","rpm"},
		{"EnginesMoment13","%.2f",""},
		{"EnginesMoment24","%.2f",""},
		
		{"EnginesFieldReduction13","%.2f","%"},
		{"EnginesFieldReduction24","%.2f","%"},		
	},
	
	
	ignore_prefix = "Engines",
	Ents = {"#gmod_subway_base"}
	
}

Debugger.DisplayGroups["Rheostat Controller"] = {
	Data = {
		{"RheostatControllerRheostatController","",""},
	
		{"RheostatControllerMotorState","%.1f","state"},
		{"RheostatControllerMotorCoilState","%.1f","state"},
		
		{"RheostatControllerPosition","%.2f","position"},
		{"RheostatControllerVelocity","%.2f","1/sec"},
		
		{"RheostatControllerRKM1","%.1f","state"},
		{"RheostatControllerRKM2","%.1f","state"},
		{"RheostatControllerRKP","%.1f","state"},
	},
	
	
	ignore_prefix = "RheostatController",
	Ents = {"#gmod_subway_base"}
	
}

Debugger.DisplayGroups["Position Switch"] = {
	Data = {
		{"PositionSwitchPositionSwitch","",""},
	
		{"PositionSwitchMotorState","%.1f","state"},
		{"PositionSwitchMotorCoilState","%.1f","state"},

		{"PositionSwitchPosition","%.2f","position"},
		{"PositionSwitchVelocity","%.2f","1/sec"},

		{"PositionSwitchRKM1","%.1f","state"},
		{"PositionSwitchRKM2","%.1f","state"},
		{"PositionSwitchRKP","%.1f","state"},
	},
	
	
	ignore_prefix = "PositionSwitch",
	Ents = {"#gmod_subway_base"}
	
}

Debugger.DisplayGroups["DURA"] = {
	Data = {
		{"DURASwitchBlocked","%.0f","state"},
		{"DURASelectedAlternate","%.0f","state"},
		{"DURASelectingAlternate","%.0f","state"},
		{"DURASelectingMain","%.0f","state"},
		
		{"DURANextLightRed","%.0f","state"},
		{"DURANextLightYellow","%.0f","state"},
		{"DURADistanceToLight","%.1f","m"},
	},
	
	
	ignore_prefix = "DURA",
	Ents = {"#gmod_subway_base"}
	
}

Debugger.DisplayGroups["Bogey"] = {
	Data = {
		{"Speed","%.1f","km/h"},
		{"Acceleration","%6.2f","","m/s2"},
	},
	
	
	Ents = {"gmod_train_bogey"}
	
}

local function ProccessGroup(group)
	group.Enabled = true
	
	local prefix = group.ignore_prefix
	for k,v in pairs(group.Data) do
		if not v[4] and prefix then
			v[4] = string.Right(v[1],string.len(v[1])-string.len(prefix))
		end
	end
end

for k,v in pairs(Debugger.DisplayGroups) do
	ProccessGroup(v)
end


local function GetEntVar(entid,varname)
	if not Debugger.EntNameMap[entid] then return end
	if not Debugger.EntNameMap[entid][varname] then return end
	if not Debugger.EntData[entid] then return end

	return Debugger.EntData[entid][Debugger.EntNameMap[entid][varname]] 
end

local function EnableGroup(group,bool)
	group.Enabled = bool
end



local function OpenConfigWindow()
	local Panel = vgui.Create("DFrame")
	Panel:SetPos(surface.ScreenWidth()/5,surface.ScreenHeight()/3)
	Panel:SetSize(250,250)
	Panel:SetTitle("Metrostroi Debugger Config")
	Panel:SetVisible(true)
	Panel:SetDraggable(true)
	Panel:ShowCloseButton(true)
	
	Panel:MakePopup()
	
	List = vgui.Create("DPanelList",Panel)
	
	List:SetPos(10,30)
	List:SetSize(200,200)
	List:SetSpacing(5)
	List:EnableHorizontal(false)
	List:EnableVerticalScrollbar(true)
	
	for k,v in pairs(Debugger.DisplayGroups) do
		local Box = vgui.Create("DCheckBoxLabel")
		Box:SetText(k)
		if v.Enabled then
			Box:SetValue(1)
		else
			Box:SetValue(0)
		end -- TODO: Do this nicer somehow
		Box:SizeToContents()
		List:AddItem(Box)
		Box.OnChange = function() EnableGroup(v,Box:GetChecked()) end
	end
end
concommand.Add("metrostroi_debugger_config",OpenConfigWindow,nil,"Show debugger system selection window")
--[[ --Unused, just reference for now
local function PresentSelectionScreen(options)
	local screen = vgui.Create("DFrame")
	screen:SetPos(50,50)
	screen:SetSize(400,400)
	screen:SetTitle("Select systems to view")
	screen:SetVisible(true)
	screen:SetDraggable(true)
	screen:ShowCloseButton(true)
	
	local syslist = vgui.Create("DListView",screen)
	syslist:SetMultiSelect(true)
	syslist:AddColumn("Systems")
	syslist:SetSize(400,300)
	syslist:SetPos(5,30)
	
	
	for k,v in pairs(options) do
		syslist:AddLine(k)
	end
	
	local send = vgui.Create("DButton",screen)
	send:SetText("Confirm")
	send:SetPos(200,370)
	send.DoClick = function()
		local selectedsystems = {}
		for k,v in pairs(syslist:GetSelected()) do
			table.insert(selectedsystems,v:GetValue(1))
		end
		
		net.Start("metrostroi_debugger_server_system_setup")
		net.WriteTable(selectedsystems)
		net.SendToServer()
	end
	send:SizeToContents()
	
	
	screen:SizeToContents()
	screen:MakePopup()

end
--]]

 --[[ --Uncomment me if you need to keep track of changes in ent:GetDebugVars returns
local lastcount 
local lastcopy
local tabledebug = true
--]]

--Receives the bulk nameless data
net.Receive("metrostroi-debugger-dataupdate",function(len,ply)
	local count = net.ReadInt(8)
	for i=1,count do
		local data = net.ReadTable()
		Debugger.EntData[data[1]]=data[2]
		Debugger.EntDataTime[data[1]]=CurTime()
		
		--Hackly code for debugging purposes, see above
		if tabledebug then
			newcopy = Debugger.EntData[data[1]]
			newcount = table.Count(newcopy)
			if newcount ~= lastcount and lastcount ~= nil then
				
				for k,v in pairs(newcopy) do
					if not lastcopy[k] then
						print("System debugger: New key ",k,v)
					end
				end
				
				for k,v in pairs(lastcopy) do
					if not newcopy[k] then
						print("System debugger: Key missing ",k,v)
					end
				end
			end

			lastcount = newcount
			lastcopy = newcopy
		end
	end
end)


surface.CreateFont( "DebugBoxText", {
 font = "Consolas",
 size = 13,
 weight = -5, --Don't question it
 blursize = 0,
 scanlines = 0,
 antialias = true,
 underline = false,
 italic = false,
 strikeout = false,
 symbol = false,
 rotary = false,
 shadow = false,
 additive = false,
 outline = false
} )

--Takes an entire displaygroup and ent, returns width of complete box
local function getDisplayGroupWidth(displaygroup,entid)
	local width = 0
	for k,v in pairs(displaygroup.Data) do
		local v2 = string.format(v[2],tonumber(GetEntVar(entid,v[1]) or 0))
		width = width + 5 + math.max(
			surface.GetTextSize(v[4] or v[1]),
			surface.GetTextSize(v2),
			surface.GetTextSize(v[3])
		)
	end
	return width
end

--Takes x,y, complete group and entid, draws debugger box
local function drawBox(x,y,displaygroup,entid)
	local localx = 10
	
	local width = getDisplayGroupWidth(displaygroup,entid)
	
	
	
	local rgb = Colors[currentcolor]

	--surface.SetTextColor(Color(120,255,255))
	surface.SetTextColor(rgb[1],rgb[2],rgb[3])
	surface.SetAlphaMultiplier(0.8)
	surface.SetDrawColor(Color(0,0,0))
	surface.DrawRect(x,y,width+10,55)
	surface.SetAlphaMultiplier(1)
	
	
	for k,v in pairs(displaygroup.Data) do
		surface.SetTextPos(x+localx,y+5)
		surface.DrawText(v[4] or v[1])
		
		local v2 = string.format(v[2],tonumber(GetEntVar(entid,v[1]) or 0))
		surface.SetTextPos(x+localx,y+20)
		surface.DrawText(v2)
		
		surface.SetTextPos(x+localx,y+35)
		surface.DrawText(v[3])
		
		localx = localx + 5 + math.max(
			surface.GetTextSize(v[4] or v[1]),
			surface.GetTextSize(v2),
			surface.GetTextSize(v[3])
		)
	end

end

--Checks if we haven't gotten data from entid in a while
local function isTimedOut(id)
	local timeout = GetConVarNumber("metrostroi_debugger_data_timeout")
	return timeout ~= nil and timeout > 0 and CurTime() - Debugger.EntDataTime[id] > timeout
end

--Checks if we should draw a group according to group settings and entity state
local function ShouldDrawGroup(group,id)
	if not group.Enabled then return false end
	local ent = ents.GetByIndex(id)
	if not IsValid(ent) then return false end
	for k,v in pairs(group.Ents) do
		if v[1]=="#" then
			if string.Right(v,string.len(v)-1) == ent.Base then return true end
		else
			if ent:GetClass() == v then return true end
		end
	end
	return false 
end


hook.Add( "HUDPaint", "metrostroi-draw-system-debugger", function()
	surface.SetFont("DebugBoxText")
	currentcolor = 1
	
	
	if Debugger.EntData ~= nil then 
		local localy = 15 --+ 65
		
		if GetConVarNumber("developer") then
			localy = 77
		end
		
		if IsValid(LocalPlayer()) then
			local wep = LocalPlayer():GetActiveWeapon()
			if IsValid(wep) and wep:GetClass() == "gmod_tool" then
				localy = 178
			end
		end
		
		--For every entity
		for id,vars in pairs(Debugger.EntData) do
			
			--For every displaygroup
			if not isTimedOut(id) then
				for groupname,group in pairs(Debugger.DisplayGroups) do
					if ShouldDrawGroup(group,id) then
						drawBox(25,localy,group,id)
						
						localy=localy+60
					end
				end
				advancecolor()
			end
		end
	end

end)

--Clears all relevant entity data
local function RemoveEnt(id)
	Debugger.EntData[id] = nil
	Debugger.EntDataTime[id] = nil
	Debugger.EntNameMap[id] = nil
end

--Receiving this from the server since the client hook is unreliable
net.Receive("metrostroi-debugger-entremoved",function(len,ply) 
	local id = net.ReadInt(16)
	if Debugger.EntData[id] then
		RemoveEnt(id)
	end
end)

--Receives the namemap
net.Receive("metrostroi-debugger-entnamemap",function(len,ply)
	local entid = net.ReadInt(16)
	local entvars = net.ReadTable()
	local index = 1
	
	Debugger.EntNameMap[entid] = {}
	for k,v in SortedPairs(entvars) do
		Debugger.EntNameMap[entid][k] = index
		index = index + 1
	end
end)