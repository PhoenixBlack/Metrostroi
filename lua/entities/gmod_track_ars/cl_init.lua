include("shared.lua")

function ENT:Draw()
	self:DrawModel()

	if GetConVarNumber("metrostroi_drawdebug") == 1 then
		local pos = self:LocalToWorld(Vector(32,0,35))
		local ang = self:LocalToWorldAngles(Angle(0,180,90))
		cam.Start3D2D(pos, ang, 0.25)
			surface.SetDrawColor(125, 125, 0, 255)
			surface.DrawRect(0, 0, 256, 120)
			
			draw.DrawText("ARS Section Information:","Trebuchet24",5,0,Color(0,0,0,255))
			draw.DrawText("Joint isolates signals: "..(self:GetIsolatingJoint() and "Yes" or "No"),
				"Trebuchet24",15,20,Color(0,0,0,255))
			draw.DrawText("Nominal speed: "..(self:GetNominalSpeed()),
				"Trebuchet36",15,50,Color(0,0,0,255))
		cam.End3D2D()
	end
end