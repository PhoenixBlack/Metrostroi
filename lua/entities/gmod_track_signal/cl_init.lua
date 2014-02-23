include("shared.lua")


--------------------------------------------------------------------------------
function ENT:Initialize() self.Models = {} end
function ENT:OnRemove() self:RemoveModels() end
function ENT:RemoveModels()
	for k,v in pairs(self.Models) do v:Remove() end
	self.Models = {}
end

function ENT:Think()
	local models = self.TrafficLightModels[self:GetLightsStyle()] or {}
	
	-- Remove old models
	if self:GetLightsStyle() ~= self.PreviousLightsStyle then
		self.PreviousLightsStyle = self:GetLightsStyle()
		self:RemoveModels()
	end
	
	-- Create new clientside models
	if self:GetTrafficLights() > 0 then
		for k,v in pairs(models) do
			if type(v) == "string" then
				if not self.Models[k] then
					self.Models[k] = ClientsideModel(v,RENDERGROUP_OPAQUE)
					self.Models[k]:SetPos(self:LocalToWorld(self.BasePosition))
					self.Models[k]:SetAngles(self:GetAngles())
					self.Models[k]:SetParent(self)
				end
			end
		end
		
		-- Create traffic light models
		local offset = self.RenderOffset[self:GetLightsStyle()] or Vector(0,0,0)
		for k,v in ipairs(models) do
			if self:GetTrafficLight(k-1) then
				offset = offset - Vector(0,0,v[1])
				if not self.Models[k] then
					self.Models[k] = ClientsideModel(v[2],RENDERGROUP_OPAQUE)
					self.Models[k]:SetPos(self:LocalToWorld(self.BasePosition + offset))
					self.Models[k]:SetAngles(self:GetAngles())
					self.Models[k]:SetParent(self)
				end
			end
		end
	else
		local k = "m1"
		local v = self.TrafficLightModels[0]["m1"]

		if not self.Models[k] then
			self.Models[k] = ClientsideModel(v,RENDERGROUP_OPAQUE)
			self.Models[k]:SetPos(self:LocalToWorld(self.BasePosition))
			self.Models[k]:SetAngles(self:GetAngles())
			self.Models[k]:SetParent(self)
		end
	end
end

function ENT:Draw()
	-- Draw long-distance traffic light value
	--[[local models = self.TrafficLightModels[self:GetLightsStyle()] or {}	
	local offset = Vector(0,0,112+32)
	for k,v in ipairs(models) do		
		offset = offset - Vector(0,0,v[1])
		if v[3] then
			for light,data in pairs(v[3]) do
				local state = self:GetTrafficLamp(light)
				
				local pos = self:LocalToWorld(self.BasePosition + offset + data[1] + Vector(10,0,0))
				local ang = self:LocalToWorldAngles(Angle(0,180,90))
				surface.SetAlphaMultiplier(0.01)
				cam.Start3D2D(pos, ang, 3)
					surface.DrawCircle(0,0,2,data[2]) 
				cam.End3D2D()
				surface.SetAlphaMultiplier(1)
				--data[2]
			end
		end
	end]]--
	
	-- Draw model
	self:DrawModel()
	
	-- Draw ARS/traffic light info
	if GetConVarNumber("metrostroi_drawdebug") == 1 then
		local pos = self:LocalToWorld(Vector(32,0,75))
		local ang = self:LocalToWorldAngles(Angle(0,180,90))
		cam.Start3D2D(pos, ang, 0.25)
			surface.SetDrawColor(125, 125, 0, 255)
			surface.DrawRect(0, 0, 256, 250)
			
			draw.DrawText("ARS Section Information:","Trebuchet24",5,0,Color(0,0,0,255))
			draw.DrawText("Joint isolates signals: "..(self:GetIsolatingJoint() and "Yes" or "No"),
				"Trebuchet24",15,20,Color(0,0,0,255))
			draw.DrawText("(75  Hz) 80 KM/H","Trebuchet24",15,50, Color(self:GetARSSignal(0) and 255 or 0,0,0,255))
			draw.DrawText("(125 Hz) 70 KM/H","Trebuchet24",15,70, Color(self:GetARSSignal(1) and 255 or 0,0,0,255))
			draw.DrawText("(175 Hz) 60 KM/H","Trebuchet24",15,90, Color(self:GetARSSignal(2) and 255 or 0,0,0,255))
			draw.DrawText("(225 Hz) 40 KM/H","Trebuchet24",15,110,Color(self:GetARSSignal(3) and 255 or 0,0,0,255))
			draw.DrawText("(275 Hz)  0 KM/H","Trebuchet24",15,130,Color(self:GetARSSignal(4) and 255 or 0,0,0,255))
			draw.DrawText("(325 Hz) Special","Trebuchet24",15,150,Color(self:GetARSSignal(5) and 255 or 0,0,0,255))
		cam.End3D2D()
	end
end