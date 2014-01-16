include("shared.lua")


--------------------------------------------------------------------------------
ENT.ClientProps = {}
ENT.ButtonMap = {}


-- Main panel
table.insert(ENT.ButtonMap,{ -- 2.0, -0.8
	pos = Vector(445.5,-35.3,-1.0),
	ang = Angle(0,-97.5,20),
	width = 410,
	height = 145,
	scale = 0.0625,
	
	buttons = {
		{ID="ControllerUp",x=50,y=60,radius=20,tooltip="Mode Up"},
		{ID="ControllerDown",x=50,y=100,radius=20,tooltip="Mode Down"},
		{ID="ReverserUp",x=100,y=60,radius=20,tooltip="Reverser Up"},
		{ID="ReverserDown",x=100,y=100,radius=20,tooltip="Reverser Down"}
	}
})




--------------------------------------------------------------------------------
ENT.ClientProps["brake"] = {
	model = "models/metrostroi/81-717/brake.mdl",
	pos = Vector(431,-59.5,2.7),
	ang = Angle(0,180,0)
}
--Vector(431,-58,-8),
ENT.ClientProps["controller"] = {
	model = "models/metrostroi/81-717/controller.mdl",
	pos = Vector(446,-25,2.2),
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


ENT.ClientProps["b_1"] = {
	model = "models/metrostroi/81-717/switch02.mdl",
	pos = Vector(444,-36.7,-1.1),
	ang = Angle(-20,0,0)
}
ENT.ClientProps["b_2"] = {
	model = "models/metrostroi/81-717/switch02.mdl",
	pos = Vector(443.7,-39.6,-1.1),
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
	
	local function animate(id,value,a,b)
		if not self["_anim_"..id] then
			self["_anim_"..id] = value
			self["_anim_"..id.."V"] = 0.0
		end
		
		local dX2dT = (a or 128)*(value - self["_anim_"..id]) - self["_anim_"..id.."V"] * (b or 8.0)
		self["_anim_"..id.."V"] = self["_anim_"..id.."V"] + dX2dT * self.DeltaTime
		self["_anim_"..id] = math.max(0,math.min(1,self["_anim_"..id] + self["_anim_"..id.."V"] * self.DeltaTime))
		return self["_anim_"..id]
	end
	
	
	if self.ClientEnts["brake"] then
		local pos = animate("brake",1 - self:GetNWFloat("DriverValve")/5,256,24)
		self.ClientEnts["brake"]:SetPoseParameter("position",0.0 + 0.65*pos)	
	end
	if self.ClientEnts["controller"] then
		local pos = animate("controller",(self:GetNWFloat("Controller")+3)/7,384,24)
		self.ClientEnts["controller"]:SetPoseParameter("position",0.3 + 0.4*pos)
	end
	if self.ClientEnts["reverser"] then
		local pos = animate("reverser",1-(self:GetNWFloat("Reverser")+1)/3,256,24)
		self.ClientEnts["reverser"]:SetPoseParameter("position",0.0 + 0.5*pos)
	end

	
	if self.ClientEnts["brake_line"] then
		self.ClientEnts["brake_line"]:SetPoseParameter("position",0.1+animate(1,self:GetNWFloat("BrakeLine")/16.0))
	end
	if self.ClientEnts["train_line"] then
		self.ClientEnts["train_line"]:SetPoseParameter("position",0.1+animate(2,self:GetNWFloat("TrainLine")/16.0))
	end
	if self.ClientEnts["brake_cylinder"] then
		self.ClientEnts["brake_cylinder"]:SetPoseParameter("position",0.40+0.20*animate(3,self:GetNWFloat("BrakeCylinder")/10.0))
	end
	if self.ClientEnts["voltmeter"] then
		self.ClientEnts["voltmeter"]:SetPoseParameter("position",0.34+0.3*animate(4,self:GetNWFloat("Volts") / 1000))
	end
	if self.ClientEnts["ampermeter"] then
		self.ClientEnts["ampermeter"]:SetPoseParameter("position",0.34+0.3*animate(5,self:GetNWFloat("Amperes") / 500))
	end
	--if self.ClientEnts["speedometer"] then
--		self.ClientEnts["speedometer"]:SetPoseParameter("position",0.3+0.41*animate(6,self:GetNWFloat("Speed") / 100))
--	end

end