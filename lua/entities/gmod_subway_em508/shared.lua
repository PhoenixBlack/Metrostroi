ENT.Type            = "anim"
ENT.Base            = "gmod_subway_base"

ENT.PrintName       = "Em-508"
ENT.Author          = ""
ENT.Contact         = ""
ENT.Purpose         = ""
ENT.Instructions    = ""
ENT.Category		= "Metrostroi"

ENT.Spawnable       = true
ENT.AdminSpawnable  = false


function ENT:InitializeSystems()
	-- Главный выключатель
	self:LoadSystem("GV","GV_10ZH")	
	
	-- Токоприёмник
	self:LoadSystem("TR","TR_3B")	
	-- Электротяговые двигатели
	self:LoadSystem("Engines","DK_117DM")	

	-- Резисторы для реостата/пусковых сопротивлений
	self:LoadSystem("KF_47A")
	-- Резисторы для ослабления возбуждения
	self:LoadSystem("KF_50A")
	-- Ящик с предохранителями
	self:LoadSystem("YAP_57")
	
	-- Резисторы для цепей управления
	--self:LoadSystem("YAS_44V")
	-- Реостатный контроллер для управления пусковыми сопротивления
	self:LoadSystem("RheostatController","EKG_17B")
	-- Групповой переключатель положений
	self:LoadSystem("PositionSwitch","EKG_18B")
	-- Кулачковый контроллер
	self:LoadSystem("KV","KV_66")

	
	-- Ящики с реле и контакторами
	self:LoadSystem("LK_755A")
	self:LoadSystem("YAR_13A")
	--self:LoadSystem("YAK_31A")
	self:LoadSystem("YAR_27")
	self:LoadSystem("YAK_37E")
	self:LoadSystem("YAS_44V")
	self:LoadSystem("YARD_2")
	
	-- Электросистема 81-705
	self:LoadSystem("Electric","81_705_Electric")
	-- Пневмосистема 81-705
	self:LoadSystem("Pneumatic","81_717_Pneumatic")
	
	
	self:LoadSystem("DURA","DURA")
end
