--------------------------------------------------------------------------------
-- Груповой переключатель положений (ЕКГ-18Б)
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("EKG_18B")

function TRAIN_SYSTEM:Initialize()
	-- Rheostat configuration
	self.Configuration = {
	--   ##      1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 
		[ 1] = { 0, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 1, 0, 0, 0, 1, 0, 1 },-- PS
		[ 2] = { 1, 0, 1, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0, 0 },-- PP
		[ 3] = { 0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 0 },-- PT1
		[ 4] = { 0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 0 },-- PT2 (not used)
	}
	Metrostroi.BaseSystems["EKG"].Initialize(self)
end

TRAIN_SYSTEM.Inputs = Metrostroi.BaseSystems["EKG"].Inputs
TRAIN_SYSTEM.Outputs = Metrostroi.BaseSystems["EKG"].Outputs
TRAIN_SYSTEM.TriggerInput = Metrostroi.BaseSystems["EKG"].TriggerInput
TRAIN_SYSTEM.Think = Metrostroi.BaseSystems["EKG"].Think