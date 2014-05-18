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
	self.Volume = self.Volume or 0
	self.Active = self.Active or false
	
	-- See of horn is active
	if active then
		self.Volume = 1
	elseif self.Active ~= active then
		self.Train:PlayOnce("horn2_end","cabin",0.75,100)	
	end
	self.Active = active
	
	-- Play horn sound
	if not self.Active then self.Volume = math.max(0,self.Volume - math.max(0,1.5*dT)) end
	self.Train:SetSoundState("horn2",self.Volume,1)
end