﻿ENT.Type            = "anim"
ENT.Base            = "gmod_subway_base"

ENT.PrintName       = "Em508T"
ENT.Author          = ""
ENT.Contact         = ""
ENT.Purpose         = ""
ENT.Instructions    = ""
ENT.Category		= "Metrostroi (trains)"

ENT.Spawnable       = true
ENT.AdminSpawnable  = false

function ENT:PassengerCapacity()
	return 300
end

function ENT:GetStandingArea()
	return Vector(-450,-30,-45),Vector(380,30,-45)
end

function ENT:InitializeSounds()
	self.BaseClass.InitializeSounds(self)
	self.SoundNames["pneumo_switch"] = {
		"subway_trains/pneumo_8.wav",
		"subway_trains/pneumo_9.wav",
	}
end

function ENT:InitializeSystems()
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
	-- Пульт маневрнового передвижения
	self:LoadSystem("PMP","PMP")

	-- Реостатный контроллер для управления пусковыми сопротивления
	self:LoadSystem("RheostatController","EKG_17B")
	-- Групповой переключатель положений
	self:LoadSystem("PositionSwitch","EKG_18B")

	-- Ящики с реле и контакторами
	self:LoadSystem("LK_755A")
	self:LoadSystem("YAR_13A")
	self:LoadSystem("YAR_27")
	self:LoadSystem("YAK_36")
	self:LoadSystem("YAK_37E")
	self:LoadSystem("YAS_44V")
	self:LoadSystem("YARD_2")
	
	-- Панель управления 81-705
	self:LoadSystem("Panel","81_705_Panel")
	-- Электросистема 81-705
	self:LoadSystem("Electric","81_704_Electric")
	-- Пневмосистема 81-705
	self:LoadSystem("Pneumatic","81_717_Pneumatic")
	-- Everything else
	self:LoadSystem("Battery")
	self:LoadSystem("PowerSupply","DIP_01K")
	self:LoadSystem("Announcer")
end