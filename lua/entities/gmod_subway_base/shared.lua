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

function ENT:InitializeSystems()
	-- Do nothing
	self:LoadSystem("DURA","DURA")
end

function ENT:InitializeSounds()
	-- Load basic sounds
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

-- Load system
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
	self[sys_name] = Metrostroi.Systems[name](self,...)
	if (name ~= sys_name) or (b) then self[sys_name].Name = sys_name end
	self.Systems[sys_name] = self[sys_name]
	
	if SERVER then
		self[sys_name].TriggerOutput = function(sys,name,value)
			local varname = (sys.Name or "")..name
			if Wire_TriggerOutput then
				Wire_TriggerOutput(self, varname, tonumber(value) or 0)
			end
			self.DebugVars[varname] = value
		end
	end
end