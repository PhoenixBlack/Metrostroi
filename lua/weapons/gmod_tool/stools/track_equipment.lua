TOOL.Category   = "Subway Tools"
TOOL.Name       = "Track Equipment"
TOOL.Command    = nil
TOOL.ConfigName = ""
--TOOL.Tab    = "Wire"

if CLIENT then
   language.Add("Tool.track_equipment.name", "Track Equipment Tool" )
  language.Add("Tool.track_equipment.desc", "Adds and modifies track equipment" )
  language.Add("Tool.track_equipment.0", "Primary: Create or modify sign\nReload:Link track switch or set alternate picket\nSecondary: Link pickets (or create next linked picket)" )
--    language.Add("WireNamerTool_name", "Name:" )
end

TOOL.ClientConVar["pole_mount"] = 0
TOOL.ClientConVar["sign_index"] = ""
TOOL.ClientConVar["speed_limit"] = 0
TOOL.ClientConVar["section_length"] = 0
TOOL.ClientConVar["track_slope"] = 0
TOOL.ClientConVar["brake_zone"] = 0
TOOL.ClientConVar["danger_zone"] = 0
TOOL.ClientConVar["picket_sign"] = 0
TOOL.ClientConVar["add_tlight"] = 0
TOOL.ClientConVar["traffic_light"] = "RYG"


function TOOL:LeftClick(trace)
  if (self:GetOwner():IsValid()) and (self:GetOwner():SteamID() ~= "STEAM_0:1:11146643") then return end
  if not trace then return false end
  if CLIENT then return true end
  if trace.Entity and trace.Entity:IsPlayer() then return false end
  if trace.Entity:GetClass() == "gmod_track_equipment" then
    if trace.Entity.IsPicketSign then
      if self.SelectedEquipment and self.SelectedEquipment:IsValid() then
        print("Set nearest picket")
        self.SelectedEquipment:SetNearestPicket(trace.Entity)
        Metrostroi.UpdateTrafficLightPositions()
      end
      self.SelectedEquipment = nil
    else
      self.SelectedEquipment = trace.Entity
    end
    return true
  end
  self.SelectedEquipment = nil
  
  local player = self:GetOwner()
  local pos,ang = trace.HitPos,trace.HitNormal:Angle() + Angle(90,180,0)
  
  -- Rotate sign properly
  local pole_mount = (self:GetClientNumber("pole_mount") == 1) or (self:GetClientNumber("add_tlight") == 1)
  if pole_mount == false then
    ang = trace.HitNormal:Angle() + Angle(0,90,0)
  else
    ang = trace.HitNormal:Angle() + Angle(90,180,0)
  end
  
  -- Added players angle
  if pole_mount == true then
    local player_angle = player:GetAngles().y
    player_angle = math.floor(player_angle / 11.25 + 0.5) * 11.25
    ang.y = ang.y + player_angle
  end

  -- Spawn track equipment
  local tlight = self:GetClientInfo("traffic_light")
  if self:GetClientNumber("add_tlight") == 0 then tlight = nil end
  local ent = MakeSubwayTrackEquipment(player,pos,ang,
    self:GetClientNumber("pole_mount"),
    self:GetClientInfo("sign_index"),
    self:GetClientNumber("speed_limit"),
    self:GetClientNumber("section_length"),
    self:GetClientNumber("track_slope"),
    self:GetClientNumber("brake_zone"),
    self:GetClientNumber("danger_zone"),
    self:GetClientNumber("picket_sign"),
    tlight)
  if ((not ent) or (not ent:IsValid())) then return false end
  self.LastPicket = self.CurrentPicket
  self.CurrentPicket = ent
  
  if ent.ExtraEnts[1] then self.CurrentPicket = ent.ExtraEnts[1] end
  
  -- Move sign properly
  local min = ent:OBBMins()
  if ent.IsPicketSign then
    ent:SetPos(pos)
  else
    ent:SetPos(pos - trace.HitNormal * min.z)
  end

  -- Add to undo
  undo.Create("gmod_track_equipment")
    undo.AddEntity(ent)
    undo.SetPlayer(player)
  undo.Finish()

  --player:AddCleanup( "wire_dhdds", dhdd )
  return true
end


function TOOL:RightClick(trace)
  if (self:GetOwner():IsValid()) and (self:GetOwner():SteamID() ~= "STEAM_0:1:11146643") then return end
  if not trace then return false end
  if CLIENT then return true end
  if trace.Entity then
    if trace.Entity.TrafficLight then
      trace.Entity.RedOnAlternateTrack = not (trace.Entity.RedOnAlternateTrack or false)
      print("Set RedOnAlternateTrack:",trace.Entity.RedOnAlternateTrack)
      self.RightMode = 1
      return true
    end
        
    if (self.RightMode == 2) and (trace.Entity == self.FirstPicket) then
      if self.FirstPicket and self.FirstPicket:IsValid() then
        print("Reset next picket")
        self.FirstPicket:SetNextPicket(nil)
        Metrostroi.UpdateSections()
      end
      self.RightMode = 1
      return true
    end
  end
  if trace.Entity:GetClass() ~= "gmod_track_equipment" then
    self.RightMode = 1
    
    -- Spawn and link to previous picket
    self:LeftClick(trace)
    
    if self.CurrentPicket and self.CurrentPicket:IsValid() and
       self.LastPicket and self.LastPicket:IsValid() then
       
      print("Set next picket (appended)")
      self.LastPicket:SetNextPicket(self.CurrentPicket)
      self.CurrentPicket:SetPreviousPicket(self.LastPicket)
      Metrostroi.UpdateSections()
    end
    return true
  end
  if trace.Entity.IsPicketSign ~= true then
    if self.FirstPicket and self.FirstPicket:IsValid() then
      print("Reset next picket")
      self.FirstPicket:SetNextPicket(nil)
      Metrostroi.UpdateSections()
    end
    self.FirstPicket = nil
    self.RightMode = 1
    return true
  end
  
  -- Link up two picket signs
  self.RightMode = self.RightMode or 1
  if self.RightMode == 1 then
    self.RightMode = 2
    self.FirstPicket = trace.Entity
  elseif self.RightMode == 2 then
    if self.FirstPicket and self.FirstPicket:IsValid() then
      if self.FirstPicket ~= trace.Entity then
        print("Set next picket")
        self.FirstPicket:SetNextPicket(trace.Entity)
        trace.Entity:SetPreviousPicket(self.FirstPicket)
        self.LastPicket = trace.Entity
      else
        print("Reset next picket")
        self.FirstPicket:SetNextPicket(nil)
      end
      Metrostroi.UpdateSections()
    end
    self.FirstPicket = nil
    self.RightMode = 1
  else
    self.FirstPicket = nil
    self.RightMode = 1
  end

  return true
end

function TOOL:Reload(trace)
  if (self:GetOwner():IsValid()) and (self:GetOwner():SteamID() ~= "STEAM_0:1:11146643") then return end
  if not trace then return false end
  if CLIENT then return true end
  if trace.Entity and (trace.Entity:GetClass() == "prop_door_rotating") and (self.FirstPicket) then
    print("Linked track switch",trace.Entity:GetName())
    self.FirstPicket:SetTrackSwitch(trace.Entity)
    self.FirstPicket = nil
    self.ReloadMode = 1
    return true
  end
  if trace.Entity and (trace.Entity:IsPlayer() or (trace.Entity == self.FirstPicket)) then
    if self.ReloadMode == 2 then
      if self.FirstPicket and self.FirstPicket:IsValid() then
        print("Reset alternate picket")
        self.FirstPicket:SetAlternatePicket(nil)
        Metrostroi.UpdateSections()
      end
    end
    self.FirstPicket = nil
    self.ReloadMode = 1
    return true
  end
  
  if trace.Entity:GetClass() ~= "gmod_track_equipment" then self.ReloadMode = 1 return true end
  if trace.Entity.IsPicketSign ~= true then self.ReloadMode = 1 return true end

  -- Link up two picket signs
  self.ReloadMode = self.ReloadMode or 1
  if self.ReloadMode == 1 then
    self.ReloadMode = 2
    self.FirstPicket = trace.Entity
  elseif self.ReloadMode == 2 then
    if self.FirstPicket and self.FirstPicket:IsValid() then
      print("Set alternate picket")
      self.FirstPicket:SetAlternatePicket(trace.Entity)
      trace.Entity:SetAlternatePicket(self.FirstPicket)
    else
      print("Reset alternate picket")
      self.FirstPicket:SetAlternatePicket(nil)
    end
    Metrostroi.UpdateSections()
    self.FirstPicket = nil
    self.ReloadMode = 1
  else
    self.FirstPicket = nil
    self.ReloadMode = 1
  end

  return true
end

function TOOL:Think()
  if SERVER then
    if self.CurrentPicket and self.CurrentPicket:IsValid() then
      local trace = self:GetOwner():GetEyeTrace()
      if trace then
       -- print("D = ",(trace.HitPos - self.CurrentPicket:GetPos()):Length()*0.01905)
      end
    end
  end
end


function TOOL.BuildCPanel(panel)
  panel:AddControl("Header", { Text = "#Tool.track_equipment.name", Description = "#Tool.track_equipment.desc" })

  panel:AddControl("Checkbox", {
    Label = "Should the sign/signal be mounted on a pole",
    Command = "track_equipment_pole_mount"
  })
  
  panel:AddControl("TextBox", {
    Label = "Index of sign",
    Command = "track_equipment_sign_index",
    MaxLength = "5"
  })
  
  panel:AddControl("Label", {Text = "Create additional signs:"})

  panel:AddControl("Slider", {
    Label = "Speed Limit (0 - disabled, km/h)",
    Type = "Integer",
    Min = "0",
    Max = "90",
    Command = "track_equipment_speed_limit"
  })
  
  panel:AddControl("Slider", {
    Label = "Track slope (0 - disabled, degrees)",
    Type = "Integer",
    Min = "-15",
    Max = "15",
    Command = "track_equipment_track_slope"
  })
  
  panel:AddControl("Slider", {
    Label = "Length of following slope or danger section (0 - disabled, meters)",
    Type = "Integer",
    Min = "0",
    Max = "999",
    Command = "track_equipment_section_length"
  })
  
  panel:AddControl("Checkbox", {
    Label = "Brake Zone",
    Command = "track_equipment_brake_zone"
  })
  
  panel:AddControl("Checkbox", {
    Label = "Danger Zone",
    Command = "track_equipment_danger_zone"
  })

  panel:AddControl("Checkbox", {
    Label = "Picket Sign (do not use with other signs)",
    Command = "track_equipment_picket_sign"
  })
  
  panel:AddControl("Label", {Text = "Traffic lights related:"})
  
  panel:AddControl("Checkbox", {
    Label = "Add traffic light",
    Command = "track_equipment_add_tlight"
  })
  panel:AddControl("ComboBox", {
    Label = "Traffic light",
    Options = {
      ["G-R"]               = { track_equipment_traffic_light = "GR" },
      ["G-R (Outside)"]     = { track_equipment_traffic_light = "GR_O" },
      
      ["Y-R"]               = { track_equipment_traffic_light = "YR" },
      ["Y-R (Outside)"]     = { track_equipment_traffic_light = "YR_O" },
      
      ["Y-G-R"]             = { track_equipment_traffic_light = "YGR" },
      ["Y-G-R (Outside)"]   = { track_equipment_traffic_light = "YGR_O" },
      
      ["Y-G Y-R"]           = { track_equipment_traffic_light = "YG_YR" },
      ["Y-G Y-R (Outside)"] = { track_equipment_traffic_light = "YG_YR_O" },
      
      ["B-Y G-R"]           = { track_equipment_traffic_light = "BY_GR" },
      ["B-Y-G R-Y"]         = { track_equipment_traffic_light = "BYG_RY" },

    }
  })
end
