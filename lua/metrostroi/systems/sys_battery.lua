--------------------------------------------------------------------------------
-- Ящик аккумуляторной батареи (АБ)
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("Battery")

function TRAIN_SYSTEM:Initialize()
	-- Предохранители цепей (ПА1, ПА2)
	self.Train:LoadSystem("PA1","Fuse","PP-28", { trigger_level = 31.5 }) -- A
	self.Train:LoadSystem("PA2","Fuse","PP-28", { trigger_level = 31.5 }) -- A
	
	-- Battery parameters
	self.ElementCapacity 	= 80 -- A*hour
	self.ElementCount 		= 56 -- 52 on 81-717
	self.Capacity = self.ElementCapacity * self.ElementCount
end

function TRAIN_SYSTEM:Think()
end