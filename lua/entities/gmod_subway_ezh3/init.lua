AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.BogeyDistance = 650 -- Needed for gm trainspawner

--------------------------------------------------------------------------------
function ENT:Initialize()
	-- Defined train information
	self.SubwayTrain = {
		Type = "E",
		Name = "Ezh3",
	}

	-- Set model and initialize
	self:SetModel("models/metrostroi/e/em508.mdl")
	self.BaseClass.Initialize(self)
	self:SetPos(self:GetPos() + Vector(0,0,140))
	
	-- Create seat entities
	self.DriverSeat = self:CreateSeat("driver",Vector(418,-45,-28))
	self.InstructorsSeat = self:CreateSeat("instructor",Vector(410,35,-28))

	-- Hide seats
	self.DriverSeat:SetColor(Color(0,0,0,0))
	self.DriverSeat:SetRenderMode(RENDERMODE_TRANSALPHA)
	
	-- Create bogeys
	self.FrontBogey = self:CreateBogey(Vector( 325-10,0,-80),Angle(0,180,0),true)
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
		
		[KEY_A] = "KDLSet",
		[KEY_D] = "KDPSet",
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
		[1] = { "headlight",		Vector(465,0,-20), Angle(0,0,0), Color(176,161,132), fov = 100 },
		[2] = { "glow",				Vector(460, 49,-28), Angle(0,0,0), Color(255,255,255), brightness = 2, scale = 3.0 },
		[3] = { "glow",				Vector(460,-49,-28), Angle(0,0,0), Color(255,255,255), brightness = 2, scale = 3.0 },
		[4] = { "glow",				Vector(458,-15, 55), Angle(0,0,0), Color(255,255,255), brightness = 0.3, scale = 2.0 },
		[5] = { "glow",				Vector(458,-5,  55), Angle(0,0,0), Color(255,255,255), brightness = 0.3, scale = 2.0 },
		[6] = { "glow",				Vector(458, 5,  55), Angle(0,0,0), Color(255,255,255), brightness = 0.3, scale = 2.0 },
		[7] = { "glow",				Vector(458, 15, 55), Angle(0,0,0), Color(255,255,255), brightness = 0.3, scale = 2.0 },
		
		-- Reverse
		[8] = { "light",			Vector(458,-27, 55), Angle(0,0,0), Color(255,0,0),     brightness = 10, scale = 1.0 },
		[9] = { "light",			Vector(458, 27, 55), Angle(0,0,0), Color(255,0,0),     brightness = 10, scale = 1.0 },
		
		-- Cabin
		[10] = { "dynamiclight",	Vector( 420, -40, 35), Angle(0,0,0), Color(255,255,255), brightness = 0.1, distance = 550 },
		
		-- Interior
		--[11] = { "dynamiclight",	Vector( 250, 0, 5), Angle(0,0,0), Color(255,255,255), brightness = 3, distance = 250 },
		[12] = { "dynamiclight",	Vector(   0, 0, 5), Angle(0,0,0), Color(255,255,255), brightness = 3, distance = 400 },
		--[13] = { "dynamiclight",	Vector(-250, 0, 5), Angle(0,0,0), Color(255,255,255), brightness = 3, distance = 250 },
		
		-- Side lights
		[14] = { "light",			Vector(390, 69, 54), Angle(0,0,0), Color(255,0,0), brightness = 0.5, scale = 0.10, texture = "models/metrostroi_signals/signal_sprite_002.vmt" },
		[15] = { "light",			Vector(390, 69, 51), Angle(0,0,0), Color(150,255,255), brightness = 0.6, scale = 0.10, texture = "models/metrostroi_signals/signal_sprite_002.vmt" },
		[16] = { "light",			Vector(390, 69, 48), Angle(0,0,0), Color(0,255,0), brightness = 0.5, scale = 0.10, texture = "models/metrostroi_signals/signal_sprite_002.vmt" },
		[17] = { "light",			Vector(390, 69, 45), Angle(0,0,0), Color(255,255,0), brightness = 0.5, scale = 0.10, texture = "models/metrostroi_signals/signal_sprite_002.vmt" },
		
		[18] = { "light",			Vector(390, -69, 54), Angle(0,0,0), Color(255,0,0), brightness = 0.5, scale = 0.10, texture = "models/metrostroi_signals/signal_sprite_002.vmt" },
		[19] = { "light",			Vector(390, -69, 51), Angle(0,0,0), Color(150,255,255), brightness = 0.6, scale = 0.10, texture = "models/metrostroi_signals/signal_sprite_002.vmt" },
		[20] = { "light",			Vector(390, -69, 48), Angle(0,0,0), Color(0,255,0), brightness = 0.5, scale = 0.10, texture = "models/metrostroi_signals/signal_sprite_002.vmt" },
		[21] = { "light",			Vector(390, -69, 45), Angle(0,0,0), Color(255,255,0), brightness = 0.5, scale = 0.10, texture = "models/metrostroi_signals/signal_sprite_002.vmt" },
	}
	
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
end


--------------------------------------------------------------------------------
function ENT:Think()
	local retVal = self.BaseClass.Think(self)
	--if not self.Panel["HeadLights1"] then return true end

	-- Check if wrench was pulled out
	if not self:IsWrenchPresent() then self.KV:TriggerInput("ReverserSet",0) end

	-- Headlights
	local brightness = (math.min(1,self.Panel["HeadLights1"])*0.50 + 
						math.min(1,self.Panel["HeadLights2"])*0.25 + 
						math.min(1,self.Panel["HeadLights3"])*0.25)
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
	self:SetLightPower(12, self.Panel["EmergencyLight"] > 0.5,0.1 + ((self.PowerSupply.XT3_4 > 65.0) and 0.4 or 0))
	--self:SetLightPower(12, self.Panel["EmergencyLight"] > 0.5)
	--self:SetLightPower(13, self.PowerSupply.XT3_4 > 65.0)
	
	-- Side lights
	self:SetLightPower(14, false)
	self:SetLightPower(18, false)
	
	self:SetLightPower(15, self.Panel["TrainDoors"] > 0.5)
	self:SetLightPower(19, self.Panel["TrainDoors"] > 0.5)
	
	self:SetLightPower(16, self.Panel["GreenRP"] > 0.5)
	self:SetLightPower(20, self.Panel["GreenRP"] > 0.5)
	
	self:SetLightPower(17, self.Panel["TrainBrakes"] > 0.5)
	self:SetLightPower(21, self.Panel["TrainBrakes"] > 0.5)
	
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
	self:SetPackedBool(29,self.DURA.SelectAlternate == false)
	self:SetPackedBool(30,self.DURA.SelectAlternate == true)
	self:SetPackedBool(31,self.DURA.Channel == 2)
	self:SetPackedBool(56,self.ARS.Value == 1.0)
	self:SetPackedBool(57,self.ALS.Value == 1.0)
	self:SetPackedBool(58,self.Panel["CabinLight"] > 0.5)

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
	self:SetPackedBool(48,self.ALS_ARS.LVD)
	
	-- AV states
	for i,v in ipairs(self.Panel.AVMap) do
		if tonumber(v) 
		then self:SetPackedBool(64+(i-1),self["A"..v].Value == 1.0)
		else self:SetPackedBool(64+(i-1),self[v].Value == 1.0)
		end
	end
    
	-- Feed packed floats
	self:SetPackedRatio(0, 1-self.Pneumatic.DriverValvePosition/5)
	self:SetPackedRatio(1, (self.KV.ControllerPosition+3)/7)
	self:SetPackedRatio(2, 1-(self.KV.ReverserPosition+1)/2)
	self:SetPackedRatio(4, self.Pneumatic.ReservoirPressure/16.0)
	self:SetPackedRatio(5, self.Pneumatic.TrainLinePressure/16.0)
	self:SetPackedRatio(6, self.Pneumatic.BrakeCylinderPressure/6.0)
	self:SetPackedRatio(7, self.Electric.Power750V/1000.0)
	self:SetPackedRatio(8, math.abs(self.Electric.I24)/1000.0)	
	self:SetPackedRatio(9, self.Pneumatic.BrakeLinePressure_dPdT or 0)
	self:SetPackedRatio(10,(self.Panel["V1"] * self.Battery.Voltage) / 100.0)
	
	-- Update ARS system
	self:SetPackedRatio(3, self.ALS_ARS.Speed/100.0)
	if (self.ALS_ARS.Ring == true) or (self:ReadTrainWire(21) > 0) then
		self:SetPackedBool(39,true)
	end
	
	-- RUT test
	local weightRatio = 2.00*math.max(0,math.min(1,(self:GetPassengerCount()/300)))
	if math.abs(self:GetAngles().pitch) > 2.5 then weightRatio = weightRatio + 0.75 end
	self.YAR_13A:TriggerInput("WeightLoadRatio",math.max(0,math.min(2.00,weightRatio)))
	
	-- Exchange some parameters between engines, pneumatic system, and real world
	self.Engines:TriggerInput("Speed",self.Speed)
	if IsValid(self.FrontBogey) and IsValid(self.RearBogey) then
		self.FrontBogey.MotorForce = 42000*0.7
		self.FrontBogey.Reversed = (self.RKR.Value > 0.5)
		self.RearBogey.MotorForce  = 42000*0.7
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
	-- Special logic
	if (button == "VDLSet") or (button == "KDLSet") or (button == "KDPSet") then
		self.VUD1:TriggerInput("Open",1)
		--self.VUD2:TriggerInput("Open",1)
	end
	if (button == "VUD1Set") or (button == "VUD1Toggle") or
	   (button == "VUD2Set") or (button == "VUD2Toggle") then
		self.VDL:TriggerInput("Open",1)
		self.KDL:TriggerInput("Open",1)
		self.KDP:TriggerInput("Open",1)
	end
	
	-- Special sounds
	if button == "PBSet" then self:PlayOnce("switch6","cabin") return end
	if button == "GVToggle" then self:PlayOnce("switch4",nil,0.7) return end
	if button == "DURASelectMain" then self:PlayOnce("switch","cabin") return end
	if button == "DURASelectAlternate" then self:PlayOnce("switch","cabin") return end
	if button == "VUD1Set" then self:PlayOnce("switch2","cabin") return end
	if button == "VDLSet" then self:PlayOnce("switch3","cabin",0.7) return end
	if button == "KDLSet" then self:PlayOnce("switch3","cabin",0.7) return end
	if button == "KDPSet" then self:PlayOnce("switch3","cabin",0.7) return end
	
	if button == "DriverValveDisconnectToggle" then
		if self.DriverValveDisconnect.Value == 1.0 then
			self:PlayOnce("pneumo_disconnect2","cabin",0.9)
		else
			self:PlayOnce("pneumo_disconnect1","cabin",0.9)
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
	if button == "PBSet" then self:PlayOnce("switch6_off","cabin") return end
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