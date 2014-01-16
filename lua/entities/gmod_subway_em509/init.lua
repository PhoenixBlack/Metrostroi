AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")



--------------------------------------------------------------------------------
function ENT:Initialize()
	-- Defined train information
	self.SubwayTrain = {
		Type = "E",
		Name = "Em509",
	}

	-- Set model and initialize
	self:SetModel("models/metrostroi/e/em509.mdl")
	self.BaseClass.Initialize(self)
	self:SetPos(self:GetPos() + Vector(0,0,140))
	
	-- Create seat entities
	self.DriverSeat = self:CreateSeat("driver",Vector(418,-45,-28))
	self.InstructorsSeat = self:CreateSeat("instructor",Vector(410,35,-28))
	
	-- Create bogeys
	self.FrontBogey = self:CreateBogey(Vector( 325,0,-75),Angle(0,180,0),true)
	self.RearBogey  = self:CreateBogey(Vector(-325,0,-75),Angle(0,0,0),false)
	
	-- Initialize key mapping
	self.KeyMap = {
		[KEY_1] = "KVSetX1",
		[KEY_2] = "KVSetX2",
		[KEY_3] = "KVSetX3",
		[KEY_4] = "KVSet0",
		[KEY_5] = "KVSetT1",
		[KEY_6] = "KVSetT1A",
		[KEY_7] = "KVSetT2",
		
		[KEY_G] = "ElectricResetRPL",
		
		[KEY_0] = "KVReverserUp",
		[KEY_9] = "KVReverserDown",		
		[KEY_W] = "KVControllerUp",
		[KEY_S] = "KVControllerDown",
		[KEY_F] = "PneumaticBrakeUp",
		[KEY_R] = "PneumaticBrakeDown",
		
		[KEY_A] = "DURASelectAlternate",
		[KEY_D] = "DURASelectMain",
	}
end


--------------------------------------------------------------------------------
function ENT:Think()
	self:SetNWFloat("Reverser",self.KV.ReverserPosition)
	self:SetNWFloat("Controller",self.KV.ControllerPosition)
	self:SetNWFloat("DriverValve",self.Pneumatic.DriverValvePosition)	
	self:SetNWFloat("BrakeLine",self.Pneumatic.BrakeLinePressure)
	self:SetNWFloat("TrainLine",self.Pneumatic.TrainLinePressure)
	self:SetNWFloat("BrakeCylinder",self.Pneumatic.BrakeCylinderPressure)
	
	self:SetNWFloat("Volts",self.Electric.Power750V)
	self:SetNWFloat("Amperes",self.DebugVars["ElectricItotal"])
	self:SetNWFloat("Speed",(self.FrontBogey.Speed + self.RearBogey.Speed)/2)
	self.DebugVars["Speed"] = (self.FrontBogey.Speed + self.RearBogey.Speed)/2
	self.DebugVars["Acceleration"] = (self.FrontBogey.Acceleration + self.RearBogey.Acceleration)/2
	return self.BaseClass.Think(self)
end
