include("shared.lua")


ENT.ClientProps = {}
table.insert(ENT.ClientProps,{
	model = "models/metrostroi/81-717/brake.mdl",
	pos = Vector(431,-58,-8),
	ang = Angle(0,-90,0)
})

--[[for i=1,6 do
	table.insert(ENT.ClientProps,{
		model = "models/metrostroi/81-717/switch03.mdl",
		pos = Vector(426,-35.8-2.5*(i-1),-18.3),
		ang = Angle(-12,0,0)
	})
end]]--

ENT.ButtonMap = {}

--Main panel
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

for i=1,6 do
	table.insert(ENT.ClientProps,{
		model = "models/metrostroi/81-717/switch01.mdl",
		pos = Vector(426,-35.8-2.5*(i-1),-19.1),
		ang = Angle(0,90,-12)
	})
end
ENT.ClientPropsInitialized = false

--function ENT:Initialize()
	--self.BaseClass.Initialize(self)
--end

--function ENT:Think()
--	self.BaseClass.Think(self)
--end

