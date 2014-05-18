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
	self.SoundNames["brake3a"]		= "subway_trains/brake_3.wav"
	
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
		local e = self
		if (k == "brake3a") and IsValid(self:GetNWEntity("TrainWheels")) then
			e = self:GetNWEntity("TrainWheels")
		end
		self.Sounds[k] = CreateSound(e, Sound(v))
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
	local brakeRamp = math.min(1.0,math.max(0.0,speed/8.0))
	if squealSound == 0 then squealSound = 2 end
	if squealSound == 3 then squealSound = 2 end
--	squealSound = 3
	if brakeSqueal > 0.0 then
		if squealSound == 0 then
			self:SetSoundState("brake1",brakeSqueal*(0.10+0.90*brakeRamp),1+0.06*(1.0-brakeRamp))
		elseif squealSound == 1 then
			self:SetSoundState("brake2",brakeSqueal*(0.10+0.90*brakeRamp),1+0.06*(1.0-brakeRamp))
		elseif squealSound == 2 then
			self:SetSoundState("brake2",brakeSqueal*0.07*(0.10+0.90*brakeRamp),1+0.06*(1.0-brakeRamp))
			self:SetSoundState("brake3",brakeSqueal*1.0*brakeRamp,1)
			self:SetSoundState("brake3a",brakeSqueal*1.0*brakeRamp,1)
		elseif squealSound == 3 then
			self:SetSoundState("brake4",brakeSqueal*(0.10+0.90*brakeRamp),1+0.10*(1.0-brakeRamp))
		end
	else
		self:SetSoundState("brake1",0,0)
		self:SetSoundState("brake2",0,0)
		self:SetSoundState("brake3",0,0)
		self:SetSoundState("brake4",0,0)
	end
end


local prevV = 0
local A = 0
local D1true = 0
local D2true = 0
local prevTime
hook.Add("PostDrawOpaqueRenderables", "metrostroi-draw-stopmarker",function()
	prevTime = prevTime or CurTime()
	local dT = math.max(0.001,CurTime() - prevTime)
	prevTime = CurTime()

	-- Get seat and train
	local seat = LocalPlayer():GetVehicle()
	if not seat then return end
	local train = seat:GetNWEntity("TrainEntity")
	if not IsValid(train) then return end

	-- Calculate acceleration
	local V = train:GetVelocity():Length()*0.01905 --0.277778*0.06858
	local newA = (V - prevV)/dT
	prevV = V

	-- Calculate marker position
	A = A + (newA - A)*1.0*dT
	local T1 = math.abs(V/(A+1e-8))
	local T2 = math.abs(V/(1.2+1e-8))
	local D1 = T1*V + (T1^2)*A/2
	local D2 = T2*V + (T2^2)*A/2

	-- Smooth out D	
	D1 = math.min(200,math.max(0,D1))*0.90
	D2 = math.min(200,math.max(0,D2))*0.90
	D1true = D1true + (D1 - D1true)*8.0*dT
	D2true = D2true + (D2 - D2true)*8.0*dT
	local offset1 = D1true/0.01905
	local offset2 = D2true/0.01905

	-- Draw marker
	if A > -0.1 then return end
	local base_pos1 = train:LocalToWorld(Vector(500+offset1,80,10))
	cam.Start3D2D(base_pos1,train:LocalToWorldAngles(Angle(0,-90,90)),1.0)
		surface.SetDrawColor(255,255,255)
		surface.DrawRect(-1,-1,8*20+2,4+2)
		for i=0,19 do
			surface.SetDrawColor(240,200,40)
			surface.DrawRect(8*i+0,0,4,4)
			surface.SetDrawColor(0,0,0)
			surface.DrawRect(8*i+4,0,4,4)
		end
		surface.SetDrawColor(255,255,255)
		surface.DrawRect(-1,-96,2,192)
		surface.DrawRect(8*20,-96,2,192)

--		surface.SetTextColor(255,255,255)
--		surface.SetFont("Trebuchet24")
--		surface.SetTextPos(64-128,-30)
--		surface.DrawText(Format("%.1f m  %.1f m/s %.1f m/s2",D,V,A))
--		surface.SetTextPos(64,-30)
--		surface.DrawText(Format("%.1f m %.0f sec",D,T))
	cam.End3D2D()

	local base_pos2 = train:LocalToWorld(Vector(500+offset2,80,10))
	cam.Start3D2D(base_pos2,train:LocalToWorldAngles(Angle(0,-90,90)),1.0)
		surface.SetDrawColor(240,40,40)
		surface.DrawRect(-1,-1,8*20+2,4+2)
		for i=0,19 do
			surface.SetDrawColor(0,0,0)
			surface.DrawRect(8*i+0,0,4,4)
			surface.SetDrawColor(240,40,40)
			surface.DrawRect(8*i+4,0,4,4)
		end

		surface.SetDrawColor(240,40,40)
		surface.DrawRect(-1,-1+110,8*20+2,16+2)
		for i=0,19 do
			surface.SetDrawColor(0,0,0)
			surface.DrawRect(8*i+0,110,4,16)
			surface.SetDrawColor(240,40,40)
			surface.DrawRect(8*i+4,110,4,16)
		end

		surface.SetDrawColor(240,40,40)
		surface.DrawRect(-6,-96,6,192)
		surface.DrawRect(8*20,-96,4,192)
	cam.End3D2D()
end)

--	print(:GetTrain())

--end)