AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

--------------------------------------------------------------------------------
function ENT:Initialize()
	-- Defined train information
	self.SubwayTrain = {
		Type = "AI",
		Name = "",
	}
	if not self.TrainType then self.TrainType = "81-717" end

	-- Set model and initialize
	self.NoPhysics = true
	if self.TrainType == "81-717" then self:SetModel("models/metrostroi/81/81-717b.mdl") end
	if self.TrainType == "81-714" then self:SetModel("models/metrostroi/81/81-714.mdl") end
	self.BaseClass.Initialize(self)

	-- Create bogeys
	self.FrontBogey = self:CreateBogey(Vector( 325-20,0,-75),Angle(0,180,0),true)
	self.RearBogey  = self:CreateBogey(Vector(-325-10,0,-75),Angle(0,0,0),false)

	-- Seats
	if self.TrainType == "81-717" then 
		self.DriverSeat = self:CreateSeat("driver",Vector(410,-2,-23))
--		self.InstructorsSeat = self:CreateSeat("instructor",Vector(410,35,-28))
--		self.ExtraSeat = self:CreateSeat("instructor",Vector(410,-35,-28))
	end

	-- Setup door positions
	self.LeftDoorPositions = {}
	self.RightDoorPositions = {}
	for i=0,3 do
		table.insert(self.LeftDoorPositions,Vector(353.0 - 35*0.5 - 231*i,65,-1.8))
		table.insert(self.RightDoorPositions,Vector(353.0 - 35*0.5 - 231*i,-65,-1.8))
	end

	-- Initial setup
	self.PathID = self.PathID or 1
	self.Position = self.Position or 100
	self.Velocity = 0
	self.RheostatPosition = 0

	-- Lights
	if self.TrainType == "81-717" then 
		self.Lights = {
			-- Head
			[1] = { "headlight",		Vector(465,0,-20), Angle(0,0,0), Color(176,161,132), fov = 100 },
			[2] = { "glow",				Vector(460, 51,-23), Angle(0,0,0), Color(255,255,255), brightness = 2 },
			[3] = { "glow",				Vector(460,-51,-23), Angle(0,0,0), Color(255,255,255), brightness = 2 },
			[4] = { "glow",				Vector(460,-8, 55), Angle(0,0,0), Color(255,255,255), brightness = 0.3 },
			[5] = { "glow",				Vector(460,-8, 55), Angle(0,0,0), Color(255,255,255), brightness = 0.3 },
			[6] = { "glow",				Vector(460, 2, 55), Angle(0,0,0), Color(255,255,255), brightness = 0.3 },
			[7] = { "glow",				Vector(460, 2, 55), Angle(0,0,0), Color(255,255,255), brightness = 0.3 },
				
			-- Reverse
			[8] = { "light",			Vector(458,-45, 55), Angle(0,0,0), Color(255,0,0),     brightness = 10, scale = 1.0 },
			[9] = { "light",			Vector(458, 45, 55), Angle(0,0,0), Color(255,0,0),     brightness = 10, scale = 1.0 },
				
			-- Cabin
			[10] = { "dynamiclight",	Vector( 420, 0, 35), Angle(0,0,0), Color(255,255,255), brightness = 0.1, distance = 550 },
				
			-- Interior
			[12] = { "dynamiclight",	Vector(   0, 0, 5), Angle(0,0,0), Color(255,255,255), brightness = 3, distance = 400 },
				
			-- Side lights
			[14] = { "light",			Vector(-50, 68, 54), Angle(0,0,0), Color(255,0,0), brightness = 0.5, scale = 0.10, texture = "models/metrostroi_signals/signal_sprite_002.vmt" },
			[15] = { "light",			Vector(4,   68, 54), Angle(0,0,0), Color(150,255,255), brightness = 0.6, scale = 0.10, texture = "models/metrostroi_signals/signal_sprite_002.vmt" },
			[16] = { "light",			Vector(1,   68, 54), Angle(0,0,0), Color(0,255,0), brightness = 0.5, scale = 0.10, texture = "models/metrostroi_signals/signal_sprite_002.vmt" },
			[17] = { "light",			Vector(-2,  68, 54), Angle(0,0,0), Color(255,255,0), brightness = 0.5, scale = 0.10, texture = "models/metrostroi_signals/signal_sprite_002.vmt" },
				
			[18] = { "light",			Vector(-50, -69, 54), Angle(0,0,0), Color(255,0,0), brightness = 0.5, scale = 0.10, texture = "models/metrostroi_signals/signal_sprite_002.vmt" },
			[19] = { "light",			Vector(5,   -69, 54), Angle(0,0,0), Color(150,255,255), brightness = 0.6, scale = 0.10, texture = "models/metrostroi_signals/signal_sprite_002.vmt" },
			[20] = { "light",			Vector(2,   -69, 54), Angle(0,0,0), Color(0,255,0), brightness = 0.5, scale = 0.10, texture = "models/metrostroi_signals/signal_sprite_002.vmt" },
			[21] = { "light",			Vector(-1,  -69, 54), Angle(0,0,0), Color(255,255,0), brightness = 0.5, scale = 0.10, texture = "models/metrostroi_signals/signal_sprite_002.vmt" },
		}
	end

	-- Spawn a dummy consist
	if (self.TrainType == "81-717") and (not self.TrainHead) then
		for i=2,5 do
			local ent = ents.Create("gmod_subway_ai")
			if i == 5 
			then ent.TrainType = "81-717"
			else ent.TrainType = "81-714"
			end
			ent.TrainIndex = i
			ent.TrainHead = self
			ent:Spawn()
		end
	end
end

concommand.Add("metrostroi_spawn_ai", function(ply, _, args)
	if (ply:IsValid()) and (not ply:IsAdmin()) then return end
	for k,v in pairs(Metrostroi.Stations) do
		for k2,v2 in pairs(v) do
			local x = v2.node_end.x-20
			local p = v2.node_end.path.id

			if (p <= 2) then
				print(x,p)

				local ent = ents.Create("gmod_subway_ai")
				ent.Position = x
				ent.PathID = p
				ent:Spawn()
			end
		end
	end
end)

concommand.Add("metrostroi_clear_ai", function(ply, _, args)
	if (ply:IsValid()) and (not ply:IsAdmin()) then return end
	for k,v in pairs(ents.FindByClass("gmod_subway_ai")) do
		SafeRemoveEntity(v)
	end
end)

--------------------------------------------------------------------------------
function ENT:DoPhysics(dT)
	-- Get current information on driving
	local speedLimit = self.ALS_ARS.SpeedLimit
	local nextLimit = self.ALS_ARS.NextLimit
	speedLimit = nextLimit
	if speedLimit == 0 then speedLimit = 20 end
	if self.RedLightDistance and (self.RedLightDistance < 30) then speedLimit = 0 end

	-- Calculate forces upon the train
	local motorPower = 0
	if self.Speed > (speedLimit-2) then
		self.SufficientSpeed = true
	end
	if self.Speed < (speedLimit-10) then
		self.SufficientSpeed = false
	end
	if self.Speed > speedLimit then
		self.Braking = true
	end
	if (self.Speed < (speedLimit-5)) and (self.Braking) then
		self.Braking = false
	end
	if (self.Speed < 5) and (self.Braking) then
		self.Pneumo = true
	else
		self.Pneumo = false
	end
	if self.RedLightDistance and (self.RedLightDistance < 30) then self.Pneumo = true end
--	print(self.Speed,self.Position,speedLimit,self.SufficientSpeed,self.Braking,self.Pneumo)

	if not self.SufficientSpeed then	motorPower = 1.0 end
	if self.Braking then			motorPower = -1.0 end

	-- Slopes code
	local slopeAngle = self:GetAngles().p
	if slopeAngle > 180 then slopeAngle = slopeAngle-360 end
	local slopeFactor = math.min(8.0,math.max(-8.0,slopeAngle))/8.0

	-- Motor code
	local motorForce = 0
	if motorPower > 0 then motorForce = motorPower end
	if motorPower < 0 then motorForce = -math.abs(motorPower) * math.max(-1.0,math.min(1.0,1.25*self.Velocity)) end

	-- Brake code
	local brakeForce = 0
	if self.Pneumo then brakeForce = -1.0*self.Velocity end

	-- Integrate position and velocity
	self.Acceleration = 0
		+motorForce * 1.6
		+brakeForce * 1.6
		-self.Velocity*0.0075
		+slopeFactor*1.6
	self.Velocity = self.Velocity + dT*self.Acceleration
	self.Position = self.Position + dT*self.Velocity

	-- Info
	self.MotorPower = motorPower
end

function ENT:Think()
	self.PrevTime = self.PrevTime or CurTime()
	self.DeltaTime = (CurTime() - self.PrevTime)
	self.PrevTime = CurTime()
	self:RecvPackedData()

	self:NextThink(CurTime()+0.05)
	local retVal = true
	for k,v in pairs(self.Systems) do
		if v.DontAccelerateSimulation then
			v:Think(self.DeltaTime / (v.SubIterations or 1),i)
		end
	end

	--local retVal = self.BaseClass.Think(self)
	local dT = self.DeltaTime

	-- Select path
	local path = Metrostroi.Paths[self.PathID]
	if (self.Position > 10910-10) and (self.PathID == 1) then
		self.Position = 100
		self.Velocity = 0
		self.PathID = 2
	end
	if (self.Position > 11180-10) and (self.PathID == 2) then
		self.Position = 100
		self.Velocity = 0
		self.PathID = 1
	end
--	self.PathID = 1
--	self.Position = 11100
--	self.Velocity = 0

	-- If needed, update train physics
	if not self.TrainHead then
		self:DoPhysics(dT)
	else
		if not IsValid(self.TrainHead) then
			SafeRemoveEntity(self)
			return
		end

		self.PathID = self.TrainHead.PathID
		self.Position = self.TrainHead.Position - 18.6*(self.TrainIndex-1)
		self.Velocity = self.TrainHead.Velocity
	end

	-- Update state of all objects and sounds
	self.Speed = math.abs(self.Velocity/0.277778)
	self.FrontBogey.Speed = self.Speed
	self.RearBogey.Speed = self.Speed
	self.FrontBogey.MotorPower = self.MotorPower
	self.RearBogey.MotorPower = self.MotorPower

	-- Update train position
	local vec,dir,node = Metrostroi.GetTrackPosition(path,self.Position)
	if vec then
		local vec1,dir1 = Metrostroi.GetTrackPosition(path,self.Position+0)
		local vec2,dir2 = Metrostroi.GetTrackPosition(path,self.Position-10)
		if dir1 and dir2 then
			dir = (dir1+dir2)*0.5
		end

		if self.TrainHead then dir = -dir end
		local trace = {
			start = vec,
			endpos = vec + Vector(0,0,-384),
			mask = MASK_NPCWORLDSTATIC
		}
		local result = util.TraceLine(trace)
		local rollAngle = Angle(0,0,0)--Angle(0,0,(180.0/math.pi)*math.acos(result.HitNormal.z))

		self:SetPos(vec)
		self:SetAngles(dir:Angle() + rollAngle)
	end

	-- Update red light info
	if node then
		self.RedLightDistance = nil

		-- Check ARS
		local nextARS = Metrostroi.GetARSJoint(node,self.Position,true)
		if nextARS and nextARS:GetRed() then
			local arsOffset = (nextARS.ARSOffset or self.Position)
			local dX = math.abs(arsOffset - self.Position)
			self.RedLightDistance = dX
		end

		--[[local trackOccupied = Metrostroi.IsTrackOccupied(node.next,node.next.x,true)
		if trackOccupied then
			self.RedLightDistance = 0
		else
			self.RedLightDistance = nil
		end]]--

		-- Find AI trains
		if not self.RedLightDistance then
			for k,v in pairs(ents.FindByClass("gmod_subway_ai")) do
				if (v.PathID == self.PathID) and (v ~= self) and (not v.TrainHead) then
					if v.Position > self.Position then
						self.RedLightDistance = math.abs(v.Position - self.Position)-200
					end
				end 
			end
		end
	end

	-- Lighting
	if self.TrainType == "81-717" then
		self:SetLightPower(1, self.TrainHead == nil)
		self:SetLightPower(2, self.TrainHead == nil)
		self:SetLightPower(3, self.TrainHead == nil)
		self:SetLightPower(4, self.TrainHead == nil)
		self:SetLightPower(5, self.TrainHead == nil)
		self:SetLightPower(6, self.TrainHead == nil)
		self:SetLightPower(7, self.TrainHead == nil)
		self:SetLightPower(8, self.TrainHead ~= nil)
		self:SetLightPower(9, self.TrainHead ~= nil)
		self:SetLightPower(10, true)
		self:SetLightPower(12, true)
	end

	-- Pneumo
--	if self.Pneumo then
--	end

	-- Misc
	self.LeftDoorsOpen = false
	self.RightDoorsOpen = false
	self:SetPackedBool(52,1)
	self:SendPackedData()
	return retVal
end