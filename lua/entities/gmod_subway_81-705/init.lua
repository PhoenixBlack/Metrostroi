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

	-- Create a drivers seat
	self.DriverSeat = self:CreateSeat(Vector(400,-40,-30),"driver")
	
	-- Create bogeys
	self.FrontBogey = self:CreateBogey(Vector( 315-20,0,-90),Angle(0,180,0),true)
	self.RearBogey  = self:CreateBogey(Vector(-315-10,0,-90),Angle(0,0,0),false)
end

