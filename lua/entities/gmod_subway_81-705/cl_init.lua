include("shared.lua")


--------------------------------------------------------------------------------
ENT.ClientProps = {}
ENT.ButtonMap = {}


-- Main panel
table.insert(ENT.ButtonMap,{
	pos = Vector(427.5,-33.3,-18.23),
	ang = Angle(0,-90,11.3),
	width = 281,
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
	pos = Vector(431,-58,-8),
	ang = Angle(0,180,0)
}
ENT.ClientProps["controller"] = {
	model = "models/metrostroi/81-717/controller.mdl",
	pos = Vector(433,-24,-12),
	ang = Angle(0,-45,90)
}
ENT.ClientProps["train_line"] = {
	model = "models/metrostroi/81-717/black_arrow.mdl",
	pos = Vector(431,-58.7,1.8),
	ang = Angle(90,0,-50+180+90)
}
ENT.ClientProps["brake_line"] = {
	model = "models/metrostroi/81-717/red_arrow.mdl",
	pos = Vector(430.8,-58.55,1.8),
	ang = Angle(90,0,-50+180+90)
}
ENT.ClientProps["brake_cylinder"] = {
	model = "models/metrostroi/81-717/black_arrow.mdl",
	pos = Vector(429.5,-60.3,10.5),
	ang = Angle(90,0,-50+180+90)
}


ENT.ClientProps["voltmeter"] = {
	model = "models/metrostroi/81-717/black_arrow.mdl",
	pos = Vector(428.5,-60.1,23.4),
	ang = Angle(90,0,-45+180+90)
}
ENT.ClientProps["ampermeter"] = {
	model = "models/metrostroi/81-717/black_arrow.mdl",
	pos = Vector(428.5,-60.1,29.4),
	ang = Angle(90,0,-45+180+90)
}
ENT.ClientProps["speedometer"] = {
	model = "models/metrostroi/81-717/red_arrow.mdl",
	pos = Vector(428.3,-43,-17),
	ang = Angle(90-42,180,0)
}


table.insert(ENT.ClientProps,{
	model = "models/metrostroi/81-717/switch01.mdl",
	pos = Vector(422,-35.8,-19.6),
	ang = Angle(-11,0,0)
})
table.insert(ENT.ClientProps,{
	model = "models/metrostroi/81-717/switch01.mdl",
	pos = Vector(422,-35.8-13,-19.6),
	ang = Angle(-11,0,0)
})
table.insert(ENT.ClientProps,{
	model = "models/metrostroi/81-717/switch04.mdl",
	pos = Vector(422,-35.8-10,-19.0),
	ang = Angle(-11,0,0)
})
table.insert(ENT.ClientProps,{
	model = "models/metrostroi/81-717/switch04.mdl",
	pos = Vector(422,-35.8-7,-19.0),
	ang = Angle(-11,0,0)
})
for i=1,6 do
	table.insert(ENT.ClientProps,{
		model = "models/metrostroi/81-717/switch02.mdl",
		pos = Vector(426,-35.8-2.5*(i-1),-18.2),
		ang = Angle(-12,0,0)
	})
end
ENT.ClientPropsInitialized = false



for i=0,3 do
	for j=0,1 do
		for k=0,1 do
			table.insert(ENT.ClientProps,{
				model = "models/metrostroi/81-705/81-705_door2.mdl",
				pos = Vector(342 - 33*j - 226*i,66*(1-2*k),8.5),
				ang = Angle(0,180*k,0)
			})
		end
	end
end
table.insert(ENT.ClientProps,{
	model = "models/metrostroi/81-705/81-705_door1.mdl",
	pos = Vector(440.5,-1,-23.5),
	ang = Angle(0,0,0)
})
table.insert(ENT.ClientProps,{
	model = "models/metrostroi/81-705/81-705_door1.mdl",
	pos = Vector(-466.5,-1,-23.5),
	ang = Angle(0,180,0)
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

	
	if self.ClientEnts["brake_line"] then
		self.ClientEnts["brake_line"]:SetPoseParameter("position",0.1+animate(1,self:GetNWFloat("BrakeLine")/16.0))
	end
	if self.ClientEnts["train_line"] then
		self.ClientEnts["train_line"]:SetPoseParameter("position",0.1+animate(2,self:GetNWFloat("TrainLine")/16.0))
	end
	if self.ClientEnts["brake_cylinder"] then
		self.ClientEnts["brake_cylinder"]:SetPoseParameter("position",0.1+animate(3,self:GetNWFloat("BrakeCylinder")/10.0))
	end
	if self.ClientEnts["voltmeter"] then
		self.ClientEnts["voltmeter"]:SetPoseParameter("position",0.36+0.3*animate(4,self:GetNWFloat("Volts") / 1000))
	end
	if self.ClientEnts["ampermeter"] then
		self.ClientEnts["ampermeter"]:SetPoseParameter("position",0.36+0.3*animate(5,self:GetNWFloat("Amperes") / 1000))
	end
	if self.ClientEnts["speedometer"] then
		self.ClientEnts["speedometer"]:SetPoseParameter("position",0.3+0.41*animate(6,self:GetNWFloat("Speed") / 100))
	end

end