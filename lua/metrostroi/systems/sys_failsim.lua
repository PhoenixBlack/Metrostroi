--------------------------------------------------------------------------------
-- Failure simulator interface
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("FailSim")
TRAIN_SYSTEM.RunEverywhere = true

function TRAIN_SYSTEM:Initialize()

end

function TRAIN_SYSTEM:Outputs()
end

function TRAIN_SYSTEM:Inputs()
	return { "Status", "Fail" }
end

function TRAIN_SYSTEM:TriggerInput(name,value)
	if name == "Status" then
		if TURBOSTROI then FailSim.Report(nil,"failures") end
	elseif name == "Fail" then
		if TURBOSTROI then FailSim.RandomFailure() end
	end
end