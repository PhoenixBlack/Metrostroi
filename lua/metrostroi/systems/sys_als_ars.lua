--------------------------------------------------------------------------------
-- АРС-АЛС
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("ALS_ARS")
TRAIN_SYSTEM.DontAccelerateSimulation = true

function TRAIN_SYSTEM:Initialize()
	-- ALS state
	self.Signal80 = false
	self.Signal70 = false
	self.Signal60 = false
	self.Signal40 = false
	self.Signal0 = false
	self.Special = false
	self.NoFreq = true
	
	-- Internal state
	self.Speed = 0
	self.Ring = false
	self.SoftOverspeed = false
	self.Overspeed = false
	self.ElectricBrake = false
	self.PneumaticBrake1 = false
	self.PneumaticBrake2 = true
	
	-- ARS wires
	self["33D"] = 0
	self["33G"] = 0
	self["33Zh"] = 0
	self["2"] = 0
	self["6"] = 0
	self["8"] = 0
	self["20"] = 0
	self["21"] = 0
	self["29"] = 0
	self["31"] = 0
	self["32"] = 0
	
	-- Lamps
	self.LKT = false
	self.LVD = false
end

function TRAIN_SYSTEM:Outputs()
	return { "2", "8", "20", "21", "29", "33D", "33G", "33Zh" }
end

function TRAIN_SYSTEM:Inputs()
	return { }
end

function TRAIN_SYSTEM:TriggerInput(name,value)

end

function TRAIN_SYSTEM:Think()
	local Train = self.Train	
	if not Train.VB then return end
	
	-- Speed check and update speed data
	if CurTime() - (self.LastSpeedCheck or 0) > 0.5 then
		self.LastSpeedCheck = CurTime()
		self.Speed = (Train.Speed or 0)
	end
	
	-- Check ARS signals
	if (Train.ALS.Value == 0.0) or (Train.VB.Value == 0.0) then
		self.Signal80 = false
		self.Signal70 = false
		self.Signal60 = false
		self.Signal40 = false
		self.Signal0 = false
		self.Special = false
		self.NoFreq = false
	else
		self.Timer = self.Timer or CurTime()
		if CurTime() - self.Timer > 1.00 then
			self.Timer = CurTime()

			-- Get train position
			local pos = Metrostroi.TrainPositions[Train]
			if pos then pos = pos[1] end

			-- Get previous ARS section
			local ars
			if pos then ars = Metrostroi.GetARSJoint(pos.node1,pos.x,false) end
			if ars then
				self.Signal80	= ars:GetActiveSignalsBit(10)
				self.Signal70	= ars:GetActiveSignalsBit(11)
				self.Signal60	= ars:GetActiveSignalsBit(12)
				self.Signal40	= ars:GetActiveSignalsBit(13)
				self.Signal0	= ars:GetActiveSignalsBit(14)
				self.Special	= ars:GetActiveSignalsBit(15)
				self.NoFreq		= false

				if not (self.Signal80 or self.Signal70 or 
						self.Signal60 or self.Signal40 or self.Signal0) then
					self.NoFreq = true
				end
			else
				self.Signal80 = false
				self.Signal70 = false
				self.Signal60 = false
				self.Signal40 = false
				self.Signal0 = false
				self.Special = false
				self.NoFreq = true
			end
		end
	end
	
	-- ARS system placeholder logic
	if (Train.ALS.Value == 1.0) then
		local V = math.floor(self.Speed)
		local Vlimit = 0
		if self.Signal40 then Vlimit = 40 end
		if self.Signal60 then Vlimit = 60 end
		if self.Signal70 then Vlimit = 70 end
		if self.Signal80 then Vlimit = 80 end

		--self.SoftOverspeed = ((Vlimit == 0) and (Train.PB.Value == 1) and (V > 20))
		self.Overspeed = false
		if (Train.PB.Value == 0) and (V > Vlimit) and (V > 5) then self.Overspeed = true end
		if (Train.PB.Value == 1) and (Vlimit ~= 0) and (V > Vlimit) then self.Overspeed = true end
		if (Train.PB.Value == 1) and (Vlimit == 0) and (V > 20) then self.Overspeed = true end
		
		--(V >= Vlimit) or self.SoftOverspeed
		self.Ring = self.Overspeed and (self.Speed > 5)
	else
		self.Overspeed = true
		self.Ring = false
	end
	
	if (Train.ARS.Value == 1.0) and (Train.KV.ReverserPosition ~= 0.0) then
		-- Check overspeed
		if self.Overspeed then
			self.ElectricBrake = true
			self.PneumaticBrake2 = true
			self.PV1Timer = CurTime()
		end
		-- Check cancel of overspeed command
		if (Train.PB.Value == 1) and (not self.Overspeed) then
			self.ElectricBrake = false
			self.PneumaticBrake2 = false
		end
		
		-- Check parking brake functionality
		self.TW1Timer = self.TW1Timer or -1e9
		if (self.Speed < 10) and ((CurTime() - self.TW1Timer) > 5) then
			self.PneumaticBrake1 = true
		end
		-- Check cancel pneumatic brake 1 command
		if Train:ReadTrainWire(1) > 0 then
			self.PneumaticBrake1 = false
			self.TW1Timer = CurTime()
		end		
		-- Check use of valve #1 during overspeed
		self.PV1Timer = self.PV1Timer or -1e9
		if ((CurTime() - self.PV1Timer) < 0.6) then self.PneumaticBrake1 = false end
		if ((CurTime() - self.PV1Timer) < 0.5) then self.PneumaticBrake1 = true end
		
		-- ARS signals
		local Ebrake,Pbrake1,Pbrake2 = 
			(self.ElectricBrake and 1 or 0),
			(self.PneumaticBrake1 and 1 or 0),
			(self.PneumaticBrake2 and 1 or 0)
	
		-- Apply ARS system commands
		self["33D"] = (1 - Ebrake)*(1 - Pbrake2)
		self["33G"] = Ebrake
		self["33Zh"] = 1-Ebrake
		self["2"] = Ebrake
		self["20"] = Ebrake
		self["29"] = Pbrake1
		self["8"] = Pbrake2
		
		-- Show lamps
		self.LKT = (self["33G"] > 0.5) or (self["29"] > 0.5)
		self.LVD = self["33D"] < 0.5
	else
		if Train.PB.Value == 0 then
			self.Train.RPB:TriggerInput("Open",1)
		end
		self.ElectricBrake = false
		self.PneumaticBrake1 = false
		self.PneumaticBrake2 = true
	
		self["33D"] = 1
		self["33G"] = 0
		self["33Zh"] = 1
		self["2"] = 0
		self["20"] = 0
		self["29"] = 0
		self["8"] = 0
		
		self.LKT = false
		self.LVD = false
	end
end