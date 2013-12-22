ENT.Type            = "anim"
ENT.Base            = "base_gmodentity"

ENT.PrintName       = "Track Equipment"
ENT.Author          = ""
ENT.Contact         = ""
ENT.Purpose         = ""
ENT.Instructions    = ""

ENT.Spawnable       = false
ENT.AdminSpawnable  = false
ENT.Editable        = true

function ENT:SetupDataTables()
  self:NetworkVar("Bool", 0, "PropDisabled", { KeyName = "kva", Edit = {
    title = "Inoperational",
    category = "Traffic Light",
    type = "Boolean" } } )
    
  self:NetworkVar("Bool", 1, "PropRedOnAlternateTrack", { KeyName = "kvb", Edit = {
    title = "Red on alternate track?",
    category = "Traffic Light",
    type = "Boolean" } } )
    
  self:NetworkVar("Bool", 2, "PropOverrideToRed", { KeyName = "kvc", Edit = {
    title = "Always red?",
    category = "Traffic Light",
    type = "Boolean" } } )
    
  if SERVER then
    self:NetworkVarNotify("PropOverrideToRed",       self.OnVariableChanged)
    self:NetworkVarNotify("PropDisabled",            self.OnVariableChanged)
    self:NetworkVarNotify("PropRedOnAlternateTrack", self.OnVariableChanged)
  end
end

function ENT:CanEditVariables(ply)
  return true
--  return ply:IsAdmin()
end

--function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS end
