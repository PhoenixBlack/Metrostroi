//Thanks old gmod wiki!
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

//Calculates line-plane intersect location
local function LinePlaneIntersect(PlanePos,PlaneNormal,LinePos,LineDir)
	local dot = LineDir:Dot(PlaneNormal)
	local fac = LinePos-PlanePos 
	local dis = -PlaneNormal:Dot(fac) / dot
	return LineDir * dis + LinePos
end


//Checks if the player is driving a train, also returns said train
local function isValidTrainDriver(ply)
	local seat = ply:GetVehicle()
	if (not seat) or (not seat:IsValid()) then return false end
	local train = seat:GetNWEntity("TrainEntity")
	if (not train) or (not train:IsValid()) then return false end
	return train
end

hook.Add("Think","Metrostroi-cabin-panel",function()
	if !IsValid(LocalPlayer()) then return end
	local train = isValidTrainDriver(LocalPlayer())
	if(IsValid(train)) then
		if(train.ButtonMap != nil) then
			local tr = LocalPlayer():GetEyeTrace()
			for k2,panel in pairs(train.ButtonMap) do
				local wpos = train:LocalToWorld(panel.pos)
				local wang = train:LocalToWorldAngles(panel.ang)
				
				local isectPos = LinePlaneIntersect(wpos,wang:Up(),tr.StartPos,tr.Normal)
				local localx,localy = WorldToScreen(isectPos,wpos,panel.scale,wang)
				
				panel.aimX = localx
				panel.aimY = localy
				panel.aimedAt = (localx > 0 and localx < panel.width and localy > 0 and localy < panel.height)
			end
			LocalPlayer().drawCabinCrosshair = false
			for kp,panel in pairs(train.ButtonMap) do
				if panel.aimedAt then 
					LocalPlayer().drawCabinCrosshair = true
					break
				end
			end
		end
	else
		LocalPlayer().drawCabinCrosshair = false
	end
end)


hook.Add("KeyPress", "Metrostroi_Cabin_Buttons", function(ply, key)
	if !IsFirstTimePredicted() then return end
	if not(key==IN_ATTACK or key==IN_ATTACK2) then return end 
	//Filter out the most common thing the quickest
	
	local train = isValidTrainDriver(ply)
	if !IsValid(train) then return end
	if train.ButtonMap == nil then return end
	
	for kp,panel in pairs(train.ButtonMap) do
		if panel.aimedAt then
			for kb,button in pairs(panel.buttons) do
				if math.Dist(button[1],button[2],panel.aimX,panel.aimY) < 10 then
					net.Start("metrostroi-cabin-button")
					net.WriteInt(kp,8) //Panel
					net.WriteInt(kb,8) //Button
					
					//Key
					if(key==IN_ATTACK) then
						net.WriteInt(1,8)
					elseif (key==IN_ATTACK2) then
						net.WriteInt(2,8)
					else
						net.WriteInt(0,8)
					end
					
					net.SendToServer()
				end
			end
		end
	end
end)

hook.Add( "HUDPaint", "metrostroi-draw-custom-crosshair", function()
	if IsValid(LocalPlayer()) then
		if LocalPlayer().drawCabinCrosshair then
			surface.DrawCircle(surface.ScreenWidth()/2,surface.ScreenHeight()/2,4.1,Color(255,255,150))
		end
	end
end)

