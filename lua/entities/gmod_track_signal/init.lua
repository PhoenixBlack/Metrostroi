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
		--local brightness = 1.0
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

function ENT:Logic(trackOccupied,nextLight,switchBlocked,switchAlternate)
	local nextRed = false
	if nextLight then nextRed = nextLight:GetTrafficLamp(0) end
	
	-- Filter changes
	--[[self.LastValueChange = self.LastValueChange or 0
	if self.LastTrackOccupied ~= trackOccupied then
		self.LastTrackOccupied = trackOccupied
		self.LastValueChange = CurTime()
	end
	if self.LastNextLight ~= nextLight then
		self.LastNextLight = nextLight
		self.LastValueChange = CurTime()
	end
	if self.LastSwitchToAlternate ~= switchToAlternate then
		self.LastSwitchToAlternate = switchToAlternate
		self.LastValueChange = CurTime()
	end]]--
	
	if self:GetTrafficLights() == 1 then -- FIXME special behavior
		switchBlocked = switchBlocked or switchAlternate
	end
	
	-- Red (always triggers when track is occupied or switch is in wrong pos)
	self:SetTrafficLamp(0,trackOccupied or switchBlocked)
	
	-- Only accept change in values after they settled
	--if (CurTime() - self.LastValueChange) < 2.0 then return end
	
	-- Yellow
	self:SetTrafficLamp(1,nextRed or switchAlternate)
	-- Second yellow
	self:SetTrafficLamp(4,switchAlternate and (not self:GetTrafficLamp(0)))
	-- Green
	self:SetTrafficLamp(2,not (
		self:GetTrafficLamp(0) or 
		self:GetTrafficLamp(1) or 
		switchAlternate) ) 
	-- Always red
	self:SetTrafficLamp(6,true)
end

function ENT:Think()
	self.PrevTime = self.PrevTime or 0
	if (CurTime() - self.PrevTime) > 1.0 then
		self.PrevTime = CurTime()
		-- Traffic light logic
		if self:GetTrafficLights() > 0 then
			local pos = Metrostroi.SignalEntityPositions[self]
			local node
			if pos then node = pos.node1 end
			if node and pos then
				-- Check if there is a train anywhere on the isolated area
				local trackOccupied = Metrostroi.IsTrackOccupied(node,pos.x,pos.forward)
				local nextLight = Metrostroi.GetNextTrafficLight(node,pos.x,pos.forward)
				
				-- Check if there's a track switch and it's set to alternate
				local switchAlternate = false
				local switchBlocked = false
				local switches = Metrostroi.GetTrackSwitches(node,pos.x,pos.forward)
				for _,switch in pairs(switches) do
					switchBlocked = switchBlocked or (switch.AlternateTrack and self.InhibitSwitching)
					switchAlternate = switchAlternate or switch.AlternateTrack
				end
				
				-- Execute logic
				self:Logic(trackOccupied,nextLight,switchBlocked,switchAlternate)
			end
		end
	end
	
	-- Create sprites and manage lamps
	if self:GetTrafficLights() > 0 then
		local index = 1
		local models = self.TrafficLightModels[self:GetLightsStyle()] or {}	
		local offset = self.RenderOffset[self:GetLightsStyle()] or Vector(0,0,0)
		for k,v in ipairs(models) do
			if self:GetTrafficLight(k-1) then
				offset = offset - Vector(0,0,v[1])
				if v[3] then
					for light,data in pairs(v[3]) do
						local state = self:GetTrafficLamp(light-1)
						if light == 5 then
							state = state and ((CurTime() % 1.00) > 0.25)
						end
						
						self:SetSprite(index,state,
							"models/metrostroi_signals/signal_sprite_001.vmt",0.40,1.0,
							self.BasePosition + offset + data[1],data[2])
						index = index + 1
						
						self:SetSprite(index,state,
							"models/metrostroi_signals/signal_sprite_002.vmt",0.25,0.5,
							self.BasePosition + offset + data[1],data[2])
						index = index + 1
						
						--self:SetSprite(index,true,"models/metrostroi_signals/signal_sprite_002.vmt",self.BasePosition + offset + data[1],data[2])
						--index = index + 1
					end
				end
			end
		end
	end
	
	self:NextThink(CurTime() + 0.25)
	return true
end