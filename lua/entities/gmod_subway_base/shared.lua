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
	self.SoundNames["switch"]	= "subway_trains/click_1.wav"
	self.SoundNames["click1"]	= "subway_trains/click_1.wav"
	self.SoundNames["click2"]	= "subway_trains/click_2.wav"
	self.SoundNames["click3"]	= "subway_trains/click_3.wav"
	self.SoundNames["click4"]	= "subway_trains/click_4.wav"
	self.SoundNames["click5"]	= "subway_trains/click_5.wav"
	
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
	self.SoundTimeout["switch"] = 0.0
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
end

--------------------------------------------------------------------------------
-- Set/get tightly packed float (for speed, pneumatic gauges, etc)
--------------------------------------------------------------------------------
function ENT:SetPackedRatio(idx,ratio,max)
	local int = 0
	if idx > 3 then int = 1 idx = idx-4 end
	
	-- Generate 8-bit integer
	local int_ratio = math.min(255,math.max(0,math.floor(255*(ratio/(max or 1))+0.5)))
	-- Pack 8-bit integer
	local packed_value = bit.lshift(int_ratio,8*idx)
	local mask = bit.bnot(bit.lshift(0xFF,8*idx))
	
	-- Create total packed integer
	local new_int = bit.bor(bit.band(self["GetPackedInt"..int](self),mask),packed_value)
	self["SetPackedInt"..int](self,new_int)
end

function ENT:GetPackedRatio(idx,max)
	local int = 0
	if idx > 3 then int = 1 idx = idx-4 end
	
	-- Pack 8-bit integer
	local mask = bit.lshift(0xFF,8*idx)
	local packed_value = bit.rshift(bit.band(self["GetPackedInt"..int](self),mask),8*idx)
	
	-- Generate ratio
	return (packed_value/255)*(max or 1)
end

--------------------------------------------------------------------------------
-- Set/get tightly packed boolean (for gauges, lights)
--------------------------------------------------------------------------------
function ENT:SetPackedBool(idx,value)
	local int = 2
	if idx > 3 then int = 3 idx = idx-4 end
	
	-- Pack value
	local packed_value = bit.lshift(value and 1 or 0,idx)
	local mask = bit.bnot(bit.lshift(1,idx))
	
	-- Create total packed integer
	local new_int2 = bit.bor(bit.band(self["GetPackedInt"..int](self),mask),packed_value)
	self["SetPackedInt"..int](self,new_int2)
end

function ENT:GetPackedBool(idx)
	local int = 2
	if idx > 3 then int = 3 idx = idx-4 end
	
	local mask = bit.lshift(1,idx)
	return bit.band(self["GetPackedInt"..int](self),mask) ~= 0
end