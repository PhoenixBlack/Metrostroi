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

