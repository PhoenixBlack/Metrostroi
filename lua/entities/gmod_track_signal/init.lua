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
end

function ENT:Think()
	-- Do no interesting logic if there's no traffic light involved
	if self:GetTrafficLights() == 0 then
		self:NextThink(CurTime() + 1.00)
		return true
	end
	
	-- Traffic light logic
	self.PrevTime = self.PrevTime or 0
	if (CurTime() - self.PrevTime) > 1.0 then
		self.PrevTime = CurTime()
		
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