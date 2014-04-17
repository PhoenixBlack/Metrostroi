AddCSLuaFile("shared.lua")
include("shared.lua")




--------------------------------------------------------------------------------
function ENT:Initialize()
	if self.WheelType == "tatra" then
		self:SetModel("models/metrostroi/tatra_t3/tatra_wheels.mdl")
	else
		self:SetModel("models/metrostroi/metro/metro_wheels.mdl")	
	end
	if not self.NoPhysics then
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
	end
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
	if (data.Speed > 115) and (data.DeltaTime > 0.095) then
		self:EmitSound("subway_trains/flange_"..math.random(1,8)..".wav",65,math.random(80,120))
	end
end
