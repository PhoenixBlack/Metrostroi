--------------------------------------------------------------------------------
-- Пульт для манверовых передвижений вагонов
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("PMP")

function TRAIN_SYSTEM:Initialize()
	self.Position = 0
	self.RealPosition = 0

	self.Matrix = {
		{"3",		"4"	},
		{	1,	0,	1	},
		{"9",		"10"},
		{	1,	0,	1	},
		{"5",		"6"	},
		{	1,	0,	0	},
		{"7",		"8"	},
		{	0,	0,	1	},
	}
	
	-- Initialize contacts values
	for i=1,#self.Matrix/2 do
		local v = self.Matrix[i*2-1]
		self[v[1].."-"..v[2]] = 0
	end	
end

function TRAIN_SYSTEM:Inputs()
	return { "Set", "Up", "Down" }
end

function TRAIN_SYSTEM:Outputs()
	return { "Position" }
end

function TRAIN_SYSTEM:TriggerInput(name,value)
	-- Change position
	if name == "Set" then
		if (self.Enabled ~= 0) and (math.floor(value) ~= self.Position) then
			local prevPosition = self.Position
			self.Position = math.floor(value)
			
			-- Limit motion
			if self.Position > 1  then self.Position = 1 end
			if self.Position < -1 then self.Position = -1 end
			
			-- Play sounds
			local dC = math.abs(prevPosition - self.Position)
			if dC == 1 then self.Train:PlayOnce("kv1","cabin",0.8) end
			if dC == 2 then self.Train:PlayOnce("kv2","cabin",0.8) end
			if dC >= 3 then self.Train:PlayOnce("kv3","cabin",0.8) end
		end		
	elseif (name == "Up") and (value > 0.5) then
		self:TriggerInput("Set",self.Position+1)
	elseif (name == "Down") and (value > 0.5) then
		self:TriggerInput("Set",self.Position-1)
	end
end


function TRAIN_SYSTEM:Think()
	local Train = self.Train
	if (self.Enabled == 0) and (self.Position ~= 0) then
		self.Position = 0
		self.Train:PlayOnce("kv1","cabin",0.6)
	end
	
	-- Move controller
	self.Timer = self.Timer or CurTime()
	if ((CurTime() - self.Timer > 0.15) and (self.Position > self.RealPosition)) then
		self.Timer = CurTime()
		self.RealPosition = self.RealPosition + 1
	end
	if ((CurTime() - self.Timer > 0.15) and (self.Position < self.RealPosition)) then
		self.Timer = CurTime()
		self.RealPosition = self.RealPosition - 1
	end
	
	-- Update contacts
	for i=1,#self.Matrix/2 do
		local v = self.Matrix[i*2-1]
		local d = self.Matrix[i*2]
		self[v[1].."-"..v[2]] = d[self.RealPosition+2]
	end
end
