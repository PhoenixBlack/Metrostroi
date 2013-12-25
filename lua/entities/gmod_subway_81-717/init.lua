AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")


--------------------------------------------------------------------------------
local CLASS_PREFIX = "gmod_subway"
ENT.WireDebugName = "81-717"




--------------------------------------------------------------------------------
function ENT:Initialize()
  self.IsSubwayTrain = true
  
  self:SetModel("models/myproject/81-717_engine_hull.mdl")
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:SetSolid(SOLID_VPHYSICS)

  if Wire_CreateInputs then
    self.Inputs = Wire_CreateInputs(self,{
      "NextMode", "PreviousMode", "ToggleReverse",
      "ToggleLeftDoors", "ToggleRightDoors",
      "ToggleHeadLight", "ToggleInteriorLight",
      "DisableDeadmansSwitch",
      "Horn",
      "SetMode", "SetReverse",
      "SelectAlternateTrack", "SelectMainTrack",
      "PlayAnnouncement", "QueueAnnouncement" })

    self.Outputs = Wire_CreateOutputs(self, {
      "Speed", "Mode", "Reverse",
      "CurrentPath", "CurrentOffset",
      "ARSSpeed",
      "NextLightYellow", "NextLightRed",
      "DistanceToLight",
      "AlternateTrack", "SelectingAlternate", "TrackSwitchBlocked",
      "Announcement" } )
  end
  
  -- Setup initial position
  self:SetPos(self:GetPos() + Vector(0,0,170))
  self:GetPhysicsObject():SetMass(29000)
  
  -- Define sounds
  self.SoundNames = {}
  self.SoundNames["bpsn"]          = "subway_trains/81717_bpsn.wav"
  self.SoundNames["brake"]         = "subway_trains/81717_brake.wav"
  self.SoundNames["brake_hard"]    = "subway_trains/81717_brake_hard.wav"
  self.SoundNames["compressor"]    = "subway_trains/81717_compressor.wav"
  self.SoundNames["engine"]        = "subway_trains/81717_engine.wav"
  self.SoundNames["horn"]          = "subway_trains/81717_horn.wav"
  self.SoundNames["release_slow"]  = "subway_trains/81717_release_slow.wav"
  self.SoundNames["run1"]          = "subway_trains/81717_run1.wav"
  self.SoundNames["run2"]          = "subway_trains/81717_run2.wav"
  self.SoundNames["run3"]          = "subway_trains/81717_run3.wav"
  self.SoundNames["start"]         = "subway_trains/81717_start.wav"
  self.SoundNames["start_reverse"] = "subway_trains/81717_start_reverse.wav"
  self.SoundNames["switch"]        = "subway_trains/81717_switch.wav"
  self.SoundNames["kv1"]           = "subway_trains/81717_kv1.wav"
  self.SoundNames["kv2"]           = "subway_trains/81717_kv2.wav"
  self.SoundNames["kv3"]           = "subway_trains/81717_kv3.wav"
  self.SoundNames["kv4"]           = "subway_trains/81717_kv4.wav"
  self.SoundNames["warning"]       = "subway_trains/81717_warning.wav"
  self.SoundNames["door_open"]     = "subway_trains/81717_door_open.wav"
  self.SoundNames["door_close"]    = "subway_trains/81717_door_close.wav"
  
  self.SoundTimeout = {}
--  self.SoundTimeout["switch"]        = 0.1
  self.SoundTimeout["start_reverse"] = 3.0
  self.SoundTimeout["start"]         = 1.0
  self.SoundTimeout["warning"]       = 2.5
  
  self.NeedSound = {}
  self.NeedSound["bpsn"] = true
  self.NeedSound["run1"] = true
  self.NeedSound["run2"] = true
  self.NeedSound["run3"] = true
  self.NeedSound["engine"] = true
  --self.NeedSound["horn"] = true
  
  -- Load sounds
  self.Sounds = {}
  for k,v in pairs(self.SoundNames) do
    util.PrecacheSound(v)
    if self.NeedSound[k] then
      self.Sounds[k] = CreateSound(self, Sound(v))
    end
  end

  -- Lists of wheels and objects
  self.TrainEnts = {}
  self.Doors = {}
  self.AllDoors = {}
  self.Wheels = {}
  self.Seats = {}
  self.SeatNPCOccupied = {}
  self.SeatNPCOccupied[0] = {}
  self.SeatNPCOccupied[1] = {}
  
  -- Create bogeys
  self.FrontBogey = self:CreateBogey(Vector(-315,0,-70),true)
  self.RearBogey  = self:CreateBogey(Vector(315,0,-70),false)
  
  -- Create doors
  for i=0,3 do
    self:CreateDoor(i,0,0,"passenger")
    self:CreateDoor(i,1,0,"passenger")
    self:CreateDoor(i,0,1,"passenger")
    self:CreateDoor(i,1,1,"passenger")
  end
  if not self.PassengerWagon then
    self:CreateDoor(-1,nil,nil,"cab")
--  else
--    self:CreateDoor(-2,nil,nil,"cab")
  end
--  self:CreateDoor(-3,nil,nil,"cab")
  
  -- Create seats
  if not self.PassengerWagon then
                      self:CreateSeat(0,-1,"driver")
    self.DriverSeat = self:CreateSeat(0, 0,"driver")
                      self:CreateSeat(0, 1,"driver")
  end
  for i = 1,14,4 do
    self:CreateSeat(i,0,"passenger")
    self:CreateSeat(i,1,"passenger")
  end
  
  -- Create horn sound from drivers seat
  if self.DriverSeat then
    self.Sounds["horn"] = CreateSound(self.DriverSeat, Sound(self.SoundNames["horn"]))
  end
  
  -- Announcer system
  self.Announcer = Metrostroi.Systems.Announcer(self)
  
  -- Create train state
  self.DoorState = {}
  self.DoorState[0] = false
  self.DoorState[1] = false
  self.LightState = {}
  self.LightState[0] = false
  self.LightState[1] = false
  self.DoorPosition = {}
  self.Reverse = false
  self.Mode = 0
  self.DriverMode = 0
  self.Horn = false
  self.DisableDeadmansSwitch = false

  self.MasterTrain = nil
  self.Inverted = false
  
  -- Setup initial state
  self:SetDriverMode(0)
  self:SetReverse(false)
  self:SetDoors(0,false)
  self:SetDoors(1,false)
  
  -- Setup drivers controls
  self.KeyBuffer = {}
  self.KeyMap = {
	[KEY_ENTER] = 1,
	[KEY_INSERT] = 2,
	[KEY_W] = 3
  }
  self.LastPressedKey = {}
  self.AltLastPressedKey = {}
  self.KeyFunction = {}
  self.ReleaseFunction = {}
  self.KeyFunction[IN_FORWARD]   = function() self:TriggerInput("NextMode",1.0) end
  self.KeyFunction[IN_BACK]      = function() self:TriggerInput("PreviousMode",1.0) end
  self.KeyFunction[IN_RELOAD]    = function() self:TriggerInput("ToggleReverse",1.0) end
  self.KeyFunction[IN_MOVELEFT]  = function() self:TriggerInput("ToggleLeftDoors",1.0) end
  self.KeyFunction[IN_MOVERIGHT] = function() self:TriggerInput("ToggleRightDoors",1.0) end
  self.KeyFunction[IN_JUMP]      = function() self:TriggerInput("SetMode",1.0) end
  self.KeyFunction[IN_ATTACK]    = function() self:TriggerInput("ToggleHeadLight",1.0) end
  self.KeyFunction[IN_ATTACK2]   = function() self:TriggerInput("ToggleInteriorLight",1.0) end
--  self.ReleaseFunction[IN_SPEED] = function() self:TriggerInput("Horn",0.0) end
  
  -- Alternate functions IN_SPEED
  self.AltKeyFunction = {}
  self.AltReleaseFunction = {}
  self.AltKeyFunction[IN_FORWARD]       = function() self:TriggerInput("Horn",1.0) end
  self.AltReleaseFunction[IN_FORWARD]   = function() self:TriggerInput("Horn",0.0) end
  self.AltKeyFunction[IN_MOVELEFT]      = function() self:TriggerInput("SelectAlternateTrack",1.0) end
--  self.AltReleaseFunction[IN_MOVELEFT]  = function() self:TriggerInput("SelectAlternateTrack",0.0) end
  self.AltKeyFunction[IN_MOVERIGHT]     = function() self:TriggerInput("SelectMainTrack",1.0) end
--  self.AltReleaseFunction[IN_MOVERIGHT] = function() self:TriggerInput("SelectMainTrack",0.0) end
  
  -- Setup controller settings
  if not self.MotorSettings then
    self.MotorSettings = {}
    --                        Power  Speed
    self.MotorSettings[3] = { -1.00, 20  } -- T2
    self.MotorSettings[4] = { -0.50, 40  } -- T1A
    self.MotorSettings[5] = { -0.22, 90  } -- T1
    self.MotorSettings[7] = {  0.20, 25  } -- X1
    self.MotorSettings[8] = {  0.45, 40  } -- X2
    self.MotorSettings[9] = {  0.60, 90  } -- X3
  end
  
  -- Assign train ID
  self.WagonID = Metrostroi.NextWagonID()
  self.TrainID = 0
end


function ENT:OnRemove()
  constraint.RemoveAll(self)
  for k,v in pairs(self.TrainEnts) do
    SafeRemoveEntity(v)
  end
  for k,v in pairs(self.Sounds) do
    v:Stop()
  end
end




--------------------------------------------------------------------------------
-- Returns useable passenger door
--------------------------------------------------------------------------------
function ENT:GetPassengerDoor(pos)
  local door = nil
  if pos then -- Find door closest to position
    local dist = 1e99
    for i=0,3 do
      for side=1,2 do
        local doorPos = self:GetDoorPosition(i,side-1)
        if doorPos then
          local worldPos = self:LocalToWorld(doorPos)

          -- Check if it's the closest door
          if (worldPos - pos):Length() < dist then
            door = doorPos
            dist = (worldPos - pos):Length()
          end
        end
      end
    end
  end
  
  -- Return position of door
  return door
end


--------------------------------------------------------------------------------
-- Returns closest useable passenger seat (that's not occupied by anybody)
--------------------------------------------------------------------------------
function ENT:GetPassengerSeat(pos)
  local seat = nil
  local ang = nil
  local si,sside
  if pos then -- Find non-occupied seat closest to position
    local dist = 1e99
    for i=1,14 do
      for side=1,2 do
        local seatPos,seatAng = self:GetSeatPosition(i,side-1)
        local worldPos = self:LocalToWorld(seatPos)
        local occupied = false
        
        -- Check if occupied
        occupied = occupied or self:GetSeatOccupied(i,side-1)

        -- Check if it's the closest seat
        if (not occupied) and ((worldPos - pos):Length() < dist) then
          seat = seatPos
          ang = seatAng
          si = i
          sside = side-1
          dist = (worldPos - pos):Length()
        end
      end
    end
  end

  -- Return position of seat and data about it
  return seat,ang,si,sside
end


--------------------------------------------------------------------------------
-- Get position of seat (used by NPCs)
--------------------------------------------------------------------------------
function ENT:GetSeatPosition(i,side)
  local j = i-1
  return Vector(-273+((j%4)*32)+math.floor(j/4)*225, (2*side-1)*35.0, -5.0),
         Angle(0,180*side,0)
end


--------------------------------------------------------------------------------
-- Get position of door (used by NPCs)
--------------------------------------------------------------------------------
function ENT:GetDoorPosition(i,side)
  if self.DoorState[side] == true then
    return Vector(-355+i*227-0.5*33.8, -64+128*side, 11.5)
  else
    return nil -- Door closed
  end
end


--------------------------------------------------------------------------------
-- Return position of the cockpit
--------------------------------------------------------------------------------
function ENT:GetCockpitPos()
  if self.PassengerWagon then
    return false -- No cockpit
  else
    return self:LocalToWorld(self.DriverSeat:GetPos())--Vector(-455,-10,7))
  end
end


--------------------------------------------------------------------------------
-- Get if seat is occupied
--------------------------------------------------------------------------------
function ENT:GetSeatOccupied(i,side)
  return (self.SeatNPCOccupied[side][i] == true)
end


--------------------------------------------------------------------------------
-- Set seat occupied
--------------------------------------------------------------------------------
function ENT:SetSeatOccupied(i,side,value)
  self.SeatNPCOccupied[side][i] = value
end




--------------------------------------------------------------------------------
-- Create seat object
--------------------------------------------------------------------------------
function ENT:CreateSeat(i,side,type)
  local seat = ents.Create("prop_vehicle_prisoner_pod")
  seat:SetModel("models/props_phx/carseat3.mdl")

  if i == 0 then
    seat:SetPos(self:LocalToWorld(Vector(-420, 0 - side*35.0, 0.0)))
    seat:SetAngles(self:GetAngles() + Angle(0,90,0))
  else
    local j = i - 1
    seat:SetPos(self:LocalToWorld(self:GetSeatPosition(i,side)))
    seat:SetAngles(self:GetAngles() + Angle(0,180*side,0))
    seat:SetColor(Color(0,0,0,0))
    seat:SetRenderMode(RENDERMODE_TRANSALPHA)
  end
  seat:Spawn()
  seat:GetPhysicsObject():SetMass(10)
  seat:SetCollisionGroup(COLLISION_GROUP_WORLD)
  table.insert(self.TrainEnts,seat)
  table.insert(self.Seats,seat)

  seat:SetNWEntity("TrainEntity", self)
  seat:SetNWEntity("SeatIndex", i)
  seat:SetNWEntity("SeatSide", side)
  seat:SetNWString("SeatType", type)

  -- Constrain seat to this object
--  constraint.NoCollide(self,seat,0,0)
  seat:SetParent(self)
  return seat
end


--------------------------------------------------------------------------------
-- Create door object
--------------------------------------------------------------------------------
function ENT:CreateDoor(i,pair,side,type)
  local door = ents.Create("prop_physics")
  if i == -1 then
    door:SetModel("models/myproject/81-717_door_cab.mdl")
    door:SetPos(self:LocalToWorld(Vector(-428.5,-64,11)))
    door:SetAngles(self:GetAngles() + Angle(0,180,0))
--  elseif i < -1 then
--    local j = (-2-i)
--    door:SetModel("models/myproject/81-717_door_cab.mdl")
--    door:SetPos(self:LocalToWorld(Vector(462,0,11)))
--    door:SetAngles(self:GetAngles() + Angle(0,90,0))
  else
    door:SetModel("models/myproject/81-717_door_passenger.mdl")
    door:SetPos(Vector(0,0,0))
    if pair == 0
    then door:SetAngles(self:GetAngles())
    else door:SetAngles(self:GetAngles() + Angle(0,180,0))
    end
  end
  door:Spawn()
  door:GetPhysicsObject():SetMass(10)
  door:SetCollisionGroup(COLLISION_GROUP_WORLD)
  table.insert(self.TrainEnts,door)
  table.insert(self.AllDoors,door)

  door:SetNWEntity("TrainEntity", self)
  door:SetNWEntity("DoorIndex", i)
  door:SetNWEntity("DoorPair", pair)
  door:SetNWEntity("DoorSide", side)
  door:SetNWString("DoorType", type)

  -- Remember doors for later animation
  if i >= 0 then
    self.Doors[side] = self.Doors[side] or {}
    self.Doors[side][pair] = self.Doors[side][pair] or {}
    self.Doors[side][pair][i] = door
  end

  -- Constrain door to this object
--  constraint.NoCollide(self,door,0,0)
  door:SetParent(self)
end


--------------------------------------------------------------------------------
-- Create train bogey
--------------------------------------------------------------------------------
function ENT:CreateBogey(pos,forward)
  local modelOffset = Vector(0,0,3)
  local wheel1Offset = Vector(52,45.5,-12)
  local wheel2Offset = Vector(-52,45.5,-12)

  local ang = Angle(0,0,0)
  if not forward then ang = Angle(0,180,0) end

  -- Create bogey itself
  local bogey = ents.Create("prop_physics")
  bogey:SetModel("models/myproject/81-717_bogey.mdl")
  bogey:SetPos(self:LocalToWorld(pos + modelOffset))
  bogey:SetAngles(self:GetAngles() + ang)
  bogey:Spawn()
  bogey:GetPhysicsObject():SetMass(5000)

  bogey:SetNWBool("IsForwardBogey", forward)
  bogey:SetNWEntity("TrainEntity", self)

  -- Constraint bogey to the train
  constraint.Axis(bogey,self,0,0,
    Vector(0,0,10),Vector(0,0,0),
    0,0,0,1,Vector(0,0,1),false)

  -- Create wheels
--  local wheel1 = ents.Create("gmod_subway_wheels")
--  wheel1:SetPos(bogey:LocalToWorld(wheel1Offset))
--  wheel1:SetAngles(bogey:GetAngles() + Angle(0,0,90))
--  wheel1:Spawn()
--  wheel1:GetPhysicsObject():SetMass(1000)

--  local wheel2 = ents.Create("gmod_subway_wheels")
--  wheel2:SetPos(bogey:LocalToWorld(wheel2Offset))
--  wheel2:SetAngles(bogey:GetAngles() + Angle(0,0,90))
--  wheel2:Spawn()
--  wheel2:GetPhysicsObject():SetMass(1000)

  local wheels = ents.Create("gmod_subway_wheels")
  wheels:SetPos(bogey:LocalToWorld(Vector(0,0.0,-14)))
  wheels:SetAngles(bogey:GetAngles() + Angle(0,90,0))
  wheels:Spawn()
--  wheels:GetPhysicsObject():SetMass(2000)

  -- Nocollide wheels from the chassis
  constraint.NoCollide(wheels,self,0,0)
  constraint.Weld(wheels,bogey,0,0,0,1,0)

--  constraint.NoCollide(wheel1,self,0,0)
--  constraint.NoCollide(wheel2,self,0,0)
--  constraint.Weld(wheel1,bogey,0,0,0,1,0)
--  constraint.Weld(wheel2,bogey,0,0,0,1,0)

  -- Add to cleanup list
  table.insert(self.TrainEnts,bogey)
  table.insert(self.TrainEnts,wheels)
  table.insert(self.Wheels,wheels)
--  table.insert(self.TrainEnts,wheel1)
--  table.insert(self.TrainEnts,wheel2)
--  table.insert(self.Wheels,wheel1)
--  table.insert(self.Wheels,wheel2)

  return bogey
end




--------------------------------------------------------------------------------
-- Check timeout of the action
--------------------------------------------------------------------------------
function ENT:CheckActionTimeout(action,timeout)
  self.LastActionTime = self.LastActionTime or {}
  self.LastActionTime[action] = self.LastActionTime[action] or (CurTime()-1000)
  if CurTime() - self.LastActionTime[action] < timeout then return true end
  self.LastActionTime[action] = CurTime()
  
  return false
end


--------------------------------------------------------------------------------
-- Play a single sound
--------------------------------------------------------------------------------
function ENT:PlayOnce(soundid,inCockpit,range,pitch)
  self.SoundTimeout["switch"]        = 0.0
  self.SoundTimeout["warning"]       = 2.5
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
  
--    sound.Play(self.SoundNames[soundid],pos or self:GetPos(),75,pitch or 100,volume or default_volume)
--  end
end


--------------------------------------------------------------------------------
-- Set full brakes active
--------------------------------------------------------------------------------
function ENT:SetFullBrakes(full_brakes)
  if not full_brakes then
    for k,v in pairs(self.Wheels) do
      if v and v:IsValid() and v:GetPhysicsObject():IsValid() then
        v:GetPhysicsObject():SetMaterial("gmod_ice")
      end
    end
  else
    for k,v in pairs(self.Wheels) do
      if v and v:IsValid() and v:GetPhysicsObject():IsValid() then
        v:GetPhysicsObject():SetMaterial("gmod_silent")
      end
    end
  end
end

function ENT:ReleaseBrakes()
  self:SetFullBrakes(false)
  self:PlayOnce("release_slow")
end


--------------------------------------------------------------------------------
-- Turn lights on or off
--------------------------------------------------------------------------------
function ENT:SetLightPower(index,power)
  if index == 0 then
    if self.PassengerWagon then return end
    if self.HeadLight then SafeRemoveEntity(self.HeadLight) end
    if self.HeadLightGlow then
      for k,v in pairs(self.HeadLightGlow) do
        SafeRemoveEntity(v)
      end
    end
    self.HeadLightGlow = {}
    
    if power then
      self.HeadLight = ents.Create("env_projectedtexture")
      self.HeadLight:SetParent(self)

      -- Set position
      self.HeadLight:SetLocalPos(Vector(-450, 0, 0))
      self.HeadLight:SetLocalAngles(Angle(0,180,0))

      -- Set parameters
      self.HeadLight:SetKeyValue("enableshadows", 1)
      self.HeadLight:SetKeyValue("farz", 2048)
      self.HeadLight:SetKeyValue("nearz", 16)
      self.HeadLight:SetKeyValue("lightfov", 120)

      -- Set Brightness
      local brightness = 1.25
      self.HeadLight:SetKeyValue("lightcolor",Format("%i %i %i 255",176*brightness,161*brightness,132*brightness))

      -- Turn light on
      self.HeadLight:Spawn() --"effects/flashlight/caustics")--
      self.HeadLight:Input("SpotlightTexture",nil,nil,"effects/flashlight001")
      
      -- Spawn headlight glow
      for i=1,6 do
        local light = ents.Create("env_sprite")
        light:SetParent(self)
    
        -- Set position
        local j = (i-1) % 2
        local k = math.floor((i-1)/2)
        if i < 5 then
          light:SetLocalPos(Vector(-463,j*10+k*88-49,-12))
        else
          light:SetLocalPos(Vector(-463,j*12-6,63))
        end
        light:SetLocalAngles(Angle(0,180,0))
    
        -- Set parameters
        local b = 0.5
        light:SetKeyValue("rendercolor",Format("%d %d %d",255*b,255*b,255*b))
        light:SetKeyValue("rendermode", 3) -- 9: WGlow, 3: Glow
        light:SetKeyValue("model", "sprites/glow1.vmt")
--      light:SetKeyValue("model", "sprites/light_glow02.vmt")
--      light:SetKeyValue("model", "sprites/yellowflare.vmt")
        light:SetKeyValue("scale", 1.0)
        light:SetKeyValue("spawnflags", 1)
    
        -- Turn light on
        light:Spawn()
        self.HeadLightGlow[light] = light
      end
    end
  elseif index == 2 then
    if self.PassengerWagon then return end
    if self.RedLightGlow then
      for k,v in pairs(self.RedLightGlow) do
        SafeRemoveEntity(v)
      end
    end
    self.RedLightGlow = {}

    if power then
      for i=1,2 do
        local light = ents.Create("env_sprite")
        light:SetParent(self)

        -- Set position
        local j = (i-1) % 2
        light:SetLocalPos(Vector(-463,j*90-45,63))
        light:SetLocalAngles(Angle(0,180,0))

        -- Set parameters
        light:SetKeyValue("rendercolor","255 0 0")
        light:SetKeyValue("rendermode", 9) -- 9: WGlow, 3: Glow
--        light:SetKeyValue("model", "sprites/glow1.vmt")
        light:SetKeyValue("model", "sprites/light_glow02.vmt")
--      light:SetKeyValue("model", "sprites/yellowflare.vmt")
        light:SetKeyValue("scale", 0.50)
        light:SetKeyValue("spawnflags", 1)

        -- Turn light on
        light:Spawn()
        self.RedLightGlow[light] = light
      end
    end
  elseif index == 1 then
    if self.InteriorLights then
      for k,v in pairs(self.InteriorLights) do
        SafeRemoveEntity(v)
      end
    end
    if power then
      self.InteriorLights = {}
      for i=0,2 do
        local light = ents.Create("light_dynamic")
        light:SetParent(self)

        -- Set position
        light:SetLocalPos(Vector(-250+i*250, 0, 60))
        light:SetLocalAngles(Angle(0,180,0))

        -- Set parameters
        light:SetKeyValue("_light","255 255 200 255")
        light:SetKeyValue("style", 0)
        light:SetKeyValue("distance", 300)
        light:SetKeyValue("brightness", 2)

        -- Turn light on
        light:Spawn()
        light:Fire("TurnOn","","0")
        table.insert(self.InteriorLights,light)
      end
    end
  elseif index >= 3 then
    self.SpecialLights = self.SpecialLights or {}

    if power and (not self.SpecialLights[index]) then
      self.SpecialLights[index] = {}
      for i=1,2 do
        local light = ents.Create("env_sprite")
        light:SetParent(self)

        -- Set position
        local j = (i-1) % 2
        if self.PassengerWagon
        then light:SetLocalPos(Vector(45-j*89.5,j*67.5*2-67.5,61-(index-3)*3.5))
        else light:SetLocalPos(Vector(47-j*89.5,j*67.5*2-67.5,61-(index-3)*3.5))
        end
        light:SetLocalAngles(Angle(0,180,0))

        -- Set parameters
        if index == 3 then light:SetKeyValue("rendercolor","255 200 0") end
        if index == 4 then light:SetKeyValue("rendercolor","0 255 0") end
        if index == 5 then light:SetKeyValue("rendercolor","255 255 255") end
        
        light:SetKeyValue("rendermode", 9) -- 9: WGlow, 3: Glow
        light:SetKeyValue("model", "sprites/light_glow02.vmt")
        light:SetKeyValue("scale", 0.09)
        light:SetKeyValue("spawnflags", 1)

        -- Turn light on
        light:Spawn()
        self.SpecialLights[index][light] = light
      end
    elseif (not power) and self.SpecialLights[index] then
      for k,v in pairs(self.SpecialLights[index]) do
        SafeRemoveEntity(v)
      end
      self.SpecialLights[index] = nil
    end
  end
end




--------------------------------------------------------------------------------
-- Is this bogey inverted in relation to the other bogey
--------------------------------------------------------------------------------
function ENT:GetInverted(thisBogey,thatBogey)
  local thisTrain = thisBogey:GetNWEntity("TrainEntity")
  local thatTrain = thatBogey:GetNWEntity("TrainEntity")

  -- Invert controls if connected by same side bogies
  if thisBogey:GetNWEntity("IsForwardBogey") == thatBogey:GetNWEntity("IsForwardBogey") then
    return true
  end
  return false
end


--------------------------------------------------------------------------------
-- Set control for this train
--------------------------------------------------------------------------------
function ENT:SetControlForTrain(masterTrain,inverted,traversedTrains)
  -- Do not stack overflow
  if not traversedTrains then
    traversedTrains = {}
  end
  
  -- Stop recursion at trains already processed
  if traversedTrains[self] then return end
  traversedTrains[self] = true

  -- Detect connected train (rear bogey)
  local constraints = constraint.GetTable(self.RearBogey)
  for k,v in pairs(constraints) do
    local train1 = v.Ent1:GetNWEntity("TrainEntity")
    local train2 = v.Ent2:GetNWEntity("TrainEntity")

    if (v.Ent1 == self.RearBogey) and (train2) and (train2 ~= self) and
       (train2:IsValid()) and (string.sub(train2:GetClass(),1,#CLASS_PREFIX) == CLASS_PREFIX) then
      if train2.DriverMode > 0 then
        train2.DriverMode = 0
      end
      
      local doInvert = inverted
      if self:GetInverted(v.Ent1,v.Ent2) then doInvert = not doInvert end
      train2:SetControlForTrain(masterTrain,doInvert,traversedTrains)
    elseif (v.Ent2 == self.RearBogey) and (train1) and (train1 ~= self) and
           (train1:IsValid()) and (string.sub(train1:GetClass(),1,#CLASS_PREFIX) == CLASS_PREFIX) then
      if train1.DriverMode > 0 then
        train1.DriverMode = 0
      end
      
      local doInvert = inverted
      if self:GetInverted(v.Ent2,v.Ent1) then doInvert = not doInvert end
      train1:SetControlForTrain(masterTrain,doInvert,traversedTrains)
    end
  end

  -- Detect connected train (front bogey). Only try one bogey
  local constraints = constraint.GetTable(self.FrontBogey)
  for k,v in pairs(constraints) do
    local train1 = v.Ent1:GetNWEntity("TrainEntity")
    local train2 = v.Ent2:GetNWEntity("TrainEntity")

    if (v.Ent1 == self.FrontBogey) and (train2) and (train2 ~= self) and
       (train2:IsValid()) and (string.sub(train2:GetClass(),1,#CLASS_PREFIX) == CLASS_PREFIX) then
      if train2.DriverMode > 0 then
        train2.DriverMode = 0
      end
      
      local doInvert = inverted
      if self:GetInverted(v.Ent1,v.Ent2) then doInvert = not doInvert end
      train2:SetControlForTrain(masterTrain,doInvert,traversedTrains)
    elseif (v.Ent2 == self.FrontBogey) and (train1) and (train1 ~= self) and
           (train1:IsValid()) and (string.sub(train1:GetClass(),1,#CLASS_PREFIX) == CLASS_PREFIX) then
      if train1.DriverMode > 0 then
        train1.DriverMode = 0
      end

      local doInvert = inverted
      if self:GetInverted(v.Ent2,v.Ent1) then doInvert = not doInvert end
      train1:SetControlForTrain(masterTrain,doInvert,traversedTrains)
    end
  end
  
  -- Set master train
  if masterTrain ~= self then
    self.MasterTrain = masterTrain
    self.Inverted = inverted
  else
    self.MasterTrain = nil
    self.Inverted = false
  end
end




--------------------------------------------------------------------------------
function ENT:SetLights(index,power)
  if self.LightState[index] == power then return end
  self.LightState[index] = power

  -- Play switch sound and turn on the power
  self:PlayOnce("switch",true)
  if self.Mode > 0 then
    self:SetLightPower(index,power)
  end
end

function ENT:SetDoors(side,open)
  if open == self.DoorState[side] then return end
  if self.Mode == 0 then return end
  if (self.Speed or 0) > 10 then return end
  
  self.DoorState[side] = open
  if open then
    self:PlayOnce("door_open",false,nil,200.0)
  else
    self:PlayOnce("door_close",false,nil,200.0)
  end
      
--  for i,v in pairs(self.Doors[side][0]) do
--    if v:IsValid() then
--      if open then
--        self:PlayOnce("door_open",v:GetPos(),200 + math.random()*80-40,1.0)
--      else
--        self:PlayOnce("door_close",v:GetPos(),200 + math.random()*80-40,1.0)
--      end
--    end
--  end
end


-- Set mode (actual mode train responds to)
function ENT:SetMode(mode,isSilent)
  -- Check if valid range of modes
  if mode == self.Mode then return end
  if mode > 9 then return end
  if mode < 0 then return end

  -- Almost always make a switch sound
  if isSilent ~= true then
    self:PlayOnce("switch",true)
  end

  local prevMode = self.Mode
  self.Mode = mode

  -- Train modes
  -- 0 Off
  -- 1 Pneumatic full (emergency brake)
  -- 2 Pneumatic half
  -- 3 Electric brake high
  -- 4 Electric brake medium
  -- 5 Electric brake low
  -- 6 Idle
  -- 7 Shunt
  -- 8 Series
  -- 9 Parallel

  -- Turn train on
  if (mode > 0) and (prevMode == 0) then
    for k,v in pairs(self.SoundNames) do
      if self.NeedSound[k] then
        self.Sounds[k] = CreateSound(self, Sound(v))
      end
    end

    self:PlayOnce("start",true)
    self:PlayOnce("kv3",true)

    self.Sounds["bpsn"]:Play()
    self.ARSSpeed = nil
    self.LastSwitchError = nil
    self.SelectAlternateTrack = nil
    self.OntoAlternateTrack = false
  end

  -- Turn train off
  if (mode == 0) then
    self.Power = false
    self.Sounds["bpsn"]:Stop()
    self:PlayOnce("kv1",true)
  end
  
  -- Turn lights off
  if mode == 0 then
    self:SetLightPower(0,false)
    self:SetLightPower(1,false)
    self:SetLightPower(2,false)
  end

  -- Turn lights on
  if (mode > 0) and (prevMode == 0) then
    self:SetLightPower(0,self.LightState[0])
    self:SetLightPower(1,self.LightState[1])
    self:SetLightPower(2,self.Reverse)
  end

  -- Set pneumatic brakes to full
  if (mode == 1) or ((mode == 0) and (prevMode > 1)) then
    self:SetFullBrakes(true)
    if (prevMode ~= 0) then
      self:PlayOnce("brake_hard",nil,0.77)
    end
  end

  -- Set pneumatic brakes to half
  if (mode == 2) then
    self:SetFullBrakes(false)
    if (prevMode > 2) then
      self:PlayOnce("brake",nil,0.77)
    else
      self:PlayOnce("kv1")
    end
  end

  -- Turned off pneumatic brakes
  if (mode > 2) and (prevMode <= 2) then
    self:SetFullBrakes(false)
    self:PlayOnce("release_slow")
  end

  -- Other modes
  -- ...
end


-- Set mode (as set by driver)
function ENT:SetDriverMode(mode,isSilent)
  -- Check if valid range of modes
  if mode == self.DriverMode then return end
  if mode > 9 then return end
  if mode < 0 then return end
  
  -- Get previous mode
  local prevMode = self.DriverMode
  
  -- Do the master train check
  if (mode > 0) and (prevMode == 0) then
    self:SetControlForTrain(self,false)
    self:PlayOnce("kv4")
  end
  if (mode == 0) then
    self:SetControlForTrain(nil,false)
  end

  -- Set mode in actual train
  self.DriverMode = mode
  self:SetMode(self.DriverMode,isSilent)
end


function ENT:SetReverse(reverse)
  if reverse == self.Reverse then return end
  if self.Mode == 0 then return end
  if self.Mode > 2 then return end

  self.ARSSpeed = nil
  self.SelectAlternateTrack = nil
  self.OntoAlternateTrack = false
  self.Reverse = reverse
  self:PlayOnce("kv3")
  self:PlayOnce("start_reverse",true)
  self:SetLightPower(2,self.Reverse)
end


function ENT:SetHorn(value)
  if value == self.Horn then return end
  if self.Mode == 0 then return end
  
  self.Horn = value
end







--------------------------------------------------------------------------------
function ENT:TriggerInput(iname, value)
  if iname == "NextMode" then
    if value > 0.0 then self:SetDriverMode(self.DriverMode+1) end
  elseif iname == "PreviousMode" then
    if value > 0.0 then self:SetDriverMode(self.DriverMode-1) end
  elseif iname == "ToggleReverse" then
    if (value > 0.0) and (self.DriverMode > 0) then self:SetReverse(not self.Reverse) end
  elseif iname == "ToggleLeftDoors" then
    if (value > 0.0) and (self.DriverMode > 0) then self:SetDoors(0,not self.DoorState[0]) end
  elseif iname == "ToggleRightDoors" then
    if (value > 0.0) and (self.DriverMode > 0) then self:SetDoors(1,not self.DoorState[1]) end
  elseif iname == "ToggleHeadLight" then
    if (value > 0.0) then self:SetLights(0,not self.LightState[0]) end
  elseif iname == "ToggleInteriorLight" then
    if (value > 0.0) and (self.DriverMode > 0) then self:SetLights(1,not self.LightState[1]) end
  elseif iname == "Horn" then
    if (value > 0.0) then self:SetHorn(true) else self:SetHorn(false) end
  elseif iname == "DisableDeadmansSwitch" then
    if value > 0.0
    then self.DisableDeadmansSwitch = true
    else self.DisableDeadmansSwitch = false
    end
  elseif iname == "SetMode" then
    self:SetDriverMode(math.floor(value))
  elseif iname == "SetReverse" then
    if self.MasterTrain ~= self then self:SetReverse(value > 0.5) end
  elseif iname == "SelectAlternateTrack" then
    if (value > 0.0) and (self.Mode > 0) then
      self.SelectAlternateTrack = true
      self.OntoAlternateTrack = false
    end
    
--    if self.Mode > 0 then
--      self.SelectingAlternateTrack = (value > 0.0)
--    end
  elseif iname == "SelectMainTrack" then
    if (value > 0.0) and (self.Mode > 0) then
      self.SelectAlternateTrack = false
    end
--    if self.Mode > 0 then
--      self.SelectingMainTrack = (value > 0.0)
--    end
    
--    if value > 0.0 then
--      local switch,err = Metrostroi.GetNextTrackSwitch(self)
--      if switch
--      then switch:SetTrackSwitchState(true)
--      else self:PlayOnce("warning",true)
--      end
--      self.LastSwitchError = err
--    end
--    end
  elseif iname == "PlayAnnouncement" then
    if self.Announcer and (self.Mode > 0) then
      self.Announcer:Play(math.floor(value))
    end
  elseif iname == "QueueAnnouncement" then
    if self.Announcer and (self.Mode > 0) then
      self.Announcer:Queue(math.floor(value))
    end
  end
end




--------------------------------------------------------------------------------
-- Process forces on a single bogey
--------------------------------------------------------------------------------
function ENT:ProcessBogey(bogey)
  -- Get bogey
  if not bogey:IsValid() then return end
  if not bogey:GetPhysicsObject():IsValid() then return end
  local forward = bogey:GetNWBool("IsForwardBogey")
  
  -- Get speed of bogey in km/h
  local localSpeed = -bogey:GetVelocity():Dot(bogey:GetAngles():Forward()) * 0.06858 --0.09144
  local absSpeed = math.abs(localSpeed)
  if not forward then localSpeed = -localSpeed end
  local sign = 1
  if localSpeed < 0 then sign = -1 end
  
  self.MotorSettings[3] = { -1.00, 20  } -- T2
  self.MotorSettings[4] = { -0.50, 40  } -- T1A
  self.MotorSettings[5] = { -0.25, 90  } -- T1
  self.MotorSettings[7] = {  0.30, 20  } -- X1
  self.MotorSettings[8] = {  0.45, 40  } -- X2
  self.MotorSettings[9] = {  0.60, 90  } -- X3
  
  -- Calculate motor power
  local motorPower = 0.0
  local totalPower = 0.0
  if self.Mode == 2 then -- Pneumatic brake (low)
    motorPower = -math.min(2.0,absSpeed/5)*sign
  elseif self.MotorSettings[self.Mode] then -- Any of the normal settings
    local limitSpeed = self.MotorSettings[self.Mode][2]
    local enginePower = self.MotorSettings[self.Mode][1]
    
    if enginePower > 0.0 then
      totalPower = 1.0 - math.max(0.0,math.min(0.95,(absSpeed-(limitSpeed-12))/20))
      motorPower = enginePower * totalPower
      
      if self.Reverse then motorPower = -motorPower end
      if self.DoorState[0] or self.DoorState[1] then motorPower = 0.0 end
    else
      totalPower = math.min(1.0,absSpeed/limitSpeed)
      motorPower = -math.min(-enginePower,totalPower)*sign
    end
  else
    motorPower = 0.0
  end
  
  -- Clamp
  if (self.Mode > 2) then
    motorPower = math.max(-1.0,motorPower)
    motorPower = math.min(1.0,motorPower)
  end
  
  -- Apply force and subtract friction
  local dt_scale = 66.6/(1/self.DeltaTime)
  local force = dt_scale*(48000*motorPower + 0*15000*math.min(0.7,0.5*absSpeed/50)*sign)
  
  if forward
  then bogey:GetPhysicsObject():ApplyForceCenter(-bogey:GetAngles():Forward()*force)
  else bogey:GetPhysicsObject():ApplyForceCenter(bogey:GetAngles():Forward()*force)
  end
  
  -- Return speed of one wheel
  return absSpeed,totalPower
end

//Do something with cabin button presses
//See cl_init buttonmap table
function ENT:OnButtonPress(button)
	print("Pressed", button)
end

function ENT:OnButtonRelease(button)
	print("Released",button)
end

function ENT:ClearKeyBuffer()
	for k,v in pairs(self.KeyBuffer) do
		local button = self.KeyMap[k]
		if button != nil then
			self:OnButtonRelease(button)
		end
	end
end

--------------------------------------------------------------------------------
-- Process train logic
--------------------------------------------------------------------------------
function ENT:Think()
  self.PrevTime = self.PrevTime or CurTime()
  self.DeltaTime = (CurTime() - self.PrevTime)
  self.PrevTime = CurTime()

  -- Compute user input
  if self.DriverSeat and self.DriverSeat:IsValid() and self.DriverSeat.GetPassenger then

    local player = self.DriverSeat:GetPassenger(0)
    if player and player:IsValid() then
		
		//Button input
		//Check for newly pressed keys
		for k,v in pairs(player.keystate) do
			if self.KeyBuffer[k] == nil then
				self.KeyBuffer[k] = true
				local button = self.KeyMap[k]
				if button != nil then
					self:OnButtonPress(button)
				end
			end
		end
		
		//Check for newly released keys
		for k,v in pairs(self.KeyBuffer) do
			if player.keystate[k] == nil then
				self.KeyBuffer[k] = nil
				local button = self.KeyMap[k]
				if button != nil then
					self:OnButtonRelease(button)
				end
			end
		end
	
      -- Main set of keys
      for k,v in pairs(self.KeyFunction) do
        if (not player:KeyDownLast(IN_SPEED)) and player:KeyDownLast(k) then
          if not self.LastPressedKey[k] then
            self.LastPressedKey[k] = true
            v()
          end
        else
          if self.LastPressedKey[k] then
            if self.ReleaseFunction[k] then
              self.ReleaseFunction[k]()
            end
          end
          self.LastPressedKey[k] = false
        end
      end
      
      -- Alternate set of keys
      for k,v in pairs(self.AltKeyFunction) do
        if player:KeyDownLast(IN_SPEED) and player:KeyDownLast(k) then
          if not self.AltLastPressedKey[k] then
            self.AltLastPressedKey[k] = true
            v()
          end
        else
          if self.AltLastPressedKey[k] then
            if self.AltReleaseFunction[k] then
              self.AltReleaseFunction[k]()
            end
          end
          self.AltLastPressedKey[k] = false
        end
      end
    else -- Dead mans switch
      if (self.DriverMode > 2) and (self.DisableDeadmansSwitch == false) then
        self:SetDriverMode(1)
      end
    end
  end


  -- Do some things once in a while
  self.OnceInAWhile = self.OnceInAWhile or CurTime()
  if CurTime() - self.OnceInAWhile > 5.0 then
    self.OnceInAWhile = CurTime()
    
    if self.Mode > 0 then
      for k,v in pairs(self.SoundNames) do
        --util.PrecacheSound(v)
        if self.NeedSound[k] then
          self.Sounds[k]:Stop()
          self.Sounds[k] = CreateSound(self, Sound(v))
        end
      end

      self.Sounds["bpsn"]:Play()
    else
      self.Sounds["bpsn"]:Stop()
    end
    
    if self.MasterTrain then
      local masterTrainFound = false
      local ents = constraint.GetAllConstrainedEntities(self)
      for k,v in pairs(ents) do
        if v == self.MasterTrain then
          masterTrainFound = true
        end
      end
      
      if not masterTrainFound then
        self:SetControlForTrain(nil,false)
      end
    end
  end


  -- Compute speed
  local speed1,power1 = self:ProcessBogey(self.FrontBogey)
  local speed2,power2 = self:ProcessBogey(self.RearBogey)
  local speed = ((speed1 or 0) + (speed2 or 0)) / 2
  local power = ((power1 or 0) + (power2 or 0)) / 2
  self.Speed = speed
  
  
  -- Update sound based on speed and motor status
  if (speed > 0.5) then
    -- Gather up noise from tunnel walls
    local tunnelNoise = 0.0
    for dir=0,1 do
      local trace = {
        start = self:GetPos(),
        endpos = self:GetPos() + (dir*2-1)*self:GetRight()*256,
        mask = -1,
        filter = { self },
      }
      for k,v in pairs(self.TrainEnts) do table.insert(trace.filter,v) end
      trace.start = self:GetPos()
      trace.mask = -1
    
      local result = util.TraceLine(trace)
      if result.Hit then
        tunnelNoise = tunnelNoise + 1*math.max(0,1.0 - result.Fraction)
      end
    end
    
--    print(tunnelNoise)

--    local tunnelNoise = 0.0
    self.Sounds["run1"]:Play()
    self.Sounds["run1"]:ChangeVolume(math.min(2.55,math.max(0,2.55*(1.0-0.0*tunnelNoise)*math.min(1,speed/20))),0)
    self.Sounds["run1"]:ChangePitch(math.min(255,50+100*(speed/30)),0)

    self.Sounds["run3"]:Play()
    self.Sounds["run3"]:ChangeVolume(math.min(2.55,math.max(0,2.55*tunnelNoise*math.min(1,speed/10))),0)
    self.Sounds["run3"]:ChangePitch(math.min(120,60+100*(speed/90)),0)
  else
    self.Sounds["run1"]:Stop()
    self.Sounds["run2"]:Stop()
    self.Sounds["run3"]:Stop()
  end

  if (speed > 0.01) then
    local modulation = math.max(0.5,math.abs(power))

    if (self.Mode >= 3) and (self.Mode ~= 6)
    then self.EngineVolume = (self.EngineVolume or 0)*0.95 + 0.05*modulation
    else self.EngineVolume = (self.EngineVolume or 0)*0.95 + 0.00
    end

    self.Sounds["engine"]:Play()
    self.Sounds["engine"]:ChangeVolume( self.EngineVolume*math.min(1.0,(0.6+2.55*math.min(1,speed/30))*math.max(1.0,speed/10)),0)
    self.Sounds["engine"]:ChangePitch(math.min(255,100*(0.3+1.5*speed/110)),0)
  else
   self.Sounds["engine"]:Stop()
  end
  
  
  -- Update horn sound
  if self.Sounds["horn"] then
    self.HornPlaying = self.HornPlaying or false
    if (self.Horn == true) and (self.HornPlaying == false) then
      -- Start horn
      self.Sounds["horn"]:Stop()
      
      if self.DriverSeat and self.DriverSeat:IsValid() then
        self.Sounds["horn"] = CreateSound(self.DriverSeat, Sound(self.SoundNames["horn"]))
      end

      self.Sounds["horn"]:Play()
      self.Sounds["horn"]:SetSoundLevel(90.0) --155.0)
      self.Sounds["horn"]:ChangeVolume(2.55,0)

      self.HornPlaying = true
    elseif (self.Horn == false) and (self.HornPlaying == true) then
      -- Fade horn out
      self.Sounds["horn"]:ChangeVolume(0.0,0.3)

      self.HornStopTime = CurTime() + 0.3
      self.HornPlaying = false
    elseif (self.Horn == false) and (self.HornPlaying == false) and
           ((self.HornStopTime or 0) < CurTime())  then
      -- Stop horn
      self.Sounds["horn"]:Stop()
    end
  end
  
  
  -- Get commands from master train
  if self.MasterTrain and (self.MasterTrain:IsValid()) and (self.DriverMode == 0) then
    self.TrainID = self.MasterTrain.WagonID
    self:SetMode(self.MasterTrain.Mode)
    if self.Inverted == false then
      self:SetDoors(0,self.MasterTrain.DoorState[0])
      self:SetDoors(1,self.MasterTrain.DoorState[1])
      self:SetReverse(self.MasterTrain.Reverse)
    else
      self:SetDoors(0,self.MasterTrain.DoorState[1])
      self:SetDoors(1,self.MasterTrain.DoorState[0])
      self:SetReverse(not self.MasterTrain.Reverse)
    end
    self:SetLights(1,self.MasterTrain.LightState[1])
  else
    self.TrainID = 0
    self:SetMode(self.DriverMode)
  end

  
  -- Update door position
  local prevPosition = {}
  prevPosition[0] = self.DoorPosition[0]
  prevPosition[1] = self.DoorPosition[1]
  
  self.DoorPosition = self.DoorPosition or {}
  if self.IsLastWagon then
    if self.DoorState[1] == true  then self.DoorPosition[0] = math.min(1,(self.DoorPosition[0] or 0) + 1.6*0.01) end
    if self.DoorState[1] == false then self.DoorPosition[0] = math.max(0,(self.DoorPosition[0] or 0) - 1.6*0.01) end
    if self.DoorState[0] == true  then self.DoorPosition[1] = math.min(1,(self.DoorPosition[1] or 0) + 1.6*0.01) end
    if self.DoorState[0] == false then self.DoorPosition[1] = math.max(0,(self.DoorPosition[1] or 0) - 1.6*0.01) end
  else
    if self.DoorState[0] == true  then self.DoorPosition[0] = math.min(1,(self.DoorPosition[0] or 0) + 1.6*0.01) end
    if self.DoorState[0] == false then self.DoorPosition[0] = math.max(0,(self.DoorPosition[0] or 0) - 1.6*0.01) end
    if self.DoorState[1] == true  then self.DoorPosition[1] = math.min(1,(self.DoorPosition[1] or 0) + 1.6*0.01) end
    if self.DoorState[1] == false then self.DoorPosition[1] = math.max(0,(self.DoorPosition[1] or 0) - 1.6*0.01) end
  end
  
  
  -- Move doors
  if (prevPosition[0] ~= self.DoorPosition[0]) or
     (prevPosition[1] ~= self.DoorPosition[1]) then
    for side,a in pairs(self.Doors) do
      for pair,b in pairs(a) do
        for i,v in pairs(b) do
          local doorPosition = self.DoorPosition[side]
          if v:IsValid() then
            local extra_offset = 0
            if self.PassengerWagon then extra_offset = -3.5 end
            v:SetPos(Vector(extra_offset-355+i*227+pair*33.8-doorPosition*31*(1-2*pair), -64+128*side, 11.5))
          end
        end
      end
    end
  end


  -- Check ARS signals
  self.ARSTimer = self.ARSTimer or CurTime()
  if (CurTime() - self.ARSTimer > 0.10) and (not self.PassengerWagon) and (self.Mode > 0) then
    self.ARSTimer = CurTime()

    local dist = 1e9
    local ents = ents.FindInSphere(self:GetPos(),256)
    for k,v in pairs(ents) do
      if v:GetClass() == "gmod_track_equipment" then
        local d = (self:GetPos() - v:GetPos()):Length()
        if (v:GetNWString("Graphic") == "speed_limit") and (d < dist) then
          dist = d
--          print("ARS",v:GetNWString("Value1"))
          if not self.ARSSpeed then
--            self:PlayOnce("warning",true)
          end
          self.ARSSpeed = tonumber(v:GetNWString("Value1"))
          self.ARSChangeTime = CurTime()
        end
      end
    end
    
    -- Get next track switch and get its state
    local switch = Metrostroi.GetNextTrackSwitch(self)
    if switch then
      self.AlternateTrack = switch:GetTrackSwitchState()
    else
      self.AlternateTrack = false
    end
    
    -- Execute logic
    if self.DriverMode > 0 then
      if (self.SelectAlternateTrack == true) and switch then
        self.TrackSwitchBlocked = not switch:SetTrackSwitchState(true,self)
      elseif (self.SelectAlternateTrack == false) and (self.AlternateTrack == true) and switch then
        self.TrackSwitchBlocked = not switch:SetTrackSwitchState(false,self)
      else
        self.TrackSwitchBlocked = false
      end
    else
      self.TrackSwitchBlocked = true
    end
    
    -- Auto-shutdown track switch logic thing
    if (self.SelectAlternateTrack == true) and (self.AlternateTrack == true) and
       (not self.OntoAlternateTrack) then
      self.OntoAlternateTrack = true
    end
    if (self.SelectAlternateTrack == true) and (self.AlternateTrack == false) and
       (self.OntoAlternateTrack == true) then
      self.OntoAlternateTrack = false
      self.SelectAlternateTrack = nil
    end
    if (self.SelectAlternateTrack == false) and (self.AlternateTrack == false) then
      self.SelectAlternateTrack = nil
      self.OntoAlternateTrack = false
    end
    
    -- Find next traffic light
    local train_pos =  Metrostroi.TrainPositions[self]
    if train_pos then
      local facing = train_pos.forward_facing
      if self.Reverse then facing = not facing end
      local foundIndex,foundType,foundEnt =
        Metrostroi.FindTrainOrLight(self,train_pos.position,train_pos.section,{},facing)
      if foundType == "light" then
        local lights = foundEnt.LightStates or {}
        self.NextLightRed = lights[1] or false
        self.NextLightYellow = lights[2] or false
        self.DistanceToLight = foundEnt:GetPos():Distance(self:GetPos())*0.01905
      elseif foundType == "train" then
        self.NextLightRed = true
        self.NextLightYellow = true
        self.DistanceToLight = 0.1
      else
        self.NextLightRed = false
        self.NextLightYellow = false
        self.DistanceToLight = -1
      end
      
      -- Red light run logic
      if (foundType == "light") and foundEnt and (self.DistanceToLight < 3) then
        if foundEnt.LightStates[1] == true then
          if (self.DriverMode > 2) and (self.Speed > 11) and (self.Reverse == false) then
            self:SetDriverMode(1)
            self:PlayOnce("warning",true)
          end
        end
      end
    else
      self.NextLightRed = false
      self.NextLightYellow = false
      self.DistanceToLight = -1
    end
  end
  
  
  -- Check ARS overspeed
--[[  if self.DisableDeadmansSwitch == false then
    if self.ARSSpeed and (speed > (self.ARSSpeed + 5)) and (self.DriverMode > 2) then
--      if self.ARSChangeTime and (CurTime() - self.ARSChangeTime < 3.0) then
--        print("WAIT",CurTime() - self.ARSChangeTime)
--      else
      self.ARSOverspeedTimer = self.ARSOverspeedTimer or CurTime()
      if CurTime() - self.ARSOverspeedTimer > 1.0 then
        self:PlayOnce("warning",true)
        if speed > self.ARSSpeed+15 then
          self:SetDriverMode(1)
        elseif speed > self.ARSSpeed+10 then
          self:SetDriverMode(2)
        else
          self:SetDriverMode(3)
        end
      end
    else
      self.ARSOverspeedTimer = nil
    end
  end]]--
  
  
  -- Update wire outputs
  if Wire_TriggerOutput then
    Wire_TriggerOutput(self, "Speed", speed)
    Wire_TriggerOutput(self, "Mode", self.Mode)
    if self.Reverse
    then Wire_TriggerOutput(self, "Reverse", 1.0)
    else Wire_TriggerOutput(self, "Reverse", 0.0)
    end
    Wire_TriggerOutput(self, "ARSSpeed", self.ARSSpeed or -1.0)
    if self.NextLightYellow == true
    then Wire_TriggerOutput(self, "NextLightYellow", 1.0)
    else Wire_TriggerOutput(self, "NextLightYellow", 0.0)
    end
    if self.NextLightRed == true
    then Wire_TriggerOutput(self, "NextLightRed", 1.0)
    else Wire_TriggerOutput(self, "NextLightRed", 0.0)
    end
    Wire_TriggerOutput(self, "DistanceToLight", self.DistanceToLight)
    
    if Metrostroi.TrainPositions and Metrostroi.TrainPositions[self] then
      local train_pos = Metrostroi.TrainPositions[self]
      Wire_TriggerOutput(self, "CurrentOffset", train_pos.position)
      Wire_TriggerOutput(self, "CurrentPath", train_pos.path)
    else
      Wire_TriggerOutput(self, "CurrentOffset", 0)
      Wire_TriggerOutput(self, "CurrentPath", -1)
    end
    
    
    if self.AlternateTrack == true
    then Wire_TriggerOutput(self, "AlternateTrack", 1.0)
    else Wire_TriggerOutput(self, "AlternateTrack", 0.0)
    end
    if self.TrackSwitchBlocked == true
    then Wire_TriggerOutput(self, "TrackSwitchBlocked", 1.0)
    else Wire_TriggerOutput(self, "TrackSwitchBlocked", 0.0)
    end
    if self.SelectAlternateTrack == true
    then Wire_TriggerOutput(self, "SelectingAlternate", 1.0)
    else Wire_TriggerOutput(self, "SelectingAlternate", 0.0)
    end
    
    if self.Announcer then
      if self.Announcer.CurrentAnnouncement then
        Wire_TriggerOutput(self, "Announcement", self.Announcer.CurrentAnnouncement[3] or 0)
      else
        Wire_TriggerOutput(self, "Announcement", 0.0)
      end
    end
  end
  
  
  -- Update systems
--    self.Announcer = nil
--    self.Announcer = Metrostroi.Systems.Announcer(self)
  if self.Announcer then
    self.Announcer:Think()
  end
  
  -- Display status lights
  if self.Mode > 0 then
    self:SetLightPower(3,self.Mode <= 2)
    self:SetLightPower(4,(self.MasterTrain == nil) and (self.PassengerWagon))
    self:SetLightPower(5,(self.DoorPosition[0] > 0.1) or (self.DoorPosition[1] > 0.1))
  else
    self:SetLightPower(3,false)
    self:SetLightPower(4,false)
    self:SetLightPower(5,false)
  end
  
  
  -- Send to client
  self:SetNWFloat("TrainID",self.WagonID)
  self:SetNWFloat("Speed",speed)
  self:SetNWFloat("Mode",self.Mode)
  self:SetNWBool("Reverse",self.Reverse)
  self:SetNWBool("LeftDoor",self.DoorPosition[0] > 0.1)
  self:SetNWBool("RightDoor",self.DoorPosition[1] > 0.1)
  self:SetNWBool("CockpitLight",self.LightState[0])
  self:SetNWBool("InteriorLight",self.LightState[1])
  self:SetNWBool("AlternateTrack",self.AlternateTrack)
  self:SetNWBool("SelectAlternateTrack",self.SelectAlternateTrack or false)
  self:SetNWBool("TrackSwitchBlocked",self.TrackSwitchBlocked)
  self:SetNWBool("NextLightYellow",self.NextLightYellow)
  self:SetNWBool("NextLightRed",self.NextLightRed)
  if self.ARSSpeed
  then self:SetNWFloat("ARSSpeed",self.ARSSpeed)
  else self:SetNWFloat("ARSSpeed",-1.0)
  end

--  self:NextThink(CurTime() + 0.0)
  self:NextThink(0.05)
  return true
end


--------------------------------------------------------------------------------
-- Spawn function
--------------------------------------------------------------------------------
function ENT:SpawnFunction(ply, tr)
  local verticaloffset = -60 -- Offset for the train model, gmod seems to add z by default, nvm its you adding 170 :V
  local distancecap = 2000 -- When to ignore hitpos and spawn at set distanace
  local pos, ang = nil
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
        -- Bit ugly because Rotate() messes with the origional vector
    else
        -- Regular spawn
        if tr.HitPos:Distance(tr.StartPos) > distancecap then
            -- Spawnpos is far away, put it at distancecap instead
            pos = tr.StartPos + tr.Normal * distancecap
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
  ent:SetAngles(ang + Angle(0,180,0))
  ent:Spawn()
  ent:Activate()
  return ent
end

--------------------------------------------------------------------------------
-- Handle cabin buttons
--------------------------------------------------------------------------------
net.Receive("metrostroi-cabin-button", function(len, ply)
	local button = net.ReadInt(8)
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
		if CurTime() - train.DriverSeat.lastDriverTime > 1  then return end
	end

	if eventtype > 0 then
		train:OnButtonPress(button)
	else
		train:OnButtonRelease(button)
	end
end)

local function CanPlayerEnter(ply,vec,role)
	local train = vec:GetNWEntity("TrainEntity")
	
	if IsValid(train) then
		local driver = vec.lastDriver
		if IsValid(driver) then
			if driver == ply and CurTime() - vec.lastDriverTime < 1 then return false end
		end
	end
end

local function HandleExitingPlayer(ply, vehicle)
	vehicle.lastDriver = ply
	vehicle.lastDriverTime = CurTime()
	ply.lastVehicleDriven = vehicle

	local train = vehicle:GetNWEntity("TrainEntity")
	if IsValid(train) then
		
		//Move exiting player
		local seattype = vehicle:GetNWString("SeatType")
		if seattype == "driver" then
			ply:SetPos(vehicle:GetPos()+Vector(0,0,-20))
		elseif seattype == "passenger" then
			ply:SetPos(vehicle:GetPos()+vehicle:GetForward()*40+Vector(0,0,-10))
		end
		
		//Reset cabin
		
		//Server
		train:ClearKeyBuffer()
		
		//Client
		net.Start("metrostroi-cabin-reset")
		net.WriteEntity(train)
		net.Send(ply)
	end
end

hook.Add("PlayerLeaveVehicle", "gmod_subway_81-717-cabin-exit", HandleExitingPlayer )
hook.Add("CanPlayerEnterVehicle","gmod_subway_81-717-cabin-entry", CanPlayerEnter )
