AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")




--------------------------------------------------------------------------------
function ENT:Initialize()
  self:SetModel("models/props_wasteland/prison_heater002a.mdl")
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetMoveType(MOVETYPE_NONE)
  self:SetSolid(SOLID_VPHYSICS)
  self:SetNWBool("OutdoorClock",self.ClockType == "outdoor")
  self:SetNWFloat("IntervalResetTime",-1e9)
end

function ENT:Think()
  -- Check if train passes the sign
  local sensingTrain = false
  for ray=0,6 do
    local trace = {
      start = self:GetPos() + self:GetForward()*16 + self:GetRight()*50*(ray-3),
      endpos = self:GetPos() + self:GetForward()*16 + self:GetRight()*50*(ray-3) - Vector(0,0,256),
      mask = -1,
      filter = { self },
    }
    
    local result = util.TraceLine(trace)
    if (result.Hit) and (not result.HitWorld) then
      if result.Entity and (not result.Entity:IsPlayer()) then
        sensingTrain = true
      end
    end
  end
      
  -- React when there is train, but there was no train before
  if sensingTrain then
    self.PrevSensingTime = self.PrevSensingTime or CurTime()
    
    if (self.PrevSensingTime - CurTime() < 2.0) and (self.IntervalReset == false) then
      self.IntervalReset = true
      self:SetNWFloat("IntervalResetTime",CurTime())
    end
    self.PrevSensingTime = CurTime()
  else
    if CurTime() - (self.PrevSensingTime or 0) > 2.0 then
      self.IntervalReset = false
    end
  end

--  self:SetNWInt("ServerTime",os.time()-1386187182)
  self:NextThink(CurTime() + 1.0)
  return true
end

function ENT:GetSavedText(format)
  if format == "lua" then
    local pos = self:GetPos()
    local ang = self:GetAngles()
    local source = "ent = MakeSubwayClock(player,"
    source = source.."Vector("..(pos.x or 0)..","..(pos.y or 0)..","..(pos.z or 0).."),"
    source = source.."Angle("..(ang.x or 0)..","..(ang.y or 0)..","..(ang.z or 0).."),"
    source = source.."\""..(self.ClockType or "tunnel").."\")\r\n"
    return source
  end
end

function MakeSubwayClock(player, pos, ang, type)
  local ent = ents.Create("gmod_track_clock")
  ent.ClockType = type
  ent:SetPlayer(player)
  ent:SetPos(pos)
  ent:SetAngles(ang)
  ent:Spawn()
  return ent
end
