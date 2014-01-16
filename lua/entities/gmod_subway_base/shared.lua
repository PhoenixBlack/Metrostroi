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