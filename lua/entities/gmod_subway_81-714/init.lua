AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.WireDebugName = "81-714"




--------------------------------------------------------------------------------
function ENT:Initialize()
  self.PassengerWagon = true
  self.BaseClass.Initialize(self)
  self:SetModel("models/myproject/81-717_passenger_hull.mdl")
end
