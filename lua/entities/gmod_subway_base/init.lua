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
	
	
	-- Train wires
	self:ResetTrainWires()
	-- Systems defined in the train
	self.Systems = {}
	-- Initialize train systems
	self:InitializeSystems()
	
	if CPPI then
		self:CPPISetOwner(self.Owner)
	end

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
	self.ButtonBuffer = {}
	self.KeyBuffer = {}
	self.KeyMap = {}

	-- Joystick module support
	if joystick then
		self.JoystickBuffer = {}
	end
	self.DebugVars = {}

	-- Entities that belong to train and must be cleaned up later
	self.TrainEntities = {}
	-- All the sitting positions in train
	self.Seats = {}
	-- List of headlights, dynamic lights, sprite lights
	self.Lights = {}

	-- Load sounds
	self:InitializeSounds()
	
	-- Is this train 'odd' or 'even' in coupled set
	self.TrainCoupledIndex = 0
end

-- Remove entity
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

function ENT:GetDebugVars()
	return self.DebugVars 
end



--------------------------------------------------------------------------------
-- Train wire I/O
--------------------------------------------------------------------------------
function ENT:TrainWireCanWrite(k)
	local lastwrite = self.TrainWireWriters[k]
	if lastwrite ~= nil then
		if (lastwrite.ent ~= self) and (CurTime() - lastwrite.time < 0.1) then
			--Last write not us and recent, conflict!
			return false
		end
	end
	return true
end

function ENT:WriteTrainWire(k,v)
	if self:TrainWireCanWrite(k) then
		self.TrainWires[k] = v
		self.TrainWireWriters[k] = {
			ent = self,
			time = CurTime()
		}
	else
		self:OnTrainWireError(k)
	end
end

function ENT:ReadTrainWire(k)
	-- Cross-commutate some wires
	if self.TrainWireWriters[k] and IsValid(self.TrainWireWriters[k].ent) and 
		(self.TrainWireWriters[k].ent.TrainCoupledIndex ~= self.TrainCoupledIndex) then
		if k == 4 then return self.TrainWires[5] or 0 end
		if k == 5 then return self.TrainWires[4] or 0 end
	end
	return self.TrainWires[k] or 0
end

function ENT:OnTrainWireError(k)

end

function ENT:ResetTrainWires()
	-- Remember old train wires reference
	local trainWires = self.TrainWires
	
	-- Create new train wires
	self.TrainWires = {}
	self.TrainWireWriters = {}
	
	-- Update train wires in all connected trains
	local function updateWires(train,checked)
		if not train then return end
		if checked[train] then return end
		checked[train] = true
		
		if train.TrainWires == trainWires then
			train.TrainWires = self.TrainWires
			train.TrainWireWriters = self.TrainWireWriters
		end
		updateWires(train.FrontTrain,checked)
		updateWires(train.RearTrain,checked)
	end
	updateWires(self,{})
end

function ENT:SetTrainWires(coupledTrain)
	-- Get train wires from train
	self.TrainWires = coupledTrain.TrainWires
	self.TrainWireWriters = coupledTrain.TrainWireWriters
	
	-- Update train wires in all connected trains
	local function updateWires(train,checked)
		if not train then return end
		if checked[train] then return end
		checked[train] = true
		
		if train.TrainWires ~= coupledTrain.TrainWires then
			train.TrainWires = coupledTrain.TrainWires
			train.TrainWireWriters = coupledTrain.TrainWireWriters
		end
		updateWires(train.FrontTrain,checked)
		updateWires(train.RearTrain,checked)
	end
	updateWires(self,{})
end




--------------------------------------------------------------------------------
-- Coupling logic
--------------------------------------------------------------------------------
function ENT:UpdateIndexes()
	local function updateIndexes(train,checked,newIndex)
		if not train then return end
		if checked[train] then return end
		checked[train] = true
		
		train.TrainCoupledIndex = newIndex
		
		if train.FrontTrain and (train.FrontTrain.FrontTrain == train) then
			updateIndexes(train.FrontTrain,checked,1-newIndex)
		else
			updateIndexes(train.FrontTrain,checked,newIndex)
		end
		if train.RearTrain and (train.RearTrain.RearTrain == train) then
			updateIndexes(train.RearTrain,checked,1-newIndex)
		else
			updateIndexes(train.RearTrain,checked,newIndex)
		end
	end
	updateIndexes(self,{},0)
end

function ENT:OnCouple(train,isfront)
	--print(self,"Coupled with ",train," at ",isfront)
	if isfront 
	then self.FrontTrain = train
	else self.RearTrain = train
	end

	if ((train.FrontTrain == self) or (train.RearTrain == self)) then
		self:UpdateIndexes()
	end
	
	-- Update train wires
	self:SetTrainWires(train)
end

function ENT:OnDecouple(isfront)
	--print(self,"Decoupled from front?:" ,isfront)	
	if isfront 
	then self.FrontTrain = nil
	else self.RearTrain = nil
	end
	
	self:UpdateIndexes()	
	self:ResetTrainWires()
end




--------------------------------------------------------------------------------
-- Create a bogey for the train
--------------------------------------------------------------------------------
function ENT:CreateBogey(pos,ang,forward,type)
	-- Create bogey entity
	local bogey = ents.Create("gmod_train_bogey")
	bogey:SetPos(self:LocalToWorld(pos))
	bogey:SetAngles(self:GetAngles() + ang)
	bogey.BogeyType = type
	bogey:Spawn()

	-- Assign ownership
	if CPPI then bogey:CPPISetOwner(self:CPPIGetOwner()) end
	
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
	seat:SetKeyValue("limitview",0)
	seat:Spawn()
	seat:GetPhysicsObject():SetMass(10)
	seat:SetCollisionGroup(COLLISION_GROUP_WORLD)
	
	--Assign ownership
	if CPPI then seat:CPPISetOwner(self:CPPIGetOwner()) end
	
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
-- Turn light on or off
--------------------------------------------------------------------------------
function ENT:SetLightPower(index,power)
	local lightData = self.Lights[index]
	self.GlowingLights = self.GlowingLights or {}

	-- Check if light already glowing
	if power and (self.GlowingLights[index]) then return end
	
	-- Turn off light
	SafeRemoveEntity(self.GlowingLights[index])
	self.GlowingLights[index] = nil
	
	-- Create light
	if (lightData[1] == "headlight") and (power) then
		local light = ents.Create("env_projectedtexture")
		light:SetParent(self)
		light:SetLocalPos(lightData[2])
		light:SetLocalAngles(lightData[3])

		-- Set parameters
		light:SetKeyValue("enableshadows", 1)
		light:SetKeyValue("farz", 2048)
		light:SetKeyValue("nearz", 16)
		light:SetKeyValue("lightfov", lightData.fov or 120)

		-- Set Brightness
		local brightness = lightData.brightness or 1.25
		light:SetKeyValue("lightcolor",
			Format("%i %i %i 255",
				lightData[4].r*brightness,
				lightData[4].g*brightness,
				lightData[4].b*brightness
			)
		)

		-- Turn light on
		light:Spawn() --"effects/flashlight/caustics"
		light:Input("SpotlightTexture",nil,nil,lightData.texture or "effects/flashlight001")
		self.GlowingLights[index] = light
	end
	if (lightData[1] == "glow") and (power) then
		local light = ents.Create("env_sprite")
		light:SetParent(self)
		light:SetLocalPos(lightData[2])
		light:SetLocalAngles(lightData[3])
	
		-- Set parameters
		local brightness = lightData.brightness or 0.5
		light:SetKeyValue("rendercolor",
			Format("%i %i %i",
				lightData[4].r*brightness,
				lightData[4].g*brightness,
				lightData[4].b*brightness
			)
		)
		light:SetKeyValue("rendermode", lightData.type or 3) -- 9: WGlow, 3: Glow
		light:SetKeyValue("model", lightData.texture or "sprites/glow1.vmt")
--		light:SetKeyValue("model", "sprites/light_glow02.vmt")
--		light:SetKeyValue("model", "sprites/yellowflare.vmt")
		light:SetKeyValue("scale", lightData.scale or 1.0)
		light:SetKeyValue("spawnflags", 1)
	
		-- Turn light on
		light:Spawn()
		self.GlowingLights[index] = light
	end
	if (lightData[1] == "light") and (power) then
		local light = ents.Create("env_sprite")
		light:SetParent(self)
		light:SetLocalPos(lightData[2])
		light:SetLocalAngles(lightData[3])
	
		-- Set parameters
		local brightness = lightData.brightness or 0.5
		light:SetKeyValue("rendercolor",
			Format("%i %i %i",
				lightData[4].r*brightness,
				lightData[4].g*brightness,
				lightData[4].b*brightness
			)
		)
		light:SetKeyValue("rendermode", lightData.type or 9) -- 9: WGlow, 3: Glow
--		light:SetKeyValue("model", "sprites/glow1.vmt")
		light:SetKeyValue("model", lightData.texture or "sprites/light_glow02.vmt")
--		light:SetKeyValue("model", "sprites/yellowflare.vmt")
		light:SetKeyValue("scale", lightData.scale or 1.0)
		light:SetKeyValue("spawnflags", 1)
	
		-- Turn light on
		light:Spawn()
		self.GlowingLights[index] = light
	end
	if (lightData[1] == "dynamiclight") and (power) then
		local light = ents.Create("light_dynamic")
		light:SetParent(self)

		-- Set position
		light:SetLocalPos(lightData[2])
		light:SetLocalAngles(lightData[3])

		-- Set parameters
		light:SetKeyValue("_light",
			Format("%i %i %i",
				lightData[4].r,
				lightData[4].g,
				lightData[4].b
			)
		)
		light:SetKeyValue("style", 0)
		light:SetKeyValue("distance", lightData.distance or 300)
		light:SetKeyValue("brightness", lightData.brightness or 2)

		-- Turn light on
		light:Spawn()
		light:Fire("TurnOn","","0")
		self.GlowingLights[index] = light
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

function ENT:PlayOnce(soundid,location,range,pitch)
	if self:CheckActionTimeout(soundid,self.SoundTimeout[soundid] or 0.0) then return end

	-- Pick wav file
	local sound = self.SoundNames[soundid]
	if type(sound) == "table" then sound = table.Random(sound) end

	-- Setup range
	local default_range = 0.80
	if soundid == "switch" then default_range = 0.50 end

	-- Emit sound from right location
	if not location then
		self:EmitSound(sound, 100*(range or default_range), pitch or math.random(95,105))
	elseif (location == true) or (location == "cabin") then
		if self.DriverSeat and self.DriverSeat:IsValid() then
			self.DriverSeat:EmitSound(sound, 100*(range or default_range),pitch or math.random(95,105))
		end
	end
end

--------------------------------------------------------------------------------
-- Joystick input
--------------------------------------------------------------------------------
function ENT:HandleJoystickInput(ply)
	for k,v in pairs(jcon.binds) do
		if v:GetCategory() == "Metrostroi" then
			local jvalue = Metrostroi.GetJoystickInput(ply,k)
			if (jvalue != nil) and (self.JoystickBuffer[k] ~= jvalue) then
				local inputname = Metrostroi.JoystickSystemMap[k]
				self.JoystickBuffer[k] = jvalue
				if inputname then
					if type(jvalue) == "boolean" then
						if jvalue then
							jvalue = 1.0
						else
							jvalue = 0.0
						end
					end
					self:TriggerInput(inputname,jvalue)
				end
			end
		end
	end
end
--------------------------------------------------------------------------------
-- Keyboard input
--------------------------------------------------------------------------------

function ENT:IsModifier(key)
	return type(self.KeyMap[key]) == "table"
end

function ENT:HasModifier(key)
	return self.KeyMods[key] ~= nil
end

function ENT:GetActiveModifiers(key)
	local tbl = {}
	local mods = self.KeyMods[key]
	for k,v in pairs(mods) do
		if self.KeyBuffer[k] ~= nil then
			table.insert(tbl,k)
		end
	end
	return tbl
end

function ENT:OnKeyEvent(key,state)
	if state then
		self:OnKeyPress(key)
	else
		self:OnKeyRelease(key)
	end
	
	
	if self:HasModifier(key) then
		--If we have a modifier
		local actmods = self:GetActiveModifiers(key)
		if #actmods > 0 then
			--Modifier is being preseed
			for k,v in pairs(actmods) do
				if self.KeyMap[v][key] ~= nil then
					self:ButtonEvent(self.KeyMap[v][key],state)
				end
			end
		elseif self.KeyMap[key] ~= nil then
			self:ButtonEvent(self.KeyMap[key],state)
		end
		
	elseif self:IsModifier(key) and not state then
		--Release modified keys
		for k,v in pairs(self.KeyMap[key]) do
			self:ButtonEvent(v,false)
		end
		
	elseif self.KeyMap[key] ~= nil and type(self.KeyMap[key]) == "string" then
		--If we're a regular binded key
		self:ButtonEvent(self.KeyMap[key],state)
	end
end

function ENT:OnKeyPress(key)

end

function ENT:OnKeyRelease(key)

end

function ENT:ProcessKeyMap()
	self.KeyMods = {}

	for mod,v in pairs(self.KeyMap) do
		if type(v) == "table" then
			for k,_ in pairs(v) do
				if not self.KeyMods[k] then
					self.KeyMods[k]={}
				end
				self.KeyMods[k][mod]=true
			end
		end
	end
end

function ENT:HandleKeyboardInput(ply)
	if not self.KeyMods and self.KeyMap then
		self:ProcessKeyMap()
	end
	
	-- Check for newly pressed keys
	for k,v in pairs(ply.keystate) do
		if self.KeyBuffer[k] == nil then
			self.KeyBuffer[k] = true
			self:OnKeyEvent(k,true)
		end
	end
	
	-- Check for newly released keys
	for k,v in pairs(self.KeyBuffer) do
		if ply.keystate[k] == nil then
			self.KeyBuffer[k] = nil
			self:OnKeyEvent(k,false)
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
			
			if self.KeyMap then
				self:HandleKeyboardInput(ply)
			end
			
			-- Joystick
			if joystick then
				self:HandleJoystickInput(ply)
				
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
	
	-- Add interesting debug variables
	self.DebugVars["TW1 X1"] = self:ReadTrainWire(1)
	self.DebugVars["TW2 X2"] = self:ReadTrainWire(3)
	self.DebugVars["TW3 X3"] = self:ReadTrainWire(2)
	self.DebugVars["TW4 FWD"] = self:ReadTrainWire(4)
	self.DebugVars["TW5 BWD"] = self:ReadTrainWire(5)
	self.DebugVars["TW6 T"] = self:ReadTrainWire(6)
	self.DebugVars["TW20 1S"] = self:ReadTrainWire(20)

	self:NextThink(CurTime())
	return true
end




--------------------------------------------------------------------------------
-- Default spawn function
--------------------------------------------------------------------------------
function ENT:SpawnFunction(ply, tr)
	local verticaloffset = 5 -- Offset for the train model
	local distancecap = 2000 -- When to ignore hitpos and spawn at set distanace
	local pos, ang = nil
	local inhibitrerail = false
	
	--TODO: Make this work better for raw base ent
	
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
	ent.Owner = ply
	ent:Spawn()
	ent:Activate()
	
	
	if not inhibitrerail then Metrostroi.RerailTrain(ent) end
	
	-- Debug mode
	--Metrostroi.DebugTrain(ent,ply)
	return ent
end




--------------------------------------------------------------------------------
-- Process Cabin button and keyboard input
--------------------------------------------------------------------------------
function ENT:OnButtonPress(button)
--	print("Pressed", button)
end

function ENT:OnButtonRelease(button)
--	print("Released",button)
end

-- Clears the serverside keybuffer and fires events
function ENT:ClearKeyBuffer()
	for k,v in pairs(self.KeyBuffer) do
		local button = self.KeyMap[k]
		if button ~= nil then
			if type(button) == "string" then
				self:ButtonEvent(button,false)
			else
				--Check modifiers as well
				for k2,v2 in pairs(button) do
					self:ButtonEvent(v2,false)
				end
			end
		end
	end
	self.KeyBuffer = {}
end

-- Checks a button with the buffer and calls 
-- OnButtonPress/Release as well as TriggerInput
function ENT:ButtonEvent(button,state)
	if self.ButtonBuffer[button] ~= state then
		self.ButtonBuffer[button] = state
		
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
	Metrostroi.RegisterJoystickInput("met_pneubrake",true,"Pneumatic Brake",1,5)
	Metrostroi.RegisterJoystickInput("met_headlight",false,"Headlight Toggle")
	
--	Metrostroi.RegisterJoystickInput("met_reverserup",false,"Reverser Up")
--	Metrostroi.RegisterJoystickInput("met_reverserdown",false,"Reverser Down")
--	Will make this somewhat better later
--	Uncommenting these somehow makes the joystick addon crap itself

	Metrostroi.JoystickSystemMap["met_controller"] = "KVControllerSet"
	Metrostroi.JoystickSystemMap["met_reverser"] = "KVReverserSet"
	Metrostroi.JoystickSystemMap["met_pneubrake"] = "PneumaticBrakeSet"
	Metrostroi.JoystickSystemMap["met_headlight"] = "HeadLightsToggle"
--	Metrostroi.JoystickSystemMap["met_reverserup"] = "KVReverserUp"
--	Metrostroi.JoystickSystemMap["met_reverserdown"] = "KVReverserDown"
end

hook.Add("JoystickInitialize","metroistroi_cabin",JoystickRegister)

hook.Add("PlayerLeaveVehicle", "gmod_subway_81-717-cabin-exit", HandleExitingPlayer )
hook.Add("CanPlayerEnterVehicle","gmod_subway_81-717-cabin-entry", CanPlayerEnter )


