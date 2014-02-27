AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/metrostroi/signals/ars_box.mdl")
	self.Sprites = {}
	Metrostroi.UpdateSignalEntities()
end

function ENT:OnRemove()
	Metrostroi.UpdateSignalEntities()
end

function ENT:SetSprite(index,active,model,scale,brightness,pos,color)
	if active and self.Sprites[index] then return end
	SafeRemoveEntity(self.Sprites[index])
	self.Sprites[index] = nil
	
	if active then
		local sprite = ents.Create("env_sprite")
		sprite:SetParent(self)
		sprite:SetLocalPos(pos)
		sprite:SetLocalAngles(self:GetAngles())
	
		-- Set parameters
		sprite:SetKeyValue("rendercolor",
			Format("%i %i %i",
				color.r*brightness,
				color.g*brightness,
				color.b*brightness
			)
		)
		sprite:SetKeyValue("rendermode", 9) -- 9: WGlow, 3: Glow
		sprite:SetKeyValue("model", model)
		sprite:SetKeyValue("scale", scale)
		sprite:SetKeyValue("spawnflags", 1)
	
		-- Turn sprite on
		sprite:Spawn()
		self.Sprites[index] = sprite
	end
end

function ENT:Logic(trackOccupied,nextRed,switchBlocked,switchAlternate)
	-- Should alternate/main position block the path
	if self:GetRedWhenMain() then
		switchBlocked = switchBlocked or (not switchAlternate)
	end
	if self:GetRedWhenAlternate() then
		switchBlocked = switchBlocked or switchAlternate
	end
	
	-- Red if track occupied, switch section is blocked (occupied), or always red
	self:SetRed(trackOccupied or switchBlocked or self:GetAlwaysRed())
	
	-- Yellow if next light is red or switch set to alternate
	self:SetYellow(nextRed or switchAlternate)
	-- Second yellow is switch set to alternate and not red
	self:SetSecondYellow(switchAlternate and (not self:GetRed()))
	
	-- Green if not alternate path selected and not red
	self:SetGreen(not (self:GetRed() or switchAlternate) )
	
	-- Mirror green with yellow, if signal does not have green on it
	--[[if not (
		self:GetTrafficLightsBit(0) or
		self:GetTrafficLightsBit(2) or
		self:GetTrafficLightsBit(7) or
		self:GetTrafficLightsBit(8)) then
		self:SetYellow(self:GetGreen())
	end]]--
end

function ENT:ARSLogic()
	if self:GetNoARS() then
		for i=10,15 do self:SetActiveSignalsBit(i,false) end
		return
	end
	
	-- Get position of the next ARS node
	local pos = Metrostroi.SignalEntityPositions[self]
	local node
	if pos then node = pos.node1 end
	if node and pos then
		-- Check if there is a train anywhere on the isolated area
		local nextARS = Metrostroi.GetARSJoint(node,pos.x,    pos.forward)
		local prevARS = Metrostroi.GetARSJoint(node,pos.x,not pos.forward)

		-- Default ARS signals
		local ARS80 = self:GetSettingsBit(0)
		local ARS70 = self:GetSettingsBit(1)
		local ARS60 = self:GetSettingsBit(2)
		local ARS40 = self:GetSettingsBit(3)
		local ARS0  = self:GetSettingsBit(4)
		local ARSsp = self:GetSettingsBit(5)
		
		-- Reset to zero when traffic light is red
		if nextARS and nextARS:GetRed() then
			ARS80 = false
			ARS70 = false
			ARS60 = false
			ARS40 = false
			ARS0 = true
		end

		-- Does this section have default set of signals defined
		if ARS80 or ARS70 or ARS60 or ARS40 or ARS0 or ARSsp then
			self:SetActiveSignalsBit(10,ARS80)
			self:SetActiveSignalsBit(11,ARS70)
			self:SetActiveSignalsBit(12,ARS60)
			self:SetActiveSignalsBit(13,ARS40)
			self:SetActiveSignalsBit(14,ARS0)
			self:SetActiveSignalsBit(15,ARSsp)
		elseif prevARS then
			-- Previous section feeds signals to this section
			for i=10,15 do self:SetActiveSignalsBit(i,false) end
			
			-- Read speed limit from previous section
			local speedLimit = prevARS.SpeedLimit or 0
			
			-- If speed limit in next section is less, create smooth stop for train
			if nextARS and ((nextARS.SpeedLimit or 0) < speedLimit) then
				if nextARS.SpeedLimit ==  0 then speedLimit = 40 end
				if nextARS.SpeedLimit == 40 then speedLimit = 60 end
				if nextARS.SpeedLimit == 60 then speedLimit = 70 end
				if nextARS.SpeedLimit == 70 then speedLimit = 80 end
			end
			
			-- Create signal based on new target speed limit
			if speedLimit ==  0 then self:SetActiveSignalsBit(14,true) end
			if speedLimit == 40 then self:SetActiveSignalsBit(13,true) end
			if speedLimit == 60 then self:SetActiveSignalsBit(12,true) end
			if speedLimit == 70 then self:SetActiveSignalsBit(11,true) end
			if speedLimit == 80 then self:SetActiveSignalsBit(10,true) end
			
			-- Add signal about next speed limit
			if nextARS and ((nextARS.SpeedLimit or 0) < speedLimit) then
				if nextARS.SpeedLimit ==  0 then self:SetActiveSignalsBit(14,true) end
				if nextARS.SpeedLimit == 40 then self:SetActiveSignalsBit(13,true) end
				if nextARS.SpeedLimit == 60 then self:SetActiveSignalsBit(12,true) end
				if nextARS.SpeedLimit == 70 then self:SetActiveSignalsBit(11,true) end
			end
		else
			-- No signals: error
			for i=10,15 do self:SetActiveSignalsBit(i,false) end
		end
		
		-- Generate speed limit in this ARS section
		self.SpeedLimit = 0
		if self:GetActiveSignalsBit(13) then self.SpeedLimit = 40 end
		if self:GetActiveSignalsBit(12) then self.SpeedLimit = 60 end
		if self:GetActiveSignalsBit(11) then self.SpeedLimit = 70 end
		if self:GetActiveSignalsBit(10) then self.SpeedLimit = 80 end
		
		--self:SetActiveSignalsBit(15,(CurTime() % 2.0) > 1.0)
	end
end

function ENT:Think()
	-- Do no interesting logic if there's no traffic light involved
	if self:GetTrafficLights() == 0 then
		self:ARSLogic()
		self:NextThink(CurTime() + 1.00)
		return true
	end
	
	-- Traffic light logic
	self.PrevTime = self.PrevTime or 0
	if (CurTime() - self.PrevTime) > 1.0 then
		self.PrevTime = CurTime()
		self:ARSLogic()
		
		-- Get position of the traffic light
		local pos = Metrostroi.SignalEntityPositions[self]
		local node
		if pos then node = pos.node1 end
		if node and pos then
			-- Check if there is a train anywhere on the isolated area
			local trackOccupied = Metrostroi.IsTrackOccupied(node,pos.x,pos.forward)
			local nextLight = Metrostroi.GetNextTrafficLight(node,pos.x,pos.forward)
			local nextRed = false
			if nextLight then nextRed = nextLight:GetRed() end
			
			-- Check if there's a track switch and it's set to alternate
			local switchAlternate = false
			local switchBlocked = false
			local switches = Metrostroi.GetTrackSwitches(node,pos.x,pos.forward)
			for _,switch in pairs(switches) do
				switchBlocked = switchBlocked or (switch.AlternateTrack and self.InhibitSwitching)
				switchAlternate = switchAlternate or switch.AlternateTrack
			end
			
			-- Execute logic
			self:Logic(trackOccupied,nextRed,switchBlocked,switchAlternate)
		else
			-- Execute logic (but no track data is available
			self:Logic(false,false,false,false)
		end
	end
	
	-- Create sprites and manage lamps
	local index = 1
	local models = self.TrafficLightModels[self:GetLightsStyle()] or {}	
	local offset = self.RenderOffset[self:GetLightsStyle()] or Vector(0,0,0)
	for k,v in ipairs(models) do
		if self:GetTrafficLightsBit(k-1) and v[3] then
			offset = offset - Vector(0,0,v[1])
			for light,data in pairs(v[3]) do
				local state = self:GetActiveSignalsBit(light)
				if light == 4 then state = state and ((CurTime() % 1.00) > 0.25) end
				
				-- The LED glow
				self:SetSprite(k..light.."a",state,
					"models/metrostroi_signals/signal_sprite_001.vmt",0.40,1.0,
					self.BasePosition + offset + data[1],data[2])
				
				-- Overall glow
				self:SetSprite(k..light.."b",state,
					"models/metrostroi_signals/signal_sprite_002.vmt",0.25,0.5,
					self.BasePosition + offset + data[1],data[2])
				index = index + 1
				
				--self:SetSprite(index,true,"models/metrostroi_signals/signal_sprite_002.vmt",
					--self.BasePosition + offset + data[1],data[2])
				--index = index + 1
			end
		end
	end
	
	self:NextThink(CurTime() + 0.25)
	return true
end