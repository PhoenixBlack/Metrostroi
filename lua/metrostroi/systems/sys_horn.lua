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

	-- Play horn sound
	self.Train:SetSoundState("horn2",self.Active and 1 or 0,1)
	if (self.Active ~= active) and (not active) then
		self.Train:PlayOnce("horn2_end","cabin",0.85,100)
		print("play")
	end
	self.Active = active
end