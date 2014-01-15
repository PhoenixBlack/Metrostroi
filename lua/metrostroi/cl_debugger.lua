local Debugger = {}
Debugger.DisplayGroups = {}
Debugger.EntData = {}

Debugger.DisplayGroups.Dice = {
	{"FloatyDiceSystem1","%.3f","Test"}, --Variable, formatting, unit
	{"FloatyDiceSystem2","%.3f",""},
	{"FloatyDiceSystem3","%.3f",""},
	{"FloatyDiceSystem4","%.3f",""},
	{"FloatyDiceSystem5","%.3f","A really looooooong unit"},
	{"FloatyDiceSystem6","%.3f",""},
	{"FloatyDiceSystem7","%.3f","Awesome Points"},
	{"FloatyDiceSystem8","%.3f",""},
	{"FloatyDiceSystem9","%.3f",""},
	{"FloatyDiceSystem10","%.3f",""}
}

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

local function getDisplayGroupWidth(displaygroup,entvars)
	local width = 0
	for k,v in pairs(displaygroup) do
		local v2 = string.format(v[2],entvars[v[1]])
		width = width + 5 + math.max(
			surface.GetTextSize(v[1]),
			surface.GetTextSize(v2),
			surface.GetTextSize(v[3])
		)
	end
	return width
end

local function drawBox(x,y,displaygroup,entvars)
	local localx = 10
	
	local width = getDisplayGroupWidth(displaygroup,entvars)
	
	
	surface.SetTextColor(Color(120,255,255))
	surface.SetAlphaMultiplier(0.8)
	surface.SetDrawColor(Color(0,0,0))
	surface.DrawRect(x,y,width+10,55)
	surface.SetAlphaMultiplier(1)
	
	
	for k,v in pairs(displaygroup) do
		surface.SetTextPos(x+localx,y+5)
		surface.DrawText(v[1])
		
		local v2 = string.format(v[2],entvars[v[1]])
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

hook.Add( "HUDPaint", "metrostroi-draw-system-debugger", function()
	surface.SetFont("DebugBoxText")
	
	
	if Debugger.EntData ~= nil then 
		local localy = 15
		
		--For every entity
		for id,vars in pairs(Debugger.EntData) do
			
			--For every displaygroup
			for groupname,displayvars in pairs(Debugger.DisplayGroups) do
				drawBox(25,localy,displayvars,vars)
				localy=localy+60
			end
		end
	end
end)

local function RemoveEnt(id)
	Debugger.EntData[id] = nil
end

hook.Add("EntityRemoved","metrostroi-debugger-cleanuponremove",function(ent) 
	local id = ent:EntIndex()
	if Debugger.EntData[id] then
		timer.Simple(0.5,function() RemoveEnt(id) end)
	end
end)