--------------------------------------------------------------------------------
-- Токоприёмник контактного рельса (ТР-3Б)
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("TR_3B")
TRAIN_SYSTEM.DontAccelerateSimulation = true

function TRAIN_SYSTEM:Initialize()
	-- Output voltage from contact rail
	self.Main750V = 0.0
end

function TRAIN_SYSTEM:Inputs()
	return { }
end

function TRAIN_SYSTEM:Outputs()
	return { "Main750V" }
end

function TRAIN_SYSTEM:CheckContact(ent,pos,dir)
	local trace = {
		start = ent:LocalToWorld(pos),
		endpos = ent:LocalToWorld(pos + dir*10),
		mask = -1,
		filter = { self.Train, ent },
	}
	
	local result = util.TraceLine(trace)
	return result.Hit
end

function TRAIN_SYSTEM:Think()
	-- Check contact states
	self.PlayTime = self.PlayTime or { 0, 0, 0, 0 }
	self.ContactStates = self.ContactStates or { false, false, false, false }
	self.NextStates = self.NextStates or {}
	self.NextStates[1] = self:CheckContact(self.Train.FrontBogey,Vector(0,-61,-14),Vector(0,-1,0))
	self.NextStates[2] = self:CheckContact(self.Train.FrontBogey,Vector(0, 61,-14),Vector(0, 1,0))
	self.NextStates[3] = self:CheckContact(self.Train.RearBogey,Vector(0, -61,-14),Vector(0,-1,0))
	self.NextStates[4] = self:CheckContact(self.Train.RearBogey,Vector(0,  61,-14),Vector(0, 1,0))
	
	-- Detect changes in contact states
	for i=1,4 do
		local state = self.NextStates[i]
		if state ~= self.ContactStates[i] then
			self.ContactStates[i] = state
			
			if true then --state then
				local dt = CurTime() - self.PlayTime[i]
				self.PlayTime[i] = CurTime()

				local volume = 0.60
				if dt < 1.0 then volume = 0.50 end
				self.Train:PlayOnce("tr","front_bogey",volume,math.random(90,120))
			end
		end
	end

	if not (GetConVarNumber("metrostroi_train_requirethirdrail") > 0) then
		self.Main750V = 750
		return 
	end

	-- Detect voltage
	self.Main750V = 0
	for i=1,4 do
		if self.ContactStates[i] then self.Main750V = 750 end
	end
end
