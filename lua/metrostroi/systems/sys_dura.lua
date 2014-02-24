--------------------------------------------------------------------------------
-- ДУРА (Дополнительная Универсальная Радиоаппаратура)
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("DURA")
TRAIN_SYSTEM.DontAccelerateSimulation = true

function TRAIN_SYSTEM:Initialize()
	self.SelectAlternate = nil
	--self.SwitchBlocked = false
	--self.AlternateTrack = false
	
	--self.NextLightRed = false
	--self.NextLightYellow = false
	--self.DistanceToLight = -1
end

function TRAIN_SYSTEM:Outputs()
	return { } --[["SwitchBlocked", "SelectedAlternate",
			 "SelectingAlternate", "SelectingMain",
			 "NextLightRed","NextLightYellow","DistanceToLight" }]]--
end

function TRAIN_SYSTEM:Inputs()
	return { "SelectAlternate", "SelectMain" }
end

function TRAIN_SYSTEM:TriggerInput(name,value)
	if (name == "SelectAlternate") and (value > 0.0) then
		self.SelectAlternate = true
	elseif (name == "SelectMain") and (value > 0.0) then
		self.SelectAlternate = false
    end
end

function TRAIN_SYSTEM:Think()
	-- Require 80 volts
	if self.Train.Electric and (self.Train.Electric.Aux80V < 70) then return end
	--self.Train:PlayOnce("dura2","cabin",0.4,100)
	
	-- Check ARS signals
	self.Timer = self.Timer or CurTime()
	if CurTime() - self.Timer > 2.00 then
		self.Timer = CurTime()

		-- Get train position
		local pos = Metrostroi.TrainPositions[self.Train]
		if pos then pos = pos[1] end

		-- Get all switches in current isolated section
		local no_switches = true
		local signal = 0
		if pos then
			local switches = Metrostroi.GetTrackSwitches(pos.node1,pos.x,pos.forward)
			for _,switch in pairs(switches) do
				no_switches = false
				if self.SelectAlternate == true then
					switch:SendSignal("alt")
				elseif self.SelectAlternate == false then
					switch:SendSignal("main")
				end
				signal = switch:GetSignal()
			end
		end
		if signal == 1 then
			self.Train:PlayOnce("dura1","cabin",0.35,200)
		end
		
		-- If no switches, reset
		if no_switches and (self.SelectAlternate ~= nil) then
			self.Train:PlayOnce("dura2","cabin",0.35,200)
			self.SelectAlternate = nil
		end
	end
end