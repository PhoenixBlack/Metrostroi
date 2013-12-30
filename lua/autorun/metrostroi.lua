--------------------------------------------------------------------------------
-- Add all required clientside files
--------------------------------------------------------------------------------
local function resource_AddDir(dir)
	local files,dirs = file.Find(dir.."/*","GAME")
	for _, fdir in pairs(dirs) do
		resource_AddDir(dir.."/"..fdir)
	end
 
	for k,v in pairs(files) do
		print("ADD",dir.."/"..v)
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
	Metrostroi.Systems[name] = function(train)
		local tbl = { _base = "_"..name }
		for k,v in pairs(TRAIN_SYSTEM) do
			if type(v) == "function" then
				tbl[k] = function(...) return Metrostroi.Systems[tbl._base][k](...) end
			else
				tbl[k] = v
			end
		end
		
		tbl.Initialize = tbl.Initialize or function() end
		tbl.ClientInitialize = tbl.ClientInitialize or function() end
		tbl.Think = tbl.Think or function() end
		tbl.ClientThink = tbl.ClientThink or function() end
		tbl.ClientDraw = tbl.ClientDraw or function() end
		tbl.WireInputs = tbl.WireInputs or function() return {} end
		tbl.WireOutputs = tbl.WireOutputs or function() return {} end
		tbl.TriggerInput = tbl.TriggerInput or function() end
		
		tbl.Train = train
		if SERVER then
			tbl:Initialize()
		else
			tbl:ClientInitialize()
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
LoadSystem("Announcer")
LoadSystem("Controller")
