AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/metrostroi/signals/ars_box.mdl")
	Metrostroi.UpdateARSEntities()
end

function ENT:OnRemove()
	Metrostroi.UpdateARSEntities()
end

function ENT:Think()
	--print("ARS",self:GetIsolatingJoint())
	self:NextThink(CurTime() + 1.0)
	return true
end