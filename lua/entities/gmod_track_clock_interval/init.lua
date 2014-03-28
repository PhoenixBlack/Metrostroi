AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")




--------------------------------------------------------------------------------
function ENT:Initialize()
	self:SetModel("models/metrostroi/signals/clock_interval.mdl")
end

function ENT:Think()
	-- Check if train passes the sign
	local sensingTrain = false
	for ray=0,6 do
		local trace = {
			start = self:GetPos() - self:GetRight()*16 + self:GetForward()*50*(ray-3) + Vector(0,0,64),
			endpos = self:GetPos() - self:GetRight()*16 + self:GetForward()*50*(ray-3) - Vector(0,0,256),
			--mask = -1,
			--filter = { },
			ignoreworld = true,
		}
		
		debugoverlay.Cross(trace.start,10,1,Color(0,0,255))
		debugoverlay.Line(trace.start,trace.endpos,1,Color(0,0,255))
		
		local result = util.TraceLine(trace)
		if result.Hit and (not result.HitWorld) then
			debugoverlay.Sphere(result.HitPos,5,1,Color(0,0,255),true)
			if result.Entity and (not result.Entity:IsPlayer()) then
				sensingTrain = true
			end
		end
	end

	-- React when there is train, but there was no train before
	self.SensingTime = self.SensingTime or (os.time())
	if sensingTrain then
		self.SensingTime = os.time()
		self.IntervalReset = false
	else
		if (os.time() - self.SensingTime > 2.0) and (not self.IntervalReset) then
			self:SetIntervalResetTime(os.time()-1396011937)
			self.IntervalReset = true
		end
	end
	self:NextThink(CurTime() + 0.5)
	return true
end