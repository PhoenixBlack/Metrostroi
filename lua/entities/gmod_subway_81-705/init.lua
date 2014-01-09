AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")



--------------------------------------------------------------------------------
function ENT:Initialize()
	-- Defined train information
	self.SubwayTrain = {
		Type = "E",
		Name = "81-705",
	}

	-- Set model and initialize
	self:SetModel("models/metrostroi/81-705/81-705.mdl")
	self.BaseClass.Initialize(self)
	self:SetPos(self:GetPos() + Vector(0,0,140))
	
	-- Create seat entities
	self.DriverSeat = self:CreateSeat("driver",Vector(400,-40,-40))
	self.InstructorsSeat = self:CreateSeat("instructor",Vector(395,35,-40))
	
	-- Create bogeys
	self.FrontBogey = self:CreateBogey(Vector( 315-20,0,-90),Angle(0,180,0),true)
	self.RearBogey  = self:CreateBogey(Vector(-315-10,0,-90),Angle(0,0,0),false)
	
	-- Initialize key mapping
	self.KeyMap = {
		[KEY_1] = "D_1",
		[KEY_2] = "D_2",
		[KEY_3] = "D_3",
		[KEY_W] = "KVControllerUp",
		[KEY_S] = "KVControllerDown"
	}
end


--------------------------------------------------------------------------------
function ENT:Think()
	self:SetNWFloat("Controller",self.KV.ControllerPosition)
	return self.BaseClass.Think(self)
end