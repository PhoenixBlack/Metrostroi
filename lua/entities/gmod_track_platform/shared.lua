ENT.Type			= "point"
ENT.Base			= "base_gmodentity"
ENT.PrintName		= "Train Platform"
ENT.Spawnable		= false
ENT.AdminSpawnable	= false

function ENT:PoolSize()
	return 2048
end

function ENT:Seed()
	return self:EntIndex()
end