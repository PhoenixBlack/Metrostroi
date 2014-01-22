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


--group.Settings.Ents is a list of entities to show the group for, # is baseclass prefix
Debugger.DisplayGroups["Train"] = {
	Data = {
		{"Speed","%.1f","km/h"},
		{"Acceleration","%6.3f","m/s2"}
	},
	Settings = {
		Ents = {"#gmod_subway_base"}
	}
}

Debugger.DisplayGroups["Power Relays"] = {
	Data = {
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
	},
	Settings = {
		Ents = {"#gmod_subway_base"}
	}
}

Debugger.DisplayGroups["Controller"] = {
	Data = {
		{"KVControllerPosition","%.0f","X/T"},
		{"KVReverserPosition",  "%.0f","fwd/rev"},
		{"TW1 X1", "%d", "level"},
		{"TW2 X2", "%d", "level"},
		{"TW3 X3", "%d", "level"},
		
		{"TW4 FWD", "%d", "level"},
		{"TW5 BWD", "%d", "level"},
		{"TW6 T", "%d", "level"},
		
		{"TW20 1S", "%d", "level"},
	},
	Settings = {
		Ents = {"#gmod_subway_base"}
	}
}

Debugger.DisplayGroups["Pneumatic System"] = {
	Data = {
		{"PneumaticDriverValvePosition",	"%d", "position"},
		{"PneumaticBrakeLinePressure",		"%.3f", "atm"},
		{"PneumaticBrakeCylinderPressure",	"%.3f", "atm"},
		{"PneumaticReservoirPressure",		"%.3f", "atm"},
		{"PneumaticTrainLinePressure",		"%.3f", "atm"},
		{"PneumaticNo1State","%.0f","on/off"},
		{"PneumaticNo2State","%.0f","on/off"},
	},
	
	Settings = {
		ignore_prefix = "Pneumatic",
		Ents = {"#gmod_subway_base"}
	}
}

Debugger.DisplayGroups["Electric System"] = {
	Data = {
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
	},
	
	Settings = {
		ignore_prefix = "Electric",
		Ents = {"#gmod_subway_base"}
	}
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
		
		{"EnginesIstator13","%.2f","A"},
		{"EnginesIstator24","%.2f","A"},
		{"EnginesIshunt13","%.2f","A"},
		{"EnginesIshunt24","%.2f","A"},
		{"RheostatControllerPosition","%.2f","position"},
	},
	
	Settings = {
		ignore_prefix = "Engines",
		Ents = {"#gmod_subway_base"}
	}
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
	
	Settings = {
		ignore_prefix = "DURA",
		Ents = {"#gmod_subway_base"}
	}
}

Debugger.DisplayGroups["Bogey"] = {
	Data = {
		{"Speed","%.2f","km/h"},
		{"Acceleration","%.2f","","Accel"},
	},
	
	Settings = {
		Ents = {"gmod_train_bogey"}
	}
}

local function ProccessGroup(group)
	if not group.Settings then
		group.Settings = {}
	end
	group.Settings.Enabled = true
	
	local prefix = group.Settings.ignore_prefix
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
	group.Settings.Enabled = bool
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
		if v.Settings.Enabled then
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
	if not group.Settings.Enabled then return false end
	local ent = ents.GetByIndex(id)
	if not IsValid(ent) then return false end
	for k,v in pairs(group.Settings.Ents) do
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