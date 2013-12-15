AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")




--------------------------------------------------------------------------------
local model = {
  ["none"]            = "models/props_trainstation/tracksign10.mdl",
  ["large"]           = "models/props_trainstation/tracksign08.mdl",
  ["large_pole"]      = "models/props_trainstation/tracksign07.mdl",
  ["small"]           = "models/props_trainstation/tracksign10.mdl",
  ["small_pole"]      = "models/props_trainstation/tracksign03.mdl",
  ["small_extra"]     = "models/props_trainstation/tracksign09.mdl",
--  ["picket"]          = "models/props_trainstation/tracksign09.mdl",
--  ["picket"]          = "models/props_trainstation/tracksign02.mdl",
  ["picket"]          = "models/Metrostroi/props/picket.mdl",
  ["pole"]            = "models/props_c17/signpole001.mdl",
  
  ["tlight_3"]        = "models/props_trainstation/light_signal001b.mdl",
  ["tlight_2"]        = "models/props_trainstation/tracklight01.mdl",
  
  ["light_2"]         = "models/Metrostroi/props_models/light_2.mdl",
  ["light_3"]         = "models/Metrostroi/props_models/light_3.mdl",
  ["light_2_2"]       = "models/Metrostroi/props_models/light_2_2.mdl",
  ["light_2_3"]       = "models/Metrostroi/props_models/light_2_3.mdl",
  ["light_2_outside"] = "models/Metrostroi/props_models/light_2_outside.mdl",
  ["light_3_outside"] = "models/Metrostroi/props_models/light_3_outside.mdl",
}




--------------------------------------------------------------------------------
function ENT:Initialize()
  self.ExtraEnts = {}
  
  -- Remove zero variables
  if self.PoleMount     and (self.PoleMount <= 0.0)     then self.PoleMount = nil end
  if self.SignIndex     and ((self.SignIndex == "") or (tonumber(self.SignIndex) and (tonumber(self.SignIndex) <= 0))) then self.SignIndex = nil end
  if self.SpeedLimit    and (self.SpeedLimit <= 0.0)    then self.SpeedLimit = nil end
  if self.SectionLength and (self.SectionLength <= 0.0) then self.SectionLength = nil end
  if self.TrackSlope    and (self.TrackSlope == 0.0)    then self.TrackSlope = nil end
  if self.BrakeZone     and (self.BrakeZone <= 0.0)     then self.BrakeZone = nil end
  if self.DangerZone    and (self.DangerZone <= 0.0)    then self.DangerZone = nil end
  if self.PicketSign    and (self.PicketSign <= 0.0)    then self.PicketSign = nil end
  if self.TrafficLight  and ((self.TrafficLight == "") or (tonumber(self.TrafficLight) and (tonumber(self.TrafficLight) <= 0))) then self.TrafficLight = nil end
  
  if self.Disabled == true then
    self:SetNWBool("Disabled",true)
  end
  
  -- Assign equipment ID to this
  self.EquipmentID = Metrostroi.NextEquipmentID()
  
  -- Traffic light
  if self.TrafficLight then
    self.LightStates = {
      false, -- Red
      false, -- Yellow
      false, -- Green
      false, -- Blue
      false, -- Flashing Yellow (second yellow)
      false, -- White
    }
    
    self.LightColors = {
      { 255,0,0 },
      { 255,255,0 },
      { 0,255,0 },
      { 0,0,255 },
      { 255,255,0 },
      { 255,255,255 },
    }
    
    if self.TrafficLight == "GR" then
      self:SetModel(model["light_2"])
      self.LightPositions = {
        Vector(2,-8,80),
        nil,
        Vector(2,-8,93),
      }
    elseif self.TrafficLight == "GR_O" then
      self:SetModel(model["light_2_outside"])
      self.LightPositions = {
        Vector(2,0,35),
        nil,
        Vector(2,0,49),
      }
    elseif self.TrafficLight == "YR" then
      self:SetModel(model["light_2"])
      self.LightPositions = {
        Vector(2,-8,80),
        Vector(2,-8,93),
      }
    elseif self.TrafficLight == "YR_O" then
      self:SetModel(model["light_2_outside"])
      self.LightPositions = {
        Vector(2,0,35),
        Vector(2,0,39),
      }
    elseif self.TrafficLight == "YGR" then
      self:SetModel(model["light_3"])
      self.LightPositions = {
        Vector(2,-8,80),
        Vector(2,-8,93),
        Vector(2,-8,106),
      }
    elseif self.TrafficLight == "YGR_O" then
      self:SetModel(model["light_3_outside"])
      self.LightPositions = {
        Vector(2,0,50+80),
        Vector(2,0,50+93),
        Vector(2,0,50+106),
      }
    elseif self.TrafficLight == "YG_YR" then
      self:SetModel(model["light_2_2"])
      self.LightPositions = {
        Vector(2,-8,60),
        Vector(2,-8,118),
        Vector(2,-8,104),
        nil,
        Vector(2,-8,73),
      }
    elseif self.TrafficLight == "YG_YR_O" then
      self:SetModel(model["light_3_outside"])
      self.LightPositions = {
        Vector(2,0,40+60),
        Vector(2,0,40+118),
        Vector(2,0,40+104),
        nil,
        Vector(2,0,40+73),
      }
    elseif self.TrafficLight == "BY_GR" then
      self:SetModel(model["light_2_2"])
      self.LightPositions = {
        Vector(2,-8,60),
        Vector(2,-8,104),
        Vector(2,-8,73),
        Vector(2,-8,118),
      }
    elseif self.TrafficLight == "BY_GR" then
      self:SetModel(model["light_2_2"])
      self.LightPositions = {
        Vector(2,-8,60),
        Vector(2,-8,104),
        Vector(2,-8,73),
        Vector(2,-8,118),
      }
    elseif self.TrafficLight == "BYG_RY" then
      self:SetModel(model["light_2_3"])
      self.LightPositions = {
        Vector(2,-8,73),
        Vector(2,-8,118),
        Vector(2,-8,104),
        Vector(2,-8,131),
        Vector(2,-8,60),
      }
    end
    
    Metrostroi.AddTrafficLight(self)
    
    self.PoleMount = nil
    self:SpawnRest()
    return
  end
  
  -- Set material for all following signs
  self:SetMaterial("models/debug/debugwhite")
  
  -- Picket (create picket first and pole later)
  if self.PicketSign then
    self.IsPicketSign = true
    self:SetNWString("Graphic","picket")

    self:SetNWString("Value1","")
    self:SetNWString("Value2","")
    self:SetNWString("Value3","")
    self:SetModel(model["picket"])
    self.SignHeight = 0

    Metrostroi.AddPicketSign(self)

    if self.PoleMount then self.SignHeight = 90 end

    self.PicketSign = nil
    self:SpawnRest()
    return
  end

  -- Create pole if required
  if self.PoleMount and (not self.SpeedLimit) then
    self:SetModel(model["pole"])
    self.SignHeight = -90
    
    self.PoleMount = nil
    self:SpawnRest()
    return
  end
  
  -- Speed limit sign on a pole
  if self.PoleMount and self.SpeedLimit then
    self:SetNWString("Graphic","speed_limit")
    self:SetNWString("Value1",self.SpeedLimit)
    self:SetModel(model["large_pole"])
    self.SignHeight = 12
    self.SignXOffset = -8.5
    self.SignYOffset = 10
    
    self.SpeedLimit = nil
    self.PoleMount = nil
    self:SpawnRest()
    return
  end
  
  -- Speed limit
  if (not self.PoleMount) and self.SpeedLimit then
    self:SetNWString("Graphic","speed_limit")
    self:SetNWString("Value1",self.SpeedLimit)
    self:SetModel(model["large"])
    self.SignHeight = 39

    self.SpeedLimit = nil
    self:SpawnRest()
    return
  end

  -- Track slope
  if self.TrackSlope then
    self:SetNWString("Graphic","slope")
    self:SetNWString("Value1",self.TrackSlope)
    self:SetNWString("Value2",self.SectionLength or "")
    self:SetModel(model["small"])
    self.SignHeight = 28

    self.TrackSlope = nil
    self.SectionLength = nil
    self:SpawnRest()
    return
  end
  
  -- Brake Zone + Danger Zone = Prohibit
  if self.BrakeZone and self.DangerZone then
    self.ProhibitPath = true
    Metrostroi.UpdateTrafficLightPositions()
    
    self:SetNWString("Graphic","prohibit")
    self:SetModel(model["large"])
    self.SignHeight = 28
  
    self.BrakeZone = nil
    self.DangerZone = nil
    self:SpawnRest()
    return
  end
  
  -- Brake Zone
  if self.BrakeZone then
    self:SetNWString("Graphic","brake_zone")
--    self:SetNWString("Value1",self.TrackSlope)
    self:SetModel(model["small"])
    self.SignHeight = 28

    self.BrakeZone = nil
    self:SpawnRest()
    return
  end
  
  -- Danger Zone
  if self.DangerZone then
    self:SetNWString("Graphic","danger_zone")
    if self.SectionLength then
      self:SetNWString("Value1",self.SectionLength)
      self:SetModel(model["small_extra"])
      self.SignHeight = 32
      self:SetPos(self:GetPos() - self:GetAngles():Up()*5)
    else
      self:SetModel(model["small"])
      self.SignHeight = 28
    end

    self.DangerZone = nil
    self.SectionLength = nil
    self:SpawnRest()
    return
  end
  
  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:SetSolid(SOLID_VPHYSICS)
end




function ENT:SpawnRest()
  self:PhysicsInit(SOLID_VPHYSICS)
--  self:SetMoveType(MOVETYPE_NONE)
  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:SetSolid(SOLID_VPHYSICS)
  self:GetPhysicsObject():EnableMotion(false)
  
  if self.PoleMount or self.SignIndex or self.SpeedLimit or
     self.TrackSlope or self.BrakeZone or self.DangerZone or
     self.PicketSign then
    local ent = MakeSubwayTrackEquipment(self:GetOwner(),
      self:GetPos()-
        self:GetAngles():Up()*(self.SignHeight or 30) +
        self:GetAngles():Forward()*(self.SignXOffset or 0) +
        self:GetAngles():Right()*(self.SignYOffset or 0),
      self:GetAngles(),
      self.PoleMount,self.SignIndex,self.SpeedLimit,self.SectionLength,
      self.TrackSlope,self.BrakeZone,self.DangerZone,self.PicketSign)

    ent.OriginalVariables = nil
    table.insert(self.ExtraEnts,ent)
  end
end


function ENT:OnRemove()
  Metrostroi.RemovePicketSign(self)
  Metrostroi.RemoveTrafficLight(self)
  if self.ExtraEnts then
    for k,v in pairs(self.ExtraEnts) do
      SafeRemoveEntity(v)
    end
  end
end




--------------------------------------------------------------------------------
-- Picket signs
--------------------------------------------------------------------------------
function ENT:SetPicketIndex(index)
  if self.IsPicketSign then
    self.Index = index
--    self:SetNWString("Value1",index)
  end
end

function ENT:SetNextPicket(sign)
  if sign == self.NextPicket then return end
  
  if self.IsPicketSign then
    local next_picket = self.NextPicket
    self.NextPicket = sign
    
    if next_picket and (not sign) then next_picket:SetPreviousPicket(nil) end

    if sign
    then self.NextIndex = sign.Index
    else self.NextIndex = nil
    end
    
    if sign
    then self:SetNWVector("next_picket_pos",sign:GetPos())
    else self:SetNWVector("next_picket_pos",Vector(0,0,0))
    end
  end
end

function ENT:SetPreviousPicket(sign)
  if sign == self.PreviousPicket then return end

  if self.IsPicketSign then
    local prev_picket = self.PreviousPicket
    self.PreviousPicket = sign
    
    if prev_picket and (not sign) then prev_picket:SetNextPicket(nil) end
    

    if sign
    then self.PreviousIndex = sign.Index
    else self.PreviousIndex = nil
    end
--    self:SetNWString("Value2",self.PreviousIndex or "")
  end
end

function ENT:SetAlternatePicket(sign)
--  print(self.Index,"has alt picket of",sign.Index)
  if sign == self.AlternatePicket then return end

  if self.IsPicketSign then
    local alt_picket = self.AlternatePicket
    self.AlternatePicket = sign

    if alt_picket and (not sign) then alt_picket:SetAlternatePicket(nil) end
    
    if sign then
      self.AlternateIndex = sign.Index
      self:SetNWVector("switch_picket_pos",sign:GetPos())
    else
      self:SetTrackSwitch(nil)
      self.AlternateIndex = nil
      self:SetNWVector("switch_picket_pos",Vector(0,0,0))
    end
  end
end

function ENT:SetPicketOffset(offset)
  self.PicketOffset = offset
  self:SetNWString("Value3",self.Index)

  self:SetNWString("Value1",math.floor((offset or 0)/10)*10)
  if self.PreviousPicket then
    self:SetNWString("Value2",math.floor((self.PreviousPicket.PicketOffset or 0)/10)*10)
  end
end

function ENT:SetNearestPicket(sign)
  if sign then
    self.NearestPicket = sign
    self.NearestIndex = sign.Index
    self:SetNWVector("nearest_picket_pos",sign:GetPos())
  else
    self.NearestPicket = nil
    self.NearestIndex = nil
    self:SetNWVector("nearest_picket_pos",Vector(0,0,0))
  end
end

function ENT:DebugSetNearestPicket(sign)
  if sign then
    timer.Create("DebugSetNearestPicket"..math.random(1,9999999),math.random(1.0,3.0),1,function()
      self:SetNWVector("nearest_path_pos",sign:GetPos())
    end)
  else
    timer.Create("DebugSetNearestPicket"..math.random(1,9999999),math.random(1.0,3.0),1,function()
      self:SetNWVector("nearest_path_pos",Vector(0,0,0))
    end)
  end
end


function ENT:SetTrackSwitch(ent)
  if ent then
    self.TrackSwitchState = false
    self.TrackSwitchName = ent:GetName()
    
    if self.AlternatePicket then
      self.AlternatePicket.TrackSwitchState = false
      self.AlternatePicket.TrackSwitchName = ent:GetName()
    end
  else
    self.TrackSwitchName = nil

    if self.AlternatePicket then
      self.AlternatePicket.TrackSwitchName = nil
    end
  end
end

function ENT:ToggleTrackSwitch()
  self:SetTrackSwitchState(not self.TrackSwitchState)
end

function ENT:IsTrackSwitchBlocked(caller)

--  print("C",self.Index,caller)
  local foundIndex,foundType,foundEnt = Metrostroi.FindTrainOrLight(self,Metrostroi.SectionOffset[self.Index],self.Index,{},false)
--  print("1",foundIndex,foundType,foundEnt)
  if (foundType == "train") and (foundEnt ~= caller) and
     not(foundEnt.MasterTrain and (foundEnt.MasterTrain == caller)) then return true end
  
  local foundIndex,foundType,foundEnt = Metrostroi.FindTrainOrLight(self,Metrostroi.SectionOffset[self.Index],self.Index,{},true)
--  print("2",foundIndex,foundType,foundEnt)
  if (foundType == "train") and (foundEnt ~= caller) and
     not(foundEnt.MasterTrain and (foundEnt.MasterTrain == caller)) then return true end
     
  local foundIndex,foundType,foundEnt = Metrostroi.FindTrainOrLight(self,Metrostroi.SectionOffset[self.AlternateIndex],self.AlternateIndex,{},false)
--  print("3",foundIndex,foundType,foundEnt)
  if (foundType == "train") and (foundEnt ~= caller) and
     not(foundEnt.MasterTrain and (foundEnt.MasterTrain == caller)) then return true end
     
  local foundIndex,foundType,foundEnt = Metrostroi.FindTrainOrLight(self,Metrostroi.SectionOffset[self.AlternateIndex],self.AlternateIndex,{},true)
--  print("4",foundIndex,foundType,foundEnt)
  if (foundType == "train") and (foundEnt ~= caller) and
     not(foundEnt.MasterTrain and (foundEnt.MasterTrain == caller)) then return true end
  
  -- Do final ultimate check: make sure no train wagons around the track switches
  local switches = ents.FindByName(self.TrackSwitchName)
  for k,v in pairs(switches) do
    local trains = ents.FindInSphere(v:GetPos(),512)
    for k2,v2 in pairs(trains) do
      local CLASS_PREFIX = "gmod_subway"
      if (string.sub(v2:GetClass(),1,#CLASS_PREFIX) == CLASS_PREFIX) and (v2 ~= caller) then
--        print("PHYSICALLY BLOCKED")
        return true
      end
    end
  end

--  print("NOT BLOCKED")
  return false
end

function ENT:DistanceToSwitch(pos)
  if not self.TrackSwitchName then return 1e99 end
  
  local distance = 1e99
  local switches = ents.FindByName(self.TrackSwitchName)
  for k,v in pairs(switches) do
    if v:GetPos():Distance(pos) < distance then
      distance = v:GetPos():Distance(pos)
    end
  end
  return distance*0.01905
end

function ENT:TrackSwitchAutoClose()
  if self.TrackSwitchState == false then
    return
  end

  if self:IsTrackSwitchBlocked() then
    timer.Create("Picket"..self.Index.."_CloseTrackSwitch",10.0,1,function()
      self:TrackSwitchAutoClose()
    end)
  else
    self:SetTrackSwitchState(false)
  end
end

function ENT:SetTrackSwitchState(value,caller)
  if not self.TrackSwitchName then return false end
  
  -- Do not move track switch if blocked
  if self:IsTrackSwitchBlocked(caller) then return false end
  
  -- Move track switch
  if value == true then
    if self.TrackSwitchState ~= true then
      local switches = ents.FindByName(self.TrackSwitchName)
      for k,v in pairs(switches) do
        v:Fire("Open","","0")
      end
    end
    self.TrackSwitchState = true
    
    timer.Create("Picket"..self.Index.."_CloseTrackSwitch",10.0,1,function()
      self:TrackSwitchAutoClose()
    end)
  else
    if self.TrackSwitchState ~= false then
      local switches = ents.FindByName(self.TrackSwitchName)
      for k,v in pairs(switches) do
        v:Fire("Close","","0")
      end
    end
    self.TrackSwitchState = false
  end
  
  -- Set alternate pickets state
  if self.AlternatePicket and self.AlternatePicket.TrackSwitchName then
    self.AlternatePicket.TrackSwitchState = self.TrackSwitchState
  end
  
  -- Success
  return true
end

function ENT:GetTrackSwitchState()
  return self.TrackSwitchState
end




--------------------------------------------------------------------------------
-- Traffic lights stuff
--------------------------------------------------------------------------------
function ENT:SetAmbientLight(index,on)
  self.LightStates[index] = on
    
  -- Check ambient light status
  if not self.AmbientLight then self.AmbientLight = {} end
  if self.AmbientLight[index] and on then return end
  if (not self.AmbientLight[index]) and (not on) then return end

  -- Update light
  if self.AmbientLight[index] then
    SafeRemoveEntity(self.AmbientLight[index])
    self.AmbientLight[index] = nil
  end
  if on and self.LightPositions and self.LightPositions[index] then
    --[[local light = ents.Create("env_lightglow")
    light:SetParent(self)

    -- Set position
    light:SetLocalPos(self.LightPositions[index])
    light:SetLocalAngles(Angle(0,0,0))

    -- Set parameters
    local r,g,b = 255,255,255
    if self.LightColors and self.LightColors[index] then
      r = self.LightColors[index][1] or 255
      g = self.LightColors[index][2] or 255
      b = self.LightColors[index][3] or 255
    end
    light:SetKeyValue("rendercolor",Format("%d %d %d",r,g,b))
    light:SetKeyValue("HorizontalGlowSize", 8)
    light:SetKeyValue("VerticalGlowSize", 8)
    light:SetKeyValue("MinDist", 8)
    light:SetKeyValue("MaxDist", 32)
    light:SetKeyValue("OuterMaxDist", 12000)
    light:SetKeyValue("spawnflags", 1) ]]--
    
    
    local light = ents.Create("env_sprite")
    light:SetParent(self)

    -- Set position
    light:SetLocalPos(self.LightPositions[index])
    light:SetLocalAngles(Angle(0,0,0))

    -- Set parameters
    local r,g,b = 255,255,255
    if self.LightColors and self.LightColors[index] then
      r = self.LightColors[index][1] or 255
      g = self.LightColors[index][2] or 255
      b = self.LightColors[index][3] or 255
    end
    light:SetKeyValue("rendercolor", Format("%d %d %d",r,g,b))
    light:SetKeyValue("rendermode", 9) -- 9: WGlow, 3: Glow
    light:SetKeyValue("model", "sprites/glow1.vmt")
--    light:SetKeyValue("model", "sprites/light_glow02.vmt")
--    light:SetKeyValue("model", "sprites/yellowflare.vmt")
    light:SetKeyValue("scale", 1.0)
    light:SetKeyValue("spawnflags", 1)

    -- Turn light on
    light:Spawn()
    self.AmbientLight[index] = light
  end
end

function ENT:UpdateTrafficLight(trainBlocksNext,trainBlocksAlt,nextLight,alternateLight,nextSwitch)
  self.TrainBlocksNext = trainBlocksNext
  self.TrainBlocksAlternate = trainBlocksAlternate
  self.NextTrafficLight = nextLight
  self.AlternateTrafficLight = alternateLight
  self.NextTrackSwitch = nextSwitch
  
  if self.Disabled == true then
    self:SetAmbientLight(1,false)
    self:SetAmbientLight(2,false)
    self:SetAmbientLight(3,false)
    self:SetAmbientLight(4,false)
    self:SetAmbientLight(5,false)
    self:SetAmbientLight(6,false)
    return
  end
  
  -- Check if next lights values must be delegated to this one
  local delegateState = false
  if self.NextTrafficLight then
    local distance = self:GetPos():Distance(self.NextTrafficLight:GetPos())*0.01905
    if distance < 75 then
      delegateState = true
    end
  end
  
  -- Check if next section is blocked and how
  local blockedByTrain = self.TrainBlocksNext
  local blockedBySwitch = (self.RedOnAlternateTrack == true) and
                          (nextSwitch) and (nextSwitch:GetTrackSwitchState())
  local blockedByDeadEnd = not self.NextTrafficLight
  local nextSwitchActive = (nextSwitch ~= nil) and (nextSwitch:GetTrackSwitchState()) and (not blockedBySwitch)
  
  -- Special logic for different types
  if (self.TrafficLight == "YR") or (self.TrafficLight == "YR_O") then
    if blockedByTrain or blockedBySwitch or blockedByDeadEnd then
      self:SetAmbientLight(2,false)
      self:SetAmbientLight(1,true)
    else
      self:SetAmbientLight(2,true)
      self:SetAmbientLight(1,false)
    end
  elseif (self.TrafficLight == "GR") or (self.TrafficLight == "GR_O") then
    if blockedByTrain or blockedBySwitch or blockedByDeadEnd then
      self:SetAmbientLight(3,false)
      self:SetAmbientLight(1,true)
    else
      self:SetAmbientLight(3,true)
      self:SetAmbientLight(1,false)
    end
  else -- Red/Yellow/Green logic
    local retainNormalLogic = true
  
    -- Do double-yellow logic
    if (self.TrafficLight == "YG_YR") or
       (self.TrafficLight == "YG_YR_O") or
       (self.TrafficLight == "BYG_RY") then
      if nextSwitchActive then
        self:SetAmbientLight(3,false)

        if blockedByTrain or blockedBySwitch then
          self:SetAmbientLight(1,true)
          self:SetAmbientLight(5,false)
          self:SetAmbientLight(2,true)
        elseif self.NextTrafficLight then
          self:SetAmbientLight(1,false)
          self:SetAmbientLight(5,true)
          if self.NextTrafficLight.LightStates[1] then
            self:SetAmbientLight(2,true)
          else
            self:SetAmbientLight(2,(CurTime() % 2.0 > 1.0))
          end
        else
          self:SetAmbientLight(1,false)
          self:SetAmbientLight(5,true)
          self:SetAmbientLight(2,true)
        end

        retainNormalLogic = false
        delegateState = false
      else
        self:SetAmbientLight(5,false)
      end
    end
      
    -- Do normal logic
    if retainNormalLogic then
      if blockedByTrain or blockedBySwitch then
        self:SetAmbientLight(1,true)
        self:SetAmbientLight(2,false)
        self:SetAmbientLight(3,false)
      elseif self.NextTrafficLight then
        if (not delegateState) and self.NextTrafficLight.LightStates[1] then
          -- Next light red, this one is yellow (unless delegating state)
          self:SetAmbientLight(1,false)
          self:SetAmbientLight(2,true)
          self:SetAmbientLight(3,false)
        else
          if delegateState then
            -- Delegate next lights state
            self:SetAmbientLight(1,self.NextTrafficLight.LightStates[1])
            self:SetAmbientLight(2,self.NextTrafficLight.LightStates[2])
            self:SetAmbientLight(3,self.NextTrafficLight.LightStates[3])
          else
            self:SetAmbientLight(1,false)
            self:SetAmbientLight(2,false)
            self:SetAmbientLight(3,true)
          end
        end
      else
        self:SetAmbientLight(1,true)
        self:SetAmbientLight(2,true)
        self:SetAmbientLight(3,false)
      end
    end
    
    -- Blue signal logic
    self:SetAmbientLight(4,false)
    self:SetAmbientLight(6,false)
  end
  
  -- Check if next light is on "wrong" track
  --[[local nextLightAfterSwitch = false
  local next = self.NextTrafficLight
  if next and Metrostroi.TrafficLightPositions[self] and Metrostroi.TrafficLightPositions[next] then
    nextLightAfterSwitch =
      (Metrostroi.TrafficLightPositions[next].path ~= Metrostroi.TrafficLightPositions[self].path) or
      (math.abs(Metrostroi.TrafficLightPositions[next].position - Metrostroi.TrafficLightPositions[self].position) > 100)
  end
  
  if nextLightAfterSwitch and nextSwitch and nextSwitch:GetTrackSwitchState() then
    self:SetAmbientLight(5,true)
--    print("NEXT LIGHT FROM WRONG TRACK")
  else
    self:SetAmbientLight(5,false)
  end]]--
end




--------------------------------------------------------------------------------
function ENT:GetSavedText(format)
  if not self.OriginalVariables then return end
  if format == "lua" then
    local pos = self:GetPos()
    local ang = self:GetAngles()
    local source = "ent = MakeSubwayTrackEquipment(player,"
    source = source.."Vector("..(pos.x or 0)..","..(pos.y or 0)..","..(pos.z or 0).."),"
    source = source.."Angle("..(ang.x or 0)..","..(ang.y or 0)..","..(ang.z or 0).."),"
    source = source..(self.OriginalVariables[1] or 0)..","
    source = source..(self.OriginalVariables[2] or 0)..","
    source = source..(self.OriginalVariables[3] or 0)..","
    source = source..(self.OriginalVariables[4] or 0)..","
    source = source..(self.OriginalVariables[5] or 0)..","
    source = source..(self.OriginalVariables[6] or 0)..","
    source = source..(self.OriginalVariables[7] or 0)..","
    source = source..(self.OriginalVariables[8] or 0)..","
    source = source.."\""..(self.OriginalVariables[9] or 0).."\")\r\n"
    
    if self.IsPicketSign then
      source = source.."ent.Index = "..self.Index.."\r\n"
      if self.NextIndex and (self.NextIndex ~= "") then
        source = source.."ent.NextIndex = "..self.NextIndex.."\r\n"
      end
      if self.PreviousIndex and (self.PreviousIndex ~= "") then
        source = source.."ent.PreviousIndex = "..self.PreviousIndex.."\r\n"
      end
      if self.AlternateIndex and (self.AlternateIndex ~= "") then
        source = source.."ent.AlternateIndex = "..self.AlternateIndex.."\r\n"
      end
      if self.TrackSwitchName then
        source = source.."ent.TrackSwitchName = \""..self.TrackSwitchName.."\"\r\n"
        source = source.."ent.TrackSwitchState = false\r\n"
      end
    end
    if self.RedOnAlternateTrack then
      source = source.."ent.RedOnAlternateTrack = "..tostring(self.RedOnAlternateTrack).."\r\n"
    end
    if self.Disabled then
      source = source.."ent.Disabled = "..tostring(self.Disabled).."\r\n"
    end
    if self.NearestIndex then
      source = source.."ent.NearestIndex = "..self.NearestIndex.."\r\n"
    end
    
    return source
  end
end




--------------------------------------------------------------------------------
--function ENT:KeyValue(key, value)
--  if key == "SignText" then self.SignText = value end
--  if key == "SignType" then self.SignType = value end
--end

function ENT:KeyValue(key, value)
--  print("SETUP NETWORK VAR",key,value)
--  if self:SetNetworkKeyValue(key, value) then
--    return
--  end
end

function ENT:OnVariableChanged()
  if self.CanEditSpecialVariables then
--    print("VAR CHANGED")
--    self.RedOnAlternateTrack = self:GetPropRedOnAlternateTrack()
--    self.Disabled = self:GetPropDisabled()
--    print("SET",self.Disabled,self.RedOnAlternateTrack)
  end
end

function ENT:Think()
  self:SetPropRedOnAlternateTrack(self.RedOnAlternateTrack == true)
  self:SetPropDisabled(self.Disabled == true)
  self.CanEditSpecialVariables = true
  
--  local data = self:GetKeyValues()
--  for k,v in pairs(data) do
--    print(k,v)
--  end
--  if self.Index == 167 then
--    print("========")
--    print("BLOCKED",self:IsTrackSwitchBlocked())
--  end
  self:NextThink(1.0)
  return true
end

function MakeSubwayTrackEquipment(player, pos, ang,
  poleMount,signIndex,speedLimit,sectionLength,
  trackSlope,brakeZone,dangerZone,picketSign,trafficLight)

  local ent = ents.Create("gmod_track_equipment")
  ent:SetPlayer(player)
  ent:SetPos(pos)
  ent:SetAngles(ang)
  
  -- Set parameters
  ent.OriginalVariables = {
    poleMount, signIndex, speedLimit, sectionLength,
    trackSlope, brakeZone, dangerZone, picketSign, trafficLight }
    
  ent.PoleMount     = poleMount
  ent.SignIndex     = signIndex
  ent.SpeedLimit    = speedLimit
  ent.SectionLength = sectionLength
  
  ent.TrackSlope    = trackSlope
  ent.BrakeZone     = brakeZone
  ent.DangerZone    = dangerZone
  ent.PicketSign    = picketSign
  ent.TrafficLight  = trafficLight

  -- Spawn entity
  ent:Spawn()
  --player:AddCount("wire_clutchs", controller)
  return ent
end
--duplicator.RegisterEntityClass("gmod_wire_clutch", MakeClutchController, "Pos", "Ang", "Model")
