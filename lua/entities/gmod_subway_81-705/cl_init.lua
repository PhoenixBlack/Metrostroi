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




--------------------------------------------------------------------------------
--function ENT:Initialize()
	--self.BaseClass.Initialize(self)
--end

function ENT:Think()
	self.BaseClass.Think(self)
	
	if self.ClientEnts["brake"] then
		self.ClientEnts["brake"]:SetPoseParameter("position",0.0 + 0.65*((CurTime()*2) % 1.0))
	end
	if self.ClientEnts["controller"] then
		local pos = (self:GetNWFloat("Controller")+3)/7
		self.ClientEnts["controller"]:SetPoseParameter("position",0.3 + 0.4*pos)
	end
end