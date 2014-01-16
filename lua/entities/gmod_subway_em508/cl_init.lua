include("shared.lua")


--------------------------------------------------------------------------------
ENT.ClientProps = {}
ENT.ButtonMap = {}


-- Main panel
ENT.ButtonMap["Main"] = {
	pos = Vector(445.5,-35.3,-1.0),
	ang = Angle(0,-97.5,20),
	width = 410,
	height = 145,
	scale = 0.0625,
	
	buttons = {
		{ID = "HeadLightsToggle",		x=118, y=28, radius=15, tooltip="Head lights"},
		{ID = "InteriorLightsToggle",	x=118, y=75, radius=15, tooltip="Interior lights"},
		{ID = "CabinLightsToggle",		x=153, y=75, radius=15, tooltip="Cabin lights"},
	}
}

-- ARS/Speedometer panel
ENT.ButtonMap["ARS"] = {
	pos = Vector(447.6,-35.3,5.0),
	ang = Angle(0,-97.4,74),
	width = 410*10,
	height = 95*10,
	scale = 0.0625/10,
	
	buttons = {}
}




--------------------------------------------------------------------------------
ENT.ClientProps["brake"] = {
	model = "models/metrostroi/81-717/brake.mdl",
	pos = Vector(431,-59.5,2.7),
	ang = Angle(0,180,0)
}
--Vector(431,-58,-8),
ENT.ClientProps["controller"] = {
	model = "models/metrostroi/81-717/controller.mdl",
	pos = Vector(446,-25,2.0),
	ang = Angle(0,-45,90)
}
ENT.ClientProps["reverser"] = {
	model = "models/metrostroi/81-717/reverser.mdl",
	pos = Vector(446,-25,1.2),
	ang = Angle(0,45,90)
}
ENT.ClientProps["train_line"] = {
	model = "models/metrostroi/81-717/black_arrow.mdl",
	pos = Vector(449.2,-34.9,9.4),
	ang = Angle(90,0,180-14)
}
ENT.ClientProps["brake_line"] = {
	model = "models/metrostroi/81-717/red_arrow.mdl",
	pos = Vector(449.15,-34.9,9.4),
	ang = Angle(90,0,180-14)
}
ENT.ClientProps["brake_cylinder"] = {
	model = "models/metrostroi/81-717/black_arrow.mdl",
	pos = Vector(450.5,-32.9,12.6),
	ang = Angle(90,0,180-18)
}


ENT.ClientProps["ampermeter"] = {
	model = "models/metrostroi/81-717/black_arrow.mdl",
	pos = Vector(445.1,-59.0,23.8),
	ang = Angle(90,0,-45+180+80)
}
ENT.ClientProps["voltmeter"] = {
	model = "models/metrostroi/81-717/black_arrow.mdl",
	pos = Vector(447.8,-55.2,23.8),
	ang = Angle(90,0,-45+180+80)
}
--[[ENT.ClientProps["speedometer"] = {
	model = "models/metrostroi/81-717/red_arrow.mdl",
	pos = Vector(428.3,-43,-17),
	ang = Angle(90-42,180,0)
}]]--


--[[ENT.ClientProps["b_1"] = {
	model = "models/metrostroi/81-717/switch02.mdl",
	pos = Vector(444,-36.7,-1.1),
	ang = Angle(-20,0,0)
}
ENT.ClientProps["b_2"] = {
	model = "models/metrostroi/81-717/switch02.mdl",
	pos = Vector(443.7,-39.6,-1.1),
	ang = Angle(-20,0,0)
}]]--

ENT.ClientProps["interiorlights"] = {
	model = "models/metrostroi/81-717/switch04.mdl",
	pos = Vector(440.3,-42.0,-2.5),
	ang = Angle(-20,0,0)
}
ENT.ClientProps["cabinlights"] = {
	model = "models/metrostroi/81-717/switch04.mdl",
	pos = Vector(439.9,-44.2,-2.5),
	ang = Angle(-20,0,0)
}
ENT.ClientProps["headlights"] = {
	model = "models/metrostroi/81-717/switch04.mdl",
	pos = Vector(443.0,-42.4,-1.5),
	ang = Angle(-20,0,0)
}

--Vector(426,-35.8-2.5*(i-1),-18.2),
ENT.ClientPropsInitialized = false



for i=0,3 do
	for k=0,1 do
		table.insert(ENT.ClientProps,{
			model = "models/metrostroi/e/em508_door1.mdl",
			pos = Vector(353.0 - 35*k - 231*i,-65*(1-2*k),-1.8),
			ang = Angle(0,180*k,0)
		})
		table.insert(ENT.ClientProps,{
			model = "models/metrostroi/e/em508_door2.mdl",
			pos = Vector(353.0 - 35*(1-k) - 231*i,-65*(1-2*k),-1.8),
			ang = Angle(0,180*k,0)
		})
	end
end
table.insert(ENT.ClientProps,{
	model = "models/metrostroi/e/em508_door5.mdl",
	pos = Vector(456.5,0.4,-3.8),
	ang = Angle(0,0,0)
})
table.insert(ENT.ClientProps,{
	model = "models/metrostroi/e/em508_door5.mdl",
	pos = Vector(-479.5,-0.5,-3.8),
	ang = Angle(0,180,0)
})
table.insert(ENT.ClientProps,{
	model = "models/metrostroi/e/em508_door4.mdl",
	pos = Vector(386.5,0.4,5.2),
	ang = Angle(0,0,0)
})
table.insert(ENT.ClientProps,{
	model = "models/metrostroi/e/em508_door3.mdl",
	pos = Vector(425.6,65.2,-2.2),
	ang = Angle(0,0,0)
})




--------------------------------------------------------------------------------
--function ENT:Initialize()
	--self.BaseClass.Initialize(self)
--end

function ENT:Think()
	self.BaseClass.Think(self)
	if CurTime() - (self.ASD or 0) > 10 then
		self.ASD = CurTime()
		self:RemoveCSEnts()
		self:CreateCSEnts()
	end

	self:Animate("brake", 			1-self:GetNWFloat("DriverValve")/5, 	0.00, 0.65,  256,24)
	self:Animate("controller",		(self:GetNWFloat("Controller")+3)/7, 	0.30, 0.70,  384,24)
	self:Animate("reverser",		1-(self:GetNWFloat("Reverser")+1)/2, 	0.20, 0.55,  512,64)
	
	self:Animate("brake_line",		self:GetNWFloat("BrakeLine")/12.0, 		0.10, 1.00)
	self:Animate("train_line",		self:GetNWFloat("TrainLine")/12.0, 		0.10, 1.00)
	self:Animate("brake_cylinder",	self:GetNWFloat("BrakeCylinder")/12.0, 	0.40, 0.60)
	self:Animate("voltmeter",		self:GetNWFloat("Volts")/1000.0, 		0.34, 0.65)
	self:Animate("ampermeter",		self:GetNWFloat("Amperes")/500.0, 		0.34, 0.65)
	
	self:Animate("interiorlights",	self:GetNWBool("InteriorLights") and 0 or 1, 	0,1, 512, 64)
	self:Animate("headlights",		self:GetNWBool("HeadLights") and 0 or 1, 		0,1, 512, 64)
	self:Animate("cabinlights",		self:GetNWBool("CabinLights") and 0 or 1, 		0,1, 512, 64)

				
	--if self.ClientEnts["speedometer"] then
--		self.ClientEnts["speedometer"]:SetPoseParameter("position",0.3+0.41*animate(6,self:GetNWFloat("Speed") / 100))
--	end

end

surface.CreateFont("MetrostroiSubway_LargeText", {
  font = "Trebuchet",
  size = 72,
  weight = 1000,
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
})

function ENT:Draw()
	self.BaseClass.Draw(self)
	self:DrawOnPanel("ARS",function()
		if not self:GetNWBool("Power") then return end
	
		local speed = self:GetNWFloat("Speed")
		local d1 = math.floor(speed) % 10
		local d2 = math.floor(speed / 10) % 10
		self:DrawDigit(242*10+20,    35*10-30, d2, 3.4,5)
		self:DrawDigit(242*10+20+100,35*10-30, d1, 3.4,5)
		
		if self:GetNWBool("RP") then
			--surface.SetDrawColor(255,200,0)
			--surface.DrawRect(190*10,34*10,16*10,7*10)
			--draw.DrawText("РП","MetrostroiSubway_LargeText",190*10+30,34*10-5,Color(0,0,0,255))
			
			surface.SetDrawColor(255,200,0)
			surface.DrawRect(300*10,34*10,16*10,7*10)
			draw.DrawText("РП","MetrostroiSubway_LargeText",300*10+30,34*10-5,Color(0,0,0,255))
			surface.SetDrawColor(255,200,0)
			surface.DrawRect(338*10,34*10,16*10,7*10)
			draw.DrawText("РП","MetrostroiSubway_LargeText",338*10+30,34*10-5,Color(0,0,0,255))
		end
		
		if self:GetNWBool("LKT") then
			surface.SetDrawColor(50,255,50)
			surface.DrawRect(185*10,66*10,16*10,7*10)
			draw.DrawText("ЛКТ","MetrostroiSubway_LargeText",185*10+5,66*10-5,Color(0,0,0,255))
		end
			
		if self:GetNWBool("LVD") then
			surface.SetDrawColor(50,255,50)
			surface.DrawRect(214*10,66*10,16*10,7*10)
			draw.DrawText("ЛВД","MetrostroiSubway_LargeText",214*10+5,66*10-5,Color(0,0,0,255))
		end
			
		if self:GetNWBool("LST") then
			surface.SetDrawColor(50,255,50)
			surface.DrawRect(245*10,66*10,16*10,7*10)
			draw.DrawText("ЛСТ","MetrostroiSubway_LargeText",245*10+5,66*10-5,Color(0,0,0,255))
		end
			
		if self:GetNWBool("LxRK") then
			surface.SetDrawColor(50,255,50)
			surface.DrawRect(275*10,66*10,16*10,7*10)
			draw.DrawText("ЛхРК","MetrostroiSubway_LargeText",275*10-4,66*10-5,Color(0,0,0,255))
		end
	end)
end
