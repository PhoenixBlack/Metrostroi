--------------------------------------------------------------------------------
-- АРС-АЛС
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("ALS_ARS")
TRAIN_SYSTEM.DontAccelerateSimulation = true

if CreateConVar then
	--[[concommand.Add("metrostroi_give_upps", function(ply, _, args)
		print("Trains on server: "..Metrostroi.TrainCount())
		if CPPI then
			local N = {}
			for k,v in pairs(Metrostroi.TrainClasses) do
				local ents = ents.FindByClass(v)
				for k2,v2 in pairs(ents) do
					N[v2:CPPIGetOwner() or "(disconnected)"] = (N[v2:CPPIGetOwner() or "(disconnected)"] or 0) + 1
				end
			end
			for k,v in pairs(N) do
				print(k,"Trains count: "..v)
			end
		end
	end)]]--

	CreateConVar("metrostroi_upps",0,FCVAR_ARCHIVE)
end

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
	self.SpeedLimit = 0
	self.NextLimit = 0
	self.Ring = false
	self.Overspeed = false
	self.ElectricBrake = false
	self.PneumaticBrake1 = false
	self.PneumaticBrake2 = true
	self.AttentionPedal = false
	
	-- ARS wires
	self["33D"] = 0
	self["33G"] = 0
	self["33Zh"] = 0
	self["2"] = 0
	self["6"] = 0
	self["8"] = 0
	self["20"] = 0
	--self["21"] = 0
	self["29"] = 0
	self["31"] = 0
	self["32"] = 0
	
	-- Lamps
	self.LKT = false
	self.LVD = false
end

function TRAIN_SYSTEM:Outputs()
	return { "2", "8", "20", "31", "32", "29", "33D", "33G", "33Zh",
			 "Speed", "Signal80","Signal70","Signal60","Signal40","Signal0","Special","NoFreq",
			 "SpeedLimit", "NextLimit","Ring" }
end

function TRAIN_SYSTEM:Inputs()
	return { "AttentionPedal" }
end

function TRAIN_SYSTEM:TriggerInput(name,value)
	local Train = self.Train
	if name == "AttentionPedal" then
		self.AttentionPedal = value > 0.5
		if Train and Train.PB then
			Train.PB:TriggerInput("Set",value)
		end
	end
end

function TRAIN_SYSTEM:Think()
	local Train = self.Train
	local OverrideState = false
	if (not Train.VB) or (not Train.ALS) or (not Train.ARS) or (not Train.KV) then
		OverrideState = true
	end
	
	-- ALS, ARS state
	local EnableARS = OverrideState or ((Train.ARS.Value == 1.0) and (Train.VB.Value == 1.0) and (Train.KV.ReverserPosition ~= 0.0))
	local EnableALS = OverrideState or ((Train.ALS.Value == 1.0) and (Train.VB.Value == 1.0))
	
	-- Pedal state
	if (Train.PB) and ((Train.PB.Value+Train.KVT.Value) >= 1.0) then self.AttentionPedal = true end
	if (Train.PB) and ((Train.PB.Value+Train.KVT.Value) <  1.0) then self.AttentionPedal = false end
	
	-- Ignore pedal
	if self.IgnorePedal and self.AttentionPedal then
		self.AttentionPedal = false
	else
		self.IgnorePedal = false
	end
	
	-- Speed check and update speed data
	if CurTime() - (self.LastSpeedCheck or 0) > 0.5 then
		self.LastSpeedCheck = CurTime()
		self.Speed = (Train.Speed or 0)
	end
	
	-- Check ARS signals
	if EnableALS then
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
	else
		self.Signal80 = false
		self.Signal70 = false
		self.Signal60 = false
		self.Signal40 = false
		self.Signal0 = false
		self.Special = false
		self.NoFreq = false
	end
	
	-- ARS system placeholder logic
	if EnableALS then
		local V = math.floor(self.Speed+0.05)
		local Vlimit = 0
		if self.Signal40 then Vlimit = 40 end
		if self.Signal60 then Vlimit = 60 end
		if self.Signal70 then Vlimit = 70 end
		if self.Signal80 then Vlimit = 80 end

		self.Overspeed = false
		if (not self.AttentionPedal) and (V > Vlimit) and (V > (self.NoFreq and 0 or 3)) then self.Overspeed = true end
		if (    self.AttentionPedal) and (Vlimit ~= 0) and (V > Vlimit) then self.Overspeed = true end
		if (    self.AttentionPedal) and (Vlimit == 0) and (V > 20) then self.Overspeed = true end

		--self.Ring = self.Overspeed and (self.Speed > 5)
		
		-- Determine next limit and current limit
		self.SpeedLimit = Vlimit
		self.NextLimit = Vlimit
		if self.Signal80 then self.NextLimit = 80 end
		if self.Signal70 then self.NextLimit = 70 end
		if self.Signal60 then self.NextLimit = 60 end
		if self.Signal40 then self.NextLimit = 40 end
		if self.Signal0  then self.NextLimit =  0 end

		if not EnableARS then
			self.ElectricBrake = false
			self.PneumaticBrake1 = false
			self.PneumaticBrake2 = true
		end
	else
		self.SpeedLimit = 0
		self.NextLimit = 0
		self.Overspeed = true
		--self.Ring = false
	end
	
	if EnableARS then
		-- Check absolute stop
		if self.NoFreq and (not self.PrevNoFreq) then
			self.IgnorePedal = true
		end	
		self.PrevNoFreq = self.NoFreq
		-- Check overspeed
		if self.Overspeed then
			self.ElectricBrake = true
			self.PneumaticBrake2 = true
			self.PV1Timer = CurTime()
		end
		-- Check cancel of overspeed command
		if self.AttentionPedal and (not self.Overspeed) then
			self.ElectricBrake = false
			self.PneumaticBrake2 = false
		end
		
		-- Parking brake limit
		triggerSpeed = 5.0
		if (Train:ReadTrainWire(6) > 0) then triggerSpeed = 0.25 end
		
		-- Check parking brake functionality
		self.TW1Timer = self.TW1Timer or -1e9
		if (self.Speed < triggerSpeed) and 
		   ((CurTime() - self.TW1Timer) > 5) and
		   ((Train:ReadTrainWire(2) > 0) or
		    (Train:ReadTrainWire(6) < 1)) then
			self.PneumaticBrake1 = true
		end
		-- Check cancel pneumatic brake 1 command
		--if (Train.RV2) and (Train.RV2.Value > 0) then
		if (Train:ReadTrainWire(1) > 0) then
			self.PneumaticBrake1 = false
			self.TW1Timer = CurTime()
		end
		-- Door close cancel pneumatic brake 1 command trigger
		if (Train:GetSkin() == 1) and (Train.KD) then
			-- Prepare
			if (Train.KD.Value == 0) then
				self.KDReadyToRelease = true
			end
			if (Train.KD.Value == 1) and (self.KDReadyToRelease == true) then
				self.KDReadyToRelease = false
				self.PneumaticBrake1 = false
				self.TW1Timer = CurTime() - 2.0
			end
		end
		-- Check use of valve #1 during overspeed
		self.PV1Timer = self.PV1Timer or -1e9
		if ((CurTime() - self.PV1Timer) < 0.45) then self.PneumaticBrake1 = false end
		if ((CurTime() - self.PV1Timer) < 0.35) then self.PneumaticBrake1 = true end
		
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
		self["8"] = Pbrake2*(((CurTime() - self.PV1Timer) > 2.5) and 1 or 0)
		
		-- Show lamps
		self.LKT = (self["33G"] > 0.5) or (self["29"] > 0.5) or (Train:ReadTrainWire(35) > 0)
		self.LVD = self["33D"] < 0.5
		self.Ring = self.LVD
	else
		if (Train.RPB) and (not self.AttentionPedal) then
			Train.RPB:TriggerInput("Open",1)
		end
		self.ElectricBrake = true
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
		self.Ring = false
	end
	
	-- ARS signalling train wires
	if EnableALS and EnableARS then
		self.Train:WriteTrainWire(21,self.LVD and 1 or 0)--self.LKT and 1 or 0)
	else
		self.Train:WriteTrainWire(21,0)
	end
	
	-- ARS anti-door-closing
	if EnableARS then
		local SD = self.Train:ReadTrainWire(15)
		if (SD < 1.0) and (self.Speed > 6.0) then
			self["31"] = 1
			self["32"] = 1
		else
			self["31"] = 0
			self["32"] = 0
		end
	end
	
	-- RC1 operation
	if self.Train.RC1 and (self.Train.RC1.Value == 0) then
		self["33D"] = 1
		self["33G"] = 0
		self["33Zh"] = 1
		self["2"] = 0
		self["20"] = 0
		self["29"] = 0
		self["8"] = 0
		self["31"] = 0
		self["32"] = 0
	end
	
	-- 81-717 autodrive/autostop
	if Train.Autodrive and (Train.Autodrive.Value > 0.0) then
		-- Calculate distance to station
		local Station = Train:ReadCell(49160)
		local Corrections = {
			[114] = 0.70,
			[123] = 3.20,
		}
		local dX = Train:ReadCell(49165)-10-5 + 6.5 - 3.3 + (Corrections[Station] or 0)
		
		-- Target and real RK position (0 if not braking)
		local TargetRKPosition = 0
		local RKPosition = math.floor(Train.RheostatController.Position+0.5)
		
		-- If standing on station and controller in zero, arm the autodrive
		if (self.Speed < 0.1) and (Train.KV.ControllerPosition == 0.0) then self.AutodriveArmed = true end
		
		-- Calculate next speed limit
		local speedLimit = self.NextLimit
		if speedLimit == 0 then speedLimit = 20 end
		
		-- Check speed constraints
		if self.Speed > (speedLimit - 3) then	self.NoAcceleration = true end
		if self.Speed < (speedLimit - 7) then	self.NoAcceleration = false end
		
		-- Check slope
		local Slope = (Train:GetAngles().pitch > 3.0)
		local Wire2 = false

		-- Slow down if overspeeding soon
		local threshold = 1.0
		if Slope and (self.NextLimit == 40) then TargetRKPosition = 7 end
		if Slope and (self.NextLimit == 60) then TargetRKPosition = 1 Wire2 = (self.Speed > 55) end
		if Slope and (self.NextLimit == 80) then TargetRKPosition = 1 Wire2 = (self.Speed > 75) end
		if (self.Speed > (speedLimit - threshold)) then TargetRKPosition = 18 Wire2 = true end
		
		-- threshold = 5 
		-- threshold = 10
		
		-- Full stop command
		if self.SpeedLimit < 30 then TargetRKPosition = 18 Wire2 = true end
		
		-- Calculate RK position based on distance and autodrive profile
		if self.AutodriveArmed ~= true then
			if dX < 160   then TargetRKPosition = 1 end
			if dX < 70+35 then TargetRKPosition = 3 end
			if dX < 50+30 then TargetRKPosition = 5 end
			if dX < 20+25 then TargetRKPosition = 9 end
			if dX < 10+20 then TargetRKPosition = 12 end
			if dX < 15    then TargetRKPosition = 13 end
			if dX < 12    then TargetRKPosition = 15 end
			if dX <  8    then TargetRKPosition = 16 end
			if dX <  5    then TargetRKPosition = 18 end
		else
			if dX > 5.0 then self.AutodriveArmed = false end
		end

		-- Generate commands
		local DriveDisabled = self.NoAcceleration and 1 or 0
		local ElectricBrakeActive = (FullStop or (TargetRKPosition > 0)) and 1 or 0
		local RheostatRotating = (Wire2 or (RKPosition < TargetRKPosition)) and 1 or 0
		local PneumaticValve1 = ((dX < 1.55) and (self.Speed > 0.1) and (self.AutodriveArmed ~= true)) and 1 or 0
		local FastEngageBrakes = (Wire2 and 1 or 0)*0
		
		-- Prevent engaging circuits
		local NoPowerCircuits = 0
		if self["33G"] > 0 then self.BrakeEngageTimer = CurTime()+0.5 end
		if self.BrakeEngageTimer and (CurTime() < self.BrakeEngageTimer) then NoPowerCircuits = 1 end
		
		-- Send commands
		self["33D"] = (1-ElectricBrakeActive)*(1-DriveDisabled)*(1-NoPowerCircuits) -- Block drive circuit
		self["33G"] = ElectricBrakeActive -- Engage electric braking
		self["33Zh"] = 1-ElectricBrakeActive -- Block manual brake
		self["2"] = ElectricBrakeActive*RheostatRotating -- Rheostat rotate
		self["20"] = ElectricBrakeActive -- Engage power circuits
		self["29"] = PneumaticValve1-- Engage PN1
		self["8"] = FastEngageBrakes -- Engage PN2
		
		-- Light up lamps
		self.LKT = (self["33G"] > 0.5) or (self["29"] > 0.5) or (Train:ReadTrainWire(35) > 0)
		self.LVD = self["33D"] < 0.5
		self.Ring = (self.Speed > math.max(10,self.SpeedLimit))
		
		-- Drive hack
		if (Train.KV.ControllerPosition == 1.0) and (self["33D"] > 0.5) then
			Train:WriteCell(2,1)
			Train:WriteCell(3,1)
		else
			Train:WriteCell(2,0)
			Train:WriteCell(3,0)
		end
	else
		self.AutodriveArmed = nil
		self.NoAcceleration = nil
		Train:WriteCell(2,0)
		Train:WriteCell(3,0)
	end
	
	-- 81-717 special VZ1 button
	if self.Train.VZ1 then
		self["29"] = self["29"] + self.Train.VZ1.Value
	end
	
	-- Special UPPS behavior
	if GetConVarNumber("metrostroi_upps") > 0 then
		local distance = Train:ReadCell(49165)
		local skip_station = false
		
		-- Check if station must be skipped
		local station = Train:ReadCell(49161)
		if Metrostroi.StationNamesConfiguration[station] then
			if (Metrostroi.StationNamesConfiguration[station][4] or 1) < 1 then
				skip_station = true
			end
		end
		
		-- Default trigger
		if (distance > 100) and (distance < 210) and (not skip_station) then self.UPPSArmed1 = true end
		if self.UPPSArmed1 and (distance < 100) then
			Train:PlayOnce("upps","cabin",0.6,100.0)
			self.UPPSArmed1 = false
		end
		
		-- KV trigger
		if Train.KV and (Train.KV.ReverserPosition == 0.0) then
			self.UPPSArmed2 = true
			--self.UPPSTimer2 = CurTime() + 1.5
		end
		if self.UPPSArmed2 and Train.KV and (Train.KV.ReverserPosition == 1.0) then --and self.UPPSTimer2 and (CurTime() > self.UPPSTimer2) then
			Train:PlayOnce("upps","cabin",0.6,100.0)
			self.UPPSArmed2 = false
		end
	end
end
