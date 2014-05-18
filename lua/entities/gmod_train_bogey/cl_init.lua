include("shared.lua")


--------------------------------------------------------------------------------
function ENT:ReinitializeSounds()
	-- Bogey-related sounds
	self.SoundNames = {}
	self.SoundNames["engine"]		= "subway_trains/engine_1.wav"
	self.SoundNames["run1"]			= "subway_trains/run_1.wav"
	self.SoundNames["run2"]			= "subway_trains/run_2.wav"
	self.SoundNames["run3"]			= "subway_trains/run_3.wav"
	self.SoundNames["release"]		= "subway_trains/release_1.wav"
	self.SoundNames["brake1"]		= "subway_trains/brake_1.wav"
	self.SoundNames["brake2"]		= "subway_trains/brake_2.wav"
	self.SoundNames["brake3"]		= "subway_trains/brake_3.wav"
	self.SoundNames["brake4"]		= "subway_trains/brake_4.wav"
	
	-- Remove old sounds
	if self.Sounds then
		for k,v in pairs(self.Sounds) do
			v:Stop()
		end
	end

	-- Create sounds
	self.Sounds = {}
	self.Playing = {}
	for k,v in pairs(self.SoundNames) do
		util.PrecacheSound(v)
		self.Sounds[k] = CreateSound(self, Sound(v))
	end
end

function ENT:SetSoundState(sound,volume,pitch)
	if (volume <= 0) or (pitch <= 0) then
		--self.Sounds[sound]:Stop()
		self.Sounds[sound]:ChangeVolume(0.0,0)
		return
	end

	if not self.Playing[sound] then
		self.Sounds[sound]:Play()
	end
	local pch = math.floor(math.max(0,math.min(255,100*pitch)) + math.random())
	self.Sounds[sound]:ChangeVolume(math.max(0,math.min(255,2.55*volume)) + (0.001/2.55) + (0.001/2.55)*math.random(),0)
	self.Sounds[sound]:ChangePitch(pch+1,0)
end

function ENT:Initialize()
--	self:ReinitializeSounds()
end

function ENT:OnRemove()
	if self.Sounds then
		for k,v in pairs(self.Sounds) do
			v:Stop()
		end
	end
end




--------------------------------------------------------------------------------
function ENT:Think()
	if not self.Sounds then
		self:ReinitializeSounds()
	end
	
	-- Get interesting parameters
	local motorPower = self:GetMotorPower()
	local speed = self:GetSpeed()
	local dPdT = self:GetdPdT()
	
	-- Engine sound
	if (speed > 1.0) and (math.abs(motorPower) > 0.0) then
		local startVolRamp = 0.2 + 0.8*math.max(0.0,math.min(1.0,(speed - 1.0)*0.5))
		local powerVolRamp = math.max(0.3,math.min(1.0,math.abs(motorPower)))
		
		local k,x = 1.0,math.max(0,math.min(1.1,(speed-1.0)/80))
		local motorPchRamp = (k*x^3 - k*x^2 + x)
		local motorPitch = 0.01+1.7*motorPchRamp
		
		self:SetSoundState("engine",startVolRamp*powerVolRamp,motorPitch)
	else
		self:SetSoundState("engine",0,0)
	end
	
	-- Run sound
	if speed > 0.01 then
		local startVolRamp = math.max(0.0,math.min(1.0,speed/30))
		local bleedVolRamp = math.max(0.0,math.min(1.0,speed/60))
		
		local speedPitch2 = (speed / 60)
		local speedPitch3 = math.min(1.2, 0.4 + 0.6 * (speed / 60))
		
		self:SetSoundState("run1",0.0,0.0)
		self:SetSoundState("run2",startVolRamp*(1-bleedVolRamp),speedPitch2)
		self:SetSoundState("run3",startVolRamp*(  bleedVolRamp),speedPitch3)
	else
		self:SetSoundState("run1",0,0)
		self:SetSoundState("run2",0,0)
		self:SetSoundState("run3",0,0)
	end
	
	-- Brake release sound
	local sign = 1
	if dPdT < 0 then sign = -1 end
	if self.PrevDpSign ~= sign then
		self.PrevDpSign = sign
		self:SetSoundState("release",0.0,0.0)
	end

	local threshold = 0.01
	if dPdT < -threshold then
		local volRamp = math.min(0.01,-0.1*(dPdT+threshold))
		self:SetSoundState("release",volRamp,1.7)
	elseif dPdT > threshold then
		local volRamp = (dPdT-threshold)/4.000
		self:SetSoundState("release",volRamp,1.0)
	else
		self:SetSoundState("release",0.0,0.0)
	end
	
	-- Brake squeal sound
	local squealSound = self:GetNWInt("SquealSound",0)
	local brakeSqueal = math.max(0.0,math.min(1.2,self:GetBrakeSqueal()))
	if brakeSqueal > 0.0 then
		if squealSound == 0 then
			self:SetSoundState("brake1",brakeSqueal,1)
		elseif squealSound == 1 then
			self:SetSoundState("brake2",brakeSqueal,1)
		elseif squealSound == 2 then
			self:SetSoundState("brake2",brakeSqueal*0.1,1)
			self:SetSoundState("brake3",brakeSqueal*1.0,1)
		elseif squealSound == 3 then
			self:SetSoundState("brake4",brakeSqueal,1)		
		end
	else
		self:SetSoundState("brake1",0,0)
		self:SetSoundState("brake2",0,0)
		self:SetSoundState("brake3",0,0)
		self:SetSoundState("brake4",0,0)
	end
end
