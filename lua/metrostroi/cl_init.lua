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


hook.Add("KeyPress", "Metrostroi_Cabin_Buttons", function(ply, key)
	if not(key==IN_ATTACK or key==IN_ATTACK2) then return end 
	//Filter out the most common thing the quickest
	
	local seat = ply:GetVehicle()
	if (not seat) or (not seat:IsValid()) then return end
	local train = seat:GetNWEntity("TrainEntity")
	if (not train) or (not train:IsValid()) then return end
	//if seat != train.DriverSeat then return end
	if train.ButtonMap == nil then return end
	
	local tr = ply:GetEyeTrace()
	local aimPos 
  
	if tr.Hit then 
		aimPos = tr.HitPos
		debugoverlay.Cross(aimPos,2,10,Color(255,255,255),true)
	else
		return 
	end
	
	
	for kp,panel in pairs(train.ButtonMap) do
		for kb,button in pairs(panel.buttons) do
			local localx,localy = WorldToScreen(aimPos,train:LocalToWorld(panel.pos),panel.scale,train:LocalToWorldAngles(panel.ang))
			if math.Dist(button[1],button[2],localx,localy) < 10 then
				net.Start("metrostroi-cabin-button")
				net.WriteInt(kp,8)
				net.WriteInt(kb,8)
				net.SendToServer()
			end
		
		end
		
	end
	
end)


