--------------------------------------------------------------------------------
-- Кулачковый контроллер КВ-66
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("KV_66")

function TRAIN_SYSTEM:Initialize()
	self.ControllerPosition = 0
	self.ReverserPosition = 0
	
	-- Relay that enables KV-66 controller
	self.Train:LoadSystem("KVEnabled","Relay")
	-- X1
	self.Train:LoadSystem("P_X1","Relay")
	-- X2
	self.Train:LoadSystem("P_X2","Relay")
	-- X3
	self.Train:LoadSystem("P_X3","Relay")
	-- Electric brake enabled
	self.Train:LoadSystem("P_T","Relay")
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
	self.Train:PlayOnce("switch",true)
	
	-- Update reverser position
	local Train = self.Train
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
	end
end

function TRAIN_SYSTEM:TriggerInput(name,value)
	if name == "ControllerSet" then
		if (self.ReverserPosition ~= 0) and (math.floor(value) ~= self.ControllerPosition) then
			self.ControllerPosition = math.floor(value)
			if self.ControllerPosition >  3 then self.ControllerPosition =  3 end
			if self.ControllerPosition < -3 then self.ControllerPosition = -3 end
			self:Step()
		end
	elseif name == "ReverserSet" then
		if math.floor(value) ~= self.ReverserPosition then
			self.ReverserPosition = math.floor(value)
			if self.ReverserPosition >  1 then self.ReverserPosition =  1 end
			if self.ReverserPosition < -1 then self.ReverserPosition = -1 end
			self:Step()
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
		self:Step()
	end

	-- Enable controller when moving into zero position
	if self.ControllerPosition == 0.0 then
		Train.KVEnabled:TriggerInput("Close",1.0)
	end

	-- Send corresponding values over the train wires
	if self.ReverserPosition ~= 0 then
		Train:WriteTrainWire(1,Train.P_X1.Value)
		Train:WriteTrainWire(2,Train.P_X2.Value)
		Train:WriteTrainWire(3,Train.P_X3.Value)
		Train:WriteTrainWire(4,Train.P_T.Value)
	end
end
