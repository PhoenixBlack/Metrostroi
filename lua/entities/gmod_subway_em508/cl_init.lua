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
		{ID = "DIPonSet",	x=22,  y=19, radius=20, tooltip="Turn DIP and interior lights ON"},
		{ID = "DIPoffSet",	x=66,  y=19, radius=20, tooltip="Turn DIP and interior lights OFF"},
	}
}

-- Front panel
ENT.ButtonMap["Front"] = {
	pos = Vector(447.6,-35.3,5.0),
	ang = Angle(0,-97.4,74),
	width = 410,
	height = 95,
	scale = 0.0625,
	
	buttons = {
		{ID = "HeadLightsToggle",		x=400, y=75, radius=15, tooltip="Head lights TOGGLE"},
		{ID = "CabinLightsToggle",		x=387, y=28, radius=15, tooltip="Cabin lights TOGGLE"},	
		{x=234,y=33,tooltip="Speed"}
	}
}

-- ARS/Speedometer panel
ENT.ButtonMap["ARS"] = {
	pos = Vector(448.7,-37.3,5.0),
	ang = Angle(0,-97.9,74),
	width = 410*10,
	height = 95*10,
	scale = 0.0625/10,
	
	buttons = {}
}

-- Help panel
ENT.ButtonMap["Help"] = {
	pos = Vector(445.0,-36.0,30.0),
	ang = Angle(40+180,0,0),
	width = 20,
	height = 20,
	scale = 1,
	
	buttons = {
		{ID = "ShowHelp", x=10, y=10, radius=15, tooltip="Show help on driving the train"},
	}
}

-- FIXME
ENT.ButtonMap["FrontPneumatic"] = {
	pos = Vector(459.0,-45.0,-50.0),
	ang = Angle(0,90,90),
	width = 900,
	height = 100,
	scale = 0.1,
	buttons = {}
}
ENT.ButtonMap["RearPneumatic"] = {
	pos = Vector(-481.0,45.0,-50.0),
	ang = Angle(0,270,90),
	width = 900,
	height = 100,
	scale = 0.1,
	buttons = {}
}




--------------------------------------------------------------------------------
ENT.ClientPropsInitialized = false
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
	pos = Vector(449.20,-35.00,9.45),
	ang = Angle(90,0,180-14)
}
ENT.ClientProps["brake_line"] = {
	model = "models/metrostroi/81-717/red_arrow.mdl",
	pos = Vector(449.15,-35.05,9.45),
	ang = Angle(90,0,180-14)
}
ENT.ClientProps["brake_cylinder"] = {
	model = "models/metrostroi/81-717/black_arrow.mdl",
	pos = Vector(450.5,-32.9,13.4),
	ang = Angle(90,0,180-18)
}


ENT.ClientProps["ampermeter"] = {
	model = "models/metrostroi/81-717/black_arrow.mdl",
	pos = Vector(445.5,-59.5,23.3),
	ang = Angle(90,0,-45+180+80)
}
ENT.ClientProps["voltmeter"] = {
	model = "models/metrostroi/81-717/black_arrow.mdl",
	pos = Vector(448.1,-55.7,23.3),
	ang = Angle(90,0,-45+180+80)
}
ENT.ClientProps["speedometer"] = {
	model = "models/metrostroi/81-717/black_arrow.mdl",
	pos = Vector(447.10,-38.15,0.4),
	ang = Angle(90-18,180,7)
}


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

--[[ENT.ClientProps["cabinlights"] = {
	model = "models/metrostroi/81-717/switch04.mdl",
	pos = Vector(439.9,-44.2,-2.5),
	ang = Angle(-20,0,0)
}
ENT.ClientProps["headlights"] = {
	model = "models/metrostroi/81-717/switch04.mdl",
	pos = Vector(443.0,-42.4,-1.5),
	ang = Angle(-20,0,0)
}]]--

ENT.ClientProps["headlights"] = {
	model = "models/metrostroi/81-717/switch04.mdl",
	pos = Vector(443.1,-60.0,0.5),
	ang = Angle(-90,0,0)
}
ENT.ClientProps["panellights"] = {
	model = "models/metrostroi/81-717/switch04.mdl",
	pos = Vector(444.1,-59.3,3.3),
	ang = Angle(-90,0,0)
}
ENT.ClientProps["dip_on"] = {
	model = "models/metrostroi/81-717/switch02.mdl",
	pos = Vector(444.3,-36.4,-1.4),
	ang = Angle(-20,0,0)
}
ENT.ClientProps["dip_off"] = {
	model = "models/metrostroi/81-717/switch02.mdl",
	pos = Vector(443.9,-39.2,-1.4),
	ang = Angle(-20,0,0)
}




ENT.ClientProps["book"] = {
	model = "models/props_lab/binderredlabel.mdl",
	pos = Vector(449.0,-40.0,45.0),
	ang = Angle(-135,0,85)
}





--------------------------------------------------------------------------------
-- Add doors
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
	
	-- Simulate pressure gauges getting stuck a little
	self:Animate("brake", 			self:GetPackedRatio(0)^0.5, 		0.00, 0.65,  256,24)
	self:Animate("controller",		self:GetPackedRatio(1),				0.30, 0.70,  384,24)
	self:Animate("reverser",		self:GetPackedRatio(2),				0.20, 0.55,  4,false)
	self:Animate("speedometer", 	self:GetPackedRatio(3),				0.38,0.64)

	self:Animate("brake_line",		self:GetPackedRatio(8),				0.16, 0.84,  256,2,0.01)
	self:Animate("train_line",		self:GetPackedRatio(9),				0.16, 0.84,  256,2,0.01)
	self:Animate("brake_cylinder",	self:GetPackedRatio(10),	 		0.17, 0.86,  256,2,0.03)
	self:Animate("voltmeter",		self:GetPackedRatio(11),			0.38, 0.63)
	self:Animate("ampermeter",		self:GetPackedRatio(12),			0.38, 0.63)
	
	self:Animate("headlights",		self:GetPackedBool(0) and 1 or 0, 	0,1, 8, false)
	--self:Animate("panellights",		self:GetPackedBool(1) and 1 or 0, 	0,1, 8, false)
	self:Animate("dip_on",			self:GetPackedBool(2) and 1 or 0, 	0,1, 16, false)
	self:Animate("dip_off",			self:GetPackedBool(3) and 1 or 0, 	0,1, 16, false)
	
	-- DIP sound
	self:SetSoundState("bpsn2",self:GetPackedBool(32) and 1 or 0,1.0)
end

surface.CreateFont("MetrostroiSubway_LargeText", {
  font = "Arial",
  size = 100,
  weight = 500,
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
		if not self:GetPackedBool(32) then return end
	
		local speed = self:GetPackedRatio(3)*100.0
		local d1 = math.floor(speed) % 10
		local d2 = math.floor(speed / 10) % 10
		self:DrawDigit((196+0) *10,	35*10, d2, 0.75, 0.55)
		self:DrawDigit((196+10)*10,	35*10, d1, 0.75, 0.55)
		
		if self:GetPackedBool(35) then
			surface.SetDrawColor(255,200,0)
			surface.DrawRect(253*10,33*10,16*10,7*10)
			draw.DrawText("РП","MetrostroiSubway_LargeText",253*10+30,33*10-19,Color(0,0,0,255))
		end
		if self:GetPackedBool(36) then
			surface.SetDrawColor(255,200,0)
			surface.DrawRect(290*10,33*10,16*10,7*10)
			draw.DrawText("РП","MetrostroiSubway_LargeText",290*10+30,33*10-19,Color(0,0,0,255))
		end
		
		--[[if self:GetNWBool("LKT") then
			surface.SetDrawColor(50,255,50)
			surface.DrawRect(133*10,73*10,16*10,7*10)
			draw.DrawText("КТ","MetrostroiSubway_LargeText",133*10+30,73*10-20,Color(0,0,0,255))
		end			
		if self:GetNWBool("KVD") then
			surface.SetDrawColor(50,255,50)
			surface.DrawRect(165*10,73*10,16*10,7*10)
			draw.DrawText("КВД","MetrostroiSubway_LargeText",165*10,73*10-20,Color(0,0,0,255))
		end]]--	
		if self:GetPackedBool(33) then
			surface.SetDrawColor(255,200,0)
			surface.DrawRect(101*10,73*10,16*10,7*10)
		end
		if self:GetPackedBool(34) then
			surface.SetDrawColor(50,255,50)
			surface.DrawRect(196*10,73*10,16*10,7*10)
			draw.DrawText("НР1","MetrostroiSubway_LargeText",196*10,73*10-20,Color(0,0,0,255))
		end
	end)
	
	self:DrawOnPanel("FrontPneumatic",function()
		draw.DrawText(self:GetNWBool("FI") and "Isolated" or "Open","Trebuchet24",150,30,Color(0,0,0,255))
	end)
	self:DrawOnPanel("RearPneumatic",function()
		draw.DrawText(self:GetNWBool("RI") and "Isolated" or "Open","Trebuchet24",150,30,Color(0,0,0,255))
	end)
end

function ENT:OnButtonPressed(button)
	if button == "ShowHelp" then
		RunConsoleCommand("train_show_manual")
	end
end