--------------------------------------------------------------------------------
-- Train horn
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("Horn")
TRAIN_SYSTEM.DontAccelerateSimulation = true

function TRAIN_SYSTEM:Initialize()
	self.Active = false
end

function TRAIN_SYSTEM:Outputs() --"21", 
	return { "Active" }
end

function TRAIN_SYSTEM:Inputs()
	return { "Engage" }
end

function TRAIN_SYSTEM:TriggerInput(name,value)
	if name == "Engage" then
		self.Active = value > 0.5
		self.Train:SetNWBool("HornState",self.Active)
	end
end

function TRAIN_SYSTEM:Think()
	
end

function TRAIN_SYSTEM:ClientThink(dT)
	local active = self.Train:GetNWBool("HornState",false)
	self.Active = self.Active or false

	-- Calculate pitch
	local absolutePitch  = 1 - math.exp(-10*self.Train:GetPackedRatio(5))
	local absoluteVolume = 1 - math.exp(-4*self.Train:GetPackedRatio(5))

	-- Play horn sound
	self.Train:SetSoundState("horn2",self.Active and absoluteVolume or 0,absolutePitch)
	if (self.Active ~= active) and (not active) then
		if absolutePitch > 0.2 then
			self.Train:PlayOnce("horn2_end","cabin",0.85,101.5*absolutePitch)
		end
	end
	if (self.Active ~= active) and (active) then
		self.Train.Transient = -5.0
	end
	self.Active = active
end