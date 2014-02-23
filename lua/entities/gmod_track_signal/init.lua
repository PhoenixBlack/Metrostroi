AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/metrostroi/signals/ars_box.mdl")
	Metrostroi.UpdateSignalEntities()

	self.Sprites = {}
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

function ENT:Think()
	-- Traffic light logic
	if self:GetTrafficLights() > 0 then
		local node = Metrostroi.NodesForSignalEntities[self]
		if node then
			-- Simulate track signal
			local trackOccupied = Metrostroi.IsTrackOccupied(node,self.TrackX or 0,false)
			local nextLight = Metrostroi.GetNextTrafficLight(node,self.TrackX or 0,false)
			
			-- Red		
			self:SetTrafficLamp(0,trackOccupied) 
			-- Yellow
			if nextLight then
				self:SetTrafficLamp(1,nextLight:GetTrafficLamp(0))
			else
				self:SetTrafficLamp(1,false)
			end
			-- Green
			self:SetTrafficLamp(2,not (self:GetTrafficLamp(0) or self:GetTrafficLamp(1)) ) 
		end	
	end
	
	-- Create sprites
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
							state = state and ((CurTime() % 0.75) > 0.25)
						end
						
						self:SetSprite(index,state,
							"models/metrostroi_signals/signal_sprite_001.vmt",0.5,1.0,
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
	
	self:NextThink(CurTime() + 1.0)
	return true
end