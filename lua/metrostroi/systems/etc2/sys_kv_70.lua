--------------------------------------------------------------------------------
-- Кулачковый контроллер КВ-70
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("KV_70")

function TRAIN_SYSTEM:Initialize()
	self.ControllerPosition = 0
	self.ReverserPosition = 0
end

function TRAIN_SYSTEM:Inputs()
	return { "ControllerSet", "ReverserSet" }
end

function TRAIN_SYSTEM:Outputs()
	return { "ControllerPosition", "ReverserPosition" }
end

function TRAIN_SYSTEM:TriggerInput(name,value)	
	if name == "ControllerSet" then
		if self.ReverserPosition ~= 0 then
			self.ControllerPosition = math.floor(value)
			if self.ControllerPosition >  3 then self.ControllerPosition =  3 end
			if self.ControllerPosition < -3 then self.ControllerPosition = -3 end
		end
	elseif name == "ReverserSet" then
		self.ReverserPosition = math.floor(value)
		if self.ReverserPosition >  1 then self.ReverserPosition =  1 end
		if self.ReverserPosition < -1 then self.ReverserPosition = -1 end
	end
end


function TRAIN_SYSTEM:Think()
	self:TriggerOutput("ControllerPosition",self.ControllerPosition)
	self:TriggerOutput("ReverserPosition",self.ReverserPosition)
	
end
