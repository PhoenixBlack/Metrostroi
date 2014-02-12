--------------------------------------------------------------------------------
-- ДУРА (Дополнительная Универсальная Радиоаппаратура)
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("DURA")
TRAIN_SYSTEM.DontAccelerateSimulation = true

function TRAIN_SYSTEM:Initialize()
	self.SelectAlternate = nil
	self.SwitchBlocked = false
	self.AlternateTrack = false
	
	self.NextLightRed = false
	self.NextLightYellow = false
	self.DistanceToLight = -1
end

function TRAIN_SYSTEM:Outputs()
	return { "SwitchBlocked", "SelectedAlternate",
			 "SelectingAlternate", "SelectingMain",
			 "NextLightRed","NextLightYellow","DistanceToLight" }
end

function TRAIN_SYSTEM:Inputs()
	return { "SelectAlternate", "SelectMain" }
end

function TRAIN_SYSTEM:TriggerInput(name,value)
	if (name == "SelectAlternate") and (value > 0.0) then
		self.SelectAlternate = true
		self.OntoAlternateTrack = false
	elseif (name == "SelectMain") and (value > 0.0) then
		self.SelectAlternate = false
    end
end

function TRAIN_SYSTEM:Think()
	-- Require 80 volts
	--if self.Train.Electric and (self.Train.Electric.Aux80V < 70) then return end
	
	-- Check ARS signals
	self.Timer = self.Timer or CurTime()
	if CurTime() - self.Timer > 0.50 then
		self.Timer = CurTime()

		-- Get next track switch and get its state
		local switch = Metrostroi.GetNextTrackSwitch(self.Train)
		if switch then
			self.AlternateTrack = switch:GetTrackSwitchState()
		else
			self.AlternateTrack = false
		end
		
		-- Execute logic
		if (self.SelectAlternate == true) and switch then
			self.SwitchBlocked = not switch:SetTrackSwitchState(true,self.Train)
		elseif (self.SelectAlternate == false) and (self.AlternateTrack == true) and switch then
			self.SwitchBlocked = not switch:SetTrackSwitchState(false,self.Train)
		else
			self.SwitchBlocked = false
		end
		
		-- Auto-shutdown track switch logic thing
		if (self.SelectAlternate == true) and (self.AlternateTrack == true) and
		   (not self.OntoAlternateTrack) then
			self.OntoAlternateTrack = true
		end
		if (self.SelectAlternate == true) and (self.AlternateTrack == false) and
		   (self.OntoAlternateTrack == true) then
			self.OntoAlternateTrack = false
			self.SelectAlternate = nil
		end
		if (self.SelectAlternate == false) and (self.AlternateTrack == false) then
			self.SelectAlternate = nil
			self.OntoAlternateTrack = false
		end
		
		-- Find next traffic light
		local train_pos =  Metrostroi.TrainPositions[self.Train]
		if train_pos then
			local facing = train_pos.forward_facing
			--if self.Reverse then facing = not facing end
			local foundIndex,foundType,foundEnt =
				Metrostroi.FindTrainOrLight(self.Train,train_pos.position,train_pos.section,{},facing)
				
			if foundType == "light" then
				local lights = foundEnt.LightStates or {}
				self.NextLightRed = lights[1] or false
				self.NextLightYellow = lights[2] or false
				self.DistanceToLight = foundEnt:GetPos():Distance(self.Train:GetPos())*0.01905
			elseif foundType == "train" then
				self.NextLightRed = true
				self.NextLightYellow = true
				self.DistanceToLight = 0.1
			else
				self.NextLightRed = false
				self.NextLightYellow = false
				self.DistanceToLight = -1
			end

			-- Red light run logic
			if (foundType == "light") and foundEnt and (self.DistanceToLight < 3) then
				if foundEnt.LightStates[1] == true then
					--if (self.DriverMode > 2) and (self.Speed > 11) and (self.Reverse == false) then
					---	self:SetDriverMode(1)
					--	self:PlayOnce("warning",true)
					--end
				end
			end
		else
			self.NextLightRed = false
			self.NextLightYellow = false
			self.DistanceToLight = -1
		end
	end
	
	-- Output
	--[[self:TriggerOutput("SwitchBlocked", 		self.SwitchBlocked and 1 or 0)
	self:TriggerOutput("SelectedAlternate", 	self.OntoAlternateTrack and 1 or 0)
	self:TriggerOutput("SelectingAlternate", 	(self.SelectAlternate == true) and 1 or 0)
	self:TriggerOutput("SelectingMain",			(self.SelectAlternate == false) and 1 or 0)
	self:TriggerOutput("NextLightRed",			self.NextLightRed and 1 or 0)
	self:TriggerOutput("NextLightYellow",		self.NextLightYellow and 1 or 0)
	self:TriggerOutput("DistanceToLight",		self.DistanceToLight)]]--
end