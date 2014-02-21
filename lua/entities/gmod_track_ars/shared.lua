ENT.Type            = "anim"

ENT.PrintName       = "ARS Railroad Element"
ENT.Category		= "Metrostroi (utility)"

ENT.Spawnable       = false
ENT.AdminSpawnable  = false

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "IsolatingJoint", { KeyName = "k1", Edit = {
		title = "Isolating joint",
		category = "Parameters",
		type = "Boolean" } } )
		
	self:NetworkVar("Float", 0, "NominalSpeed", { KeyName = "k2", Edit = {
		title = "Nominal Speed",
		category = "ARS/ALS",
		type = "Float" } } )
end