--------------------------------------------------------------------------------
-- Metrostroi simulation acceleration DLL support
--------------------------------------------------------------------------------
local function split(inputstr, sep)
	if sep == nil then sep = "%s" end

	local t = {} i=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do 
		t[i] = str
		i = i + 1
	end return t
end

if not TURBOSTROI then
	hook.Add("Think", "Turbostroi_Think", function()
		if Turbostroi then 
			Turbostroi.SetSimulationFPS(66)
			if not Turbostroi.Initialized then
				--Turbostroi.SetSimulationTime(CurTime())
				Turbostroi.Initialized = true

				Turbostroi.TriggerInput = function(train,system,name,value)
					local v = value
					if type(v) == "boolean" then
						if v then v = "true" else v = "false" end
					end
					v = tostring(v) or "0"
					Turbostroi.TrainData[train] = Turbostroi.TrainData[train]..
						"T\t"..system.."\t"..name.."\t"..v.."\n"
				end
			end
			
			-- Add outputs of all systems
			for train,send_data in pairs(Turbostroi.TrainData) do
				for k,v in pairs(train.Systems) do
					if v.DontAccelerateSimulation then
						for k2,v2 in pairs(v.OutputsList) do
							Turbostroi.TrainData[train] = Turbostroi.TrainData[train]..
								"V\t"..k.."\t"..v2.."\t"..tostring(v[v2] or 0).."\n"
						end
					end
				end
			end
			
			-- Add all train wire values
			for train,send_data in pairs(Turbostroi.TrainData) do
				for i=1,32 do
					Turbostroi.TrainData[train] = Turbostroi.TrainData[train]..
						"TW\t"..i.."\t"..train:ReadTrainWire(i).."\n"
		
--					print(train,"TW",k,train:ReadTrainWire(k))
				end
			end

			-- Exchange data between simulation and GMOD
			for train,send_data in pairs(Turbostroi.TrainData) do
				local data = Turbostroi.ExchangeData(train,send_data)
				Turbostroi.TrainData[train] = ""
				--print("Incoming "..(#data).." bytes")
				
				local packets = split(data,"\n")
				for k,v in pairs(packets) do
					local d = split(v,"\t")
					if d[1] == "V" then
						if train.Systems[d[2] ] then
							train.Systems[d[2] ][d[3] ] = tonumber(d[4]) or d[4]
							--print("train.Systems[",d[2],"][",d[3],"] = ",d[4])
						end
					end
					if d[1] == "S" then
						train:PlayOnce(d[2],d[3],tonumber(d[4]),tonumber(d[5]))
					end
					if d[1] == "TW" then

train.TrainWireCanWrite = function(self,k)
	local lastwrite = self.TrainWireWriters[k]
	if lastwrite then
		-- Check all last writers, make sure all of trains other than us wrote a while ago
		--[[for writer,v in pairs(lastwrite) do
			if tonumber(v) and (writer ~= self) and (CurTime() - v < 0.1) then
				return false
			end
		end]]--

		if (lastwrite.ent ~= self) and (CurTime() - lastwrite.time < 0.10) then
			--Last write not us and recent, conflict!
			return false
		end
	end
	return true
end

train.WriteTrainWire = function(self,k,v)
--[[	-- Clean wire (no-one has wrote to it in a while)
	local wire_clean = self:TrainWireCanWrite(k)
	local wrote = false

	-- Writing rules for different wires
	local allowed_write = v > 0
	if k == 18 then allowed_write = v <= 0 end
	if self:IsTrainWireCrossConnected(4) or self:IsTrainWireCrossConnected(5) then
			if k == 4 then k = 5
		elseif k == 5 then k = 4 end
	end

	if allowed_write or wire_clean then
		self.TrainWires[k] = v
		wrote = true
	end

	if wrote then
		self.TrainWireWriters[k] = self.TrainWireWriters[k] or {}
		self.TrainWireWriters[k][self] = CurTime()
	end]]--

	-- Check if line is write-able
	local can_write = self:TrainWireCanWrite(k)
	local wrote = false
	
	-- Writing rules for different wires
	local allowed_write = v > 0
	if k == 18 then allowed_write = v <= 0 end
	if self:IsTrainWireCrossConnected(4) or self:IsTrainWireCrossConnected(5) then
			if k == 4 then k = 5
		elseif k == 5 then k = 4 end
	end
	
	-- If value is write-able, write it right away and do nothing interesting
	if can_write then
		self.TrainWires[k] = v
		wrote = true
	elseif allowed_write then -- If trying to write positive value, overwrite value of the previous writer
		self.TrainWires[k] = v
		wrote = true
	end
	
	-- Record us as last writer
	if wrote and (allowed_write or can_write) then
--		self.TrainWireWriters[k] = self.TrainWireWriters[k] or {}
--		self.TrainWireWriters[k][self] = CurTime()

--		if k == 1 then print(self,k,v,wrote,allowed_write,can_write) end
		self.TrainWireWriters[k] = self.TrainWireWriters[k] or {}
		self.TrainWireWriters[k].ent = self
		self.TrainWireWriters[k].time = CurTime()
--		self.TrainWireWriters[k].writers = self.TrainWireWriters[k].writers or {}
--		self.TrainWireWriters[k].writers[self] = CurTime()
	end
end

						train:WriteTrainWire(tonumber(d[2]) or d[2],tonumber(d[3]) or 0)
						--if tonumber(d[2]) == 23 then
						--	print("TRAIN WIRE",train,d[2],d[3])
						--end
					end
				end
			end
			
			-- Proceed with the think loop
			Turbostroi.SetTargetTime(CurTime())
			Turbostroi.Think()
			
			-- HACK
			GLOBAL_SKIP_TRAIN_SYSTEMS = nil
		end
	end)
	return
end


--------------------------------------------------------------------------------
-- Metrostroi emulator
--------------------------------------------------------------------------------
Metrostroi = {}
Metrostroi.BaseSystems = {} -- Systems that can be loaded
Metrostroi.Systems = {} -- Constructors for systems

LoadSystems = {} -- Systems that must be loaded/initialized
GlobalTrain = {} -- Train emulator
GlobalTrain.Systems = {} -- Train systems
GlobalTrain.TrainWires = {}
GlobalTrain.WriteTrainWires = {}

ExtraData = ""

function Metrostroi.DefineSystem(name)
	TRAIN_SYSTEM = {}
	Metrostroi.BaseSystems[name] = TRAIN_SYSTEM
	
	-- Create constructor
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
		tbl.Think = tbl.Think or function() end
		tbl.Inputs = tbl.Inputs or function() return {} end
		tbl.Outputs = tbl.Outputs or function() return {} end
		tbl.TriggerInput = tbl.TriggerInput or function() end
		tbl.TriggerOutput = tbl.TriggerOutput or function() end
		
		tbl.Train = train
		tbl:Initialize(...)
		tbl.OutputsList = tbl:Outputs()
		return tbl
	end
end

function GlobalTrain.LoadSystem(self,a,b,...)
	local name
	local sys_name
	if b then
		name = b
		sys_name = a
	else
		name = a
		sys_name = a
	end
	
	if not Metrostroi.Systems[name] then error("No system defined: "..name) end
	if self.Systems[sys_name] then error("System already defined: "..sys_name)  end
	
	self[sys_name] = Metrostroi.Systems[name](self,...)
	if (name ~= sys_name) or (b) then self[sys_name].Name = sys_name end
	self.Systems[sys_name] = self[sys_name]
	
	-- Don't simulate on here
	local no_acceleration = Metrostroi.BaseSystems[name].DontAccelerateSimulation
	if no_acceleration then
		self.Systems[sys_name].Think = function() end
		self.Systems[sys_name].TriggerInput = function(self,name,value) print("ERR",self,name,value) end
	end
end

function GlobalTrain.PlayOnce(self,soundid,location,range,pitch)
	ExtraData = ExtraData.."S\t"..
		(soundid or "nil").."\t"..
		(location or "nil").."\t"..
		(range or "nil").."\t"..
		(pitch or "nil").."\n"
end

function GlobalTrain.ReadTrainWire(self,n)
	return self.TrainWires[n] or 0
end

function GlobalTrain.WriteTrainWire(self,n,v)
	self.WriteTrainWires[n] = v
	--print(self.TrainWires,n,v)
--	ExtraData = ExtraData.."TW\t"..n.."\t"..v.."\n"
end


--------------------------------------------------------------------------------
-- Turbostroi lua code (this all runs outside of GMOD)
--------------------------------------------------------------------------------
function CurTime() return CurrentTime end

print("[!] Train initialized!")
function Think()
	-- This is just blatant copy paste from init.lua of base train entity
	local self = GlobalTrain
	
	----------------------------------------------------------------------------
	self.PrevTime = self.PrevTime or CurTime()
	self.DeltaTime = (CurTime() - self.PrevTime)
	self.PrevTime = CurTime()
--	print("FRAME",1/self.DeltaTime)
	
	-- Is initialized?
	if not self.Initialized then return end
	
	-- Run iterations on systems simulation
	local iterationsCount = 1
	if (not self.Schedule) or (iterationsCount ~= self.Schedule.IterationsCount) then
		self.Schedule = { IterationsCount = iterationsCount }
		
		-- Find max number of iterations
		local maxIterations = 0
		for k,v in pairs(self.Systems) do maxIterations = math.max(maxIterations,(v.SubIterations or 1)) end

		-- Create a schedule of simulation
		for iteration=1,maxIterations do self.Schedule[iteration] = {} end

		-- Populate schedule
		for k,v in pairs(self.Systems) do
			local simIterationsPerIteration = (v.SubIterations or 1) / maxIterations
			local iterations = 0
			for iteration=1,maxIterations do
				iterations = iterations + simIterationsPerIteration
				while iterations >= 1 do
					table.insert(self.Schedule[iteration],v)
					iterations = iterations - 1
				end
			end
		end
	end
	
	-- Simulate according to schedule
	if FirstPacketArrived then
		for i,s in ipairs(self.Schedule) do
			for k,v in ipairs(s) do
				v:Think(self.DeltaTime / (v.SubIterations or 1),i)
			end
		end
	end
end

function Initialize()
	print("[!] Loading systems")
	for k,v in pairs(LoadSystems) do
		GlobalTrain:LoadSystem(k,v)
	end
	GlobalTrain.Initialized = true
end

FirstPacketArrived = false
DataCache = {}
function DataExchange(data)
	FirstPacketArrived = true	
	
	-- Get input
	local packets = split(data,"\n")
	for k,v in pairs(packets) do
		local data = split(v,"\t")
		if data[1] == "T" then
			if GlobalTrain.Systems[data[2]] then
				GlobalTrain.Systems[data[2]]:TriggerInput(data[3],tonumber(data[4]) or data[4])
				--print("TRIGGER",data[2],data[3],data[4])
			end
		end
		if data[1] == "V" then
			if GlobalTrain.Systems[data[2]] then
				GlobalTrain.Systems[data[2]][data[3]] = tonumber(data[4]) or data[4]
				--if data[2] == "TR" then
					--print(GlobalTrain.Systems.TR.Main750V,"VOLTAGE")
					--print("TVALUE",data[2],data[3],lobalTrain.Systems[data[2]][data[3]],type(lobalTrain.Systems[data[2]][data[3]]))
				--end
			end
		end
		if data[1] == "TW" then
			GlobalTrain.TrainWires[tonumber(data[2]) or data[2]] = tonumber(data[3]) or 0
			--print("TW",tonumber(data[2]),tonumber(data[3]))
		end
	end
	
	-- Create output
	local str = ""
	for k1,v1 in pairs(GlobalTrain.Systems) do
		if v1.OutputsList and (not v1.DontAccelerateSimulation) then
			for k2,v2 in pairs(v1.OutputsList) do
				local value = (v1[v2] or 0)
				if DataCache[k1..k2] ~= value then
					DataCache[k1..k2] = value				
					str = str.."V\t"..k1.."\t"..v2.."\t"..value.."\n"
				end
			end
		end
	end
	for k,v in pairs(GlobalTrain.WriteTrainWires) do
		str = str.."TW\t"..k.."\t"..v.."\n"
		GlobalTrain.WriteTrainWires[k] = nil
	end
	str = str..ExtraData
	ExtraData = ""
	return str
end
