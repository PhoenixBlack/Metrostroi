--------------------------------------------------------------------------------
-- АРС-АЛС
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("ALS_ARS")
TRAIN_SYSTEM.DontAccelerateSimulation = true

function TRAIN_SYSTEM:Initialize()
	self.Signal80 = false
	self.Signal70 = false
	self.Signal60 = false
	self.Signal40 = false
	self.Signal0 = false
	self.Special = false
	self.NoFreq = true
end

function TRAIN_SYSTEM:Outputs()
	return { }
end

function TRAIN_SYSTEM:Inputs()
	return { }
end

function TRAIN_SYSTEM:TriggerInput(name,value)

end

function TRAIN_SYSTEM:Think()
	if self.Train.VB and (self.Train.VB.Value == 0.0) then return end
	if self.Train.ALS.Value == 0.0 then
		self.Signal80 = false
		self.Signal70 = false
		self.Signal60 = false
		self.Signal40 = false
		self.Signal0 = false
		self.Special = false
		self.NoFreq = false
		return
	end
	
	-- Check ARS signals
	self.Timer = self.Timer or CurTime()
	if CurTime() - self.Timer > 1.00 then
		self.Timer = CurTime()

		-- Get train position
		local pos = Metrostroi.TrainPositions[self.Train]
		if pos then pos = pos[1] end

		-- Get previous ARS section
		local ars
		if pos then ars = Metrostroi.GetARSJoint(pos.node1,pos.x,false) end
		if ars then
			self.Signal80	= ars:GetActiveSignalsBit(10)
			self.Signal70	= ars:GetActiveSignalsBit(11)
			self.Signal60	= ars:GetActiveSignalsBit(12)
			self.Signal40	= ars:GetActiveSignalsBit(13)
			self.Signal0	= ars:GetActiveSignalsBit(14)
			self.Special	= ars:GetActiveSignalsBit(15)
			self.NoFreq		= false

			if not (self.Signal80 or self.Signal70 or 
					self.Signal60 or self.Signal40 or self.Signal0) then
				self.NoFreq = true
			end
		else
			self.Signal80 = false
			self.Signal70 = false
			self.Signal60 = false
			self.Signal40 = false
			self.Signal0 = false
			self.Special = false
			self.NoFreq = true
		end
	end
end