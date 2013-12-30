ENT.Type            = "anim"
ENT.Base            = "base_gmodentity"

ENT.PrintName       = "Train Bogey"
ENT.Author          = ""
ENT.Contact         = ""
ENT.Purpose         = ""
ENT.Instructions    = ""

ENT.Spawnable       = true
ENT.AdminSpawnable  = false

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "Speed")
	self:NetworkVar("Float", 1, "MotorPower")
	self:NetworkVar("Float", 2, "dPdT")
end
