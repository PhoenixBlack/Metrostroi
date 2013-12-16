util.AddNetworkString("metrostroi-cabin-button")

if SERVER then
  resource.AddFile("materials/myproject/22_-_Default.vmt")
  resource.AddFile("materials/myproject/cyan_-_Default.vmt")
  resource.AddFile("materials/myproject/grey_-_Default.vmt")
  resource.AddFile("materials/myproject/test_-_Default.vmt")
  resource.AddFile("materials/myproject/blank.vtf")
  
  resource.AddFile("materials/Metrostroi/props/concretewall001a.vmt")
  resource.AddFile("materials/Metrostroi/props/concretewall010b.vmt")
  resource.AddFile("materials/Metrostroi/props/concretewall010c.vmt")
  resource.AddFile("materials/Metrostroi/props/concretewall060f.vmt")
  resource.AddFile("materials/Metrostroi/props/dev_measurehall01.vmt")
  resource.AddFile("materials/Metrostroi/props/dev_measurewall01a.vmt")
  resource.AddFile("materials/Metrostroi/props/metalhull003a.vmt")
  resource.AddFile("materials/Metrostroi/props/metalhull010b.vmt")
  resource.AddFile("materials/Metrostroi/props/metalwall030a.vmt")
  resource.AddFile("materials/Metrostroi/props/reflectivity_40.vmt")
  
  resource.AddFile("models/myproject/81-717_bogey.mdl")
  resource.AddFile("models/myproject/81-717_door_cab.mdl")
  resource.AddFile("models/myproject/81-717_door_passenger.mdl")
  resource.AddFile("models/myproject/81-717_engine_hull.mdl")
  resource.AddFile("models/myproject/81-717_passenger_hull.mdl")
  resource.AddFile("models/myproject/81-717_wheels.mdl")
  
  resource.AddFile("models/Metrostroi/props/picket.mdl")
  resource.AddFile("models/Metrostroi/props_models/light_2.mdl")
  resource.AddFile("models/Metrostroi/props_models/light_3.mdl")
  resource.AddFile("models/Metrostroi/props_models/light_2_2.mdl")
  resource.AddFile("models/Metrostroi/props_models/light_2_3.mdl")
  resource.AddFile("models/Metrostroi/props_models/light_2_outside.mdl")
  resource.AddFile("models/Metrostroi/props_models/light_3_outside.mdl")
    
  resource.AddFile("sound/subway_trains/81717_bpsn.wav")
  resource.AddFile("sound/subway_trains/81717_brake.wav")
  resource.AddFile("sound/subway_trains/81717_brake_hard.wav")
  resource.AddFile("sound/subway_trains/81717_brake_low.wav")
  resource.AddFile("sound/subway_trains/81717_door_close.wav")
  resource.AddFile("sound/subway_trains/81717_door_open.wav")
  resource.AddFile("sound/subway_trains/81717_engine.wav")
  resource.AddFile("sound/subway_trains/81717_horn.wav")
  resource.AddFile("sound/subway_trains/81717_kv1.wav")
  resource.AddFile("sound/subway_trains/81717_kv2.wav")
  resource.AddFile("sound/subway_trains/81717_kv3.wav")
  resource.AddFile("sound/subway_trains/81717_kv4.wav")
  resource.AddFile("sound/subway_trains/81717_release_slow.wav")
  resource.AddFile("sound/subway_trains/81717_run1.wav")
  resource.AddFile("sound/subway_trains/81717_run2.wav")
  resource.AddFile("sound/subway_trains/81717_run3.wav")
  resource.AddFile("sound/subway_trains/81717_start.wav")
  resource.AddFile("sound/subway_trains/81717_start_reverse.wav")
  resource.AddFile("sound/subway_trains/81717_switch.wav")
  resource.AddFile("sound/subway_trains/81717_warning.wav")
  resource.AddFile("sound/subway_trains/flange_1.wav")
  resource.AddFile("sound/subway_trains/flange_2.wav")
  resource.AddFile("sound/subway_trains/flange_3.wav")
  resource.AddFile("sound/subway_trains/flange_4.wav")
  resource.AddFile("sound/subway_trains/flange_5.wav")
  resource.AddFile("sound/subway_trains/flange_6.wav")
  resource.AddFile("sound/subway_trains/flange_7.wav")
  resource.AddFile("sound/subway_trains/flange_8.wav")
  
  resource.AddFile("sound/subway_trains/junct_1.wav")
  resource.AddFile("sound/subway_trains/junct_2.wav")
  resource.AddFile("sound/subway_trains/junct_3.wav")
  resource.AddFile("sound/subway_trains/junct_4.wav")
end

-- Create subway manager
Metrostroi = {}

-- Load everything else
if SERVER then
  include("metrostroi/sv_init.lua")
  include("metrostroi/sv_saveload.lua")
  include("metrostroi/sv_debug.lua")
  include("metrostroi/sv_telemetry.lua")
  
  -- Alpha tester stuff
  hook.Add("PlayerInitialSpawn", "Metrostroi_PlayerConnect", function(ply)
    local name = ply:GetName()
  
    local testers = file.Read("alpha_testers.txt") or ""
    local tbl = string.Explode("\r\n",testers)
  
    for k,v in pairs(tbl) do
      if v == name then return end
    end
    table.insert(tbl,name)
    file.Write("alpha_testers.txt",string.Implode("\r\n",tbl))
  end)
end
