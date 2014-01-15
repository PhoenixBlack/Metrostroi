--------------------------------------------------------------------------------
-- Кулачковый контроллер КВ-66
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("KV_66")

function TRAIN_SYSTEM:Initialize()
	self.ControllerPosition = 0
	self.ReverserPosition = 0
	
	-- Relay that enables KV-66 controller
	self.Train:LoadSystem("KVEnabled","Relay")
end

function TRAIN_SYSTEM:Inputs()
	return { "ControllerSet", "ReverserSet",
			 "ControllerUp","ControllerDown","ReverserUp","ReverserDown",
			 "SetX1", "SetX2", "SetX3", "Set0", "SetT1", "SetT1A", "SetT2" }
end

function TRAIN_SYSTEM:Outputs()
	return { "ControllerPosition", "ReverserPosition" }
end

function TRAIN_SYSTEM:Step()
	
	
	-- Update reverser position
	--[[local Train = self.Train
	if self.ReverserPosition > 0 then
		Train.PR_772:TriggerInput("Open",1.0)
	elseif self.ReverserPosition < 0 then
		Train.PR_772:TriggerInput("Close",1.0)
	end
	
	-- If contrller enabled, trigger relays
	if Train.KVEnabled.Value == 1.0 then
		-- Setup parallel or series circuit
		if self.ControllerPosition <= 2 then
			Train.T_Parallel:TriggerInput("Open",1.0)
			-- Parallel circuit will be enabled when rheostat reaches position 18
		--else
			--Train.T_Parallel:TriggerInput("Close",1.0)
		end
		
		-- Setup brake or drive circuit
		if self.ControllerPosition > 0 then
			Train.T_Brake:TriggerInput("Open",1.0)
			Train.P_T:TriggerInput("Open",1.0)
		end
		if self.ControllerPosition < 0 then
			Train.T_Brake:TriggerInput("Close",1.0)
			Train.P_T:TriggerInput("Close",1.0)
		end
		
		-- Trigger information relays
		if math.abs(self.ControllerPosition) == 1 then
			Train.P_X1:TriggerInput("Close",1.0)
			Train.P_X2:TriggerInput("Open",1.0)
			Train.P_X3:TriggerInput("Open",1.0)
		elseif math.abs(self.ControllerPosition) == 2 then
			Train.P_X1:TriggerInput("Open",1.0)
			Train.P_X2:TriggerInput("Close",1.0)
			Train.P_X3:TriggerInput("Open",1.0)
		elseif math.abs(self.ControllerPosition) == 3 then
			Train.P_X1:TriggerInput("Open",1.0)
			Train.P_X2:TriggerInput("Open",1.0)
			Train.P_X3:TriggerInput("Close",1.0)
		end
		
		-- Trigger corresponding relays	
		if self.ControllerPosition == 0 then
			Train.LK1:TriggerInput("Open",1.0)
			Train.LK2:TriggerInput("Open",1.0)
			Train.LK3:TriggerInput("Open",1.0)
			Train.LK4:TriggerInput("Open",1.0)
			Train.KSH1:TriggerInput("Open",1.0)
			Train.KSH2:TriggerInput("Open",1.0)
			Train.KSH3:TriggerInput("Open",1.0)
			Train.KSH4:TriggerInput("Open",1.0)		
		else
			Train.LK1:TriggerInput("Close",1.0)
			Train.LK2:TriggerInput("Close",1.0)
			Train.LK3:TriggerInput("Close",1.0)
			Train.LK4:TriggerInput("Close",1.0)
			Train.KSH1:TriggerInput("Close",1.0)
			Train.KSH2:TriggerInput("Close",1.0)
			Train.KSH3:TriggerInput("Close",1.0)
			Train.KSH4:TriggerInput("Close",1.0)
		end
	end]]--
end

function TRAIN_SYSTEM:TriggerInput(name,value)
	
	local prevReverserPosition = self.ReverserPosition
	
	-- Change position
	if name == "ControllerSet" then
		if (self.ReverserPosition ~= 0) and (math.floor(value) ~= self.ControllerPosition) then
			local prevControllerPosition = self.ControllerPosition
			self.ControllerPosition = math.floor(value)
			
			-- Limit motion
			if self.ControllerPosition >  3 then self.ControllerPosition =  3 end
			if self.ControllerPosition < -3 then self.ControllerPosition = -3 end
			
			-- Play sounds
			local dC = math.abs(prevControllerPosition - self.ControllerPosition)
			if dC == 1 then self.Train:PlayOnce("kv1",true,0.6) end
			if dC == 2 then self.Train:PlayOnce("kv2",true,0.6) end
			if dC >= 3 then self.Train:PlayOnce("kv3",true,0.6) end
		end		
		
	elseif name == "ReverserSet" then
		if math.floor(value) ~= self.ReverserPosition then
			self.ReverserPosition = math.floor(value)
			if self.ReverserPosition >  1 then self.ReverserPosition =  1 end
			if self.ReverserPosition < -1 then self.ReverserPosition = -1 end
		end
	elseif (name == "ControllerUp") and (value > 0.5) then
		self:TriggerInput("ControllerSet",self.ControllerPosition+1)
	elseif (name == "ControllerDown") and (value > 0.5) then
		self:TriggerInput("ControllerSet",self.ControllerPosition-1)
		elseif (name == "ReverserUp") and (value > 0.5) then
		self:TriggerInput("ReverserSet",self.ReverserPosition+1)
	elseif (name == "ReverserDown") and (value > 0.5) then
		self:TriggerInput("ReverserSet",self.ReverserPosition-1)
	elseif (name == "SetX1") and (value > 0.5) then
		self:TriggerInput("ControllerSet",1)
	elseif (name == "SetX2") and (value > 0.5) then
		self:TriggerInput("ControllerSet",2)
	elseif (name == "SetX3") and (value > 0.5) then
		self:TriggerInput("ControllerSet",3)
	elseif (name == "Set0") and (value > 0.5) then
		self:TriggerInput("ControllerSet",0)		
	elseif (name == "SetT1") and (value > 0.5) then
		self:TriggerInput("ControllerSet",-1)
	elseif (name == "SetT1A") and (value > 0.5) then
		self:TriggerInput("ControllerSet",-2)
	elseif (name == "SetT2") and (value > 0.5) then
		self:TriggerInput("ControllerSet",-3)
	end
end


function TRAIN_SYSTEM:Think()
	local Train = self.Train
	self:TriggerOutput("ControllerPosition",self.ControllerPosition)
	self:TriggerOutput("ReverserPosition",self.ReverserPosition)

	if (self.ReverserPosition == 0) and (self.ControllerPosition ~= 0) then
		self.ControllerPosition = 0
		self.Train:PlayOnce("kv1",true,0.6)
	end

	-- Enable controller when moving into zero position
	if self.ControllerPosition == 0.0 then
		Train.KVEnabled:TriggerInput("Close",1.0)
	end

	-- Trigger train wires according to the controller value
	if (self.ReverserPosition ~= 0) and (Train.KVEnabled.Value == 1.0) then
		local W9 = Train:ReadTrainWire(9)
		
		-- X1 X2 X3
		Train:WriteTrainWire(1,W9 * ((math.abs(self.ControllerPosition) == 1) and 1 or 0))
		Train:WriteTrainWire(3,W9 * ((math.abs(self.ControllerPosition) == 2) and 1 or 0))
		Train:WriteTrainWire(2,W9 * ((math.abs(self.ControllerPosition) == 3) and 1 or 0))
		
		-- T1 T2 T3
		Train:WriteTrainWire(6,W9 * ((self.ControllerPosition < 0) and 1 or 0))
		
		-- R1 R2
		Train:WriteTrainWire(4,W9 * ((self.ReverserPosition ==  1) and 1 or 0))
		Train:WriteTrainWire(5,W9 * ((self.ReverserPosition == -1) and 1 or 0))
	end
end
