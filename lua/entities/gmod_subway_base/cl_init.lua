include("shared.lua")

--------------------------------------------------------------------------------
-- Console commands and convars
--------------------------------------------------------------------------------
CreateClientConVar("metrostroi_tooltip_delay",0,true)

concommand.Add("metrostroi_train_manual", function(ply, _, args)
	local w = ScrW() * 2/3
	local h = ScrH() * 2/3
	local browserWindow = vgui.Create("DFrame")
	browserWindow:SetTitle("Train Manual")
	browserWindow:SetPos((ScrW() - w)/2, (ScrH() - h)/2)
	browserWindow:SetSize(w,h)
	browserWindow.OnClose = function()
		browser = nil
		browserWindow = nil
	end
	browserWindow:MakePopup()

	local browser = vgui.Create("DHTML",browserWindow)
	browser:SetPos(10, 25)
	browser:SetSize(w - 20, h - 35)

	browser:OpenURL("http://foxworks.wireos.com/metrostroi/manual.html")
end)




--------------------------------------------------------------------------------
-- Buttons layout
--------------------------------------------------------------------------------
--ENT.ButtonMap = {} Leave nil if unused

-- General Panel
--[[table.insert(ENT.ButtonMap,{
	pos = Vector(7,0,0),
	ang = Angle(0,90,90),
	width = 300,
	height = 100,
	scale = 0.0625,
	
	buttons = {
		{ID=1, x=-117,  y=   0,  radius=20, tooltip="Test 1"},
		{ID=2, x= -80,  y=   0,  radius=20, tooltip="Test 2"},
	}
})]]--


--------------------------------------------------------------------------------
-- Decoration props
--------------------------------------------------------------------------------
ENT.ClientProps = {}

--[[table.insert(ENT.ClientProps,{
	model = "models/metrostroi/81-717/cabin.mdl",
	pos = Vector(421,-5,15),
	ang = Angle(0,-90,0)
})]]--





--------------------------------------------------------------------------------
-- Clientside entities support
--------------------------------------------------------------------------------
local lastButton
local drawCrosshair
local toolTipText
local lastAimButtonChange
local lastAimButton

function ENT:ShouldRenderClientEnts()
	return true--self:LocalToWorld(Vector(-450,0,0)):Distance(LocalPlayer():GetPos()) < 512
end

function ENT:CreateCSEnts()
	for k,v in pairs(self.ClientProps) do
		if k ~= "BaseClass" then
			local cent = ClientsideModel(v.model ,RENDERGROUP_OPAQUE)
			cent:SetPos(self:LocalToWorld(v.pos))
			cent:SetAngles(self:LocalToWorldAngles(v.ang))
			cent:SetParent(self)
			self.ClientEnts[k] = cent
		end
	end
end

function ENT:RemoveCSEnts()
	for k,v in pairs(self.ClientEnts) do
		v:Remove()
	end
	self.ClientEnts = {}
end

function ENT:ApplyCSEntRenderMode(render)
	for k,v in pairs(self.ClientEnts) do
		if render then
			v:SetRenderMode(RENDERMODE_NORMAL)
		else
			v:SetRenderMode(RENDERMODE_NONE)
		end
	end
end



--------------------------------------------------------------------------------
-- Clientside initialization
--------------------------------------------------------------------------------
function ENT:Initialize()
	-- Create clientside props
	self.ClientEnts = {}
	self.RenderClientEnts = self:ShouldRenderClientEnts()
	if self.RenderClientEnts then
		self:CreateCSEnts()
	end
	
	-- Systems defined in the train
	self.Systems = {}
	-- Initialize train systems
	self:InitializeSystems()
end

function ENT:OnRemove()
	self:RemoveCSEnts()
	drawCrosshair = false
	toolTipText = nil
end




--------------------------------------------------------------------------------
-- Default think function
--------------------------------------------------------------------------------
function ENT:Think()
	self.PrevTime = self.PrevTime or CurTime()
	self.DeltaTime = (CurTime() - self.PrevTime)
	self.PrevTime = CurTime()
	
	if self.Systems then
		for k,v in pairs(self.Systems) do
			v:ClientThink()
		end
	end
	
	-- Update CSEnts
	if CurTime() - (self.PrevThinkTime or 0) > .5 then
		self.PrevThinkTime = CurTime()
		
		-- Invalidate entities if needed, for hotloading purposes
		if not self.ClientPropsInitialized then
			self.ClientPropsInitialized = true
			self:RemoveCSEnts()
			self.RenderClientEnts = false
		end
		
		local shouldrender = self:ShouldRenderClientEnts()
		if self.RenderClientEnts ~= shouldrender then
			self.RenderClientEnts = shouldrender
			if self.RenderClientEnts then
				self:CreateCSEnts()
			else
				self:RemoveCSEnts()
			end
		end
		
		--Uncomment for skin disco \o/
		--[[
		for k,v in pairs(self.ClientEnts) do
			if v:SkinCount() > 0 then
				v:SetSkin((v:GetSkin()+1)%(v:SkinCount()-1))
			end
		end
		]]--
	end
	
	--Example of pose parameter
	--[[for k,v in pairs(self.ClientEnts) do
		if v:GetPoseParameterRange(0) != nil then
			v:SetPoseParameter("position",math.sin(CurTime()*4)/2+0.5)
		end
	end]]--

end



--------------------------------------------------------------------------------
-- Various rendering shortcuts for trains
--------------------------------------------------------------------------------
function ENT:DrawCircle(cx,cy,radius)
	local step = 2*math.pi/12
	local vertexBuffer = { {}, {}, {} }

	for i=1,12 do
		vertexBuffer[1].x = cx + radius*math.sin(step*(i+0))
		vertexBuffer[1].y = cy + radius*math.cos(step*(i+0))
		vertexBuffer[2].x = cx
		vertexBuffer[2].y = cy
		vertexBuffer[3].x = cx + radius*math.sin(step*(i+1))
		vertexBuffer[3].y = cy + radius*math.cos(step*(i+1))
		surface.DrawPoly(vertexBuffer)
	end
end

--------------------------------------------------------------------------------
-- Default rendering function
--------------------------------------------------------------------------------
function ENT:Draw()
	self.dT = CurTime() - (self.PrevTime or CurTime())
	self.PrevTime = CurTime()
	
	

	-- Draw model
	self:DrawModel()
	
	-- Debug draw for buttons
	if GetConVarNumber("metrostroi_drawdebug") > 0 then
		if self.ButtonMap ~= nil then
			for kp,panel in pairs(self.ButtonMap) do
				if kp ~= "BaseClass" then
					cam.Start3D2D(self:LocalToWorld(panel.pos),self:LocalToWorldAngles(panel.ang),panel.scale)
						surface.SetDrawColor(0,0,255)
						surface.DrawOutlinedRect(0,0,panel.width,panel.height)
						
						--surface.SetDrawColor(255,255,255)
						--surface.DrawRect(0,0,panel.width,panel.height)
						for kb,button in pairs(panel.buttons) do
							if button.state then
								surface.SetDrawColor(255,0,0)
							else
								surface.SetDrawColor(0,255,0)
							end
							self:DrawCircle(button.x,button.y,button.radius or 10)
							surface.DrawRect(button.x-8,button.y-8,16,16)
						end
					
					cam.End3D2D()
				end
			end
		end
	end
end




--------------------------------------------------------------------------------
-- Look into mirrors hook
--------------------------------------------------------------------------------
hook.Add("CalcView", "Metrostroi_ThirdPersonMirrorView", function(ply,pos,ang,fov,nearz,farz)
	--[[local seat = ply:GetVehicle()
	if (not seat) or (not seat:IsValid()) then return end
	local train = seat:GetNWEntity("TrainEntity")
	if (not train) or (not train:IsValid()) then return end
	
	if seat:GetThirdPersonMode() then
	local trainAng = ang - train:GetAngles()
	if trainAng.y >  180 then trainAng.y = trainAng.y - 360 end
	if trainAng.y < -180 then trainAng.y = trainAng.y + 360 end
	if trainAng.y > 0 then
		return {
			origin = train:LocalToWorld(Vector(-471,70,34)),
			angles = train:GetAngles() + Angle(2,5,0),
			fov = 20,
			znear = znear,
			zfar = zfar
		}
	else --if trainAng.y < 0 then
		return {
			origin = train:LocalToWorld(Vector(-471,-70,34)),
			angles = train:GetAngles() + Angle(2,-5,0),
			fov = 20,
			znear = znear,
			zfar = zfar
		}
	end
	end]]--
end)




--------------------------------------------------------------------------------
-- Buttons/panel clicking
--------------------------------------------------------------------------------
--Thanks old gmod wiki!
--[[
Converts from world coordinates to Draw3D2D screen coordinates.
vWorldPos is a vector in the world nearby a Draw3D2D screen.
vPos is the position you gave Start3D2D. The screen is drawn from this point in the world.
scale is a number you also gave to Start3D2D.
aRot is the angles you gave Start3D2D. The screen is drawn rotated according to these angles.
]]--

local function WorldToScreen(vWorldPos,vPos,vScale,aRot)
    local vWorldPos=vWorldPos-vPos;
    vWorldPos:Rotate(Angle(0,-aRot.y,0));
    vWorldPos:Rotate(Angle(-aRot.p,0,0));
    vWorldPos:Rotate(Angle(0,0,-aRot.r));
    return vWorldPos.x/vScale,(-vWorldPos.y)/vScale;
end

-- Calculates line-plane intersect location
local function LinePlaneIntersect(PlanePos,PlaneNormal,LinePos,LineDir)
	local dot = LineDir:Dot(PlaneNormal)
	local fac = LinePos-PlanePos 
	local dis = -PlaneNormal:Dot(fac) / dot
	return LineDir * dis + LinePos
end


-- Checks if the player is driving a train, also returns said train
local function isValidTrainDriver(ply)
	local seat = ply:GetVehicle()
	if (not seat) or (not seat:IsValid()) then return false end
	local train = seat:GetNWEntity("TrainEntity")
	if (not train) or (not train:IsValid()) then return false end
	return train
end

local function findAimButton(ply)
	local train = isValidTrainDriver(ply)
	if IsValid(train) and train.ButtonMap != nil then
		local foundbuttons = {}
		for kp,panel in pairs(train.ButtonMap) do
			
			--If player is looking at this panel
			if panel.aimedAt then
				
				--Loop trough every button on it
				for kb,button in pairs(panel.buttons) do
					
					--If the aim location is withing button radis
					local dist = math.Dist(button.x,button.y,panel.aimX,panel.aimY)
					if dist < (button.radius or 10) then
						table.insert(foundbuttons,{button,dist})
					end
				end
			end
		end
		
		if #foundbuttons > 0 then
			table.SortByMember(foundbuttons,2,true)
			return foundbuttons[1][1]
		else 
			return false
		end
	end
end

-- Checks what button/panel is being looked at and check for custom crosshair
hook.Add("Think","metrostroi-cabin-panel",function()
	local ply = LocalPlayer()
	if !IsValid(ply) then return end
	
	toolTipText = nil
	drawCrosshair = false
	
	local train = isValidTrainDriver(ply)
	if(IsValid(train) and not ply:GetVehicle():GetThirdPersonMode() and train.ButtonMap != nil) then
		
		local tr = ply:GetEyeTrace()
		
		-- Loop trough every panel
		for k2,panel in pairs(train.ButtonMap) do
			local wpos = train:LocalToWorld(panel.pos)
			local wang = train:LocalToWorldAngles(panel.ang)
			
			local isectPos = LinePlaneIntersect(wpos,wang:Up(),tr.StartPos,tr.Normal)
			local localx,localy = WorldToScreen(isectPos,wpos,panel.scale,wang)
			
			panel.aimX = localx
			panel.aimY = localy
			panel.aimedAt = (localx > 0 and localx < panel.width and localy > 0 and localy < panel.height)
		end
		
		-- Check if we should draw the crosshair
		for kp,panel in pairs(train.ButtonMap) do
			if panel.aimedAt then 
				drawCrosshair = true
				break
			end
		end
		
		-- Tooltips
		local ttdelay = GetConVarNumber("metrostroi_tooltip_delay")
		if ttdelay and ttdelay >= 0 then
			local button = findAimButton(ply)
			
			if button != lastAimButton then
				lastAimButtonChange = CurTime()
				lastAimButton = button
			end
			
			
			if button then
				if ttdelay == 0 or CurTime() - lastAimButtonChange > ttdelay then
					toolTipText = findAimButton(ply).tooltip
				end
			end
		end
	end
end)


-- Takes button table, sends current status
local function sendButtonMessage(button)
	net.Start("metrostroi-cabin-button")
	net.WriteString(button.ID) 
	net.WriteBit(button.state)
	net.SendToServer()
end

-- Goes over a train's buttons and clears them, sending a message if needed
function ENT:ClearButtons()
	if self.ButtonMap == nil then return end
	for kp,panel in pairs(self.ButtonMap) do
		for kb,button in pairs(panel.buttons) do
			if button.state == true then
				button.state = false
				sendButtonMessage(button)
			end
		end
	end
end


-- Args are player, IN_ enum and bool for press/release
local function handleKeyEvent(ply,key,pressed)
	-- if !IsFirstTimePredicted() then return end
	if key ~= IN_ATTACK then return end
	if not IsValid(ply) then return end
	local train = isValidTrainDriver(ply)
	if not IsValid(train) then return end
	if train.ButtonMap == nil then return end

	if pressed then
		local button = findAimButton(ply)
		if button and !button.state then
			button.state = true
			sendButtonMessage(button)
			lastButton = button
		end
	else 
		-- Reset the last button pressed
		if lastButton != nil then
			if lastButton.state == true then
				lastButton.state = false
				sendButtonMessage(lastButton)
			end
		end
	end
end

-- Hook for clearing the buttons when player exits
net.Receive("metrostroi-cabin-reset",function(len,_)
	local ent = net.ReadEntity()
	if IsValid(ent) and ent.ClearButtons ~= nil then
		ent:ClearButtons()
	end
end)

hook.Add("KeyPress", "metrostroi-cabin-buttons", function(ply,key) handleKeyEvent(ply, key,true) end)
hook.Add("KeyRelease", "metrostroi-cabin-buttons", function(ply,key) handleKeyEvent(ply, key,false) end)

hook.Add( "HUDPaint", "metrostroi-draw-crosshair-tooltip", function()
	if IsValid(LocalPlayer()) then
		local scrX,scrY = surface.ScreenWidth(),surface.ScreenHeight()
		
		if drawCrosshair then
			surface.DrawCircle(scrX/2,scrY/2,4.1,Color(255,255,150))
		end
		
		if toolTipText != nil then
			surface.SetTextPos(scrX/2,scrY/2+10)
			surface.DrawText(toolTipText)
		end
		
		
	end
end)
