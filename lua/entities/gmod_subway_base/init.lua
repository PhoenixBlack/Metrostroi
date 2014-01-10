AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")



--------------------------------------------------------------------------------
function ENT:Initialize()
	if self:GetModel() == "models/error.mdl" then
		self:SetModel("models/props_lab/reciever01a.mdl")
	end
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	
	self.TrainWires = {}
	self.TrainWireWriters = {}
	-- Systems defined in the train
	self.Systems = {}
	-- Initialize train systems
	self:InitializeSystems()
	
	-- Initialize wire interface
	if Wire_CreateInputs then
		local inputs = {}
		local outputs = {}
		local inputTypes = {}
		local outputTypes = {}
		for k,v in pairs(self.Systems) do
			local i = v:Inputs()
			local o = v:Outputs()
			
			for _,v2 in pairs(i) do 
				if type(v2) == "string" then
					table.insert(inputs,(v.Name or "")..v2) 
					table.insert(inputTypes,"NORMAL")
				elseif type(v2) == "table" then
					table.insert(inputs,(v.Name or "")..v2[1])
					table.insert(inputTypes,v2[2])
				else
					ErrorNoHalt("Invalid wire input for metrostroi subway entity")
				end
			end
			
			for _,v2 in pairs(o) do 
				if type(v2) == "string" then
					table.insert(outputs,(v.Name or "")..v2) 
					table.insert(outputTypes,"NORMAL")
				elseif type(v2) == "table" then
					table.insert(outputs,(v.Name or "")..v2[1])
					table.insert(outputTypes,v2[2])
				else
					ErrorNoHalt("Invalid wire output for metrostroi subway entity")
				end
			end
		end
		
		-- Add input for a custom driver seat
		table.insert(inputs,"DriverSeat")
		table.insert(inputTypes,"ENTITY")
		
		self.Inputs = WireLib.CreateSpecialInputs(self,inputs,inputTypes)
		self.Outputs = WireLib.CreateSpecialOutputs(self,outputs,outputTypes)
	end

	-- Setup drivers controls
	self.ButtonBuffer = { }
	self.KeyBuffer = { }
	self.KeyMap = { }
	
	-- Joystick module support
	if joystick then
		self.JoystickBuffer = {}
	end
	
	-- Entities that belong to train and must be cleaned up later
	self.TrainEntities = {}
	-- All the sitting positions in train
	self.Seats = {}
	
	-- Load basic sounds
	self.SoundNames = {}
	self.SoundNames["switch"]	= "subway_trains/81717_switch.wav"
	self.SoundNames["kv1"]		= "subway_trains/81717_kv1.wav"
	self.SoundNames["kv2"]   	= "subway_trains/81717_kv2.wav"
	self.SoundNames["kv3"]    	= "subway_trains/81717_kv3.wav"
	self.SoundNames["kv4"]   	= "subway_trains/81717_kv4.wav"
	
	self.SoundTimeout = {}
	self.SoundTimeout["switch"]        = 0.0
end

function ENT:OnRemove()
	constraint.RemoveAll(self)
	if self.TrainEntities then
		for k,v in pairs(self.TrainEntities) do
			SafeRemoveEntity(v)
		end
	end
end

-- Trigger output
function ENT:TriggerOutput(name,value)
	if Wire_TriggerOutput then
		Wire_TriggerOutput(self,name,tonumber(value) or 0)
	end
end

-- Trigger input
function ENT:TriggerInput(name, value)
	-- Custom seat 
	if name == "DriverSeat" then
		if IsValid(value) and value:IsVehicle() then
			self.DriverSeat = value
		else
			self.DriverSeat = nil
		end
	end

	-- Propagate inputs to relevant systems
	for k,v in pairs(self.Systems) do
		if v.Name then
			v:TriggerInput(string.sub(name,#v.Name+1),value)
		else
			v:TriggerInput(name,value)
		end
	end
end

--------------------------------------------------------------------------------
-- Train wire I/O
--------------------------------------------------------------------------------
function ENT:TrainWireCanWrite(k)
	local lastwrite = self.TrainWireWriters[k]
	if lastwrite ~= nil then
		if lastwrite.ent ~= self and CurTime() - lastwrite.time < 0.1 then
			--Last write not us and recent, conflict!
			return false
		end
	end
	return true
end

function ENT:WriteTrainWire(k,v)
	if self:TrainWireCanWrite(k) then
		self.TrainWires[k]=v
		self.TrainWireWriters[k] = {
			ent = self,
			time = CurTime()
		}
	else
		self:OnTrainWireError(k)
	end
end

function ENT:ReadTrainWire(k)
	return self.TrainWires[k] or 0
end

function ENT:OnTrainWireError(k)

end

function ENT:ResetTrainWires()
	
	for k,v in pairs(self.TrainWires) do
		if k ~= "BaseClass" then 
			self.TrainWires[k] = 0
		end
	end
	
	self.TrainWireWriters = {}
end

--------------------------------------------------------------------------------
-- Create a bogey for the train
--------------------------------------------------------------------------------
function ENT:CreateBogey(pos,ang,forward)
	-- Create bogey entity
	bogey = ents.Create("gmod_train_bogey")
	bogey:SetPos(self:LocalToWorld(pos))
	bogey:SetAngles(self:GetAngles() + ang)
	bogey:Spawn()
	bogey:SetOwner(self:GetOwner())
	
	-- Some shared general information about the bogey
	bogey:SetNWBool("IsForwardBogey", forward)
	bogey:SetNWEntity("TrainEntity", self)

	-- Constraint bogey to the train
	constraint.Axis(bogey,self,0,0,
		Vector(0,0,0),Vector(0,0,0),
		0,0,0,1,Vector(0,0,1),false)

	-- Add to cleanup list
	table.insert(self.TrainEntities,bogey)
	return bogey
end


--------------------------------------------------------------------------------
-- Create an entity for the seat
--------------------------------------------------------------------------------
function ENT:CreateSeatEntity(seat_info)
	-- Create seat entity
	local seat = ents.Create("prop_vehicle_prisoner_pod")
	seat:SetModel("models/nova/jeep_seat.mdl") --jalopy
	seat:SetPos(self:LocalToWorld(seat_info.offset))
	seat:SetAngles(self:GetAngles()+Angle(0,-90,0)+seat_info.angle)
	seat:Spawn()
	seat:GetPhysicsObject():SetMass(10)
	seat:SetCollisionGroup(COLLISION_GROUP_WORLD)
	
	-- Hide the entity visually
	--if seat_info.type ~= "instructor" then
		--seat:SetColor(Color(0,0,0,0))
		--seat:SetRenderMode(RENDERMODE_TRANSALPHA)
	--end

	-- Set some shared information about the seat
	seat:SetNWString("SeatType", seat_info.type)
	seat:SetNWEntity("TrainEntity", self)
	seat_info.entity = seat

	-- Constrain seat to this object
	-- constraint.NoCollide(self,seat,0,0)
	seat:SetParent(self)
	
	-- Add to cleanup list
	table.insert(self.TrainEntities,seat)
	return seat
end


--------------------------------------------------------------------------------
-- Create a seat position
--------------------------------------------------------------------------------
function ENT:CreateSeat(type,offset,angle)
	-- Add a new seat
	local seat_info = {
		type = type,
		offset = offset,
		angle = angle or Angle(0,0,0),
	}
	table.insert(self.Seats,seat_info)
	
	-- If needed, create an entity for this seat
	if (type == "driver") or (type == "instructor") then
		return self:CreateSeatEntity(seat_info)
	end
end




--------------------------------------------------------------------------------
-- Play sound once emitting frmo the train
--------------------------------------------------------------------------------
function ENT:CheckActionTimeout(action,timeout)
  self.LastActionTime = self.LastActionTime or {}
  self.LastActionTime[action] = self.LastActionTime[action] or (CurTime()-1000)
  if CurTime() - self.LastActionTime[action] < timeout then return true end
  self.LastActionTime[action] = CurTime()
  
  return false
end

function ENT:PlayOnce(soundid,inCockpit,range,pitch)
  if self:CheckActionTimeout(soundid,self.SoundTimeout[soundid] or 0.0) then return end
  
  local default_range = 0.80
  if soundid == "switch" then default_range = 0.50 end
  
  if not inCockpit then
    self:EmitSound(self.SoundNames[soundid], 100*(range or default_range), pitch or math.random(95,105))
  else
    if self.DriverSeat and self.DriverSeat:IsValid() then
      self.DriverSeat:EmitSound(self.SoundNames[soundid], 100*(range or default_range),pitch or math.random(95,105))
    end
  end
end




--------------------------------------------------------------------------------
-- Process train logic
--------------------------------------------------------------------------------
-- Think and execute systems stuff
function ENT:Think()
	self.PrevTime = self.PrevTime or CurTime()
	self.DeltaTime = (CurTime() - self.PrevTime)
	self.PrevTime = CurTime()
	
	-- Handle player input
	if IsValid(self.DriverSeat) then
		local ply = self.DriverSeat:GetPassenger(0) 
		if ply and IsValid(ply) then
		
			-- Keypresses
			-- Check for newly pressed keys
			for k,v in pairs(ply.keystate) do
				if self.KeyBuffer[k] == nil then
					self.KeyBuffer[k] = true
					local button = self.KeyMap[k]
					if button != nil then
						self:ButtonEvent(button,true)
					end
				end
			end
			
			-- Check for newly released keys
			for k,v in pairs(self.KeyBuffer) do
				if ply.keystate[k] == nil then
					self.KeyBuffer[k] = nil
					local button = self.KeyMap[k]
					if button != nil then
						self:ButtonEvent(button,false)
					end
				end
			end
			
			-- Joystick
			if joystick then
				for k,v in pairs(jcon.binds) do
					if v:GetCategory() == "Metrostroi" then
						local jvalue = Metrostroi.GetJoystickInput(ply,k)
						if jvalue != nil then
							if self.JoystickBuffer[k] ~= jvalue then
								self.JoystickBuffer[k] = jvalue
								for _,system in pairs(self.Systems) do
									local inputname = Metrostroi.JoystickSystemMap[k]
									if inputname then
										system:TriggerInput(inputname,jvalue)
									end
								end
							end
						end
					end
				end
			end
		end
	end
	
	-- Run iterations on systems simulation
	local maxIterations = 4
	for iteration=1,maxIterations do
		for k,v in pairs(self.Systems) do
			v:Think(self.DeltaTime / maxIterations)
		end
	end
	self:NextThink(CurTime())
	return true
end




--------------------------------------------------------------------------------
-- Default spawn function
--------------------------------------------------------------------------------
function ENT:SpawnFunction(ply, tr)
	local verticaloffset = 0 -- Offset for the train model, gmod seems to add z by default, nvm its you adding 170 :V
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
	
	if not inhabitrerail then Metrostroi.RerailTrain(ent) end
	return ent
end


--------------------------------------------------------------------------------
-- Coupling logic
--------------------------------------------------------------------------------
function ENT:OnCouple(train,isfront)
	print("Coupled with ",train," at ",isfront)
	
	if isfront then
		self.FrontTrain = train
	else
		self.RearTrain = train
	end
	
	self.TrainWires = train.TrainWires
	self.TrainWireWriters = train.TrainWireWriters
	
end

function ENT:OnDecouple(isfront)
	print("Decoupled from front?:" ,isfront)
	
	if isfront then
		self.FrontTrain = nil
	else 
		self.RearTrain = nil
	end
	
	self:ResetTrainWires()
end
--------------------------------------------------------------------------------
-- Process Cabin button and keyboard input
--------------------------------------------------------------------------------
function ENT:OnButtonPress(button)
	print("Pressed", button)
end

function ENT:OnButtonRelease(button)
	print("Released",button)
end

-- Clears the serverside keybuffer and fires events
function ENT:ClearKeyBuffer()
	for k,v in pairs(self.KeyBuffer) do
		local button = self.KeyMap[k]
		if button ~= nil then
			self:ButtonEvent(button,false)
		end
	end
	self.KeyBuffer = {}
end

-- Checks a button with the buffer and calls 
-- OnButtonPress/Release as well as TriggerInput
function ENT:ButtonEvent(button,state)
	if self.ButtonBuffer[button] != state then
		self.ButtonBuffer[button]=state
		
		if state then
			self:OnButtonPress(button)
			self:TriggerInput(button,1.0)
		else
			self:OnButtonRelease(button)
			self:TriggerInput(button,0.0)
		end
	end
end




--------------------------------------------------------------------------------
-- Handle cabin buttons
--------------------------------------------------------------------------------
-- Receiver for CS buttons, Checks if people are the legit driver and calls buttonevent on the train
net.Receive("metrostroi-cabin-button", function(len, ply)
	local button = net.ReadString()
	local eventtype = net.ReadBit()
	local seat = ply:GetVehicle()
	local train 
	
	if seat and IsValid(seat) then 
		-- Player currently driving
		train = seat:GetNWEntity("TrainEntity")
		if (not train) or (not train:IsValid()) then return end
		if seat != train.DriverSeat then return end
	else
		-- Player not driving, check recent train
		train = ply.lastVehicleDriven:GetNWEntity("TrainEntity")
		if !IsValid(train) then return end
		if ply != train.DriverSeat.lastDriver then return end
		if CurTime() - train.DriverSeat.lastDriverTime > 1	then return end
	end
	
	train:ButtonEvent(button,(eventtype > 0))
end)

-- Denies entry if player recently sat in the same train seat
-- This prevents getting stuck in seats when trying to exit
local function CanPlayerEnter(ply,vec,role)
	local train = vec:GetNWEntity("TrainEntity")
	
	if IsValid(train) and IsValid(ply.lastVehicleDriven) and ply.lastVehicleDriven.lastDriverTime != nil then
		if CurTime() - ply.lastVehicleDriven.lastDriverTime < 1 then return false end
	end
end

-- Exiting player hook, stores some vars and moves player if vehicle was train seat
local function HandleExitingPlayer(ply, vehicle)
	vehicle.lastDriver = ply
	vehicle.lastDriverTime = CurTime()
	ply.lastVehicleDriven = vehicle

	local train = vehicle:GetNWEntity("TrainEntity")
	if IsValid(train) then
		
		-- Move exiting player
		local seattype = vehicle:GetNWString("SeatType")
		if (seattype == "driver") or (seattype == "instructor") then
			ply:SetPos(vehicle:GetPos()+Vector(0,0,-20))
		elseif seattype == "passenger" then
			ply:SetPos(vehicle:GetPos()+vehicle:GetForward()*40+Vector(0,0,-10))
		end
		ply:SetEyeAngles(vehicle:GetForward():Angle())
		
		-- Server
		train:ClearKeyBuffer()
		
		-- Client
		net.Start("metrostroi-cabin-reset")
		net.WriteEntity(train)
		net.Send(ply)
	end
end




--------------------------------------------------------------------------------
-- Register joystick buttons
-- Won't get called if joystick isn't installed
-- I've put it here for now, trains will likely share these inputs anyway
local function JoystickRegister()
	Metrostroi.RegisterJoystickInput("met_controller",true,"Controller",-3,3)
	Metrostroi.RegisterJoystickInput("met_reverser",true,"Reverser",-1,1)
	
	Metrostroi.JoystickSystemMap["met_controller"] = "SetController"
	Metrostroi.JoystickSystemMap["met_reverser"] = "SetReverser"
end

hook.Add("JoystickInitialize","metroistroi_cabin",JoystickRegister)

hook.Add("PlayerLeaveVehicle", "gmod_subway_81-717-cabin-exit", HandleExitingPlayer )
hook.Add("CanPlayerEnterVehicle","gmod_subway_81-717-cabin-entry", CanPlayerEnter )


