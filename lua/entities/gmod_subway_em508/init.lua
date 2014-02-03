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
	
	self.DriverSeat:SetRenderMode(RENDERMODE_NONE)
	
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
		
		[KEY_G] = "VozvratRPSet",
		
		[KEY_0] = "KVReverserUp",
		[KEY_9] = "KVReverserDown",		
		[KEY_W] = "KVControllerUp",
		[KEY_S] = "KVControllerDown",
		[KEY_F] = "PneumaticBrakeUp",
		[KEY_R] = "PneumaticBrakeDown",

		[KEY_LSHIFT] = {
			--[KEY_W] = "Shift W",
			[KEY_A] = "DURASelectAlternate",
			--[KEY_S] = "Shift S",
			[KEY_D] = "DURASelectMain",			
			[KEY_1] = "DIPonSet",
			[KEY_2] = "DIPoffSet",
		},
	}
	
	self.InteractionZones = {
		{	Pos = Vector(458,-30,-55),
			Radius = 32,
			ID = "FrontBrakeLineIsolationToggle" },
		{	Pos = Vector(458, 30,-55),
			Radius = 32,
			ID = "FrontTrainLineIsolationToggle" },
		{	Pos = Vector(-482,30,-55),
			Radius = 32,
			ID = "RearBrakeLineIsolationToggle" },
		{	Pos = Vector(-482, -30,-55),
			Radius = 32,
			ID = "RearTrainLineIsolationToggle" },
		{	Pos = Vector(154,62.5,-65),
			Radius = 32,
			ID = "GVToggle" },
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
	self:LoadSystem("HeadLights","Relay","Switch")
end


--------------------------------------------------------------------------------
function ENT:Think()
	-- Headlights
	self:SetLightPower(1, (self.HeadLights.Value * self:ReadTrainWire(10)) == 1.0)
	self:SetLightPower(2, (self.HeadLights.Value * self:ReadTrainWire(10)) == 1.0)
	self:SetLightPower(3, (self.HeadLights.Value * self:ReadTrainWire(10)) == 1.0)
	self:SetLightPower(4, (self.HeadLights.Value * self:ReadTrainWire(10)) == 1.0)
	self:SetLightPower(5, (self.HeadLights.Value * self:ReadTrainWire(10)) == 1.0)
	self:SetLightPower(6, (self.HeadLights.Value * self:ReadTrainWire(10)) == 1.0)
	self:SetLightPower(7, (self.HeadLights.Value * self:ReadTrainWire(10)) == 1.0)
	
	-- Reverser lights
	self:SetLightPower(8, (self.RKR.Value * self:ReadTrainWire(10)) == 1.0)
	self:SetLightPower(9, (self.RKR.Value * self:ReadTrainWire(10)) == 1.0)
	
	-- Interior/cabin lights
	self:SetLightPower(10, self.PowerSupply.XT3[4] > 65.0)
	self:SetLightPower(11, self.PowerSupply.XT3[4] > 65.0)
	self:SetLightPower(12, self.PowerSupply.XT3[4] > 65.0)
	self:SetLightPower(13, self.PowerSupply.XT3[4] > 65.0)
	
	-- Switch and button states
	self:SetPackedBool(0,self.HeadLights.Value == 1.0)
	self:SetPackedBool(1,self.VozvratRP.Value == 1.0)
	self:SetPackedBool(2,self.DIPon.Value == 1.0)
	self:SetPackedBool(3,self.DIPoff.Value == 1.0)
	self:SetPackedBool(4,self.GV.Value == 1.0)
	
	-- DIP/power
	self:SetPackedBool(32,self.Electric.Aux80V > 65.0)
	-- LxRK
	self:SetPackedBool(33,self.RheostatController.MotorCoilState ~= 0.0)
	-- NR1
	self:SetPackedBool(34,self.NR.Value == 1.0)
	-- Red RP
	self:SetPackedBool(35,self.Electric.HACK_2_7R_31 ~= 0.0)
	-- Green RP
	self:SetPackedBool(36,self.RPvozvrat.Value ~= 0.0)

	-- Feed packed floats
	local speed = (self.FrontBogey.Speed + self.RearBogey.Speed)/2
	self:SetPackedRatio(0, 1-self.Pneumatic.DriverValvePosition/5)
	self:SetPackedRatio(1, (self.KV.ControllerPosition+3)/7)
	self:SetPackedRatio(2, 1-(self.KV.ReverserPosition+1)/2)
	self:SetPackedRatio(3, speed/100.0)
	
	self:SetPackedRatio(8, self.Pneumatic.ReservoirPressure/16.0)
	self:SetPackedRatio(9, self.Pneumatic.TrainLinePressure/16.0)
	self:SetPackedRatio(10,self.Pneumatic.BrakeCylinderPressure/6.0)
	self:SetPackedRatio(11,self.Electric.Power750V/1000.0)
	self:SetPackedRatio(12,math.abs(self.Electric.I24)/1000.0)	

	self.DebugVars["Speed"] = (self.FrontBogey.Speed + self.RearBogey.Speed)/2
	self.DebugVars["Acceleration"] = (self.FrontBogey.Acceleration + self.RearBogey.Acceleration)/2
	return self.BaseClass.Think(self)
end


--------------------------------------------------------------------------------
function ENT:OnButtonPress(button)
	if (button == "DIPonSet") or
	   (button == "DIPoffSet") or
	   (button == "HeadLightsToggle") or
	   (button == "VozvratRPSet") then
		self:PlayOnce("switch","cabin")
	end
	if (button == "GVToggle") then
		self:PlayOnce("switch4",nil,0.7)	
	end
end

function ENT:OnCouple(train,isfront)
	self.BaseClass.OnCouple(self,train,isfront)
	
	if isfront 
	then self.FrontBrakeLineIsolation:TriggerInput("Open",1.0)
	else self.RearBrakeLineIsolation:TriggerInput("Open",1.0)
	end
end