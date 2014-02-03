ENT.Type            = "anim"
ENT.Base            = "base_gmodentity"

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



--------------------------------------------------------------------------------
-- Load/define basic sounds
--------------------------------------------------------------------------------
function ENT:InitializeSounds()
	self.SoundNames = {}
	self.SoundNames["switch"]	= "subway_trains/switch_1.wav"
	self.SoundNames["switch1"]	= "subway_trains/switch_1.wav"
	self.SoundNames["switch2"]	= {
		"subway_trains/switch_2.wav",
		"subway_trains/switch_3.wav",
	}
	self.SoundNames["switch4"]	= "subway_trains/switch_4.wav"

	self.SoundNames["bpsn1"] 	= "subway_trains/bpsn_1.wav"
	self.SoundNames["bpsn2"] 	= "subway_trains/bpsn_2.wav"
	
	self.SoundNames["pneumo_switch"] = {
		"subway_trains/pneumo_1.wav",
		"subway_trains/pneumo_2.wav"
	}
	
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
	
	self.SoundTimeout = {}
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
	
	self[sys_name] = Metrostroi.Systems[name](self,...)
	if (name ~= sys_name) or (b) then self[sys_name].Name = sys_name end
	self.Systems[sys_name] = self[sys_name]
	
	if SERVER then
		self[sys_name].TriggerOutput = function(sys,name,value)
			local varname = (sys.Name or "")..name
			--self:TriggerOutput(varname, tonumber(value) or 0)
			self.DebugVars[varname] = value
		end
	end
end




--------------------------------------------------------------------------------
-- Setup datatables for faster, more optimized transmission
--------------------------------------------------------------------------------
function ENT:SetupDataTables()
	-- Int0,Int1: packed floating point values
	self:NetworkVar("Int", 0, "PackedInt0")
	self:NetworkVar("Int", 1, "PackedInt1")
	-- Int2,Int3: packed bit values
	self:NetworkVar("Int", 2, "PackedInt2")
	self:NetworkVar("Int", 3, "PackedInt3")
	
	-- Acceleration of the train as felt in the center of mass
	self:NetworkVar("Vector", 0, "TrainAcceleration")
	-- Angular velocity of the train
	self:NetworkVar("Vector", 1, "TrainAngularVelocity")
	
	-- Vec2,Vec3: gauge values
	self:NetworkVar("Vector", 2, "PackedVec2")
	self:NetworkVar("Vector", 3, "PackedVec3")
end

--------------------------------------------------------------------------------
-- Set/get tightly packed float (for speed, pneumatic gauges, etc)
--------------------------------------------------------------------------------
function ENT:SetPackedRatio(idx,ratio)
	if idx >= 8 then
		local int = 2
		local vecn = idx-8
		if vecn >= 3 then int = 3 vecn = vecn-3 end
		
		local vector = self["GetPackedVec"..int](self)
		if vecn == 0 then vector.x = ratio/(max or 1) end
		if vecn == 1 then vector.y = ratio/(max or 1) end
		if vecn == 2 then vector.z = ratio/(max or 1) end
		self["SetPackedVec"..int](self,vector)		
	else
		local int = 0
		if idx >= 4 then int = 1 idx = idx-4 end
		
		-- Integer limit
		local width = 8
		local bitn = width*idx
		local limit = (2^width)-1
		-- Generate integer
		local int_ratio = math.min(limit,math.max(0,math.floor(limit*(ratio/(max or 1))+0.5)))
		-- Pack integer
		local packed_value = bit.lshift(int_ratio,bitn)
		local mask = bit.bnot(bit.lshift(limit,bitn))
		
		-- Create total packed integer
		local new_int = bit.bor(bit.band(self["GetPackedInt"..int](self),mask),packed_value)
		self["SetPackedInt"..int](self,new_int)
	end
end

function ENT:GetPackedRatio(idx)	
	if idx >= 8 then
		local int = 2
		local vecn = idx-8
		if vecn >= 3 then int = 3 vecn = vecn-3 end

		local vector = self["GetPackedVec"..int](self)
		if vecn == 0 then return vector.x*(max or 1) end
		if vecn == 1 then return vector.y*(max or 1) end
		if vecn == 2 then return vector.z*(max or 1) end
	else
		local int = 0
		if idx >= 4 then int = 1 idx = idx-4 end
	
		-- Integer limit
		local width = 8
		local bitn = width*idx
		local limit = (2^width)-1
		-- Unpack integer
		local mask = bit.lshift(limit,bitn)
		local packed_value = bit.rshift(bit.band(self["GetPackedInt"..int](self),mask),bitn)
		
		-- Generate ratio
		return (packed_value/limit)*(max or 1)
	end
end

--------------------------------------------------------------------------------
-- Set/get tightly packed boolean (for gauges, lights)
--------------------------------------------------------------------------------
function ENT:SetPackedBool(idx,value)
	local int = 2
	if idx >= 32 then int = 3 idx = idx-32 end
	
	-- Pack value
	local packed_value = bit.lshift(value and 1 or 0,idx)
	local mask = bit.bnot(bit.lshift(1,idx))
	
	-- Create total packed integer
	local new_int2 = bit.bor(bit.band(self["GetPackedInt"..int](self),mask),packed_value)
	self["SetPackedInt"..int](self,new_int2)
end

function ENT:GetPackedBool(idx)
	local int = 2
	if idx >= 32 then int = 3 idx = idx-32 end
	
	local mask = bit.lshift(1,idx)
	return bit.band(self["GetPackedInt"..int](self),mask) ~= 0
end