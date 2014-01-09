AddCSLuaFile("shared.lua")
include("shared.lua")




--------------------------------------------------------------------------------
function ENT:Initialize()
	self:SetModel("models/metrostroi/81-717/81-714_wheels.mdl")
	--models/metrostroi/props_models/train_wheel_test.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
end

function ENT:PhysicsCollide(data,physobj)
	-- Generate junction sounds
	if data.HitEntity and data.HitEntity:IsValid() and data.HitEntity:GetClass() == "prop_door_rotating" then
		self.LastJunctionTime = self.LastJunctionTime or CurTime()
		local dt = CurTime() - self.LastJunctionTime

		if dt > 3.5 then
			local speed = self:GetVelocity():Length() * 0.06858
			if speed > 10 then
				self.LastJunctionTime = CurTime()

				local pitch_var = math.random(90,110)
				local pitch = pitch_var*math.max(0.8,math.min(1.3,speed/40))
				self:EmitSound("subway_trains/junct_"..math.random(1,4)..".wav",100,pitch )
			end
		end
	end

	-- Generate flange sounds
	if (data.Speed > 115) and (data.DeltaTime > 0.085) then
		self:EmitSound("subway_trains/flange_"..math.random(1,8)..".wav",55,math.random(80,120))
	end
end
