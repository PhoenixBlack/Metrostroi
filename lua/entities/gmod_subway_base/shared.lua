ENT.Type            = "anim"

ENT.PrintName       = "Subway Train Base"
ENT.Author          = ""
ENT.Contact         = ""
ENT.Purpose         = ""
ENT.Instructions    = ""
ENT.Category		= "Metrostroi"

ENT.Spawnable       = true
ENT.AdminSpawnable  = false




--------------------------------------------------------------------------------
-- Default initializer only loads up DURA
--------------------------------------------------------------------------------
function ENT:InitializeSystems()
	self:LoadSystem("DURA","DURA")
end

function ENT:PassengerCapacity()
	return 100
end

function ENT:GetStandingArea()
	return Vector(-64,-64,0),Vector(64,64,0)
end



--------------------------------------------------------------------------------
-- Load/define basic sounds
--------------------------------------------------------------------------------
function ENT:InitializeSounds()
	self.SoundPositions = {} -- Positions (used clientside)
	self.SoundNames = {}
	self.SoundNames["switch"]	= "subway_trains/switch_1.wav"
	self.SoundNames["switch1"]	= "subway_trains/switch_1.wav"
	self.SoundNames["switch2"]	= {
		"subway_trains/switch_2.wav",
		"subway_trains/switch_3.wav",
	}
	self.SoundNames["switch3"]	= {
		"subway_trains/switch_5.wav",
		"subway_trains/switch_6.wav",
		"subway_trains/switch_7.wav",
	}
	self.SoundNames["switch4"]		= "subway_trains/switch_4.wav"

	self.SoundNames["bpsn1"] 		= "subway_trains/bpsn_1.wav"
	self.SoundNames["bpsn2"] 		= "subway_trains/bpsn_2.wav"
	
	self.SoundNames["release1"]		= "subway_trains/release_1.wav"
	self.SoundNames["release2"]		= "subway_trains/release_2.wav"
	self.SoundNames["release3"]		= "subway_trains/release_3.wav"
	self.SoundPositions["release2"] = "cabin"
	self.SoundPositions["release3"] = "cabin"
	
	self.SoundNames["ring"]			= "subway_trains/ring_1.wav"
	self.SoundNames["ring_end"]		= "subway_trains/ring_2.wav"
	self.SoundPositions["ring"] 	= "cabin"
	self.SoundPositions["ring_end"] = "cabin"
	
	self.SoundNames["pneumo_switch"] = {
		"subway_trains/pneumo_1.wav",
		"subway_trains/pneumo_2.wav",
	}
	self.SoundNames["pneumo_disconnect1"] = {
		"subway_trains/pneumo_3.wav",
	}
	self.SoundNames["pneumo_disconnect2"] = {
		"subway_trains/pneumo_4.wav",
		"subway_trains/pneumo_5.wav",
	}
	
	self.SoundNames["door_close1"] = {
		"subway_trains/door_close_2.wav",
		"subway_trains/door_close_3.wav",
		"subway_trains/door_close_4.wav",
		"subway_trains/door_close_5.wav",
	}
	self.SoundNames["door_open1"] = {
		"subway_trains/door_open_1.wav",
		"subway_trains/door_open_2.wav",
		"subway_trains/door_open_3.wav",
	}
	
	self.SoundNames["compressor"]		= "subway_trains/compressor_1.wav"
	self.SoundNames["compressor_end"] 	= "subway_trains/compressor_2.wav"
	
	self.SoundNames["kv1"] = {
		"subway_trains/kv1_1.wav",
		"subway_trains/kv1_2.wav",
		"subway_trains/kv1_3.wav",
		"subway_trains/kv1_4.wav",
		"subway_trains/kv1_5.wav",
		"subway_trains/kv1_6.wav",
		"subway_trains/kv1_7.wav",
		"subway_trains/kv1_8.wav",
		"subway_trains/kv1_9.wav",
		"subway_trains/kv1_10.wav",
		"subway_trains/kv1_11.wav",
		"subway_trains/kv1_12.wav",
	}
	
	self.SoundNames["kv2"] = {
		"subway_trains/kv2_1.wav",
		"subway_trains/kv2_2.wav",
		"subway_trains/kv2_3.wav",
	}
	
	self.SoundNames["kv3"] = {
		"subway_trains/kv3_1.wav",
		"subway_trains/kv3_2.wav",
		"subway_trains/kv3_3.wav",
	}
	
	self.SoundNames["tr"] = {
		"subway_trains/tr_1.wav",
		"subway_trains/tr_2.wav",
		"subway_trains/tr_3.wav",
		"subway_trains/tr_4.wav",
		"subway_trains/tr_5.wav",
	}
	
	self.SoundTimeout = {}
end


--------------------------------------------------------------------------------
-- Sound functions
--------------------------------------------------------------------------------
function ENT:SetSoundState(sound,volume,pitch)
	if not self.Sounds[sound] then 
		if self.SoundNames and self.SoundNames[sound] then
			local name = self.SoundNames[sound]
			if self.SoundPositions[sound] then
				local ent_nwID
				if self.SoundPositions[sound] == "cabin" then ent_nwID = "seat_driver" end
				
				local ent = self:GetNWEntity(ent_nwID)
				if IsValid(ent) then
					self.Sounds[sound] = CreateSound(ent, Sound(name))
				else
					return
				end
			else
				self.Sounds[sound] = CreateSound(self, Sound(name))
			end
		else
			return 
		end
	end
	if (volume <= 0) or (pitch <= 0) then
		self.Sounds[sound]:Stop()
		self.Sounds[sound]:ChangeVolume(0.0,0)
		return
	end

	local pch = math.floor(math.max(0,math.min(255,100*pitch)) + math.random())
	self.Sounds[sound]:Play()
	self.Sounds[sound]:ChangeVolume(math.max(0,math.min(255,2.55*volume)) + (0.001/2.55) + (0.001/2.55)*math.random(),0)
	self.Sounds[sound]:ChangePitch(pch+1,0)
end

--[[function ENT:CheckActionTimeout(action,timeout)
	self.LastActionTime = self.LastActionTime or {}
	self.LastActionTime[action] = self.LastActionTime[action] or (CurTime()-1000)
	if CurTime() - self.LastActionTime[action] < timeout then return true end
	self.LastActionTime[action] = CurTime()

	return false
end
]]--
function ENT:PlayOnce(soundid,location,range,pitch)
	--if self:CheckActionTimeout(soundid,self.SoundTimeout[soundid] or 0.0) then return end

	-- Pick wav file
	local sound = self.SoundNames[soundid]
	if type(sound) == "table" then sound = table.Random(sound) end

	-- Setup range
	local default_range = 0.80
	if soundid == "switch" then default_range = 0.50 end

	-- Emit sound from right location
	if not location then
		self:EmitSound(sound, 100*(range or default_range), pitch or math.random(95,105))
	elseif (location == true) or (location == "cabin") then
		if CLIENT then self.DriverSeat = self:GetNWEntity("seat_driver") end				
		if IsValid(self.DriverSeat) then
			self.DriverSeat:EmitSound(sound, 100*(range or default_range),pitch or math.random(95,105))
		end
	elseif location == "front_bogey" then
		if IsValid(self.FrontBogey) then
			self.FrontBogey:EmitSound(sound, 100*(range or default_range),pitch or math.random(95,105))
		end
	elseif location == "rear_bogey" then
		if IsValid(self.RearBogey) then
			self.RearBogey:EmitSound(sound, 100*(range or default_range),pitch or math.random(95,105))
		end
	end
end




--------------------------------------------------------------------------------
-- Load a single system with given name
--------------------------------------------------------------------------------
function ENT:LoadSystem(a,b,...)
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
	
	local no_acceleration = Metrostroi.BaseSystems[name].DontAccelerateSimulation
	if SERVER and Turbostroi then
		-- Load system into turbostroi
		if (not GLOBAL_SKIP_TRAIN_SYSTEMS) then
			Turbostroi.LoadSystem(sys_name,name)
		end
		
		-- Load system locally (this may load any systems nested in the initializer)
		GLOBAL_SKIP_TRAIN_SYSTEMS = GLOBAL_SKIP_TRAIN_SYSTEMS or 0
		if GLOBAL_SKIP_TRAIN_SYSTEMS then GLOBAL_SKIP_TRAIN_SYSTEMS = GLOBAL_SKIP_TRAIN_SYSTEMS + 1 end
		self[sys_name] = Metrostroi.Systems[name](self,...)
		GLOBAL_SKIP_TRAIN_SYSTEMS = GLOBAL_SKIP_TRAIN_SYSTEMS - 1
		if GLOBAL_SKIP_TRAIN_SYSTEMS == 0 then GLOBAL_SKIP_TRAIN_SYSTEMS = nil end
		
		-- Setup nice name as normal
		if (name ~= sys_name) or (b) then self[sys_name].Name = sys_name end
		self.Systems[sys_name] = self[sys_name]
		
		-- Create fake placeholder
		if not no_acceleration then
			self[sys_name].TriggerInput = function(system,name,value)
				Turbostroi.TriggerInput(self,sys_name,name,value)
			end
			self[sys_name].Think = function() end
		end
	else
		-- Load system like normal
		self[sys_name] = Metrostroi.Systems[name](self,...)
		if (name ~= sys_name) or (b) then self[sys_name].Name = sys_name end
		self.Systems[sys_name] = self[sys_name]

		--if SERVER then
			--[[self[sys_name].TriggerOutput = function(sys,name,value)
				local varname = (sys.Name or "")..name
				--self:TriggerOutput(varname, tonumber(value) or 0)
				self.DebugVars[varname] = value
			end]]--
		--end
	end
end




--------------------------------------------------------------------------------
-- Setup datatables for faster, more optimized transmission
--------------------------------------------------------------------------------
function ENT:SetupDataTables()
	-- Int0,Int1,Int2,Int3: packet bit values
	self:NetworkVar("Int", 0, "PackedInt0")
	self:NetworkVar("Int", 1, "PackedInt1")
	self:NetworkVar("Int", 2, "PackedInt2")
	self:NetworkVar("Int", 3, "PackedInt3")

	-- Vec0,Vec1,Vec2,Vec3: floating point values
	self:NetworkVar("Vector", 0, "PackedVec0")
	self:NetworkVar("Vector", 1, "PackedVec1")
	self:NetworkVar("Vector", 2, "PackedVec2")
	self:NetworkVar("Vector", 3, "PackedVec3")
	
	-- Other variables
	self:NetworkVar("Float", 0, "PassengerCount")
end

--------------------------------------------------------------------------------
-- Set/get tightly packed float (for speed, pneumatic gauges, etc)
--------------------------------------------------------------------------------
function ENT:SetPackedRatio(vecn,ratio)
	local int = 0
	if vecn >= 3 then int = 1 vecn = vecn-3 end
	if vecn >= 3 then int = 2 vecn = vecn-3 end
	if vecn >= 3 then int = 3 vecn = vecn-3 end
		
	local vector = self["GetPackedVec"..int](self)
	if vecn == 0 then vector.x = ratio/(max or 1) end
	if vecn == 1 then vector.y = ratio/(max or 1) end
	if vecn == 2 then vector.z = ratio/(max or 1) end
	self["SetPackedVec"..int](self,vector)		
end

function ENT:GetPackedRatio(vecn)	
	local int = 0
	if vecn >= 3 then int = 1 vecn = vecn-3 end
	if vecn >= 3 then int = 2 vecn = vecn-3 end
	if vecn >= 3 then int = 3 vecn = vecn-3 end
		
	local vector = self["GetPackedVec"..int](self)
	if vecn == 0 then return vector.x*(max or 1) end
	if vecn == 1 then return vector.y*(max or 1) end
	if vecn == 2 then return vector.z*(max or 1) end
end

--------------------------------------------------------------------------------
-- Set/get tightly packed boolean (for gauges, lights)
--------------------------------------------------------------------------------
function ENT:SetPackedBool(idx,value)
	local int = 0
	if idx >= 32 then int = 1 idx = idx-32 end
	if idx >= 32 then int = 2 idx = idx-32 end
	if idx >= 32 then int = 3 idx = idx-32 end
	
	-- Pack value
	local packed_value = bit.lshift(value and 1 or 0,idx)
	local mask = bit.bnot(bit.lshift(1,idx))
	
	-- Create total packed integer
	local new_int2 = bit.bor(bit.band(self["GetPackedInt"..int](self),mask),packed_value)
	self["SetPackedInt"..int](self,new_int2)
end

function ENT:GetPackedBool(idx)
	local int = 0
	if idx >= 32 then int = 1 idx = idx-32 end
	if idx >= 32 then int = 2 idx = idx-32 end
	if idx >= 32 then int = 3 idx = idx-32 end
	
	local mask = bit.lshift(1,idx)
	return bit.band(self["GetPackedInt"..int](self),mask) ~= 0
end