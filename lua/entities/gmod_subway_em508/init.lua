AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")



--------------------------------------------------------------------------------
function ENT:Initialize()
	-- Defined train information
	self.SubwayTrain = {
		Type = "E",
		Name = "Em508",
	}

	-- Set model and initialize
	self:SetModel("models/metrostroi/e/em508.mdl")
	self.BaseClass.Initialize(self)
	self:SetPos(self:GetPos() + Vector(0,0,140))
	
	-- Create seat entities
	self.DriverSeat = self:CreateSeat("driver",Vector(418,-45,-28))
	self.InstructorsSeat = self:CreateSeat("instructor",Vector(410,35,-28))
	
	-- Create bogeys
	self.FrontBogey = self:CreateBogey(Vector( 325-10,0,-75),Angle(0,180,0),true)
	self.RearBogey  = self:CreateBogey(Vector(-325-10,0,-75),Angle(0,0,0),false)
	
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
	
	-- Lights
	self.Lights = {
		-- Head
		[1] = { "headlight", Vector(465,0,-20), Angle(0,0,0), Color(176,161,132), fov = 100 },
		[2] = { "glow",      Vector(460, 49,-28), Angle(0,0,0), Color(255,255,255), brightness = 2 },
		[3] = { "glow",      Vector(460,-49,-28), Angle(0,0,0), Color(255,255,255), brightness = 2 },
		[4] = { "glow",      Vector(458,-15, 55), Angle(0,0,0), Color(255,255,255), brightness = 0.3 },
		[5] = { "glow",      Vector(458,-5,  55), Angle(0,0,0), Color(255,255,255), brightness = 0.3 },
		[6] = { "glow",      Vector(458, 5,  55), Angle(0,0,0), Color(255,255,255), brightness = 0.3 },
		[7] = { "glow",      Vector(458, 15, 55), Angle(0,0,0), Color(255,255,255), brightness = 0.3 },
		
		-- Reverse
		[8] = { "light",     Vector(458,-27, 55), Angle(0,0,0), Color(255,0,0),     brightness = 10, scale = 1.0 },
		[9] = { "light",     Vector(458, 27, 55), Angle(0,0,0), Color(255,0,0),     brightness = 10, scale = 1.0 },
		
		-- Cabin
		[10] = { "dynamiclight",	Vector( 420, -40, 35), Angle(0,0,0), Color(255,255,255), brightness = 0.1, distance = 550 },
		
		-- Interior
		[11] = { "dynamiclight",	Vector( 250, 0, 5), Angle(0,0,0), Color(255,255,255), brightness = 3, distance = 250 },
		[12] = { "dynamiclight",	Vector(   0, 0, 5), Angle(0,0,0), Color(255,255,255), brightness = 3, distance = 150 },
		[13] = { "dynamiclight",	Vector(-250, 0, 5), Angle(0,0,0), Color(255,255,255), brightness = 3, distance = 250 },
	}
	
	-- Load relays for lights
	self:LoadSystem("HeadLights","Relay")
	self:LoadSystem("CabinLights","Relay")
	self:LoadSystem("InteriorLights","Relay")
end


--------------------------------------------------------------------------------
function ENT:Think()
	-- Enable lights
	self:SetLightPower(1, self.HeadLights.Value == 1.0)
	self:SetLightPower(2, self.HeadLights.Value == 1.0)
	self:SetLightPower(3, self.HeadLights.Value == 1.0)
	self:SetLightPower(4, self.HeadLights.Value == 1.0)
	self:SetLightPower(5, self.HeadLights.Value == 1.0)
	self:SetLightPower(6, self.HeadLights.Value == 1.0)
	self:SetLightPower(7, self.HeadLights.Value == 1.0)
	
	self:SetLightPower(8, self.RR.Value == 1.0)
	self:SetLightPower(9, self.RR.Value == 1.0)
	
	self:SetLightPower(10, self.CabinLights.Value == 1.0)
	
	self:SetLightPower(11, self.InteriorLights.Value == 1.0)
	self:SetLightPower(12, self.InteriorLights.Value == 1.0)
	self:SetLightPower(13, self.InteriorLights.Value == 1.0)
	
	-- Enable console
	self:SetNWBool("Power",true)
	self:SetNWBool("LxRK",self.RheostatController.Moving)
	--self:SetNWBool("LST",self:ReadTrainWire(6) > 0.5)
	self:SetNWBool("KVD",self:ReadTrainWire(20) > 0.5)
	self:SetNWBool("HeadLights",self.HeadLights.Value == 1.0)
	self:SetNWBool("CabinLights",self.CabinLights.Value == 1.0)
	self:SetNWBool("InteriorLights",self.InteriorLights.Value == 1.0)
	
	-- Feed values
	self:SetNWFloat("Reverser",self.KV.ReverserPosition)
	self:SetNWFloat("Controller",self.KV.ControllerPosition)
	self:SetNWFloat("DriverValve",self.Pneumatic.DriverValvePosition)	
	self:SetNWFloat("BrakeLine",self.Pneumatic.BrakeLinePressure)
	self:SetNWFloat("TrainLine",self.Pneumatic.TrainLinePressure)
	self:SetNWFloat("BrakeCylinder",self.Pneumatic.BrakeCylinderPressure)
	
	self:SetNWFloat("Volts",self.Electric.Power750V)
	self:SetNWFloat("Amperes",math.abs(self.Electric.Itotal))
	self:SetNWFloat("Speed",(self.FrontBogey.Speed + self.RearBogey.Speed)/2)
	self.DebugVars["Speed"] = (self.FrontBogey.Speed + self.RearBogey.Speed)/2
	self.DebugVars["Acceleration"] = (self.FrontBogey.Acceleration + self.RearBogey.Acceleration)/2
	return self.BaseClass.Think(self)
end