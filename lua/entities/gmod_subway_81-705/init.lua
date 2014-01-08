AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")



--------------------------------------------------------------------------------
function ENT:Initialize()
	-- Defined train information
	self.SubwayTrain = {
		Name = "81-705",
	}

	-- Set model and initialize
	self:SetModel("models/metrostroi/81-705/81-705.mdl")
	self.BaseClass.Initialize(self)
	self:SetPos(self:GetPos() + Vector(0,0,140))
	
	self.DriverSeat = self:CreateSeat(Vector(400,-40,-30),"driver")
	
	-- Define controller parameters
	self.MotorSettings = {}
	self.MotorForce = 30000
	--                        Power  Speed
	self.MotorSettings[-3] = { -1.00, 20  } -- T2
	self.MotorSettings[-2] = { -0.50, 40  } -- T1A
	self.MotorSettings[-1] = { -0.20, 90  } -- T1
	self.MotorSettings[ 0] = {  0.00, 00  }
	self.MotorSettings[ 1] = {  0.30, 25  } -- X1
	self.MotorSettings[ 2] = {  0.50, 40  } -- X2
	self.MotorSettings[ 3] = {  1.00, 90  } -- X3
	
	-- Create bogeys
	self.FrontBogey = self:CreateBogey(Vector( 315-20,0,-90),Angle(0,180,0),true)
	self.RearBogey  = self:CreateBogey(Vector(-315-10,0,-90),Angle(0,0,0),false)
end

