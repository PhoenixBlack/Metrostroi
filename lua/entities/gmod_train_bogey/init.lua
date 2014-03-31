AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local DECOUPLE_TIMEOUT 		= 2		-- Time after decoupling furing wich a bogey cannot couple
local COUPLE_MAX_DISTANCE 	= 20	-- Maximum distance between couple offsets
local COUPLE_MAX_ANGLE 		= 18	-- Maximum angle between bogeys on couple


--------------------------------------------------------------------------------
COUPLE_MAX_DISTANCE = COUPLE_MAX_DISTANCE ^ 2
COUPLE_MAX_ANGLE = math.cos(math.rad(COUPLE_MAX_ANGLE))

--------------------------------------------------------------------------------
function ENT:Initialize()
	if self.BogeyType == "tatra" then
		self:SetModel("models/metrostroi/tatra_t3/tatra_bogey.mdl")
	else
		self:SetModel("models/metrostroi/metro/metro_bogey.mdl")
	end
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	
	-- Set proper parameters for the bogey
	self:GetPhysicsObject():SetMass(5000)
	
	-- Store coupling point offset
	self.CouplingPointOffset = Vector(-162,0,13)
	
	-- Create wire controls
	if Wire_CreateInputs then
		self.Inputs = Wire_CreateInputs(self,{
			"TrainLinePressure", "DriverValvePosition",
			"MotorPower", "MotorForce", "MotorReversed" })
		self.Outputs = Wire_CreateOutputs(self,{
			"Speed",
			"ReservoirPressure", "TrainLinePressure",
			"BrakeLinePressure", "BrakeCylinderPressure"
		})
	end
	
	-- Setup default motor state
	self.Reversed = false
	self.MotorForce = 30000.0
	self.MotorPower = 0.0
	self.Speed = 0
	self.Acceleration = 0
	self.PneumaticBrakeForce = 60000.0
	
	self.Variables = {}
	
	-- Pressure in brake cylinder
	self.BrakeCylinderPressure = 0.0 -- atm
	-- Speed at which pressure in cylinder changes
	self.BrakeCylinderPressure_dPdT = 0.0
end

function ENT:InitializeWheels()
	-- Check if wheels are already connected
	local c_ents = constraint.FindConstraints(self,"Weld")
	local wheels = nil
	for k,v in pairs(c_ents) do
		if v.Ent2:GetClass() == "gmod_train_wheels" then
			wheels = v.Ent2
		end
	end

	-- Create missing wheels
	if not wheels then
		wheels = ents.Create("gmod_train_wheels")
		if self.BogeyType == "tatra" then
			wheels:SetPos(self:LocalToWorld(Vector(0,0.0,-3)))
			wheels:SetAngles(self:GetAngles() + Angle(0,0,0))
		else
			wheels:SetPos(self:LocalToWorld(Vector(0,0.0,-10)))
			wheels:SetAngles(self:GetAngles() + Angle(0,0,0))
		end		
		--wheels = ents.Create("gmod_subway_wheels")
		--wheels:SetPos(self:LocalToWorld(Vector(0,0.0,-10)))
		--wheels:SetAngles(self:GetAngles() + Angle(0,90,0))
		wheels.WheelType = self.BogeyType
		wheels:Spawn()

		constraint.Weld(self,wheels,0,0,0,1,0)
	end
	if CPPI then wheels:CPPISetOwner(self:CPPIGetOwner()) end
	wheels:SetNWEntity("TrainBogey",self)
	self.Wheels = wheels
end

function ENT:OnRemove()
	SafeRemoveEntity(self.Wheels)
	if self.CoupledBogey ~= nil then
		self:Decouple()
	end
end

function ENT:GetDebugVars()
	return self.Variables
end

function ENT:TriggerInput(iname, value)
	if iname == "TrainLinePressure" then
		self.TrainLinePressure = value
	elseif iname == "DriverValvePosition" then
		self.DriverValvePosition = value
		
	elseif iname == "MotorPower" then
		self.MotorPower = value
	elseif iname == "MotorForce" then
		self.MotorForce = value
	elseif iname == "MotorReversed" then
		self.Reversed = value > 0.5
	end
end

-- Checks if there's an advballsocket between two entities
local function AreCoupled(ent1,ent2)
	if ent1.CoupledBogey or ent2.CoupledBogey then return false end
	local constrainttable = constraint.FindConstraints(ent1,"AdvBallsocket")
	local coupled = false
	for k,v in pairs(constrainttable) do
		if v.Type == "AdvBallsocket" then 
			if( (v.Ent1 == ent1 or v.Ent1 == ent2) and (v.Ent2 == ent1 or v.Ent2 == ent2)) then
				coupled = true
			end
		end
	end
	
	return coupled
end

-- Adv ballsockets ents by their CouplingPointOffset 
function ENT:Couple(ent) 
	if IsValid(constraint.AdvBallsocket(
		self,
		ent,
		0, --bone
		0, --bone
		self.CouplingPointOffset,
		ent.CouplingPointOffset,
		0, --forcelimit
		0, --torquelimit
		-180, --xmin
		-180, --ymin
		-180, --zmin
		180, --xmax
		180, --ymax
		180, --zmax
		0, --xfric
		0, --yfric
		0, --zfric
		0, --rotonly
		1 --nocollide
	)) then
		sound.Play("buttons/lever2.wav",(self:GetPos()+ent:GetPos())/2)
		
		self:OnCouple(ent)
		ent:OnCouple(self)
	end
end

local function AreInCoupleDistance(ent,self)
	return self:LocalToWorld(self.CouplingPointOffset):DistToSqr(ent:LocalToWorld(ent.CouplingPointOffset)) < COUPLE_MAX_DISTANCE
end


local function AreFacingEachother(ent1,ent2)
	return ent1:GetForward():Dot(ent2:GetForward()) < - COUPLE_MAX_ANGLE
end

function ENT:IsInTimeOut()
	return (((self.DeCoupleTime or 0) + DECOUPLE_TIMEOUT) > CurTime())
end

function ENT:CanCouple()
	if self.CoupledBogey then return false end
	if self:IsInTimeOut() then return false end
	if not constraint.CanConstrain(self,0) then return false end
	return true
end

-- This feels so wrong, any ideas how to improve this?
local function CanCoupleTogether(ent1,ent2)
	if not (ent1.CanCouple and ent1:CanCouple()) then return false end
	if not (ent2.CanCouple and ent2:CanCouple()) then return false end
	if not AreInCoupleDistance(ent1,ent2) then return false end
	if not AreFacingEachother(ent1,ent2) then return false end
	return true 
end

-- Used the couple with other bogeys
function ENT:StartTouch(ent) 
	if CanCoupleTogether(self,ent) then
		self:Couple(ent)
	end
end


-- Used to decouple
function ENT:Use(ply)
	if self.CoupledBogey ~= nil then
		self:Decouple()
	end
end

local function removeAdvBallSocketBetweenEnts(ent1,ent2)
	local constrainttable = constraint.FindConstraints(ent1,"AdvBallsocket")
	for k,v in pairs(constrainttable) do
		if (v.Ent1 == ent1 or v.Ent1 == ent2) and (v.Ent2 == ent1 or v.Ent2 == ent2) then
			v.Constraint:Remove()
		end
	end
end

function ENT:Decouple()
	if self.CoupledBogey then
		sound.Play("buttons/lever8.wav",(self:GetPos()+self.CoupledBogey:GetPos())/2)
		removeAdvBallSocketBetweenEnts(self,self.CoupledBogey)
		
		self.CoupledBogey.CoupledBogey = nil
		self.CoupledBogey:Decouple()
		self.CoupledBogey = nil
	end
	
	-- Above this runs on initiator, below runs on both
	self.DeCoupleTime = CurTime()
	self:OnDecouple()
end


function ENT:OnCouple(ent)
	self.CoupledBogey = ent
	
	--Call OnCouple on our parent train as well
	local parent = self:GetNWEntity("TrainEntity")
	local isforward = self:GetNWBool("IsForwardBogey")
	
	if IsValid(parent) then
		parent:OnCouple(ent,isforward)
	end
end

function ENT:OnDecouple()
	--Call OnDecouple on our parent train as well
	local parent = self:GetNWEntity("TrainEntity")
	local isforward = self:GetNWBool("IsForwardBogey")
	
	if IsValid(parent) then
		parent:OnDecouple(isforward)
	end
end


function ENT:Think()
	-- Re-initialize wheels
	if (not self.Wheels) or
		(not self.Wheels:IsValid()) or
		(self.Wheels:GetNWEntity("TrainBogey") ~= self) then
		self:InitializeWheels()
		
		if IsValid(self:GetNWEntity("TrainEntity")) then
			constraint.NoCollide(self.Wheels,self:GetNWEntity("TrainEntity"),0,0)
		end
	end
 
	-- Update timing
	self.PrevTime = self.PrevTime or CurTime()
	self.DeltaTime = (CurTime() - self.PrevTime)
	self.PrevTime = CurTime()
	

	-- Skip logic
	if not (self.Wheels and self.Wheels:IsValid() and self.Wheels:GetPhysicsObject():IsValid()) then
		return
	end

	-- Get speed of bogey in km/h
	local localSpeed = -self:GetVelocity():Dot(self:GetAngles():Forward()) * 0.06858
	local absSpeed = math.abs(localSpeed)
	if self.Reversed then localSpeed = -localSpeed end

	local sign = 1
	if localSpeed < 0 then sign = -1 end
	self.Speed = absSpeed
	
	-- Calculate acceleration in m/s
	self.Acceleration = 0.277778*(self.Speed - (self.PrevSpeed or 0)) / self.DeltaTime
	self.PrevSpeed = self.Speed

	-- Add variables to debugger
	self.Variables["Speed"] = self.Speed
	self.Variables["Acceleration"] = self.Acceleration

	-- Final brake cylinder pressure
	--self.BrakeCylinderPressure = math.max(0.0,4.5 - self.BrakeLinePressure)
	if (self.BrakeCylinderPressure > 1.5) and (absSpeed < 1) then
		self.Wheels:GetPhysicsObject():SetMaterial("gmod_silent")
	else
		self.Wheels:GetPhysicsObject():SetMaterial("gmod_ice")
	end

	-- Calculate motor power
	local motorPower = 0.0
	if self.MotorPower > 0.0 then
		motorPower = self.MotorPower
	else
		motorPower = self.MotorPower*sign
	end
	motorPower = math.max(-1.0,motorPower)
	motorPower = math.min(1.0,motorPower)
	
	
	-- Calculate forces
	local motorForce = self.MotorForce*motorPower
	local pneumaticFactor = math.max(0,math.min(1,2.5*self.Speed))
	local pneumaticForce = -sign*pneumaticFactor*self.PneumaticBrakeForce*((self.BrakeCylinderPressure / 4.5)^1.2)
	if self.BrakeCylinderPressure < 0.05 then pneumaticForce = 0 end
	
	-- Compensate forward friction
	local compensateA = self.Speed / 175
	local compensateF = sign * self:GetPhysicsObject():GetMass() * compensateA
	-- Apply sideways friction
	local sideSpeed = -self:GetVelocity():Dot(self:GetAngles():Right()) * 0.06858
	if sideSpeed < 0.5 then sideSpeed = 0 end
	local sideForce = sideSpeed * 0.5 * self:GetPhysicsObject():GetMass()
	
	-- Apply force
	local dt_scale = 66.6/(1/self.DeltaTime)
	local force = dt_scale*(motorForce + pneumaticForce + compensateF)
	local side_force = dt_scale*(sideForce)
	
	if self.Reversed
	then self:GetPhysicsObject():ApplyForceCenter( self:GetAngles():Forward()*force + self:GetAngles():Right()*side_force)
	else self:GetPhysicsObject():ApplyForceCenter(-self:GetAngles():Forward()*force + self:GetAngles():Right()*side_force)
	end
	
	-- Send parameters to client
	self:SetMotorPower(motorPower)
	self:SetSpeed(absSpeed)
	self:SetdPdT(self.BrakeCylinderPressure_dPdT)
	self:NextThink(CurTime())
	
	-- Trigger outputs
	if Wire_TriggerOutput then
		Wire_TriggerOutput(self, "Speed", absSpeed)
		Wire_TriggerOutput(self, "BrakeCylinderPressure", self.BrakeCylinderPressure)
	end
	return true
end



--------------------------------------------------------------------------------
-- Default spawn function
--------------------------------------------------------------------------------
function ENT:SpawnFunction(ply, tr)
	local verticaloffset = 40 -- Offset for the train model, gmod seems to add z by default, nvm its you adding 170 :V
	local distancecap = 2000 -- When to ignore hitpos and spawn at set distanace
	local pos, ang = nil
	local inhibitrerail = false
	
	if tr.Hit then
		-- Setup trace to find out of this is a track
		local tracesetup = {}
		tracesetup.start=tr.HitPos
		tracesetup.endpos=tr.HitPos+tr.HitNormal*80
		tracesetup.filter=ply

		local tracedata = util.TraceLine(tracesetup)

		if tracedata.Hit then
			-- Trackspawn
			pos = (tr.HitPos + tracedata.HitPos)/2 + Vector(0,0,verticaloffset)
			ang = tracedata.HitNormal
			ang:Rotate(Angle(0,90,0))
			ang = ang:Angle()
			-- Bit ugly because Rotate() messes with the orthogonal vector | Orthogonal? I wrote "origional?!" :V
		else
			-- Regular spawn
			if tr.HitPos:Distance(tr.StartPos) > distancecap then
				-- Spawnpos is far away, put it at distancecap instead
				pos = tr.StartPos + tr.Normal * distancecap
				inhibitrerail = true
			else
				-- Spawn is near
				pos = tr.HitPos + tr.HitNormal * verticaloffset
			end
			ang = Angle(0,tr.Normal:Angle().y,0)
		end
	else
		-- Trace didn't hit anything, spawn at distancecap
		pos = tr.StartPos + tr.Normal * distancecap
		ang = Angle(0,tr.Normal:Angle().y,0)
	end

	local ent = ents.Create(self.ClassName)
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:Spawn()
	ent:Activate()
	
	if not inhibitrerail then Metrostroi.RerailBogey(ent) end
	
	return ent
end
