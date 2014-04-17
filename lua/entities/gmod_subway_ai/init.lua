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
		self.InstructorsSeat = self:CreateSeat("instructor",Vector(410,35,-28))
		self.ExtraSeat = self:CreateSeat("instructor",Vector(410,-35,-28))
	end
	
	for i=1,17 do
		local pos = Vector(280-(i-1)*30-math.floor((i-1)/5)*80,-47,-32)
		local p1 = self:CreateSeat("passenger",pos,Angle(0,90,0))
		pos.y = -pos.y
		local p2 = self:CreateSeat("passenger",pos,Angle(0,270,0))
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
	if self.TrainType == "81-714" then
		self.Lights = {
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
-- Train driving AI
--------------------------------------------------------------------------------
function ENT:DoAI(dT)
	-- Get a schedule
	if self.Schedule and (#self.Schedule == 0) then
		self.Schedule = nil
	end
	if not self.Schedule then
		print(self.PathID,"NEW SCHEDULE")
		self.Schedule = Metrostroi.GenerateSchedule("Line1_Platform"..self.PathID)
		self.StopTimer = 10
	end
	
	-- See if must move to next station
	if (Metrostroi.ServerTime() > (self.Schedule[1][3]*60)) and (self.StopTimer < 0) then
		table.remove(self.Schedule,1)
		self.StopTimer = 10
	end

	-- Get current target station info
	local platformEdgeX
	if self.Schedule[1] then
		local targetStation = self.Schedule[1][1]
		local targetPlatform = self.Schedule[1][2]
		local stationData = Metrostroi.Stations[targetStation]
		local platformData
		if stationData then platformData = stationData[targetPlatform] end
		if platformData then platformEdgeX = platformData.x_end end
	end
	
	-- Get current information on driving
	local speedLimit = self.ALS_ARS.SpeedLimit
	local nextLimit = self.ALS_ARS.NextLimit
	local targetSpeed = nextLimit
	
	-- Move at slow speed to next red light or blocked section
	if targetSpeed == 0 then targetSpeed = 20 end
	-- If there is a red light ahead, stop once in its range
	if self.RedLightDistance and (self.RedLightDistance < 20) then
		targetSpeed = 0
	end
	
	-- Stop at station gradually
	if platformEdgeX and (platformEdgeX > self.Position)  then
		local dX = platformEdgeX - self.Position
		if dX < 100 then
			targetSpeed = math.min(targetSpeed,55) * (math.max(0.0,math.min(1.0,(dX-11)/90))^0.5)
			if self.Speed < 1 then
				self.StopTimer = self.StopTimer - dT
			end
		end
	end
	
	-- Reached target speed, stop accelerating
	if self.Speed > (targetSpeed-2) then
		self.Accelerating = false
	end
	-- Speed is below required, try to accelerate
	if self.Speed < (targetSpeed-10) then
		self.Accelerating = true
	end
	-- Exceeding speed limit, apply brakes
	if self.Speed > targetSpeed then
		self.Braking = true
	end
	-- Braked enough, stop braking
	if (self.Speed < (targetSpeed-5)) and (self.Braking) then
		self.Braking = false
	end
	
	-- ARS system logic
	if self.ALS_ARS.LVD then
		self.Braking = true
		self.Accelerating = false
	end
	if self.ALS_ARS.LVD
	then self.ALS_ARS.AttentionPedal = true
	else self.ALS_ARS.AttentionPedal = false
	end
	if speedLimit == 0 then self.ALS_ARS.AttentionPedal = true end
	
	-- Apply pneumatic brakes if overspeeding much or stopped
	self.Pneumo = false
	if (self.Speed < 5) and (not self.Accelerating) then
		self.Pneumo = true
	end
	if (self.Speed > (targetSpeed+5)) then
		--self.Pneumo = true
	end
	
	-- Save for statistics
	self.TargetSpeed = targetSpeed
	--if self.RedLightDistance and (self.RedLightDistance < 30) then self.Pneumo = true end
end



--------------------------------------------------------------------------------
-- Train physics
--------------------------------------------------------------------------------
function ENT:DoPhysics(dT)
	-- Slopes code
	local slopeAngle = self:GetAngles().p
	if slopeAngle > 180 then slopeAngle = slopeAngle-360 end
	local slopeFactor = math.min(8.0,math.max(-8.0,slopeAngle))/8.0

	-- Motor code
	local motorPower = 0
	if self.Accelerating then	motorPower = 1.0 end
	if self.Braking then		motorPower = -1.0 end
	
	local motorForce = 0
	if motorPower > 0 then motorForce = 1.6*motorPower end
	if motorPower < 0 then motorForce = -1.6*math.abs(motorPower) * math.max(-1.0,math.min(1.0,0.25*self.Velocity)) end

	-- Brake code
	local brakeForce = 0
	if self.Pneumo then
		brakeForce = -2.0*math.max(-1.0,math.min(1.0,3.0*self.Velocity))
		slopeFactor = slopeFactor*math.max(-1.0,math.min(1.0,3.0*self.Velocity))
	end

	-- Integrate position and velocity
	self.Acceleration = 0
		+motorForce
		+brakeForce
		-self.Velocity*0.0075
		+slopeFactor*1.6
	self.Velocity = self.Velocity + dT*self.Acceleration
	self.Position = self.Position + dT*self.Velocity
	--print(Format("%.2f/%.2f km/h  %.0f m  A-%s B-%s P-%s",
		--self.Speed,self.TargetSpeed,self.Position,
		--tostring(self.Accelerating),tostring(self.Braking),tostring(self.Pneumo)))

	-- Info
	self.MotorPower = motorPower
end

function ENT:Think()
	-- Basic think loop
	self.PrevTime = self.PrevTime or CurTime()
	self.DeltaTime = (CurTime() - self.PrevTime)
	self.PrevTime = CurTime()
	
	self:RecvPackedData()
	self:NextThink(CurTime()+0.01)
	
	-- Simulate equipment specific to trains
	local dT = self.DeltaTime
	if self.TrainType == "81-717" then
		self.ALS_ARS:Think(dT,1)
	end

	-- Select path
	local path = Metrostroi.Paths[self.PathID]
	if (self.Position > 10910-10) and (self.PathID == 1) then
		self.Position = 100
		self.Velocity = 0
		self.PathID = 2
		self.Schedule = nil
	end
	if (self.Position > 11180-10) and (self.PathID == 2) then
		self.Position = 100
		self.Velocity = 0
		self.PathID = 1
		self.Schedule = nil
	end
	--self.Position = 11000
	--self.Velocity = 0

	----------------------------------------------------------------------------
	-- If needed, update train physics and AI
	if not self.TrainHead then
		self:DoAI(dT)
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


	----------------------------------------------------------------------------	
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
	if self.TrainType == "81-714" then
		self:SetLightPower(12, true)
	end
	-- Pneumatic brakes
	self.PneumaticPressure = self.PneumaticPressure or 0
	self.PneumaticPressure_dPdT = self.PneumaticPressure_dPdT or 0
	if self.Pneumo 
	then self.PneumaticPressure_dPdT = 0.75*(1.5 - self.PneumaticPressure)
	else self.PneumaticPressure_dPdT = 0.75*(0.0 - self.PneumaticPressure)
	end
	self.PneumaticPressure = self.PneumaticPressure + self.PneumaticPressure_dPdT*dT
	--print(self.PneumaticPressure,self.PneumaticPressure_dPdT)

	-- Minor state
	self.LeftDoorsOpen = self.Speed < 1
	self.RightDoorsOpen = self.Speed < 1
	self:SetPackedBool(52,1)
	self:SetPackedBool(39,self.ALS_ARS.LVD and (not self.TrainHead))		
	
	-- Update state of all objects and sounds
	self.Speed = math.abs(self.Velocity/0.277778)
	self.FrontBogey.Speed = self.Speed
	self.RearBogey.Speed = self.Speed
	self.FrontBogey.MotorPower = self.MotorPower
	self.RearBogey.MotorPower = self.MotorPower
	self.FrontBogey.BrakeCylinderPressure_dPdT = -self.PneumaticPressure_dPdT
	self.RearBogey.BrakeCylinderPressure_dPdT = -self.PneumaticPressure_dPdT
	

	----------------------------------------------------------------------------
	-- Update train position
	local vec,dir,node = Metrostroi.GetTrackPosition(path,self.Position)
	if vec then
		--local vec1,dir1 = Metrostroi.GetTrackPosition(path,self.Position+0)
		local vec2,dir2 = Metrostroi.GetTrackPosition(path,self.Position-5)
		if dir2 then
			dir = dir2
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

	-- Update information about restrictions in driving
	if node and (not self.TrainHead) then
		self.RedLightDistance = nil

		-- Check ARS signal/traffic light being red
		local nextARS = Metrostroi.GetARSJoint(node,self.Position,true)
		if nextARS and nextARS:GetRed() then
			local arsOffset = (nextARS.ARSOffset or self.Position)
			local dX = math.abs(arsOffset - self.Position)
			self.RedLightDistance = dX
		end

		-- Find other trains on the same line
		if not self.RedLightDistance then
			for k,v in pairs(ents.FindByClass("gmod_subway_ai")) do
				if (v.PathID == self.PathID) and (v ~= self) and (v.Position > self.Position) then
					self.RedLightDistance = math.abs(v.Position - self.Position)
				end 
			end
		end
	end

	self:SendPackedData()
	return true
end