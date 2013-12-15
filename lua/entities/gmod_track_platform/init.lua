AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")




--------------------------------------------------------------------------------
function ENT:Initialize()
  -- Invisible point entity
  --
  -- StationName = "Asdasd"
  -- StationIndex = "110"
  --
  -- Width of the platform
  --  PlatformWidth
  --
  -- Points to define platform start/end area:
  --  LeftPlatformStart = info_target
  --  LeftPlatformEnd
  --  RightPlatformStart
  --  RightPlatformEnd
  --
  -- Points to define spawn/despawn area:
  --  StationEntry_North_Start
  --  StationEntry_North_End
  --  StationEntry_South_Start
  --  StationEntry_South_End
--  self:SetSolid(SOLID_VPHYSICS)
--  self:SetModel(model["pole"])

  -- Find all entities
--  print("INITIALIZE",self._LeftPlatformStart)
--  PrintTable(ents.FindByName(self._LeftPlatformStart))
  self.LeftPlatformStart  = ents.FindByName(self._LeftPlatformStart)[1]
  self.LeftPlatformEnd    = ents.FindByName(self._LeftPlatformEnd)[1]
  self.RightPlatformStart = ents.FindByName(self._RightPlatformStart)[1]
  self.RightPlatformEnd   = ents.FindByName(self._RightPlatformEnd)[1]

end

function ENT:KeyValue(key, value)
  -- Fix names
  if string.sub(key,1,7) == "Station" then key = string.gsub(key," ","_") end
  
  -- Create variables
  self["_"..key] = value
  print("Station",key,"=",value)
end

function ENT:Think()
--  if self.LeftPlatformStart then
--    print("STATION",self.LeftPlatformStart:GetPos())
--  end
  
--  local data = self:GetKeyValues()
--  for k,v in pairs(data) do
--    print(k,v)
--  end
  self:NextThink(1.0)
  return true
end
