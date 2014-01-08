--------------------------------------------------------------------------------
-- Панель автовыключетелей АК-63Б
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("AK_63B_Relays")

function TRAIN_SYSTEM:Initialize()
	-- A22 КК
	self.Train:LoadSystem("A22","Relay","AK_63B")
	-- A24 Плюс БПСН
	self.Train:LoadSystem("A24","Relay","AK_63B")
	-- A53 КВЦ, КУП
end

function TRAIN_SYSTEM:Inputs()
	return { }
end

function TRAIN_SYSTEM:Outputs()
	return { }
end

function TRAIN_SYSTEM:TriggerInput(name,value)	
	
end

function TRAIN_SYSTEM:Think()
	local Train = self.Train
	
	-- A22
	if (Train.KK.Value < 0.0) and (Train.A22.Value > 0.5) then
		Train.A22:TriggerInput("Close",1.0)
	end
	if Train.A22.Value > 0.5 then
		Train.KK:TriggerInput("Open",1.0)
	else
		Train.KK:TriggerInput("Close",1.0)
	end
end
