--------------------------------------------------------------------------------
-- Кулачковый контроллер КВ-66
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("KV_66")

function TRAIN_SYSTEM:Initialize()
	self.ControllerPosition = 0
	self.ReverserPosition = 0
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

	local Train = self.Train
	if self.ReverserPosition > 0 then
		Train.PR_772:TriggerInput("Open",1.0)
	elseif self.ReverserPosition < 0 then
		Train.PR_772:TriggerInput("Close",1.0)
	end
	
	
	if self.ControllerPosition == 1 then
		Train.T_Parallel:TriggerInput("Open",1.0)
		Train.T_Brake:TriggerInput("Open",1.0)
	elseif self.ControllerPosition == 2 then
		Train.T_Parallel:TriggerInput("Open",1.0)
		Train.T_Brake:TriggerInput("Open",1.0)
	elseif self.ControllerPosition == 3 then
		Train.T_Parallel:TriggerInput("Close",1.0)		
		Train.T_Brake:TriggerInput("Open",1.0)
	elseif self.ControllerPosition == -1 then
		Train.T_Parallel:TriggerInput("Open",1.0)
		Train.T_Brake:TriggerInput("Close",1.0)
	elseif self.ControllerPosition == -2 then
		Train.T_Parallel:TriggerInput("Open",1.0)
		Train.T_Brake:TriggerInput("Close",1.0)
	elseif self.ControllerPosition == -3 then
		Train.T_Parallel:TriggerInput("Open",1.0)
		Train.T_Brake:TriggerInput("Close",1.0)
	end
	
	
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
		--if self.ControllerPosition == 3 then
			--Train.RheostatController.Position = 18
		--end
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
	self:TriggerOutput("ControllerPosition",self.ControllerPosition)
	self:TriggerOutput("ReverserPosition",self.ReverserPosition)

	self:TriggerInput("ReverserSet",1)
--	self:TriggerInput("ControllerSet",2)
end
