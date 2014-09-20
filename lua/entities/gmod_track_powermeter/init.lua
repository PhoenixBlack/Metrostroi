AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/z-o-m-b-i-e/metro_2033/electro/m33_electro_box_12_4.mdl")
	
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
end

function ENT:Think()
	self:SetTotal(Metrostroi.TotalkWh)
	self:SetRate(Metrostroi.TotalRateWatts)
	self:SetV(Metrostroi.Voltage)
	self:SetA(Metrostroi.Current)
	
	if Metrostroi.Voltage < 10 then
		self.SoundTimer = self.SoundTimer or CurTime()
		if (CurTime() - self.SoundTimer) > 1.0 then
			self:EmitSound("ambient/alarms/klaxon1.wav", 100, 100)
			self.SoundTimer = CurTime()
		end
	end
	
	self:NextThink(CurTime())
	return true
end