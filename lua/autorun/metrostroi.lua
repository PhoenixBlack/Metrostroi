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
	resource_AddDir("materials/models/metrostroi_passengers")
	resource_AddDir("materials/models/metrostroi_signals")

	resource_AddDir("models/metrostroi/81-717")
	resource_AddDir("models/metrostroi/e")
	resource_AddDir("models/metrostroi/81")
	resource_AddDir("models/metrostroi/metro")
	resource_AddDir("models/metrostroi/passengers")
	resource_AddDir("models/metrostroi/signals")
	resource_AddDir("models/metrostroi/tatra_t3")
	
	resource_AddDir("sound/subway_trains")
	resource_AddDir("sound/subway_announcer")
end


--------------------------------------------------------------------------------
-- Create metrostroi global library
--------------------------------------------------------------------------------
if not Metrostroi then
	-- Global library
	Metrostroi = {}
	
	-- Supported train classes
	Metrostroi.TrainClasses = {}
	Metrostroi.IsTrainClass = {}
	timer.Simple(0.05, function() 
		for name,ent_base in pairs(scripted_ents.GetList()) do
			local prefix = "gmod_subway_"
			if string.sub(name,1,#prefix) == prefix then
				table.insert(Metrostroi.TrainClasses,name)
				Metrostroi.IsTrainClass[name] = true
			end
		end
	end)
	
	-- List of all systems
	Metrostroi.Systems = {}
	Metrostroi.BaseSystems = {}
end


--------------------------------------------------------------------------------
-- Load core files
--------------------------------------------------------------------------------
if SERVER then
	DISABLE_TURBOSTROI = true
	if not DISABLE_TURBOSTROI then
		print("Metrostroi: Trying to load simulation acceleration DLL...")
		
		--TODO: OS specific check
		if file.Exists("lua/bin/gmsv_turbostroi_win32.dll", "GAME") then
			require("turbostroi")
		else
			print("Metrostroi: Turbostroi DLL not not found")
		end
	else
		Turbostroi = nil
	end
	
	if Turbostroi 
	then print("Metrostroi: Simulation acceleration ENABLED!")
	else print("Metrostroi: Simulation acceleration DISABLED")
	end

	-- Load all serverside lua files
	local files = file.Find("metrostroi/sv_*.lua","LUA")
	for _,filename in pairs(files) do include("metrostroi/"..filename) end
	-- Load all shared files serverside
	local files = file.Find("metrostroi/sh_*.lua","LUA")
	for _,filename in pairs(files) do include("metrostroi/"..filename) end

	-- Add all clientside files
	local files = file.Find("metrostroi/cl_*.lua","LUA")
	for _,filename in pairs(files) do AddCSLuaFile("metrostroi/"..filename) end
	-- Add all shared files
	local files = file.Find("metrostroi/sh_*.lua","LUA")
	for _,filename in pairs(files) do AddCSLuaFile("metrostroi/"..filename) end
	-- Add all system files
	local files = file.Find("metrostroi/systems/sys_*.lua","LUA")
	for _,filename in pairs(files) do AddCSLuaFile("metrostroi/systems/"..filename) end
else
	-- Load all clientside files
	local files = file.Find("metrostroi/cl_*.lua","LUA")
	for _,filename in pairs(files) do include("metrostroi/"..filename) end
	
	-- Load all shared files
	local files = file.Find("metrostroi/sh_*.lua","LUA")
	for _,filename in pairs(files) do include("metrostroi/"..filename) end
end




--------------------------------------------------------------------------------
-- Load systems
--------------------------------------------------------------------------------
if not Metrostroi.TurbostroiRegistered then
	Metrostroi.TurbostroiRegistered = {}
end

function Metrostroi.DefineSystem(name)
	if not Metrostroi.BaseSystems[name] then
		Metrostroi.BaseSystems[name] = {}
	end
	TRAIN_SYSTEM = Metrostroi.BaseSystems[name]
	TRAIN_SYSTEM_NAME = name
end

local function loadSystem(filename)
	-- Get the Lua code
	include(filename)
	
	-- Load train systems
	if TRAIN_SYSTEM then TRAIN_SYSTEM.FileName = filename end
	local name = TRAIN_SYSTEM_NAME or "UndefinedSystem"
	TRAIN_SYSTEM_NAME = nil
	
	-- Register system with turbostroi
	if Turbostroi and (not Metrostroi.TurbostroiRegistered[name]) then
		Turbostroi.RegisterSystem(name,filename) 
		Metrostroi.TurbostroiRegistered[name] = true
	end

	-- Load up the system
	Metrostroi.Systems["_"..name] = TRAIN_SYSTEM
	Metrostroi.BaseSystems[name] = TRAIN_SYSTEM
	Metrostroi.Systems[name] = function(train,...)
		local tbl = { _base = name }
		local TRAIN_SYSTEM = Metrostroi.BaseSystems[tbl._base]
		if not TRAIN_SYSTEM then print("No system: "..tbl._base) return end
		for k,v in pairs(TRAIN_SYSTEM) do
			if type(v) == "function" then
				tbl[k] = function(...) 
					if not Metrostroi.BaseSystems[tbl._base][k] then
						print("ERROR",k,tbl._base)
					end
					return Metrostroi.BaseSystems[tbl._base][k](...) 
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
		tbl.OutputsList = tbl:Outputs()
		tbl.InputsList = tbl:Inputs()
		tbl.IsInput = {}
		for k,v in pairs(tbl.InputsList) do tbl.IsInput[v] = true end
		return tbl
	end
end

-- Load all systems
local files = file.Find("metrostroi/systems/sys_*.lua","LUA")
for _,short_filename in pairs(files) do 
	local filename = "metrostroi/systems/"..short_filename
	
	-- Load the file
	if SERVER 
	then loadSystem(filename)
	else timer.Simple(0.05, function() loadSystem(filename) end)
	end
end
