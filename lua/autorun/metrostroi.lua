--------------------------------------------------------------------------------
-- Add all required clientside files
--------------------------------------------------------------------------------
if SERVER then
  util.AddNetworkString("metrostroi-cabin-button")

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
  resource.AddFile("materials/Metrostroi/props/metalstainless01.vmt")
  
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
  resource.AddFile("models/Metrostroi/props_models/train_wheel_test.mdl")
    
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

  resource.AddFile("sound/subway_announcer/00_00.mp3")
  resource.AddFile("sound/subway_announcer/00_01.mp3")
  resource.AddFile("sound/subway_announcer/00_02.mp3")
  resource.AddFile("sound/subway_announcer/01_01.mp3")
  resource.AddFile("sound/subway_announcer/01_02.mp3")
  resource.AddFile("sound/subway_announcer/02_01.mp3")
  resource.AddFile("sound/subway_announcer/02_02.mp3")
  resource.AddFile("sound/subway_announcer/02_03.mp3")
  resource.AddFile("sound/subway_announcer/02_04.mp3")
  resource.AddFile("sound/subway_announcer/02_05.mp3")
  
  resource.AddFile("sound/subway_announcer/05_01.mp3")
  resource.AddFile("sound/subway_announcer/05_02.mp3")
  resource.AddFile("sound/subway_announcer/05_03.mp3")
  resource.AddFile("sound/subway_announcer/05_04.mp3")
  resource.AddFile("sound/subway_announcer/05_05.mp3")
  resource.AddFile("sound/subway_announcer/05_06.mp3")
  resource.AddFile("sound/subway_announcer/05_07.mp3")
  resource.AddFile("sound/subway_announcer/05_08.mp3")
  
  resource.AddFile("sound/subway_announcer/06_08.mp3")
  resource.AddFile("sound/subway_announcer/06_09.mp3")
  resource.AddFile("sound/subway_announcer/06_10.mp3")
  resource.AddFile("sound/subway_announcer/06_11.mp3")
  resource.AddFile("sound/subway_announcer/06_12.mp3")
  resource.AddFile("sound/subway_announcer/06_13.mp3")
  resource.AddFile("sound/subway_announcer/06_14.mp3")
  resource.AddFile("sound/subway_announcer/06_15.mp3")
  resource.AddFile("sound/subway_announcer/06_16.mp3")
  resource.AddFile("sound/subway_announcer/06_17.mp3")
  resource.AddFile("sound/subway_announcer/06_18.mp3")
  resource.AddFile("sound/subway_announcer/06_19.mp3")
  resource.AddFile("sound/subway_announcer/06_20.mp3")
  resource.AddFile("sound/subway_announcer/06_21.mp3")
  resource.AddFile("sound/subway_announcer/06_22.mp3")
  resource.AddFile("sound/subway_announcer/06_23.mp3")
  
  resource.AddFile("sound/subway_announcer/07_15.mp3")
  
  resource.AddFile("sound/subway_announcer/08_01.mp3")

  resource.AddFile("sound/subway_announcer/11_01b.mp3")
  resource.AddFile("sound/subway_announcer/11_02b.mp3")
  resource.AddFile("sound/subway_announcer/11_03b.mp3")
  resource.AddFile("sound/subway_announcer/11_04b.mp3")
  resource.AddFile("sound/subway_announcer/11_05b.mp3")
  resource.AddFile("sound/subway_announcer/11_06b.mp3")
  resource.AddFile("sound/subway_announcer/11_07b.mp3")
  
  resource.AddFile("sound/subway_announcer/12_08b.mp3")
  resource.AddFile("sound/subway_announcer/12_09b.mp3")
  resource.AddFile("sound/subway_announcer/12_10b.mp3")
  resource.AddFile("sound/subway_announcer/12_11b.mp3")
  resource.AddFile("sound/subway_announcer/12_12b.mp3")
  resource.AddFile("sound/subway_announcer/12_13b.mp3")
  resource.AddFile("sound/subway_announcer/12_14b.mp3")
  resource.AddFile("sound/subway_announcer/12_15b.mp3")
  resource.AddFile("sound/subway_announcer/12_16b.mp3")
  resource.AddFile("sound/subway_announcer/12_17b.mp3")
  resource.AddFile("sound/subway_announcer/12_18b.mp3")
  resource.AddFile("sound/subway_announcer/12_19b.mp3")
  resource.AddFile("sound/subway_announcer/12_20b.mp3")
  resource.AddFile("sound/subway_announcer/12_21b.mp3")
  resource.AddFile("sound/subway_announcer/12_22b.mp3")
  resource.AddFile("sound/subway_announcer/12_23b.mp3")

  resource.AddFile("sound/subway_announcer/13_15b.mp3")
end


--------------------------------------------------------------------------------
-- Create subway manager
--------------------------------------------------------------------------------
if not Metrostroi then
  -- Subway manager
  Metrostroi = {}
  
  -- List of all systems
  Metrostroi.Systems = {}
end


--------------------------------------------------------------------------------
-- Load core files
--------------------------------------------------------------------------------
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


--------------------------------------------------------------------------------
-- Load systems (shared)
--------------------------------------------------------------------------------
local function LoadSystem(cond,name)
  if not cond then return end

  include("metrostroi/systems/sys_"..string.lower(name)..".lua")
  
  Metrostroi.Systems["_"..name] = TRAIN_SYSTEM
  Metrostroi.Systems[name] = function(train)
    local tbl = { _base = "_"..name }
    for k,v in pairs(TRAIN_SYSTEM) do
      if type(v) == "function" then
        tbl[k] = function(...) return Metrostroi.Systems[tbl._base][k](...) end
      else
        tbl[k] = v
      end
    end
    
    tbl.Train = train
    tbl:Initialize()
    return tbl
  end
end

function Metrostroi.DefineSystem(name)
  if not Metrostroi.Systems["_"..name] then
    Metrostroi.Systems["_"..name] = {}
  end
  TRAIN_SYSTEM = Metrostroi.Systems["_"..name]
end

-- Load systems
LoadSystem(SERVER,"Announcer")
