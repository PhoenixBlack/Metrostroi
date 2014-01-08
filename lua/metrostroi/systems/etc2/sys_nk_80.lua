--------------------------------------------------------------------------------
-- Аккумуляторная батарея (НК-80)
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("NK_80")

function TRAIN_SYSTEM:Initialize()
	-- Battery voltage
	self.Voltage = 70
	
	-- Battery capacity
	self.Capacity = 70*80*3600 -- Watt-Seconds
end

function TRAIN_SYSTEM:Inputs()
	return { }
end

function TRAIN_SYSTEM:Outputs()
	return { "Output80V" }
end

function TRAIN_SYSTEM:Think()
	--self.Voltage = 80
end
