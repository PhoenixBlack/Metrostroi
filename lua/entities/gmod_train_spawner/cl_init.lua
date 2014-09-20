include("shared.lua")

local frame = nil
local Settings = {
	Train = 1,
	WagNum = 3,
	Paint = 1,
	ARS = 1,
	Skin = 1,
	Cran = 1,
	Prom = 1,
	Mask = 1,
	NM = 8.2,
	Battery = 0,
	Switches = 1,
	SwitchesR = 0,
	DoorsL = 0,
	DoorsR = 0,
	GV = 1,
}
local Trains = {"81-71x","Ezh","81-703x"}
local Crans = {"334","013"}
local Paints = {{
	"Moscow",
	"Kiev",
},{
	"Random",
	"Green-Blue",
	"Dark Green-Dark Blue",
	"Blue-Dark Blue",
}}
local ARSes = {"Standart(square lamps)","Standart(round lamps)","Kiev/St.Petersburg"}
local Masks = {"1-4-1","2-2-2"}

local function UpdateConCMD()
	for k,v in pairs(Settings) do
		RunConsoleCommand("train_spawner_"..k:lower(), v)
	end
end

local function LoadConCMD()
	for k in pairs(Settings) do
		Settings[k] = GetConVarNumber("train_spawner_"..k:lower())	
	end
end

local function Draw()
	local trainTypeT = vgui.Create("DLabel", frame)--
	trainTypeT:SetPos(5, 28+24*0)
	trainTypeT:SetText("Train:")
	
	local trainType = vgui.Create("DComboBox", frame)
	trainType:SetPos(130, 28) 
	trainType:SetWide(80)
	for i=1,#Trains do
		trainType:AddChoice(Trains[i], i, Settings.Train == i)
	end
	
	local WagNum = vgui.Create("DNumSlider", frame)--
	WagNum:SetPos(5, 28+24*1-5)
	WagNum:SetWide(290)
	WagNum:SetMinMax(1, 6)
	WagNum:SetDecimals(0)
	WagNum:SetText("Wagons:")
	WagNum:SetValue(Settings.WagNum)
	local _old = WagNum.ValueChanged
	function WagNum:ValueChanged(...)
		_old(self, ...)
		Settings.WagNum = math.floor(self:GetValue())
		UpdateConCMD()
	end
	
	local trainPaintT = vgui.Create("DLabel", frame)--
	trainPaintT:SetPos(5, 28+24*2) 
	trainPaintT:SetText("Paint:")
	
	local trainPaint = vgui.Create("DComboBox", frame)
	trainPaint:SetPos(130, 28+24*2) 
	trainPaint:SetWide(80)

	function trainPaint:OnSelect(_, _, index)
		Settings.Paint = index
		UpdateConCMD()
	end

	local cranTypeT = vgui.Create("DLabel", frame)--
	cranTypeT:SetPos(5, 28+24*3)
	cranTypeT:SetText("Cran type:")
	
	local cranType = vgui.Create("DComboBox", frame)
	cranType:SetPos(130, 28+24*3)
	cranType:SetWide(80)
	for i=1,#Crans do
		cranType:AddChoice(Crans[i], i, Settings.Cran == i)
	end
	
	function cranType:OnSelect(_, _, index)
		Settings.Cran = index
		UpdateConCMD()
	end
	
	local NMPressure = vgui.Create("DNumSlider", frame)--
	NMPressure:SetPos(5, 28+24*4-5)
	NMPressure:SetWide(290)
	NMPressure:SetMinMax(0.1, 9)
	NMPressure:SetDecimals(1)
	NMPressure:SetText("Train Line Pressure:")
	NMPressure:SetValue(Settings.NM)
	local _old = NMPressure.ValueChanged
	function NMPressure:ValueChanged(...)
		_old(self, ...)
		Settings.NM = self:GetValue()
		UpdateConCMD()
	end
	
	local GVT = vgui.Create("DLabel", frame)--
	GVT:SetPos(5, 25+24*5)
	GVT:SetText("Main Switch:")
	
	local GV = vgui.Create("DCheckBox", frame)
	GV:SetPos(130, 28+24*5)
	GV:SetValue(Settings.GV)
	function GV:OnChange()
		Settings.GV = GV:GetChecked() and 1 or 0
		UpdateConCMD()
	end
	
	local BatteryT = vgui.Create("DLabel", frame)--
	BatteryT:SetPos(5, 25+24*6)
	BatteryT:SetText("Battery:")
	
	local Battery = vgui.Create("DCheckBox", frame)
	Battery:SetPos(130, 28+24*6)
	Battery:SetValue(Settings.Battery)
	function Battery:OnChange()
		Settings.Battery = Battery:GetChecked() and 1 or 0
		UpdateConCMD()
	end

	local SwitchesT = vgui.Create("DLabel", frame)--
	SwitchesT:SetPos(5, 25+24*7)
	SwitchesT:SetWide(120)
	SwitchesT:SetText("Automatic breakers:")
	
	local Switches = vgui.Create("DCheckBox", frame)
	Switches:SetPos(130, 28+24*7)
	Switches:SetValue(Settings.Switches)
	
	local SwitchesRT = vgui.Create("DLabel", frame)--
	SwitchesRT:SetPos(160, 25+24*7)
	SwitchesRT:SetWide(120)
	SwitchesRT:SetText("Random:")
	
	local SwitchesR = vgui.Create("DCheckBox", frame)
	SwitchesR:SetPos(220, 28+24*7)
	SwitchesR:SetValue(Settings.SwitchesR * Settings.Switches)
	function SwitchesR:OnChange()
		if Settings.Switches == 0 and SwitchesR:GetChecked() then
			SwitchesR:SetValue(Settings.Switches)
		end
		Settings.SwitchesR = SwitchesR:GetChecked() and 1 or 0
		UpdateConCMD()
	end

	function Switches:OnChange()
		Settings.Switches = Switches:GetChecked() and 1 or 0
		if Settings.Switches == 0 then SwitchesR:OnChange() end
		UpdateConCMD()
	end
	
	local DoorsT = vgui.Create("DLabel", frame)--
	DoorsT:SetPos(5, 25+24*8)
	DoorsT:SetWide(120)
	DoorsT:SetText("Doors opened [L/R]:")
	
	local DoorsL = vgui.Create("DCheckBox", frame)
	DoorsL:SetPos(130, 28+24*8)
	DoorsL:SetValue(Settings.DoorsL)
	local DoorsR = vgui.Create("DCheckBox", frame)
	DoorsR:SetPos(150, 28+24*8)
	DoorsR:SetValue(Settings.DoorsR)
	function DoorsL:OnChange()
		Settings.DoorsL = DoorsL:GetChecked() and 1 or 0
		UpdateConCMD()
	end
	function DoorsR:OnChange()
		Settings.DoorsR = DoorsR:GetChecked() and 1 or 0
		UpdateConCMD()
	end
	
	local PromT = vgui.Create("DLabel", frame)--
	PromT:SetPos(5, 25+24*9)
	PromT:SetText("Interim wags:")
	
	local Prom = vgui.Create("DCheckBox", frame)
	Prom:SetPos(130, 28+24*9) 
	Prom:SetValue(Settings.Prom)
	function Prom:OnChange()
		Settings.Prom = Prom:GetChecked() and 1 or 0
		UpdateConCMD()
	end
	
	
	local ARST = vgui.Create("DLabel", frame)--
	ARST:SetPos(5, 28+24*9)
	ARST:SetText("ARS Panel:")
	
	local ARS = vgui.Create("DComboBox", frame)
	ARS:SetPos(130, 28+24*9) 
	ARS:SetWide(80)
	for i=1,#ARSes do
		ARS:AddChoice(ARSes[i], i, Settings.ARS == i)
	end
	
	function ARS:OnSelect(_, _, index)
		Settings.ARS = index
		UpdateConCMD()
	end
	
	local MaskT = vgui.Create("DLabel", frame)--
	MaskT:SetPos(5, 28+24*10)
	MaskT:SetText("Mask:")
	
	local Mask = vgui.Create("DComboBox", frame)
	Mask:SetPos(130, 28+24*10) 
	Mask:SetWide(80)
	for i=1,#Masks do
		Mask:AddChoice(Masks[i], i, Settings.Mask == i)
	end
	
	function Mask:OnSelect(_, _, index)
		Settings.Mask = index
		UpdateConCMD()
	end
	
	function trainType:OnSelect(_, _, index)
		Settings.Train = index
		if index < 3 then
			if #Paints[index] < Settings.Paint then Settings.Paint = 1 end
			trainPaint:Clear()
			for i=1,#Paints[index] do
				trainPaint:AddChoice(Paints[index][i], i, i == Settings.Paint)
			end
		end
		trainPaintT:SetVisible(index < 3) 	trainPaint:SetVisible(index < 3)
		cranTypeT:SetVisible(index < 3) 	cranType:SetVisible(index < 3)
											NMPressure:SetVisible(index < 3)
		GVT:SetVisible(index < 3) 			GV:SetVisible(index < 3)
		BatteryT:SetVisible(index < 3) 		Battery:SetVisible(index < 3)
		SwitchesT:SetVisible(index < 3) 	Switches:SetVisible(index < 3) 	SwitchesRT:SetVisible(index < 3) 	SwitchesR:SetVisible(index < 3)
		PromT:SetVisible(index == 2) 		Prom:SetVisible(index == 2)
		DoorsT:SetVisible(index < 3) 		DoorsL:SetVisible(index < 3) 	DoorsR:SetVisible(index < 3)
		ARST:SetVisible(index < 2) 			ARS:SetVisible(index < 2)
		MaskT:SetVisible(index < 2) 		Mask:SetVisible(index < 2)
		UpdateConCMD()
	end
	
	trainType:OnSelect(nil,nil,Settings.Train)
end

local function createFrame()
	if GetConVarString("gmod_toolmode") == "train_spawner" then RunConsoleCommand("gmod_toolmode", "weld") end
	if !frame or !frame:IsValid() then
		frame = vgui.Create("DFrame")
			frame:SetDeleteOnClose(true)
			frame:SetTitle("Train Spawner")
			frame:SetSize(275, 34+24*12)
			frame:SetDraggable(false)
			frame:SetSizable(false)
			frame:Center()
			frame:MakePopup()
	end

	LoadConCMD()
	Draw()
	
	local Close = vgui.Create("DButton", frame)
	Close:SetWide(80)
	Close:SetPos(5, frame:GetTall() - Close:GetTall() - 5)
	Close:SetText("Close")
	
	Close.DoClick = function()
		frame:Close()
	end
	
	local spawn = vgui.Create("DButton", frame)
	spawn:SetWide(80)
	spawn:SetPos(frame:GetWide() - Close:GetWide() - 5, frame:GetTall() - Close:GetTall() - 5)
	spawn:SetText("Spawn Tool")
	
	spawn.DoClick = function()
		local Tool = GetConVarString("gmod_toolmode")
		if Tool == "train_spawner" then Tool = "weld" end
		RunConsoleCommand("train_spawner_oldT", Tool)
		RunConsoleCommand("train_spawner_oldW", LocalPlayer():GetActiveWeapon():GetClass())
		RunConsoleCommand("gmod_tool", "train_spawner")
		frame:Close()
	end
end

net.Receive("MetrostroiTrainSpawner",createFrame)