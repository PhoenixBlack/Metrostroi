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
			local i = v:WireInputs()
			local o = v:WireOutputs()
			
			for _,v2 in pairs(i) do 
				if type(v2) == "string" then
					table.insert(inputs,v2) 
					table.insert(inputTypes,"NORMAL")
				elseif type(v2) == "table" then
					table.insert(inputs,v2[1])
					table.insert(inputTypes,v2[2])
				else
					ErrorNoHalt("Metrostroi System gave invalid input")
				end
			end
			
			for _,v2 in pairs(o) do 
				if type(v2) == "string" then
					table.insert(outputs,v2) 
					table.insert(outputTypes,"NORMAL")
				elseif type(v2) == "table" then
					table.insert(outputs,v2[1])
					table.insert(outputTypes,v2[2])
				else
					ErrorNoHalt("Metrostroi System gave invalid output")
				end
			end
		end
		
		--Custom driver seat
		table.insert(inputs,"Seat")
		table.insert(inputTypes,"ENTITY")
		
		self.Inputs = WireLib.CreateSpecialInputs(self,inputs,inputTypes)
		self.Outputs = WireLib.CreateSpecialOutputs(self,outputs,outputTypes)
		
		--[[
			To use the special types, make a system return a table with name,type instead of just name
			EG: { Mode , Speed , { Name , "STRING" }}
		--]]
	end

	-- Setup drivers controls
	self.ButtonBuffer = {}
	self.KeyBuffer = {}
	self.KeyMap = {
		[KEY_1] = "D_1",
		[KEY_2] = "D_2",
		[KEY_3] = "D_3",
		[KEY_W] = "ControllerUp",
		[KEY_S] = "ControllerDown"
	}
	
	if joystick then
		self.JoystickBuffer = {}
	end
	
	-- Entities that belong to train and must be cleaned up later
	self.TrainEntities = {}
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
	--Custom seat 
	if name == "Seat" then
		if IsValid(value) and value:IsVehicle() then
			self.DriverSeat = value
		else
			self.DriverSeat = nil
		end
	end

	for k,v in pairs(self.Systems) do
		v:TriggerInput(name,value)
	end
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


function ENT:CreateSeat(offset,type)
  local seat = ents.Create("prop_vehicle_prisoner_pod")
  seat:SetModel("models/props_phx/carseat3.mdl")

    seat:SetPos(self:LocalToWorld(offset))
    seat:SetAngles(self:GetAngles()+Angle(0,-90,0))

  seat:Spawn()
  seat:GetPhysicsObject():SetMass(10)
  seat:SetCollisionGroup(COLLISION_GROUP_WORLD)
  table.insert(self.TrainEntities,seat)
  
  --table.insert(self.Seats,seat) --No longer used?

  seat:SetNWEntity("TrainEntity", self)
  seat:SetNWString("SeatType", type)

  -- Constrain seat to this object
--  constraint.NoCollide(self,seat,0,0)
  seat:SetParent(self)
  return seat
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
		
		for k,v in pairs(self.Systems) do
			if type(state) == "boolean" then
				if state then
					state = 1
				else
					state = 0
				end
			end
			print(state)
			v:TriggerInput(button,state)
		end
		
		
		if state then
			self:OnButtonPress(button)
		else
			self:OnButtonRelease(button)
		end
	end
end


--------------------------------------------------------------------------------
-- Process train logic
--------------------------------------------------------------------------------
-- Load system
function ENT:LoadSystem(name)
	self[name] = Metrostroi.Systems[name](self)
	self.Systems[name] = self[name]
end

-- Think and execute systems stuff
function ENT:Think()
	self.PrevTime = self.PrevTime or CurTime()
	self.DeltaTime = (CurTime() - self.PrevTime)
	self.PrevTime = CurTime()
	
	--Handle player input
	if IsValid(self.DriverSeat) then
		local ply = self.DriverSeat:GetPassenger(0) 
		if ply and IsValid(ply) then
		
			//Keypresses
			//Check for newly pressed keys
			for k,v in pairs(ply.keystate) do
				if self.KeyBuffer[k] == nil then
					self.KeyBuffer[k] = true
					local button = self.KeyMap[k]
					if button != nil then
						self:ButtonEvent(button,true)
					end
				end
			end
			
			//Check for newly released keys
			for k,v in pairs(self.KeyBuffer) do
				if ply.keystate[k] == nil then
					self.KeyBuffer[k] = nil
					local button = self.KeyMap[k]
					if button != nil then
						self:ButtonEvent(button,false)
					end
				end
			end
			
			//Joystick
			if joystick then
				for k,v in pairs(jcon.binds) do
					if v:GetCategory() == "Metrostroi" then
						local jvalue = Metrostroi.GetJoystickInput(ply,k)
						if jvalue != nil then
							if self.JoystickBuffer[k]~=jvalue then
								self.JoystickBuffer[k]=jvalue
								for _,system in pairs(self.Systems) do
									local inputname = Metrostroi.JoystickSystemMap[k]
									if inputname then
										print("triggered",k,jvalue)
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
	
	for k,v in pairs(self.Systems) do
		v:Think()
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
-- Handle cabin buttons
--------------------------------------------------------------------------------
-- Receiver for CS buttons, Checks if people are the legit driver and calls buttonevent on the train
net.Receive("metrostroi-cabin-button", function(len, ply)
	local button = net.ReadString()
	local eventtype = net.ReadBit()
	local seat = ply:GetVehicle()
	local train 
	
	if seat and IsValid(seat) then 
		//Player currently driving
		train = seat:GetNWEntity("TrainEntity")
		if (not train) or (not train:IsValid()) then return end
		if seat != train.DriverSeat then return end
	else
		//Player not driving, check recent train
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
		if seattype == "driver" then
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



--Register joystick buttons
--Won't get called if joystick isn't installed
--I've put it here for now, trains will likely share these inputs anyway
local function JoystickRegister()
	Metrostroi.RegisterJoystickInput("met_controller",true,"Controller",-3,3)
	Metrostroi.RegisterJoystickInput("met_reverser",true,"Reverser",-1,1)
	
	Metrostroi.JoystickSystemMap["met_controller"]="SetController"
	Metrostroi.JoystickSystemMap["met_reverser"]="SetReverser"
end

hook.Add("JoystickInitialize","metroistroi_cabin",JoystickRegister)

hook.Add("PlayerLeaveVehicle", "gmod_subway_81-717-cabin-exit", HandleExitingPlayer )
hook.Add("CanPlayerEnterVehicle","gmod_subway_81-717-cabin-entry", CanPlayerEnter )


