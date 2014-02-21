AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/metrostroi/signals/box.mdl")
	Metrostroi.DropToFloor(self)
	
	-- Initial state of the switch
	self.AlternateTrack = false
end

function ENT:Think()
	-- Find all prop_door_rotating
	--[[local list = ents.FindInSphere(self:GetPos(),512)
	self.TrackSwitches = {}
	for k,v in pairs(list) do
		if (v:GetClass() == "prop_door_rotating") and (string.find(v:GetName(),"switch")) then
			table.insert(self.TrackSwitches,v)
		end
	end
	
	-- Force state
	self.AlternateTrack = (CurTime() % 5) > 2.5
	if self.AlternateTrack then
		for k,v in pairs(self.TrackSwitches) do v:Fire("Open","","0") end
	else
		for k,v in pairs(self.TrackSwitches) do v:Fire("Close","","0") end
	end
	
	-- Print things
	local asd = self.TrackSwitches[1]
	local results = Metrostroi.GetPositionOnTrack(asd:GetPos(),asd:GetAngles())
	for k,v in pairs(results) do
		print(Format("\t[%d] APath #%d: (%.2f x %.2f x %.2f) m  Facing %.3f",k,v.path.id,v.x,v.y,v.z,v.angle))
	end
	
	local asd = self.TrackSwitches[2]
	local results = Metrostroi.GetPositionOnTrack(asd:GetPos(),asd:GetAngles())
	for k,v in pairs(results) do
		print(Format("\t[%d] BPath #%d: (%.2f x %.2f x %.2f) m  Facing %.3f",k,v.path.id,v.x,v.y,v.z,v.angle))
	end]]--
	
	--debugoverlay.Sphere(self:GetPos(),512,1,Color(0,255,255),true)
	self:NextThink(CurTime() + 1.0)
	return true
end