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

//There's got to be a better way to do this all
local function copyVec(v)
	return Vector(v[1],v[2],v[3])
end

//I seriously ragequit developing this function, not because of the math but because vector functions modify the original,
//wich fucks up references
local function LinePlaneIntersect(PlanePos,PlaneNormal,LinePos,LineDir)
	local dot = LineDir:Dot(PlaneNormal)
	local fac = copyVec(LinePos) //Stupid Sub modifying the origional
	fac:Sub(PlanePos)
	local dis = -PlaneNormal:Dot(fac) / dot
	local LdCopy = copyVec(LineDir)
	LdCopy:Mul(dis)
	LinePos:Add(LdCopy)
	return LinePos
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
	if !tr.Hit then return end
	
	
	for kp,panel in pairs(train.ButtonMap) do
		local wpos = train:LocalToWorld(panel.pos)
		local wang = train:LocalToWorldAngles(panel.ang)
		
		//See note at definition
		local v1 = copyVec(wpos)
		local v2 = copyVec(wang:Up())
		local v3 = copyVec(tr.StartPos)
		local v4 = copyVec(tr.Normal)
		local isectPos = LinePlaneIntersect(v1,v2,v3,v4)
		local localx,localy = WorldToScreen(isectPos,wpos,panel.scale,wang)
		debugoverlay.Cross(isectPos,2,10,Color(255,255,255),true) //Only shows up when developer = 1
		for kb,button in pairs(panel.buttons) do
			if math.Dist(button[1],button[2],localx,localy) < 10 then
				net.Start("metrostroi-cabin-button")
				net.WriteInt(kp,8)
				net.WriteInt(kb,8)
				net.SendToServer()
			end
		
		end
		
	end
	
end)


