AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.BogeyDistance = 650 -- Needed for gm trainspawner

--------------------------------------------------------------------------------
function ENT:Initialize()
	-- Defined train information
	self.SubwayTrain = {
		Type = "81",
		Name = "81-717",
	}

	-- Set model and initialize
	local model_b = math.random() > 0.5
	if model_b then
		self:SetModel("models/metrostroi/81/81-717a.mdl")
	else
		self:SetModel("models/metrostroi/81/81-717b.mdl")
	end
	self.BaseClass.Initialize(self)
	self:SetPos(self:GetPos() + Vector(0,0,140))
	
	-- Create seat entities
	self.DriverSeat = self:CreateSeat("driver",Vector(410,0,-23))
	self.InstructorsSeat = self:CreateSeat("instructor",Vector(410,37,-28))
	self.ExtraSeat = self:CreateSeat("instructor",Vector(410,-33,-28))

	-- Hide seats
	self.DriverSeat:SetColor(Color(0,0,0,0))
	self.DriverSeat:SetRenderMode(RENDERMODE_TRANSALPHA)
	self.ExtraSeat:SetColor(Color(0,0,0,0))
	self.ExtraSeat:SetRenderMode(RENDERMODE_TRANSALPHA)
	
	-- Create bogeys
	self.FrontBogey = self:CreateBogey(Vector( 325-20,0,-80),Angle(0,180,0),true)
	self.RearBogey  = self:CreateBogey(Vector(-325-10,0,-80),Angle(0,0,0),false)
	
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
		
		[KEY_A] = "KDL",
		[KEY_D] = "KDP",
		[KEY_V] = "VUD1Set",
		[KEY_L] = "HornEngage",
		
		[KEY_SPACE] = "PBSet",

		[KEY_LSHIFT] = {
			[KEY_A] = "DURASelectAlternate",
			[KEY_D] = "DURASelectMain",
			[KEY_V] = "DURAToggleChannel",
			[KEY_1] = "DIPonSet",
			[KEY_2] = "DIPoffSet",
			[KEY_L] = "DriverValveDisconnectToggle",
			
			[KEY_7] = "KVWrenchNone",
			[KEY_8] = "KVWrenchKRU",
			[KEY_9] = "KVWrenchKV",
			[KEY_0] = "KVWrench0",
		},
		
		[KEY_RSHIFT] = {
			[KEY_7] = "KVWrenchNone",
			[KEY_8] = "KVWrenchKRU",
			[KEY_9] = "KVWrenchKV",
			[KEY_0] = "KVWrench0",
		},
	}
	
	self.InteractionZones = {
		{	Pos = Vector(458,-30,-55),
			Radius = 16,
			ID = "FrontBrakeLineIsolationToggle" },
		{	Pos = Vector(458, 30,-55),
			Radius = 16,
			ID = "FrontTrainLineIsolationToggle" },
		{	Pos = Vector(-482,30,-55),
			Radius = 16,
			ID = "RearBrakeLineIsolationToggle" },
		{	Pos = Vector(-482, -30,-55),
			Radius = 16,
			ID = "RearTrainLineIsolationToggle" },
		{	Pos = Vector(154,62.5,-65),
			Radius = 16,
			ID = "GVToggle" },
		{	Pos = Vector(398.0,-56.0+1.5,25.0),
			Radius = 16,
			ID = "VBToggle" },
	}

	-- Lights
	if not model_b then
		self.Lights = {
			-- Head
			[1] = { "headlight",		Vector(465,0,-20), Angle(0,0,0), Color(216,161,92), fov = 100 },
			[2] = { "glow",				Vector(460, 51,-23), Angle(0,0,0), Color(255,255,255), brightness = 2, scale = 3.0 },
			[3] = { "glow",				Vector(460,-51,-23), Angle(0,0,0), Color(255,255,255), brightness = 2, scale = 3.0 },
			[4] = { "glow",				Vector(460,-8, 55), Angle(0,0,0),  Color(255,255,255), brightness = 0.3, scale = 2.0 },
			[5] = { "glow",				Vector(460,-8, 55), Angle(0,0,0),  Color(255,255,255), brightness = 0.3, scale = 2.0 },
			[6] = { "glow",				Vector(460, 2, 55), Angle(0,0,0),  Color(255,255,255), brightness = 0.3, scale = 2.0 },
			[7] = { "glow",				Vector(460, 2, 55), Angle(0,0,0),  Color(255,255,255), brightness = 0.3, scale = 2.0 },
			
			-- Reverse
			[8] = { "light",			Vector(458,-45, 55), Angle(0,0,0), Color(255,0,0),     brightness = 10, scale = 1.0 },
			[9] = { "light",			Vector(458, 45, 55), Angle(0,0,0), Color(255,0,0),     brightness = 10, scale = 1.0 },
			
			-- Cabin
			[10] = { "dynamiclight",	Vector( 420, 0, 35), Angle(0,0,0), Color(255,255,255), brightness = 0.1, distance = 550 },
			
			-- Interior
			--[11] = { "dynamiclight",	Vector( 250, 0, 5), Angle(0,0,0), Color(255,255,255), brightness = 3, distance = 250 },
			[12] = { "dynamiclight",	Vector(   0, 0, 5), Angle(0,0,0), Color(255,255,255), brightness = 3, distance = 400 },
			--[13] = { "dynamiclight",	Vector(-250, 0, 5), Angle(0,0,0), Color(255,255,255), brightness = 3, distance = 250 },
			
			-- Side lights
			[14] = { "light",			Vector(-50, 68, 54), Angle(0,0,0), Color(255,0,0), brightness = 0.9, scale = 0.10, texture = "models/metrostroi_signals/signal_sprite_002.vmt" },
			[15] = { "light",			Vector(4,   68, 54), Angle(0,0,0), Color(150,255,255), brightness = 0.9, scale = 0.10, texture = "models/metrostroi_signals/signal_sprite_002.vmt" },
			[16] = { "light",			Vector(1,   68, 54), Angle(0,0,0), Color(0,255,0), brightness = 0.9, scale = 0.10, texture = "models/metrostroi_signals/signal_sprite_002.vmt" },
			[17] = { "light",			Vector(-2,  68, 54), Angle(0,0,0), Color(255,255,0), brightness = 0.9, scale = 0.10, texture = "models/metrostroi_signals/signal_sprite_002.vmt" },
			
			[18] = { "light",			Vector(-50, -69, 54), Angle(0,0,0), Color(255,0,0), brightness = 0.9, scale = 0.10, texture = "models/metrostroi_signals/signal_sprite_002.vmt" },
			[19] = { "light",			Vector(5,   -69, 54), Angle(0,0,0), Color(150,255,255), brightness = 0.9, scale = 0.10, texture = "models/metrostroi_signals/signal_sprite_002.vmt" },
			[20] = { "light",			Vector(2,   -69, 54), Angle(0,0,0), Color(0,255,0), brightness = 0.9, scale = 0.10, texture = "models/metrostroi_signals/signal_sprite_002.vmt" },
			[21] = { "light",			Vector(-1,  -69, 54), Angle(0,0,0), Color(255,255,0), brightness = 0.9, scale = 0.10, texture = "models/metrostroi_signals/signal_sprite_002.vmt" },

			-- Green RP
			[22] = { "light",			Vector(439.8,12.5+1.5-9.6,-6.1), Angle(0,0,0), Color(100,255,0), brightness = 1.0, scale = 0.020 },
			-- AVU
			[23] = { "light",			Vector(441.6,12.5+1.5-20.3,-4.15), Angle(0,0,0), Color(255,40,0), brightness = 1.0, scale = 0.020 },
			-- LKVP
			[24] = { "light",			Vector(441.6,12.5+1.5-23.0,-4.15), Angle(0,0,0), Color(255,160,0), brightness = 1.0, scale = 0.020 },
			-- Pneumatic brake
			[25] = { "light",			Vector(438.7,-26.1,-5.35), Angle(0,0,0), Color(255,160,0), brightness = 1.0, scale = 0.020 },
			-- Cabin heating
			[26] = { "light",			Vector(438.7,-21.1,-5.35), Angle(0,0,0), Color(255,160,0), brightness = 1.0, scale = 0.020 },
			-- Door left open (#1)
			[27] = { "light",			Vector(437.8,4.4,-8.0), Angle(0,0,0), Color(255,160,0), brightness = 1.0, scale = 0.024 },
			-- Door left open (#2)
			[28] = { "light",			Vector(437.8,10.8,-8.0), Angle(0,0,0), Color(255,160,0), brightness = 1.0, scale = 0.024 },
			-- Door right open 
			[29] = { "light",			Vector(438.7,-23.3,-5.35), Angle(0,0,0), Color(255,160,0), brightness = 1.0, scale = 0.024 },

			-- Cabin texture light
			[30] = { "headlight", 		Vector(390.0,16,45), Angle(60,-50,0), Color(176,161,132), farz = 128, nearz = 1, shadows = 0, brightness = 0.20, fov = 140 },
			-- Manometers
			[31] = { "headlight", Vector(450.00,5,3.0), Angle(0,-90,0), Color(216,161,92), farz = 32, nearz = 1, shadows = 0, brightness = 0.4, fov = 30 },
			-- Voltmeter
			[32] = { "headlight", Vector(449.00,10,7.0), Angle(28,90,0), Color(216,161,92), farz = 16, nearz = 1, shadows = 0, brightness = 0.4, fov = 40 },
			-- Ampermeter
			[33] = { "headlight", Vector(445.0,-35,9.0), Angle(-90,0,0), Color(216,161,92), farz = 10, nearz = 1, shadows = 0, brightness = 4.0, fov = 60 },
			-- Voltmeter
			[34] = { "headlight", Vector(445.0,-35,13.0), Angle(-90,0,0), Color(216,161,92), farz = 10, nearz = 1, shadows = 0, brightness = 4.0, fov = 60 },
		}
	else
		self.Lights = {
			-- Head
			[1] = { "headlight",		Vector(465,0,-20), Angle(0,0,0),   Color(216,161,92), fov = 100 },
			[2] = { "glow",				Vector(460, 51,-23), Angle(0,0,0), Color(255,255,255), brightness = 2, scale = 3.0 },
			[3] = { "glow",				Vector(460,-51,-23), Angle(0,0,0), Color(255,255,255), brightness = 2, scale = 3.0 },
			[4] = { "glow",				Vector(460,-18,-23), Angle(0,0,0), Color(255,255,255), brightness = 0.3, scale = 2.0 },
			[5] = { "glow",				Vector(460,-7, -23), Angle(0,0,0), Color(255,255,255), brightness = 0.3, scale = 2.0 },
			[6] = { "glow",				Vector(460, 7, -23), Angle(0,0,0), Color(255,255,255), brightness = 0.3, scale = 2.0 },
			[7] = { "glow",				Vector(460, 18,-23), Angle(0,0,0), Color(255,255,255), brightness = 0.3, scale = 2.0 },
			
			-- Reverse
			[8] = { "light",			Vector(458,-45, 55), Angle(0,0,0), Color(255,0,0),     brightness = 10, scale = 1.0 },
			[9] = { "light",			Vector(458, 45, 55), Angle(0,0,0), Color(255,0,0),     brightness = 10, scale = 1.0 },
			
			-- Cabin
			[10] = { "dynamiclight",	Vector( 420, 0, 35), Angle(0,0,0), Color(255,255,255), brightness = 0.1, distance = 550 },
			
			-- Interior
			--[11] = { "dynamiclight",	Vector( 250, 0, 5), Angle(0,0,0), Color(255,255,255), brightness = 3, distance = 250 },
			[12] = { "dynamiclight",	Vector(   0, 0, 5), Angle(0,0,0), Color(255,255,255), brightness = 3, distance = 400 },
			--[13] = { "dynamiclight",	Vector(-250, 0, 5), Angle(0,0,0), Color(255,255,255), brightness = 3, distance = 250 },
			
			-- Side lights
			[14] = { "light",			Vector(-50, 68, 54), Angle(0,0,0), Color(255,0,0), brightness = 0.9, scale = 0.10, texture = "models/metrostroi_signals/signal_sprite_002.vmt" },
			[15] = { "light",			Vector(4,   68, 54), Angle(0,0,0), Color(150,255,255), brightness = 0.9, scale = 0.10, texture = "models/metrostroi_signals/signal_sprite_002.vmt" },
			[16] = { "light",			Vector(1,   68, 54), Angle(0,0,0), Color(0,255,0), brightness = 0.9, scale = 0.10, texture = "models/metrostroi_signals/signal_sprite_002.vmt" },
			[17] = { "light",			Vector(-2,  68, 54), Angle(0,0,0), Color(255,255,0), brightness = 0.9, scale = 0.10, texture = "models/metrostroi_signals/signal_sprite_002.vmt" },
			
			[18] = { "light",			Vector(-50, -69, 54), Angle(0,0,0), Color(255,0,0), brightness = 0.9, scale = 0.10, texture = "models/metrostroi_signals/signal_sprite_002.vmt" },
			[19] = { "light",			Vector(5,   -69, 54), Angle(0,0,0), Color(150,255,255), brightness = 0.9, scale = 0.10, texture = "models/metrostroi_signals/signal_sprite_002.vmt" },
			[20] = { "light",			Vector(2,   -69, 54), Angle(0,0,0), Color(0,255,0), brightness = 0.9, scale = 0.10, texture = "models/metrostroi_signals/signal_sprite_002.vmt" },
			[21] = { "light",			Vector(-1,  -69, 54), Angle(0,0,0), Color(255,255,0), brightness = 0.9, scale = 0.10, texture = "models/metrostroi_signals/signal_sprite_002.vmt" },
			
			-- Green RP
			[22] = { "light",			Vector(439.8,12.5+1.5-9.6,-6.1), Angle(0,0,0), Color(100,255,0), brightness = 1.0, scale = 0.020 },
			-- AVU
			[23] = { "light",			Vector(441.6,12.5+1.5-20.3,-4.15), Angle(0,0,0), Color(255,40,0), brightness = 1.0, scale = 0.020 },
			-- LKVP
			[24] = { "light",			Vector(441.6,12.5+1.5-23.0,-4.15), Angle(0,0,0), Color(255,160,0), brightness = 1.0, scale = 0.020 },
			-- Pneumatic brake
			[25] = { "light",			Vector(438.7,-26.1,-5.35), Angle(0,0,0), Color(255,160,0), brightness = 1.0, scale = 0.020 },
			-- Cabin heating
			[26] = { "light",			Vector(438.7,-21.1,-5.35), Angle(0,0,0), Color(255,160,0), brightness = 1.0, scale = 0.020 },
			-- Door left open (#1)
			[27] = { "light",			Vector(437.8,4.4,-8.0), Angle(0,0,0), Color(255,160,0), brightness = 1.0, scale = 0.024 },
			-- Door left open (#2)
			[28] = { "light",			Vector(437.8,10.8,-8.0), Angle(0,0,0), Color(255,160,0), brightness = 1.0, scale = 0.024 },
			-- Door right open 
			[29] = { "light",			Vector(438.7,-23.3,-5.35), Angle(0,0,0), Color(255,160,0), brightness = 1.0, scale = 0.024 },

			-- Cabin texture light
			[30] = { "headlight", 		Vector(390.0,16,45), Angle(60,-50,0), Color(176,161,132), farz = 128, nearz = 1, shadows = 0, brightness = 0.20, fov = 140 },
			-- Manometers
			[31] = { "headlight", Vector(450.00,5,3.0), Angle(0,-90,0), Color(216,161,92), farz = 32, nearz = 1, shadows = 0, brightness = 0.4, fov = 30 },
			-- Voltmeter
			[32] = { "headlight", Vector(449.00,10,7.0), Angle(28,90,0), Color(216,161,92), farz = 16, nearz = 1, shadows = 0, brightness = 0.4, fov = 40 },
			-- Ampermeter
			[33] = { "headlight", Vector(445.0,-35,9.0), Angle(-90,0,0), Color(216,161,92), farz = 10, nearz = 1, shadows = 0, brightness = 4.0, fov = 60 },
			-- Voltmeter
			[34] = { "headlight", Vector(445.0,-35,13.0), Angle(-90,0,0), Color(216,161,92), farz = 10, nearz = 1, shadows = 0, brightness = 4.0, fov = 60 },
		}
	end
	
	-- Cross connections in train wires
	self.TrainWireCrossConnections = {
		[5] = 4, -- Reverser F<->B
		[31] = 32, -- Doors L<->R
	}
	
	-- Setup door positions
	self.LeftDoorPositions = {}
	self.RightDoorPositions = {}
	for i=0,3 do
		table.insert(self.LeftDoorPositions,Vector(353.0 - 35*0.5 - 231*i,65,-1.8))
		table.insert(self.RightDoorPositions,Vector(353.0 - 35*0.5 - 231*i,-65,-1.8))
	end
	
	-- KV wrench mode
	self.KVWrenchMode = 0
end


--------------------------------------------------------------------------------
function ENT:Think()
	local retVal = self.BaseClass.Think(self)

	-- Check if wrench was pulled out
	if not self:IsWrenchPresent() then self.KV:TriggerInput("ReverserSet",0) end	

	-- Headlights
	local brightness = (math.min(1,self.Panel["HeadLights1"])*0.50 + 
						math.min(1,self.Panel["HeadLights2"])*0.25 + 
						math.min(1,self.Panel["HeadLights3"])*0.25)
	self:SetLightPower(1, (self.Panel["HeadLights3"] > 0.5) and (self.L_4.Value > 0.5),brightness)
	self:SetLightPower(2, (self.Panel["HeadLights3"] > 0.5) and (self.L_4.Value > 0.5))
	self:SetLightPower(3, (self.Panel["HeadLights3"] > 0.5) and (self.L_4.Value > 0.5))
	self:SetLightPower(4, (self.Panel["HeadLights1"] > 0.5) and (self.L_4.Value > 0.5))
	self:SetLightPower(5, (self.Panel["HeadLights2"] > 0.5) and (self.L_4.Value > 0.5))
	self:SetLightPower(6, (self.Panel["HeadLights2"] > 0.5) and (self.L_4.Value > 0.5))
	self:SetLightPower(7, (self.Panel["HeadLights1"] > 0.5) and (self.L_4.Value > 0.5))
	
	-- Reverser lights
	self:SetLightPower(8, self.Panel["RedLightRight"] > 0.5)
	self:SetLightPower(9, self.Panel["RedLightLeft"] > 0.5)
	
	-- Interior/cabin lights
	self:SetLightPower(10, (self.Panel["CabinLight"] > 0.5) and (self.L_2.Value > 0.5))
	self:SetLightPower(30, (self.Panel["CabinLight"] > 0.5), 0.03 + 0.97*self.L_2.Value)
	self:SetLightPower(12, (self.Panel["EmergencyLight"] > 0.5) and ((self.L_1.Value > 0.5) or (self.L_5.Value > 0.5)),
		0.1*self.L_5.Value + ((self.PowerSupply.XT3_4 > 65.0) and 0.5 or 0))
	--self:SetLightPower(12, self.Panel["EmergencyLight"] > 0.5)
	--self:SetLightPower(13, self.PowerSupply.XT3_4 > 65.0)	
	self:SetLightPower(31, (self.Panel["CabinLight"] > 0.5) and (self.L_3.Value > 0.5))
	self:SetLightPower(32, (self.Panel["CabinLight"] > 0.5) and (self.L_3.Value > 0.5))
	self:SetLightPower(33, (self.Panel["CabinLight"] > 0.5) and (self.L_3.Value > 0.5))
	self:SetLightPower(34, (self.Panel["CabinLight"] > 0.5) and (self.L_3.Value > 0.5))
	
	-- Door button lights
	self:SetLightPower(27, (self.Panel["HeadLights2"] > 0.5) and (self.DoorSelect.Value == 0))
	self:SetLightPower(28, (self.Panel["HeadLights2"] > 0.5) and (self.DoorSelect.Value == 0))
	self:SetLightPower(29, (self.Panel["HeadLights2"] > 0.5) and (self.DoorSelect.Value == 1))
	
	-- Side lights
	self:SetLightPower(15, self.Panel["TrainDoors"] > 0.5)
	self:SetLightPower(19, self.Panel["TrainDoors"] > 0.5)
	
	self:SetLightPower(16, self.Panel["GreenRP"] > 0.5)
	self:SetLightPower(20, self.Panel["GreenRP"] > 0.5)
	
	self:SetLightPower(17, self.Panel["TrainBrakes"] > 0.5)
	self:SetLightPower(21, self.Panel["TrainBrakes"] > 0.5)
	self:SetLightPower(25, self.Panel["TrainBrakes"] > 0.5)
	
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
	--self:SetPackedBool(22,self.Pneumatic.LeftDoorState[2] > 0.5)
	--self:SetPackedBool(23,self.Pneumatic.LeftDoorState[3] > 0.5)
	--self:SetPackedBool(24,self.Pneumatic.LeftDoorState[4] > 0.5)
	self:SetPackedBool(25,self.Pneumatic.RightDoorState[1] > 0.5)
	--self:SetPackedBool(26,self.Pneumatic.RightDoorState[2] > 0.5)
	--self:SetPackedBool(26,(self.Electric.T1 > 400) or (self.Electric.T2 > 400))
	--self:SetPackedBool(27,self.Pneumatic.RightDoorState[3] > 0.5)
	self:SetPackedBool(27,self.KVWrenchMode == 2)
	--self:SetPackedBool(28,self.Pneumatic.RightDoorState[4] > 0.5)
	self:SetPackedBool(28,self.KVT.Value == 1.0)
	self:SetPackedBool(29,self.DURA.SelectAlternate == false)
	self:SetPackedBool(30,self.DURA.SelectAlternate == true)
	self:SetPackedBool(31,self.DURA.Channel == 2)
	self:SetPackedBool(56,self.ARS.Value == 1.0)
	self:SetPackedBool(57,self.ALS.Value == 1.0)
	self:SetPackedBool(58,(self.Panel["CabinLight"] > 0.5) and (self.L_2.Value > 0.5))
	self:SetPackedBool(59,self.BPSNon.Value == 1.0)
	self:SetPackedBool(60,self.L_1.Value == 1.0)
	self:SetPackedBool(61,self.L_2.Value == 1.0)
	self:SetPackedBool(62,self.L_3.Value == 1.0)
	self:SetPackedBool(63,self.L_4.Value == 1.0)
	self:SetPackedBool(53,self.L_5.Value == 1.0)
	self:SetPackedBool(55,self.DoorSelect.Value == 1.0)
	--self:SetPackedBool(112,(self.RheostatController.Velocity ~= 0.0))
	self:SetPackedBool(112,(self.PositionSwitch.Velocity ~= 0.0))

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
	self:SetPackedBool(33,self:ReadTrainWire(2) > 0.5)--self.RheostatController.MotorCoilState ~= 0.0)
	-- NR1
	self:SetPackedBool(34,(self.NR.Value == 1.0) or (self.RPU.Value == 1.0))
	-- Red RP
	self:SetPackedBool(35,self.Panel["RedRP"] > 0.5)
	-- Green RP
	self:SetPackedBool(36,self.Panel["GreenRP"] > 0.5)
	self:SetLightPower(22,self.Panel["GreenRP"] > 0.5)
	-- Cabin heating
	self:SetPackedBool(37,self.Panel["KUP"] > 0.5)
	self:SetLightPower(26,self.Panel["KUP"] > 0.5)
	-- AVU
	self:SetPackedBool(38,self.Panel["AVU"] > 0.5)
	self:SetLightPower(23,self.Panel["AVU"] > 0.5)
	-- Ring
	self:SetPackedBool(39,self.Panel["Ring"] > 0.5)
	-- SD
	self:SetPackedBool(40,self.Panel["SD"] > 0.5)
	-- OCh
	self:SetPackedBool(41,self.ALS_ARS.NoFreq)
	-- 0
	self:SetPackedBool(42,self.ALS_ARS.Signal0)
	-- 40
	self:SetPackedBool(43,self.ALS_ARS.Signal40)
	-- 60
	self:SetPackedBool(44,self.ALS_ARS.Signal60)
	-- 75
	self:SetPackedBool(45,self.ALS_ARS.Signal70)
	-- 80
	self:SetPackedBool(46,self.ALS_ARS.Signal80)
	-- KT
	self:SetPackedBool(47,self.ALS_ARS.LKT)
	-- KVD
	self:SetPackedBool(48,self:ReadTrainWire(21) > 0.5)--self.ALS_ARS.LVD)
	-- LST
	self:SetPackedBool(49,self:ReadTrainWire(6) > 0.5)
	-- LVD
	self:SetPackedBool(50,self:ReadTrainWire(1) > 0.5)
	-- LKVC
	self:SetPackedBool(51,self.KVC.Value < 0.5)
	-- BPSN
	self:SetLightPower(24,(self.PowerSupply.XT3_1 > 0) and (self.Panel["V1"] > 0.5))
	self:SetPackedBool(52,self.PowerSupply.XT3_1 > 0)
	-- LRS
	self:SetPackedBool(54,(self.Panel["V1"] > 0.5) and 
		(self.ALS.Value > 0.5) and 
		(self.ALS_ARS.NextLimit >= self.ALS_ARS.SpeedLimit))
	
	-- AV states
	for i,v in ipairs(self.Panel.AVMap) do
		if tonumber(v) 
		then self:SetPackedBool(64+(i-1),self["A"..v].Value == 1.0)
		else self:SetPackedBool(64+(i-1),self[v].Value == 1.0)
		end
	end
	
	-- Total temperature
	local IGLA_Temperature = math.max(self.Electric.T1,self.Electric.T2)
    
	-- Feed packed floats
	self:SetPackedRatio(0, 1-self.Pneumatic.DriverValvePosition/5)
	self:SetPackedRatio(1, (self.KV.ControllerPosition+3)/7)
	self:SetPackedRatio(2, 1-(self.KV.ReverserPosition+1)/2)
	self:SetPackedRatio(4, self.Pneumatic.ReservoirPressure/16.0)
	self:SetPackedRatio(5, self.Pneumatic.TrainLinePressure/16.0)
	self:SetPackedRatio(6, self.Pneumatic.BrakeCylinderPressure/6.0)
	self:SetPackedRatio(7, self.Electric.Power750V/1000.0)
	self:SetPackedRatio(8, 0.5 + (self.Electric.I24/500.0))
	self:SetPackedRatio(9, self.Pneumatic.BrakeLinePressure_dPdT or 0)
	self:SetPackedRatio(10,(self.Panel["V1"] * self.Battery.Voltage) / 150.0)
	self:SetPackedRatio(11,IGLA_Temperature)

	-- Update ARS system
	self:SetPackedRatio(3, self.ALS_ARS.Speed/100.0)
	if (self.ALS_ARS.Ring == true) or (self:ReadTrainWire(21) > 0) or 
		((IGLA_Temperature > 500) and ((CurTime() % 2.0) > 1.0)) then
		self:SetPackedBool(39,true)
	end
	
	-- RUT test
	local weightRatio = 2.00*math.max(0,math.min(1,(self:GetPassengerCount()/300)))
	if math.abs(self:GetAngles().pitch) > 2.5 then weightRatio = weightRatio + 1.00 end
	self.YAR_13A:TriggerInput("WeightLoadRatio",math.max(0,math.min(2.50,weightRatio)))
	
	-- Exchange some parameters between engines, pneumatic system, and real world
	self.Engines:TriggerInput("Speed",self.Speed)
	if IsValid(self.FrontBogey) and IsValid(self.RearBogey) then
		self.FrontBogey.MotorForce = 35300
		self.FrontBogey.Reversed = (self.RKR.Value > 0.5)
		self.RearBogey.MotorForce  = 35300
		self.RearBogey.Reversed = (self.RKR.Value < 0.5)
	
		self.RearBogey.MotorPower  = self.Engines.BogeyMoment
		self.FrontBogey.MotorPower = self.Engines.BogeyMoment
		
		-- Apply brakes
		self.FrontBogey.PneumaticBrakeForce = 65000.0
		self.FrontBogey.BrakeCylinderPressure = self.Pneumatic.BrakeCylinderPressure
		self.FrontBogey.BrakeCylinderPressure_dPdT = -self.Pneumatic.BrakeCylinderPressure_dPdT
		self.RearBogey.PneumaticBrakeForce = 65000.0
		self.RearBogey.BrakeCylinderPressure = self.Pneumatic.BrakeCylinderPressure
		self.RearBogey.BrakeCylinderPressure_dPdT = -self.Pneumatic.BrakeCylinderPressure_dPdT
	end
	
	-- Temporary hacks
	--self:SetNWFloat("V",self.Speed)
	--self:SetNWFloat("A",self.Acceleration)

	-- Send networked variables
	self:SendPackedData()
	return retVal
end


--------------------------------------------------------------------------------
function ENT:OnButtonPress(button)
	if button == "KVSetT1A" then
		if self.KV.ControllerPosition == -2 then
			self.KV:TriggerInput("ControllerSet",-1)
			timer.Simple(0.2,function()
				self.KV:TriggerInput("ControllerSet",-2)			
			end)
		end
	end
	if button == "KVWrench0" then 
		self.KVWrenchMode = 0
		self.DriversWrenchPresent = false
		self.DriversWrenchMissing = false
		self:PlayOnce("kv1","cabin",0.7,120.0)
	end
	if button == "KVWrenchKV" then
		self.KVWrenchMode = 1
		self.DriversWrenchPresent = true
		self.DriversWrenchMissing = false
		self:PlayOnce("kv1","cabin",0.7,120.0)
	end
	if button == "KVWrenchKRU" then
		self.KVWrenchMode = 2
		self.DriversWrenchPresent = false
		self.DriversWrenchMissing = true
		self:PlayOnce("kv1","cabin",0.7,120.0)
	end
	if button == "KVWrenchNone" then
		self.KVWrenchMode = 3
		self.DriversWrenchPresent = false
		self.DriversWrenchMissing = true
		self:PlayOnce("kv1","cabin",0.7,120.0)
	end
	if button == "KVT2Set" then self.KVT:TriggerInput("Close",1) end
	if button == "KDL" then self.KDL:TriggerInput("Close",1) self:OnButtonPress("KDLSet") end
	if button == "KDP" then self.KDP:TriggerInput("Close",1) self:OnButtonPress("KDPSet") end
	if button == "VDL" then self.VDL:TriggerInput("Close",1) self:OnButtonPress("VDLSet") end
	
	-- Special logic
	if (button == "VDL") or (button == "KDL") or (button == "KDP") then
		self.VUD1:TriggerInput("Open",1)
		--self.VUD2:TriggerInput("Open",1)
	end
	if (button == "VDL") or (button == "KDL") then
		self.DoorSelect:TriggerInput("Open",1)
	end
	if (button == "KDP") then
		self.DoorSelect:TriggerInput("Close",1)
	end
	if (button == "VUD1Set") or (button == "VUD1Toggle") or
	   (button == "VUD2Set") or (button == "VUD2Toggle") then
		self.VDL:TriggerInput("Open",1)
		self.KDL:TriggerInput("Open",1)
		self.KDP:TriggerInput("Open",1)
	end
	
	-- Special sounds
	if (button == "VUToggle") or ((string.sub(button,1,1) == "A") and (tonumber(string.sub(button,2,2)))) then
		local name = string.sub(button,1,(string.find(button,"Toggle") or 0)-1)
		if self[name] then
			if self[name].Value > 0.5 then
				self:PlayOnce("av_off","cabin")
			else
				self:PlayOnce("av_on","cabin")
			end
		end
		return
	end
	if button == "PBSet" then self:PlayOnce("switch6","cabin",0.6,100) return end
	if button == "GVToggle" then self:PlayOnce("switch4",nil,0.7) return end
	if button == "DURASelectMain" then self:PlayOnce("switch","cabin") return end
	if button == "DURASelectAlternate" then self:PlayOnce("switch","cabin") return end
	if button == "VUD1Toggle" then 
		if self.VUD1.Value > 0.5 then
			self:PlayOnce("switch_door_off","cabin")
		else
			self:PlayOnce("switch_door_on","cabin")
		end
		return
	end
	if button == "VUD1Set" then 
		self:PlayOnce("switch_door_on","cabin")
		return
	end
	
	if button == "DriverValveDisconnectToggle" then
		if self.DriverValveDisconnect.Value == 1.0 then
			self:PlayOnce("pneumo_disconnect2","cabin",0.9)
		else
			self:PlayOnce("pneumo_disconnect1","cabin",0.9)
		end
	end
	if (not string.find(button,"KVT")) and string.find(button,"KV") then return end
	if string.find(button,"Brake") then self:PlayOnce("switch","cabin") return end

	-- Generic button or switch sound
	if string.find(button,"Set") then
		self:PlayOnce("button_press","cabin")
	end
	if string.find(button,"Toggle") then
		self:PlayOnce("switch2","cabin",0.7)
	end
end
function ENT:OnButtonRelease(button)
	if button == "KVT2Set" then self.KVT:TriggerInput("Open",1) end
	if button == "KDL" then self.KDL:TriggerInput("Open",1) self:OnButtonRelease("KDLSet") end
	if button == "KDP" then self.KDP:TriggerInput("Open",1) self:OnButtonRelease("KDPSet") end
	if button == "VDL" then self.VDL:TriggerInput("Open",1) self:OnButtonRelease("VDLSet") end
	
	if button == "PBSet" then self:PlayOnce("switch6_off","cabin",0.6,100) return end
	if (button == "PneumaticBrakeDown") and (self.Pneumatic.DriverValvePosition == 1) then
		self.Pneumatic:TriggerInput("BrakeSet",2)
	end
	if (button == "PneumaticBrakeUp") and (self.Pneumatic.DriverValvePosition == 5) then
		self.Pneumatic:TriggerInput("BrakeSet",4)
	end
	if button == "VUD1Set" then 
		self:PlayOnce("switch_door_off","cabin")
		return
	end
	
	if (not string.find(button,"KVT")) and string.find(button,"KV") then return end

	if string.find(button,"Set") then
		self:PlayOnce("button_release","cabin")
	end
end

function ENT:OnCouple(train,isfront)
	self.BaseClass.OnCouple(self,train,isfront)
	
	if isfront 
	then self.FrontBrakeLineIsolation:TriggerInput("Open",1.0)
	else self.RearBrakeLineIsolation:TriggerInput("Open",1.0)
	end
end