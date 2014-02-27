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
			if self:GetTrafficLightsBit(k-1) then
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
		local pos = self:LocalToWorld(Vector(32,0,95))
		local ang = self:LocalToWorldAngles(Angle(0,180,90))
		cam.Start3D2D(pos, ang, 0.25)
			surface.SetDrawColor(self:GetNoARS() and 255 or 125, 125, 0, 255)
			surface.DrawRect(0, 0, 256, 320)

			draw.DrawText("Joint Information:","Trebuchet24",5,0,Color(0,0,0,255))
			draw.DrawText("Always red: "..				(self:GetAlwaysRed() and "Yes" or "No"),"Trebuchet24",			15, 20,Color(0,0,0,255))
			draw.DrawText("Red when alternate: "..		(self:GetRedWhenAlternate() and "Yes" or "No"),"Trebuchet24",	15, 40,Color(0,0,0,255))
			draw.DrawText("Red when main: "..			(self:GetRedWhenMain() and "Yes" or "No"),"Trebuchet24",		15, 60,Color(0,0,0,255))
			
			draw.DrawText("Isolates light signals: "..	(self:GetIsolatingLight() and "Yes" or "No"),"Trebuchet24",		15, 80,Color(0,0,0,255))
			draw.DrawText("Isolates switch signals: "..	(self:GetIsolatingSwitch() and "Yes" or "No"),"Trebuchet24",	15,100,Color(0,0,0,255))
			
			draw.DrawText("Invert switch chan #1: "..	(self:GetInvertChannel1() and "Yes" or "No"),"Trebuchet24",	15,120,Color(0,0,0,255))
			draw.DrawText("Invert switch chan #2: "..	(self:GetInvertChannel2() and "Yes" or "No"),"Trebuchet24",	15,140,Color(0,0,0,255))
			--draw.DrawText("ARS speed warning: "..		(self:GetARSSpeedWarning() and "Yes" or "No"),"Trebuchet24",	15,100,Color(0,0,0,255))
			
			
			draw.DrawText("(75  Hz) 80 KM/H","Trebuchet24",15,180,Color(self:GetSettingsBit(0) and 255 or 0,0,self:GetActiveSignalsBit(10) and 255 or 0,255))
			draw.DrawText("(125 Hz) 70 KM/H","Trebuchet24",15,200,Color(self:GetSettingsBit(1) and 255 or 0,0,self:GetActiveSignalsBit(11) and 255 or 0,255))
			draw.DrawText("(175 Hz) 60 KM/H","Trebuchet24",15,220,Color(self:GetSettingsBit(2) and 255 or 0,0,self:GetActiveSignalsBit(12) and 255 or 0,255))
			draw.DrawText("(225 Hz) 40 KM/H","Trebuchet24",15,240,Color(self:GetSettingsBit(3) and 255 or 0,0,self:GetActiveSignalsBit(13) and 255 or 0,255))
			draw.DrawText("(275 Hz)  0 KM/H","Trebuchet24",15,260,Color(self:GetSettingsBit(4) and 255 or 0,0,self:GetActiveSignalsBit(14) and 255 or 0,255))
			draw.DrawText("(325 Hz) Special","Trebuchet24",15,280,Color(self:GetSettingsBit(5) and 255 or 0,0,self:GetActiveSignalsBit(15) and 255 or 0,255))
		cam.End3D2D()
	end
end