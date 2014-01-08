ENT.Type            = "anim"
ENT.Base            = "gmod_subway_base"

ENT.PrintName       = "81-705"
ENT.Author          = ""
ENT.Contact         = ""
ENT.Purpose         = ""
ENT.Instructions    = ""
ENT.Category		= "Metrostroi"

ENT.Spawnable       = true
ENT.AdminSpawnable  = false


function ENT:InitializeSystems()
	--self:LoadSystem("Controller")
	
	-- Ящик с предохранителями
	self:LoadSystem("YAP_57")
	self:LoadSystem("GV","GV_10ZH")	
	
	-- Токоприёмник
	self:LoadSystem("TR","TR_3B")	
	-- Электросистема 81-705
	self:LoadSystem("Electric","81_705_Electric")	
	-- Электротяговой двигатель
	self:LoadSystem("Engine","DK_117DM")
	
	self:LoadSystem("RheostatResistors","KF_47A")
	self:LoadSystem("RheostatController","EKG_17B")
	
end