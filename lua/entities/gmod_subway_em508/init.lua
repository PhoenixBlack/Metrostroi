AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.BogeyDistance = 650 --Needed for gm trainspawner

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
		
		[KEY_A] = "KDLSet",
		[KEY_D] = "KDPSet",
		[KEY_V] = "VUD1Set",
		[KEY_L] = "HeadLightsToggle",

		[KEY_LSHIFT] = {
			[KEY_A] = "DURASelectAlternate",
			[KEY_D] = "DURASelectMain",			
			[KEY_1] = "DIPonSet",
			[KEY_2] = "DIPoffSet",
			[KEY_L] = "DriverValveDisconnectToggle",
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
		{	Pos = Vector(393.6,26.0+4.6*1,24.9),
			Radius = 16,
			ID = "VBToggle" },
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
	
	-- Cross connections in train wires
	self.TrainWireCrossConnections = {
		[5] = 4, -- Reverser F<->B
		[31] = 32, -- Doors L<->R
	}
end


--------------------------------------------------------------------------------
function ENT:Think()
	local retVal = self.BaseClass.Think(self)

	-- Check if wrench was pulled out
	if not self:IsWrenchPresent() then self.KV:TriggerInput("ReverserSet",0) end

	-- Headlights
	local brightness = (math.min(1,self.Panel["HeadLights1"] or 0) + 
						math.min(1,self.Panel["HeadLights2"] or 0) + 
						math.min(1,self.Panel["HeadLights3"] or 0))/3
	self:SetLightPower(1, self.Panel["HeadLights3"] > 0.5,brightness)
	self:SetLightPower(2, self.Panel["HeadLights3"] > 0.5)
	self:SetLightPower(3, self.Panel["HeadLights3"] > 0.5)
	self:SetLightPower(4, self.Panel["HeadLights1"] > 0.5)
	self:SetLightPower(5, self.Panel["HeadLights2"] > 0.5)
	self:SetLightPower(6, self.Panel["HeadLights2"] > 0.5)
	self:SetLightPower(7, self.Panel["HeadLights1"] > 0.5)
	
	-- Reverser lights
	self:SetLightPower(8, self.Panel["RedLightRight"] > 0.5)
	self:SetLightPower(9, self.Panel["RedLightLeft"] > 0.5)
	
	-- Interior/cabin lights
	self:SetLightPower(10, self.Panel["CabinLight"] > 0.5)
	self:SetLightPower(11, self.PowerSupply.XT3_4 > 65.0)
	self:SetLightPower(12, self.Panel["EmergencyLight"] > 0.5)
	self:SetLightPower(13, self.PowerSupply.XT3_4 > 65.0)
	
	-- Switch and button states
	self:SetPackedBool(0,self:IsWrenchPresent())
	self:SetPackedBool(1,self.VUS.Value == 1.0)
	self:SetPackedBool(2,self.VozvratRP.Value == 1.0)
	self:SetPackedBool(3,self.DIPon.Value == 1.0)
	self:SetPackedBool(4,self.DIPoff.Value == 1.0)
	self:SetPackedBool(5,self.GV.Value == 1.0)
	self:SetPackedBool(6,self.DriverValveDisconnect.Value == 1.0)
	self:SetPackedBool(7,self.VB.Value == 1.0)
	self:SetPackedBool(8,self.RezMK.Value == 1.0)
	self:SetPackedBool(9,self.VMK.Value == 1.0)
	self:SetPackedBool(10,self.VAH.Value == 1.0)
	self:SetPackedBool(11,self.VAD.Value == 1.0)
	self:SetPackedBool(12,self.VUD1.Value == 1.0)
	self:SetPackedBool(13,self.VUD2.Value == 1.0)
	self:SetPackedBool(14,self.VDL.Value == 1.0)
	self:SetPackedBool(15,self.KDL.Value == 1.0)
	self:SetPackedBool(16,self.KDP.Value == 1.0)
	self:SetPackedBool(17,self.KRZD.Value == 1.0)
	self:SetPackedBool(18,self.KSN.Value == 1.0)
	self:SetPackedBool(19,self.OtklAVU.Value == 1.0)
	self:SetPackedBool(20,self.Pneumatic.Compressor == 1.0)
	self:SetPackedBool(21,self.Pneumatic.LeftDoorState[1] > 0.5)
	self:SetPackedBool(22,self.Pneumatic.LeftDoorState[2] > 0.5)
	self:SetPackedBool(23,self.Pneumatic.LeftDoorState[3] > 0.5)
	self:SetPackedBool(24,self.Pneumatic.LeftDoorState[4] > 0.5)
	self:SetPackedBool(25,self.Pneumatic.RightDoorState[1] > 0.5)
	self:SetPackedBool(26,self.Pneumatic.RightDoorState[2] > 0.5)
	self:SetPackedBool(27,self.Pneumatic.RightDoorState[3] > 0.5)
	self:SetPackedBool(28,self.Pneumatic.RightDoorState[4] > 0.5)
	
	-- Signal if doors are open or no to platform simulation
	self.LeftDoorsOpen = 
		(self.Pneumatic.LeftDoorState[1] > 0.5) or
		(self.Pneumatic.LeftDoorState[2] > 0.5) or
		(self.Pneumatic.LeftDoorState[3] > 0.5) or
		(self.Pneumatic.LeftDoorState[4] > 0.5)
	self.RightDoorsOpen = 
		(self.Pneumatic.RightDoorState[1] > 0.5) or
		(self.Pneumatic.RightDoorState[2] > 0.5) or
		(self.Pneumatic.RightDoorState[3] > 0.5) or
		(self.Pneumatic.RightDoorState[4] > 0.5)
	
	-- DIP/power
	self:SetPackedBool(32,self.Panel["V1"] > 0.5)
	-- LxRK
	self:SetPackedBool(33,self.RheostatController.MotorCoilState ~= 0.0)
	-- NR1
	self:SetPackedBool(34,(self.NR.Value == 1.0) or (self.RPU.Value == 1.0))
	-- Red RP
	self:SetPackedBool(35,self.Panel["RedRP"] > 0.5)
	-- Green RP
	self:SetPackedBool(36,self.Panel["GreenRP"] > 0.5)
	-- Cabin heating
	self:SetPackedBool(37,self.Panel["KUP"] > 0.5)	
	-- AVU
	self:SetPackedBool(38,self.Panel["AVU"] > 0.5)	
	-- Ring
	self:SetPackedBool(39,self.Panel["Ring"] > 0.5)
	-- SD
	self:SetPackedBool(40,self.Panel["SD"] > 0.5)
	
	-- AV states
	for i,v in ipairs(self.Panel.AVMap) do
		if tonumber(v) 
		then self:SetPackedBool(64+(i-1),self["A"..v].Value == 1.0)
		else self:SetPackedBool(64+(i-1),self[v].Value == 1.0)
		end
	end
    
	-- Feed packed floats
	local speed = (self.FrontBogey.Speed + self.RearBogey.Speed)/2
	self:SetPackedRatio(0, 1-self.Pneumatic.DriverValvePosition/5)
	self:SetPackedRatio(1, (self.KV.ControllerPosition+3)/7)
	self:SetPackedRatio(2, 1-(self.KV.ReverserPosition+1)/2)
	self:SetPackedRatio(3, speed/100.0)
	self:SetPackedRatio(4, self.Pneumatic.ReservoirPressure/16.0)
	self:SetPackedRatio(5, self.Pneumatic.TrainLinePressure/16.0)
	self:SetPackedRatio(6, self.Pneumatic.BrakeCylinderPressure/6.0)
	self:SetPackedRatio(7, self.Electric.Power750V/1000.0)
	self:SetPackedRatio(8, math.abs(self.Electric.I24)/1000.0)	
	self:SetPackedRatio(9, self.Pneumatic.BrakeLinePressure_dPdT or 0)
	self:SetPackedRatio(10,(self.Panel["V1"] * self.Battery.Voltage) / 100.0)

	local speed,acceleration = 0,0
	if IsValid(self.FrontBogey) and IsValid(self.RearBogey) then
		speed = (self.FrontBogey.Speed + self.RearBogey.Speed)/2
		acceleration = (self.FrontBogey.Acceleration + self.RearBogey.Acceleration)/2
	end
	self.DebugVars["Speed"] = speed
	self.DebugVars["Acceleration"] = acceleration
	
	-- Exchange some parameters between engines, pneumatic system, and real world
	self.Engines:TriggerInput("Speed",speed)
	if IsValid(self.FrontBogey) and IsValid(self.RearBogey) then
		self.FrontBogey.MotorForce = 40000
		self.FrontBogey.Reversed = (self.RKR.Value > 0.5)
		self.RearBogey.MotorForce  = 40000
		self.RearBogey.Reversed = (self.RKR.Value < 0.5)
	
		self.RearBogey.MotorPower  = self.Engines.BogeyMoment
		self.FrontBogey.MotorPower = self.Engines.BogeyMoment
		
		-- Apply brakes
		self.FrontBogey.PneumaticBrakeForce = 100000.0
		self.FrontBogey.BrakeCylinderPressure = self.Pneumatic.BrakeCylinderPressure
		self.FrontBogey.BrakeCylinderPressure_dPdT = -self.Pneumatic.BrakeCylinderPressure_dPdT
		self.RearBogey.PneumaticBrakeForce = 100000.0
		self.RearBogey.BrakeCylinderPressure = self.Pneumatic.BrakeCylinderPressure
		self.RearBogey.BrakeCylinderPressure_dPdT = -self.Pneumatic.BrakeCylinderPressure_dPdT
	end
	return retVal
end


--------------------------------------------------------------------------------
function ENT:OnButtonPress(button)
	-- Special sounds
	if button == "GVToggle" then self:PlayOnce("switch4",nil,0.7) return end
	if button == "DriverValveDisconnectToggle" then
		if self.DriverValveDisconnect.Value == 1.0 then
			self:PlayOnce("pneumo_disconnect1","cabin",0.9)
		else
			self:PlayOnce("pneumo_disconnect2","cabin",0.9)
		end
	end
	if string.find(button,"KV") then return end
	if string.find(button,"Brake") then self:PlayOnce("switch","cabin") return end

	-- Generic button or switch sound
	if string.find(button,"Set") then
		self:PlayOnce("switch","cabin")
	end
	if string.find(button,"Toggle") then
		self:PlayOnce("switch2","cabin",0.7)
	end
end
function ENT:OnButtonRelease(button)
	if (button == "PneumaticBrakeDown") and (self.Pneumatic.DriverValvePosition == 1) then
		self.Pneumatic:TriggerInput("BrakeSet",2)
	end
	if (button == "PneumaticBrakeUp") and (self.Pneumatic.DriverValvePosition == 5) then
		self.Pneumatic:TriggerInput("BrakeSet",4)
	end
end

function ENT:OnCouple(train,isfront)
	self.BaseClass.OnCouple(self,train,isfront)
	
	if isfront 
	then self.FrontBrakeLineIsolation:TriggerInput("Open",1.0)
	else self.RearBrakeLineIsolation:TriggerInput("Open",1.0)
	end
end