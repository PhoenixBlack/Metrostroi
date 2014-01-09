--------------------------------------------------------------------------------
-- Add all required clientside files
--------------------------------------------------------------------------------
local function resource_AddDir(dir)
	local files,dirs = file.Find(dir.."/*","GAME")
	for _, fdir in pairs(dirs) do
		resource_AddDir(dir.."/"..fdir)
	end
 
	for k,v in pairs(files) do
		resource.AddFile(dir.."/"..v)
	end
end

if SERVER then
	util.AddNetworkString("metrostroi-cabin-button")
	util.AddNetworkString("metrostroi-cabin-reset")
	
	resource_AddDir("materials/metrostroi/props")
	resource_AddDir("materials/models/metrostroi_train")
	resource_AddDir("materials/myproject")
	
	resource_AddDir("models/metrostroi/props_models")
	resource_AddDir("models/metrostroi/props")
	resource_AddDir("models/metrostroi/81-705")
	resource_AddDir("models/metrostroi/81-717")
	resource_AddDir("models/myproject")
	
	resource_AddDir("sound/subway_trains")
	resource_AddDir("sound/subway_announcer")
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
	include("metrostroi/sv_railnetwork.lua")
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
-- Load shared files
--------------------------------------------------------------------------------
AddCSLuaFile("metrostroi/sh_failsim.lua")
if SERVER then
	include("metrostroi/sh_failsim.lua")
else
	timer.Simple(0.05, function() include("metrostroi/sh_failsim.lua") end)
end


--------------------------------------------------------------------------------
-- Load systems
--------------------------------------------------------------------------------
local function LoadSystem(name)
	local filename = "metrostroi/systems/sys_"..string.lower(name)..".lua"
	
	-- Make the file shared
	AddCSLuaFile(filename)
	if SERVER then
		include(filename)
	else
		timer.Simple(0.05, function() include(filename) end)
	end
	
	-- Load train systems
	Metrostroi.Systems["_"..name] = TRAIN_SYSTEM
	Metrostroi.Systems[name] = function(train,...)
		local tbl = { _base = "_"..name }
		local TRAIN_SYSTEM = Metrostroi.Systems[tbl._base]
		--if not TRAIN_SYSTEM then error("No system: "..tbl._base) end
		for k,v in pairs(TRAIN_SYSTEM) do
			if type(v) == "function" then
				tbl[k] = function(...) 
					if not Metrostroi.Systems[tbl._base][k] then
						print("ERROR",k,tbl._base)
					end
					return Metrostroi.Systems[tbl._base][k](...) 
				end
			else
				tbl[k] = v
			end
		end
		
		tbl.Initialize = tbl.Initialize or function() end
		tbl.ClientInitialize = tbl.ClientInitialize or function() end
		tbl.Think = tbl.Think or function() end
		tbl.ClientThink = tbl.ClientThink or function() end
		tbl.ClientDraw = tbl.ClientDraw or function() end
		tbl.Inputs = tbl.Inputs or function() return {} end
		tbl.Outputs = tbl.Outputs or function() return {} end
		tbl.TriggerOutput = tbl.TriggerOutput or function() end
		tbl.TriggerInput = tbl.TriggerInput or function() end
		
		tbl.Train = train
		if SERVER then
			tbl:Initialize(...)
		else
			tbl:ClientInitialize(...)
		end
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
--LoadSystem("Announcer")
--LoadSystem("Controller")
LoadSystem("Fuse")
LoadSystem("Relay")

--LoadSystem("81_717_Electric")
--LoadSystem("AK_63B_Relays")
--LoadSystem("BPSN_5U2M")

--LoadSystem("NK_80")
--LoadSystem("YAK_36")
--LoadSystem("YAK_37E")

LoadSystem("81_717_Pneumatic")
LoadSystem("81_705_Electric")
LoadSystem("DK_117DM")
LoadSystem("TR_3B")
LoadSystem("YAP_57")
LoadSystem("EKG_17B")
LoadSystem("KF_47A")
LoadSystem("GV_10ZH")
LoadSystem("KV_66")
