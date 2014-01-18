local Debugger = {}
Debugger.DisplayGroups = {}
Debugger.EntData = {}
Debugger.EntDataTime = {}
Debugger.EntNameMap = {}

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

Debugger.DisplayGroups["Train"] = {
	{"Speed","%.1f","km/h"},
	{"Acceleration","%6.3f","m/s2"},
}

Debugger.DisplayGroups["Power Relays"] = {
	{"RRState","%.0f","on/off"},	

	{"LK1State","%.0f","on/off"},
	{"LK2State","%.0f","on/off"},
	{"LK3State","%.0f","on/off"},
	{"LK4State","%.0f","on/off"},
	
	{"RPLState","%.0f","on/off"},
	{"RP1_3State","%.0f","on/off"},
	{"RP2_4State","%.0f","on/off"},
	
	{"RUTState","%.0f","on/off"},	
	
	{"TpState","%.0f","on/off"},
	{"TpbState","%.0f","on/off"},
	{"TbState","%.0f","on/off"},
	{"TsState","%.0f","on/off"},
}

Debugger.DisplayGroups["Controller"] = {
	{"KVControllerPosition","%.0f","X/T"},
	{"KVReverserPosition",  "%.0f","fwd/rev"},
	{"TW1 X1", "%d", "level"},
	{"TW2 X2", "%d", "level"},
	{"TW3 X3", "%d", "level"},
	
	{"TW4 FWD", "%d", "level"},
	{"TW5 BWD", "%d", "level"},
	{"TW6 T", "%d", "level"},
	
	{"TW20 1S", "%d", "level"},	
}

Debugger.DisplayGroups["Pneumatic System"] = {
	{"PneumaticDriverValvePosition",	"%d", "position"},
	{"PneumaticBrakeLinePressure",		"%.3f", "atm"},
	{"PneumaticBrakeCylinderPressure",	"%.3f", "atm"},
	{"PneumaticReservoirPressure",		"%.3f", "atm"},
	{"PneumaticTrainLinePressure",		"%.3f", "atm"},
	{"PneumaticNo1State","%.0f","on/off"},
	{"PneumaticNo2State","%.0f","on/off"},
	ignore_prefix = {"Pneumatic"}
}

Debugger.DisplayGroups["Electric System"] = {
	{"ElectricVs","%.3f","V"},
	{"ElectricU13","%.3f","V"},
	{"ElectricU24","%.3f","V"},
	{"ElectricVR1","%.3f","V"},
	{"ElectricVR2","%.3f","V"},
	{"ElectricI13","%.2f","A"},
	{"ElectricI24","%.2f","A"},
	{"ElectricItotal","%.2f","A"},
	
	{"ElectricRw13","%.3f","Ohm"},
	{"ElectricRw24","%.3f","Ohm"},	
	{"ElectricRs1","%.3g","Ohm"},
	{"ElectricRs2","%.3g","Ohm"},
	{"ElectricR1","%.3f","Ohm"},
	{"ElectricR2","%.3f","Ohm"},
	ignore_prefix = "Electric"
}

Debugger.DisplayGroups["Engines"] = {
	{"EnginesMagneticFlux13","%.3f",""},
	{"EnginesMagneticFlux24","%.3f",""},
	{"EnginesE13","%.3f","V"},
	{"EnginesE24","%.3f","V"},
	{"EnginesRotationRate","%.1f","rpm"},
	{"EnginesMoment13","%.2f",""},
	{"EnginesMoment24","%.2f",""},
	
	{"EnginesIstator13","%.2f","A"},
	{"EnginesIstator24","%.2f","A"},
	{"EnginesIshunt13","%.2f","A"},
	{"EnginesIshunt24","%.2f","A"},
	{"RheostatControllerPosition","%.2f","position"},
	ignore_prefix = "Engines"
}

Debugger.DisplayGroups["DURA"] = {
	{"DURASwitchBlocked","%.0f","state"},
	{"DURASelectedAlternate","%.0f","state"},
	{"DURASelectingAlternate","%.0f","state"},
	{"DURASelectingMain","%.0f","state"},
	
	{"DURANextLightRed","%.0f","state"},
	{"DURANextLightYellow","%.0f","state"},
	{"DURADistanceToLight","%.1f","m"},
	ignore_prefix = "DURA"
}

local function ProccessGroup(group)
	local prefix = group.ignore_prefix
	for k,v in pairs(group) do
		if k ~= "ignore_prefix" and not v[4] then
			if prefix then
			
			end
		end
	end
end

local function GetEntVar(entid,varname)
	if not Debugger.EntNameMap[entid] then return end
	if not Debugger.EntNameMap[entid][varname] then return end
	if not Debugger.EntData[entid] then return end

	return Debugger.EntData[entid][Debugger.EntNameMap[entid][varname]] 
end


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

net.Receive("metrostroi-debugger-dataupdate",function(len,ply)
	local count = net.ReadInt(8)
	for i=1,count do
		local data = net.ReadTable()
		Debugger.EntData[data[1]]=data[2]
		Debugger.EntDataTime[data[1]]=CurTime()
	end
	--PrintTable(Debugger)
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

local function getDisplayGroupWidth(displaygroup,entid)
	local width = 0
	for k,v in pairs(displaygroup) do
		if k ~= "ignore_prefix" then
			local v2 = string.format(v[2],tonumber(GetEntVar(entid,v[1]) or 0))
			width = width + 5 + math.max(
				surface.GetTextSize(v[1]),
				surface.GetTextSize(v2),
				surface.GetTextSize(v[3])
			)
		end
	end
	return width
end

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
	
	
	for k,v in pairs(displaygroup) do
		if k ~= "ignore_prefix" then
			surface.SetTextPos(x+localx,y+5)
			surface.DrawText(v[1])
			
			local v2 = string.format(v[2],tonumber(GetEntVar(entid,v[1]) or 0))
			surface.SetTextPos(x+localx,y+20)
			surface.DrawText(v2)
			
			surface.SetTextPos(x+localx,y+35)
			surface.DrawText(v[3])
			
			localx = localx + 5 + math.max(
				surface.GetTextSize(v[1]),
				surface.GetTextSize(v2),
				surface.GetTextSize(v[3])
			)
		end
	end

end


local function isTimedOut(id)
	local timeout = GetConVarNumber("metrostroi_debugger_data_timeout")
	return timeout ~= nil and timeout > 0 and CurTime() - Debugger.EntDataTime[id] > timeout
end

hook.Add( "HUDPaint", "metrostroi-draw-system-debugger", function()
	surface.SetFont("DebugBoxText")
	currentcolor = 1
	
	
	if Debugger.EntData ~= nil then 
		local localy = 15 --+ 65
		
		--For every entity
		for id,vars in pairs(Debugger.EntData) do
			
			--For every displaygroup
			if not isTimedOut(id) then
				for groupname,displayvars in pairs(Debugger.DisplayGroups) do
					drawBox(25,localy,displayvars,id)
					
					localy=localy+60
				end
				advancecolor()
			end
		end
	end
end)



local function RemoveEnt(id)
	Debugger.EntData[id] = nil
end

net.Receive("metrostroi-debugger-entremoved",function(len,ply) 
	local id = net.ReadInt(16)
	if Debugger.EntData[id] then
		RemoveEnt(id)
	end
end)

net.Receive("metrostroi-debugger-entnamemap",function(len,ply)
	local entid = net.ReadInt(16)
	local entvars = net.ReadTable()
	local index = 1
	
	Debugger.EntNameMap[entid] = {}
	for k,v in pairs(entvars) do
		Debugger.EntNameMap[entid][k] = index
		index = index + 1
	end
end)