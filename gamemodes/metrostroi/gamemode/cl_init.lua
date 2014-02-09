include( "shared.lua" )

CreateClientConVar( "metro_admin_listentoall", 0 , true, true )

DEFAULT_MOTD = "http://foxworks.wireos.com/metrostroi/manual.html"


--MOTD
local function ShowMOTD(url)
	local w = ScrW() * 2/3
	local h = ScrH() * 2/3
	local browserWindow = vgui.Create("DFrame")
	browserWindow:SetTitle("Train Manual")
	browserWindow:SetPos((ScrW() - w)/2, (ScrH() - h)/2)
	browserWindow:SetSize(w,h)
	browserWindow.OnClose = function()
		browser = nil
		browserWindow = nil
	end
	browserWindow:MakePopup()

	local browser = vgui.Create("DHTML",browserWindow)
	browser:SetPos(10, 25)
	browser:SetSize(w - 20, h - 35)

	browser:OpenURL(url)
end

local function MOTDCMD(ply,cmd,args,fullstring)
	local url = GetConVarString("metro_motd_overrideurl")
	if tonumber(url) ~= nil then return end
	if url == "" then url = DEFAULT_MOTD end
	ShowMOTD(url)
end
concommand.Add("metro_showmotd",MOTDCMD,nil,"Show the message of the day again")
