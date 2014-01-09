AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")




--------------------------------------------------------------------------------
function ENT:Initialize()
	-- Set bogey model
	self:SetModel("models/myproject/81-717_bogey.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
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
	self.PneumaticBrakeForce = 60000.0
	
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
		wheels:SetPos(self:LocalToWorld(Vector(0,0.0,-14)))
		wheels:SetAngles(self:GetAngles() + Angle(0,0,0))
		wheels:Spawn()

		constraint.Weld(self,wheels,0,0,0,1,0)
	end
	wheels:SetOwner(self:GetOwner())
	wheels:SetNWEntity("TrainBogey",self)
	self.Wheels = wheels
end

function ENT:OnRemove()
	SafeRemoveEntity(self.Wheels)
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
local function Couple(ent1,ent2) 
	if IsValid(constraint.AdvBallsocket(
		ent1,
		ent2,
		0, --bone
		0, --bone
		ent1.CouplingPointOffset,
		ent2.CouplingPointOffset,
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
		sound.Play("buttons/lever2.wav",(ent1:GetPos()+ent2:GetPos())/2)
	else
		ErrorNoHalt("Error contraining 2 bogeys, please report")
	end
end

-- Quick and simple check, maybe expand later?
local function IsValidBogey(ent)
	return IsValid(ent) and ent:GetClass() == "gmod_train_bogey"
end

-- Used the couple with other bogeys
function ENT:StartTouch(ent) 
	if IsValidBogey(ent) and
	not AreCoupled(ent,self) and 
	constraint.CanConstrain(self,0) and
	constraint.CanConstrain(ent,0) then
		Couple(self,ent)
	end
end



-- Used to decouple
function ENT:Use(ply)
	local constrainttable = constraint.FindConstraints(self,"AdvBallsocket")
	local didsomething = false
	local ent1,ent2 = nil
	
	for k,v in pairs(constrainttable) do
		if IsValidBogey(v.Ent1) and IsValidBogey(v.Ent2) then
			v.Constraint:Remove()
			didsomething = true
			ent1=v.Ent1
			ent2=v.Ent2
			break
		end
	end
	
	if didsomething then 
		sound.Play("buttons/lever8.wav",(ent1:GetPos()+ent2:GetPos())/2)
	end
end


function ENT:Think()
	-- Re-initialize wheels
	if (not self.Wheels) or
		(not self.Wheels:IsValid()) or
		(self.Wheels:GetNWEntity("TrainBogey") ~= self) then
		self:InitializeWheels()
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
	
	self.Acc = (self.Speed - (self.PrevSpeed or 0)) / self.DeltaTime
	self.PrevSpeed = self.Speed


	-- Final brake cylinder pressure
	--self.BrakeCylinderPressure = math.max(0.0,4.5 - self.BrakeLinePressure)
	if (self.BrakeCylinderPressure > 1.5) and (absSpeed < 0.5) then
		self.Wheels:GetPhysicsObject():SetMaterial("gmod_silent")
	else
		self.Wheels:GetPhysicsObject():SetMaterial("gmod_ice")
	end
	self.Wheels:GetPhysicsObject():SetMaterial("gmod_ice")

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
	local pneumaticForce = -sign*self.PneumaticBrakeForce*(self.BrakeCylinderPressure / 4.5)
	
	-- Apply sideways friction
--	local sideSpeed = -self:GetVelocity():Dot(self:GetAngles():Right()) * 0.06858
--	local sideForce = sideSpeed*100000
	
	-- Apply force
	local dt_scale = 66.6/(1/self.DeltaTime)
	local force = dt_scale*(motorForce + pneumaticForce)
	
	if self.Reversed
	then self:GetPhysicsObject():ApplyForceCenter( self:GetAngles():Forward()*force)-- + self:GetAngles():Forward()*side_force*dt_scale)
	else self:GetPhysicsObject():ApplyForceCenter(-self:GetAngles():Forward()*force)-- + self:GetAngles():Forward()*side_force*dt_scale)
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
	local inhinitererail = false
	
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
			inhibitrerail = true
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
	
	if not inhabitrerail then Metrostroi.RerailBogey(ent) end
	
	return ent
end
