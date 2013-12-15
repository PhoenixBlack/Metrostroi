function Metrostroi.Save(format)
  format = format or "lua"
  if not SERVER then return end
  
  local text = "local ent\r\n"
  local equipment = ents.FindByClass("gmod_track_equipment")
  for k,v in pairs(equipment) do
    text = text..(v:GetSavedText("lua") or "")
    text = text.."\r\n"
  end
  
  local clocks = ents.FindByClass("gmod_track_clock")
  for k,v in pairs(clocks) do
    text = text..(v:GetSavedText("lua") or "")
    text = text.."\r\n"
  end
  
  local filename = filename or ("metrostroi_signs/"..game.GetMap()..".txt")
  local bak = file.Read(filename) or ""
  local idx = 1
  while file.Read(filename.."_"..idx..".txt") do idx = idx + 1 end
  file.Write(filename.."_"..idx..".txt",bak)
  file.Write(filename,text)
  print("Saved track signals and signs")
end


function Metrostroi.Load(filename)
  filename = filename or ("metrostroi_signs/"..game.GetMap()..".txt")
  print("Loading track signals and signs from",filename)
  
  -- Inhibit making new picket signs or removing them
  Metrostroi.InhibitSectionUpdates = true
  
  local equipment = ents.FindByClass("gmod_track_equipment")
  for k,v in pairs(equipment) do
    SafeRemoveEntity(v)
  end
  local clocks = ents.FindByClass("gmod_track_clock")
  for k,v in pairs(clocks) do
    SafeRemoveEntity(v)
  end

  timer.Create("Metrostroi_LoadLua",0.05,1,function()
    -- Remove all crap
    Metrostroi.PicketSignByIndex = {}
    Metrostroi.PicketSigns = {}
    Metrostroi.TrafficLightPositions = {}
    Metrostroi.TrafficLightsAtSection = {}
    Metrostroi.EquipmentID = 1
    
    -- Read entities from file
    if filename then
      local code = file.Read(filename)
      if code then RunString(code) else print("Read error",filename) end
    end
    
    -- Fix links between pickets
    Metrostroi.PicketSignByIndex = {}
    Metrostroi.PicketSigns = {}
  
    local equipment = ents.FindByClass("gmod_track_equipment")
    for k,v in pairs(equipment) do
      if v.IsPicketSign then
        Metrostroi.AddPicketSign(v,v.Index)
      end
    end
    
    -- Quickly check and fix any bad links
    local equipment = ents.FindByClass("gmod_track_equipment")
    for k,v in pairs(equipment) do
      if v.IsPicketSign then
        if v.NextIndex then
          if (not Metrostroi.PicketSignByIndex[v.NextIndex]) or
             (Metrostroi.PicketSignByIndex[v.NextIndex].PreviousIndex ~= v.Index) then
            print("WARNING: Bad next link in sign",v.Index)
            if Metrostroi.PicketSignByIndex[v.NextIndex] then
              Metrostroi.PicketSignByIndex[v.NextIndex].PreviousIndex = v.Index
            else
              v.NextIndex = nil
            end
          end
        end
        if v.PreviousIndex then
          if (not Metrostroi.PicketSignByIndex[v.PreviousIndex]) or
             (Metrostroi.PicketSignByIndex[v.PreviousIndex].NextIndex ~= v.Index) then
            print("WARNING: Bad prev link in sign",v.Index)
            v.PreviousIndex = nil
          end
        end
      end
    end
    
    -- Connect pickets
    for k,v in pairs(equipment) do
      if v.IsPicketSign then
        if v.NextIndex then
          v:SetNextPicket(Metrostroi.PicketSignByIndex[v.NextIndex])
        end
        if v.PreviousIndex then
          v:SetPreviousPicket(Metrostroi.PicketSignByIndex[v.PreviousIndex])
        end
        if v.AlternateIndex then
          v:SetAlternatePicket(Metrostroi.PicketSignByIndex[v.AlternateIndex])
        end
      end
      if v.NearestIndex then
        v:SetNearestPicket(Metrostroi.PicketSignByIndex[v.NearestIndex])
      end
    end

    Metrostroi.InhibitSectionUpdates = false
    Metrostroi.UpdateSections()
    Metrostroi.UpdateTrafficLightPositions()
  end)
end

hook.Add("Initialize", "Metrostroi_MapInitialize", function()
  Metrostroi.Load("metrostroi_signs/"..game.GetMap()..".txt")
end)

concommand.Add("metrostroi_save", function(ply, _, args)
--  if plyply:SteamID() ~= "STEAM_0:1:11146643" then return end
  Metrostroi.Save()
end)

concommand.Add("metrostroi_load", function(ply, _, args)
--  if ply:SteamID() ~= "STEAM_0:1:11146643" then return end
  Metrostroi.Load()
end)


--Metrostroi.LoadLua("metrotrain_signs/gm_metrostroi_b7.txt")
--Metrostroi.Save(lua)
