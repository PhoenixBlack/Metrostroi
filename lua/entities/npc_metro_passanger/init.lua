AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")




--------------------------------------------------------------------------------
ENT.PassengerModels = {
  "male_01", "male_02", "male_03",
  "male_04", "male_05", "male_06",
  "male_07", "male_08", "male_09",
  "female_01", "female_02", "female_03",
  "female_04", "female_06", "female_07" }

ENT.PassengerSounds = {
  ["female"] = {
    ["chat"] = {
      "vo/npc/female01/hi01.wav",
      "vo/npc/female01/hi02.wav",
      "vo/Streetwar/barricade/female01/c17_05_letusthru.wav",
      "vo/coast/barn/female01/youmadeit.wav",
      "vo/coast/odessa/female01/nlo_cheer01.wav",
      "vo/npc/female01/excuseme01.wav",
      "vo/npc/female01/excuseme02.wav",
      "vo/npc/female01/gordead_ans14.wav",
      "vo/npc/female01/moan01.wav",
      "vo/npc/female01/moan02.wav",
      "vo/npc/female01/moan03.wav",
      "vo/npc/female01/moan04.wav",
      "vo/npc/female01/moan05.wav",
      "vo/npc/female01/pardonme01.wav",
      "vo/npc/female01/pardonme02.wav",
    },
    ["scared"] = {
      "vo/canals/female01/stn6_incoming.wav",
      "vo/canals/female01/stn6_shellingus.wav",
      "vo/coast/odessa/female01/nlo_cubdeath01.wav",
      "vo/coast/odessa/female01/nlo_cubdeath02.wav",
    },
    ["pain"] = {
      "vo/trainyard/female01/cit_hit01.wav",
      "vo/trainyard/female01/cit_hit02.wav",
      "vo/trainyard/female01/cit_hit03.wav",
    },
  },
  ["male"] = {
    ["chat"] = {
      "vo/npc/male01/hi01.wav",
      "vo/npc/male01/hi02.wav",
      "vo/npc/male01/gordead_ans19.wav",
      "vo/npc/male01/gordead_ans01.wav",
      "vo/npc/male01/excuseme01.wav",
      "vo/npc/male01/excuseme02.wav",
      "vo/npc/male01/busy02.wav",
      "vo/npc/male01/answer40.wav",
      "vo/npc/male01/answer39.wav",
      "vo/npc/male01/answer30.wav",
      "vo/npc/male01/answer05.wav",
      "vo/Streetwar/rubble/male01/d3_c17_13_horse01.wav",
    },
    ["scared"] = {
      "vo/Streetwar/sniper/male01/c17_09_help01.wav",
      "vo/Streetwar/sniper/male01/c17_09_help02.wav",
      "vo/npc/male01/notthemanithought02.wav",
      "vo/npc/male01/heretohelp02.wav",
      "vo/Streetwar/sniper/male01/c17_09_help03.wav",
    },
    ["pain"] = {
      "vo/trainyard/male01/cit_hit01.wav",
      "vo/trainyard/male01/cit_hit02.wav",
      "vo/trainyard/male01/cit_hit03.wav",
    },
  },
}




--------------------------------------------------------------------------------
local NPCINF = 1e9
local scheduleSitFemale = ai_schedule.New("Sit anim female")
scheduleSitFemale:AddTask("PlaySequence", {ID = 334, Speed = 0.4}) -- Sit down anim
scheduleSitFemale:AddTask("PlaySequence", {ID = 335, Dur = NPCINF})    -- Sitting anim
scheduleSitFemale:AddTask("PlaySequence", {ID = 336, Speed = 0.8}) -- Stand up anim
scheduleSitFemale:AddTask("EndSit")

local scheduleSit = ai_schedule.New("Sit anim")
scheduleSit:AddTask("PlaySequence", {ID = 353, Speed = 0.4}) -- Sit down anim
scheduleSit:AddTask("PlaySequence", {ID = 354, Dur = NPCINF})    -- Sitting anim
scheduleSit:AddTask("PlaySequence", {ID = 355, Speed = 0.4}) -- Stand up anim
scheduleSit:AddTask("EndSit")

function ENT:Task_EndSit(data)
  -- Reset NPC state
  self:TaskComplete()
  self:SetNPCState(NPC_STATE_IDLE)
  
  -- Stand up
  self:SitAt(nil)
end

function ENT:TaskStart_EndSit(data)
  return
end




--------------------------------------------------------------------------------
function ENT:Initialize()
  self:SetModel("models/Humans/Group02/"..table.Random(self.PassengerModels)..".mdl")
  self:SetHullType(HULL_HUMAN)
  self:SetHullSizeNormal()
  self:SetSolid(SOLID_BBOX)
  self:SetMoveType(MOVETYPE_STEP)
  self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
  
  self:SetTrigger(true)
  self:CapabilitiesAdd(bit.bor(CAP_USE, CAP_AUTO_DOORS, CAP_OPEN_DOORS, CAP_ANIMATEDFACE, CAP_TURN_HEAD, CAP_MOVE_GROUND))
  self:SetMaxYawSpeed(20)
  self:SetHealth(100)
  self:SetNPCState(NPC_STATE_IDLE)
  
  self.NextRelaxTime = 0
  self.NextActTime = 0
  self.NextSoundTime = CurTime()
  
  -- Default animations
  self.SitAnim = (self:GetGender() == "female") and scheduleSitFemale or scheduleSit
  
  -- Give wishes
  self.Sitting = false
  self.WantsToExit = false
  self.WantsToEnter = true
  
  -- Give weapon
  --self:Give("weapon_crossbow")
end

function ENT:OnRemove()
  if self.Sitting then
    self:Task_EndSit()
  end
end




--------------------------------------------------------------------------------
function ENT:GetGender()
  return self:GetModel():lower():find("female",1,true) and "female" or "male"
end

function ENT:PlayOnce(soundid)
  if CurTime() < self.NextSoundTime then return end
  local sound = table.Random(self.PassengerSounds[self:GetGender()][soundid])
--  self:EmitSound(sound,100,math.random(96,104))
  self.NextSoundTime = CurTime() + 0.5
end

function ENT:Schedule(schedule)
  if not self:IsCurrentSchedule(schedule) then
    self:SetSchedule(schedule)
  end
end

function ENT:GetWagonInformation(wagon)
  local seatPosition,seatAngles,seatIndex,seatSide = wagon:GetPassengerSeat(self:GetPos())
  if seatPosition then
    local doorPosition = wagon:GetPassengerDoor(wagon:LocalToWorld(seatPosition))
    if doorPosition then
      return seatPosition,seatAngles,seatIndex,seatSide,doorPosition
    end
  end
end

function ENT:FindClosestWagon(range)
  local dist = range or 4096
  local wagon = nil

  local wagons = ents.FindByClass("gmod_subway_81-717")
  for k,v in pairs(wagons) do
    if (v:GetPos() - self:GetPos()):Length() < dist then
      -- Check if there are any free seats in this
      local freeSeats = self:GetWagonInformation(v)

      -- Only count in wagon if it has free seats/open doors
      if freeSeats and (v.Mode > 0) then
--        if not (wagon and (math.random() > 4/5)) then
          dist = (v:GetPos() - self:GetPos()):Length()
          wagon = v
--        end
      end
    end
  end

  local wagons = ents.FindByClass("gmod_subway_81-714")
  for k,v in pairs(wagons) do
    if (v:GetPos() - self:GetPos()):Length() < dist then
      -- Check if there are any free seats in this
      local freeSeats = self:GetWagonInformation(v)

      -- Only count in wagon if it has free seats/open doors
      if freeSeats and (v.Mode > 0) then
--        if not (wagon and (math.random() > 4/5)) then
          dist = (v:GetPos() - self:GetPos()):Length()
          wagon = v
--        end
      end
    end
  end

  -- Return wagon
  return wagon,dist
end




--------------------------------------------------------------------------------
-- NPC's brains
--------------------------------------------------------------------------------
function ENT:Think()
  if (GetConVarNumber("ai_disabled") == 0) and
     (self:GetNPCState() ~= NPC_STATE_DEAD) and
     (CurTime() > self.NextActTime) then

--    if (self:GetNPCState() == NPC_STATE_ALERT) and (self.NextRelaxTime > CurTime()) then
--      self:SetNPCState(NPC_STATE_IDLE)
--    end
    
    if not self.Sitting then
      --print("I AM IDLING")
      self:SetNPCState(NPC_STATE_IDLE)
      
      -- Fix orientation in space
      local ang = self:GetAngles()
      ang.p = 0
      ang.r = 0
      self:SetAngles(ang)
    else
      if self.Sitting then
        if self.Wagon and self.Wagon:IsValid() then
          if not self.AnimationAbortTime then
            if (((self.LastDoorState0 == false) and (self.Wagon.DoorState[0] == true)) or
                ((self.LastDoorState1 == false) and (self.Wagon.DoorState[1] == true))) and
               (math.random() > 0.5) then
              print("I want to leave")
              self.AnimationAbortTime = CurTime() + math.random()*10.0
  
              -- Mark seat as unoccupied right away
              self.Wagon:SetSeatOccupied(self.SeatIndex,self.SeatSide,false)
            end
  
            if ((self.Wagon.DoorState[0] == true) or (self.Wagon.DoorState[1] == true)) and
               (self.Wagon.Mode == 0) then
              print("I want to leave ASAP")
              self.AnimationAbortTime = CurTime() + math.random()*10.0
              self.Wagon:SetSeatOccupied(self.SeatIndex,self.SeatSide,false)
            end
          
            self.LastDoorState0 = self.Wagon.DoorState[0]
            self.LastDoorState1 = self.Wagon.DoorState[1]
          end
        end
      end
    end
  end
end




--------------------------------------------------------------------------------
-- Makes NPC sit down or get up
--------------------------------------------------------------------------------
function ENT:SitAt(wagon,seatPosition,seatAngles,seatIndex,seatSide)
  if wagon then -- Sit down
    self:StopMoving()
    self:StartSchedule(self.SitAnim)
    self.Sitting = true
    
    self.SeatIndex = seatIndex
    self.SeatSide = seatSide
    self.Wagon = wagon
    self.Wagon:SetSeatOccupied(seatIndex,seatSide,true)
    
    self:SetParent(wagon)
    self:SetAngles(seatAngles + wagon:GetAngles() + Angle(0,90,0))
    if self:GetGender() == "male" then
      self:SetPos(seatPosition - seatAngles:Right()*10 + Vector(0,0,-25))
    else
      self:SetPos(seatPosition + seatAngles:Right()*7 + Vector(0,0,-25))
    end
    
    self.WantsToEnter = false
    self.AnimationAbortTime = nil
    
    self.LastDoorState0 = self.Wagon.DoorState[0]
    self.LastDoorState1 = self.Wagon.DoorState[1]
  else -- Stand up
    if self.Wagon and self.Wagon:IsValid() then
      local doorPosition = self.Wagon:GetPassengerDoor(self:GetPos())
      --self.Wagon:SetSeatOccupied(self.SeatIndex,self.SeatSide,false)
      
      if not doorPosition then
        print("I tried to stand up with closed doors")
      else ---2
        if doorPosition.y > 0 then
          self:SetPos(doorPosition + Vector(30,30,-45) +
            Vector(math.random()*50.0-25.0,
                   100.0*math.random(),
                   0.0))
        else
          self:SetPos(doorPosition + Vector(30,-30,-45) +
            Vector(math.random()*50.0-25.0,
                   -100.0*math.random(),
                   0.0))
        end
      end
    end
    
    print("I stood up and exited")
    
    self.Wagon = nil
    self:SetParent(nil)
    
    self.Sitting = false
    self.WantsToExit = true
  end
end




--------------------------------------------------------------------------------
-- Selects what NPC should do next
--------------------------------------------------------------------------------
function ENT:SelectSchedule()
  if self:GetNPCState() == NPC_STATE_SCRIPT then
    return
  elseif self:GetNPCState() == NPC_STATE_IDLE then
    if self.WantsToEnter == true then
      -- Find closest non-full wagon
      local wagon = self:FindClosestWagon()
      
      -- Go to the wagon door
      if wagon then
        local seatPosition,seatAngles,seatIndex,seatSide,doorPosition = self:GetWagonInformation(wagon)
        local distance = self:GetPos():Distance(wagon:LocalToWorld(doorPosition))
        
        -- Fix door position
        local ang = wagon:GetAngles()
        if doorPosition.y > 0 then
          doorPosition = doorPosition + Vector(30,30,-40)
        else
          doorPosition = doorPosition + Vector(30,-30,-40)
        end

        -- Go
        --print("DIST",distance)
        if distance < 96 then
          --print("IN WAGON NOW")
          self:SitAt(wagon,seatPosition,seatAngles,seatIndex,seatSide)
        else
          --print("GO TO",wagon:LocalToWorld(doorPosition))

          self:SetLastPosition(wagon:LocalToWorld(doorPosition))
          if distance < 512 then
            self:Schedule(SCHED_FORCED_GO)
          else
            self:Schedule(SCHED_FORCED_GO_RUN)
          end
        end
      else
        local waitSpots = {}
        for i=2100,3800,100 do
          table.insert(waitSpots,Vector(880,i,30))
        end
        
        -- Check if far away from any waiting spot
        local mindist = 1e99
        for k,v in pairs(waitSpots) do
          local dist = self:GetPos():Distance(v)
          if dist < mindist then mindist = dist end
        end

        -- Find a spot to wait for the train
        if mindist > 150 then
          self:SetLastPosition(table.Random(waitSpots))
          self:Schedule(SCHED_FORCED_GO)
        end
      end
    end
    if self.WantsToExit == true then
      self:SetLastPosition(Vector(-2932,-1629,304))
      self:Schedule(SCHED_FORCED_GO)
      
      if not self.TT then
        self.TT = CurTime()
      end
      if self.TT and (CurTime() - self.TT > 20.0) then
        SafeRemoveEntity(self)
      end
    end

    self.NextActTime = CurTime() + 2.0
  elseif self:GetNPCState() == NPC_STATE_ALERT then
--    self:SetLastPosition( table.Random(self.walktable) + Vector( 0, 0, 40 ) )
--    self:SetLastPosition(Vector(10000,10000,10000))
--    self:Schedule( SCHED_FORCED_GO_RUN )
--    self.__delay = CurTime() + self.SchedDelay

    self.NextActTime = CurTime() + 2.0
  end
end

function ENT:OnTakeDamage(dmg)
  if self.Sitting then
    self:Task_EndSit()
  end

  -- Deal damage
  self:SpawnBlood(dmg)
  self:SetHealth(self:Health() - dmg:GetDamage())
  self:SetNPCState(NPC_STATE_ALERT)
  self:SelectSchedule()
  
  -- NPC in pain
  self:PlayOnce("pain")

  -- Kill NPC
  if (self:Health() <= 0) and (self:GetNPCState() ~= NPC_STATE_DEAD) then
    local ent = dmg:GetAttacker()
    if ent:IsValid() then
      self:SetVelocity(ent:GetVelocity())
    end

    self:SetNPCState(NPC_STATE_DEAD)
    self:ClearSchedule()
    self:Schedule(SCHED_FALL_TO_GROUND)
    SafeRemoveEntity(self)
  end
end

function ENT:SpawnBlood(dmg)
  local bloodeffect = ents.Create("info_particle_system")
  bloodeffect:SetKeyValue("effect_name", "blood_impact_red_01")
  bloodeffect:SetPos(dmg:GetDamagePosition())
  bloodeffect:Spawn()
  bloodeffect:Activate()
  bloodeffect:Fire("Start", "", 0)
  bloodeffect:Fire("Kill", "", 0.1)
end




--------------------------------------------------------------------------------
-- Interactivity with user
--------------------------------------------------------------------------------
function ENT:StartTouch(ent)
  if (self:GetNPCState() != NPC_STATE_ALERT) then
    if math.random() < 1/5 then self:PlayOnce("chat") end
  else
    self:PlayOnce("scared")
  end
end

function ENT:AcceptInput(what,who,who2)
  if what == "Use" then
    self:StartTouch(who)
  end
end




--------------------------------------------------------------------------------
function ENT:TaskStart_PlaySequence(data)
  local SequenceID = data.ID

  if data.Name then SequenceID = self:LookupSequence(data.Name) end
  self:ResetSequence(SequenceID)
  self:SetNPCState(NPC_STATE_SCRIPT)

  local Duration = self:SequenceDuration()
  if data.Speed and (data.Speed > 0) then
    SequenceID = self:SetPlaybackRate(data.Speed)
    Duration = Duration / data.Speed
  end
  Duration = data.Dur or Duration
  self.TaskSequenceEnd = CurTime() + Duration
  if Duration == NPCINF then
    self.InfiniteWait = true
  end
end


function ENT:Task_PlaySequence(data)
  -- Wait until sequence is finished
--  if (self.InfiniteWait == false) or (CurTime() >= self.TaskSequenceEnd) then
  if (self.AnimationAbortTime and (CurTime() > self.AnimationAbortTime)) or
     (CurTime() >= self.TaskSequenceEnd) then
    self:TaskComplete()
    self:SetNPCState(NPC_STATE_NONE)

    -- Clean up
    self.TaskSequenceEnd = nil
    self.InfiniteWait = nil
  end
end
