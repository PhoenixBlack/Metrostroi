--------------------------------------------------------------------------------
-- Signs in tunnels and on stations
--------------------------------------------------------------------------------
Metrostroi.Signs = Metrostroi.Signs or {}



--------------------------------------------------------------------------------
-- Helper for commonly used trace
--------------------------------------------------------------------------------
local function trace(pos,dir,col)
	local tr = util.TraceLine({
		start = pos,
		endpos = pos+dir,
		mask = MASK_NPCWORLDSTATIC
	})
	timer.Simple(0.05,function()
		local t = 5
		debugoverlay.Line(tr.StartPos,tr.HitPos,t,col or Color(0,0,255),true)
		debugoverlay.Sphere(tr.StartPos,2,t,Color(0,255,255),true)
		debugoverlay.Sphere(tr.HitPos,2,t,Color(255,0,0),true)
	end)
	return tr
end


--------------------------------------------------------------------------------
-- Create station name signs
--------------------------------------------------------------------------------
function Metrostroi.AddStationSign(ent)
	local platformStart	= ent.PlatformStart
	local platformEnd	= ent.PlatformEnd
	local platformDir   = platformEnd-platformStart
	local platformN		= (platformDir:Angle()-Angle(0,90,0)):Forward()
	local platformD		= platformDir:GetNormalized()

	local N = 2
	local X = { 0.25, 0.75 }
	for i=1,N do
		local pos = (platformStart + platformDir*X[i]) + Vector(0,0,64+32) + platformN*96
		local tr = trace(pos,platformN*384)
		
		-- Bad hit workaround
		if (not tr.Hit) or (tr.Fraction < 0.05) then
			--print("STATION",ent.StationIndex,tr.Hit,tr.Fraction)

			pos = (platformStart + platformDir*X[i]) + Vector(0,0,64+32) + platformN*0
			tr = trace(pos,platformN*384)
		end
		
		local sign = ents.Create("gmod_track_sign")
		if IsValid(sign) then
			if tr.Hit then
				sign:SetPos(tr.HitPos + tr.HitNormal*4)
				sign:SetAngles(tr.HitNormal:Angle())
			else
				sign:SetPos(tr.HitPos + tr.HitNormal*4)
				sign:SetAngles(-platformN:Angle())
			end
			sign:Spawn()
			
			sign:SetNWString("Type","station")
			sign:SetNWString("Name",Metrostroi.StationNames[ent.StationIndex])
			sign:SetNWInt("ID",ent.StationIndex)
			sign:SetNWInt("Platform",ent.PlatformIndex)

			-- Get stations list
			local stationList = {}
			local path1 = math.floor(ent.StationIndex/100)
			for k,v in pairs(Metrostroi.StationNames) do
				local path2 = math.floor(k/100)
				if path1 == path2 then
					local R = (Metrostroi.StationNamesConfiguration[k] or {})[1] or 0
					local G = (Metrostroi.StationNamesConfiguration[k] or {})[2] or 0
					local B = (Metrostroi.StationNamesConfiguration[k] or {})[3] or 0
					local Use = (Metrostroi.StationNamesConfiguration[k] or {})[4] or 0
					if (Use > 0) then
						if ((ent.PlatformIndex == 2) and (ent.StationIndex >= k)) or
						   ((ent.PlatformIndex == 1) and (ent.StationIndex <= k)) then
							table.insert(stationList,k)
						end
					end
				end
			end
			
			-- Sort stations list
			if ent.PlatformIndex == 2 then
				table.sort(stationList, function(a, b) return a < b end)
			else
				table.sort(stationList, function(a, b) return a > b end)
			end
			
			-- Send stations list
			sign:SetNWInt("StationList#",#stationList)
			for k,v in ipairs(stationList) do
				sign:SetNWInt("StationList"..k.."[ID]",v)
				sign:SetNWString("StationList"..k.."[Name1]",Metrostroi.StationTitles[v])
				sign:SetNWString("StationList"..k.."[Name2]",Metrostroi.StationNames[v])
				sign:SetNWInt("StationList"..k.."[R]",(Metrostroi.StationNamesConfiguration[v] or {})[1])
				sign:SetNWInt("StationList"..k.."[G]",(Metrostroi.StationNamesConfiguration[v] or {})[2])
				sign:SetNWInt("StationList"..k.."[B]",(Metrostroi.StationNamesConfiguration[v] or {})[3])
				--sign:SetNWInt("StationList"..k.."[R]",(Metrostroi.StationNamesConfiguration[v.ID] or {})[1])
			end			
			
			--[[sign:MakeStationSign(
				Metrostroi.StationTitles[ent.StationIndex] or Metrostroi.StationNames[ent.StationIndex],
				Metrostroi.StationNames[ent.StationIndex])]]--
			table.insert(Metrostroi.Signs,sign)
		end
	end
end


--------------------------------------------------------------------------------
-- Create horizontal lift signals
--------------------------------------------------------------------------------
function Metrostroi.AddStationSignal(ent)
	if ent.HorliftStation == 0 then return end

	local platformStart	= ent.PlatformStart
	local platformEnd	= ent.PlatformEnd
	local platformDir   = platformEnd-platformStart
	local platformN		= (platformDir:Angle()-Angle(0,90,0)):Forward()
	local platformD		= platformDir:GetNormalized()

	local pos = platformEnd + Vector(0,0,64) + platformN*96 + platformD*(192-32)
	local tr = trace(pos,platformN*384)
		
	local sign = ents.Create("gmod_track_horlift_signal")
	if IsValid(sign) then
		if tr.Hit then
			sign:SetPos(tr.HitPos)
			sign:SetAngles(tr.HitNormal:Angle())
		else
			sign:SetPos(tr.HitPos)
			sign:SetAngles(-platformN:Angle())
		end
		sign:Spawn()
		table.insert(Metrostroi.Signs,sign)
	end
end


--------------------------------------------------------------------------------
-- Create all signs
--------------------------------------------------------------------------------
function Metrostroi.InitializeSigns()
	-- Clear old signs
	for k,v in pairs(Metrostroi.Signs) do
		SafeRemoveEntity(v)
	end
	Metrostroi.Signs = {}
	
	-- Add sign for every station name
	local entities = ents.FindByClass("gmod_track_platform")
	for k,v in pairs(entities) do
		Metrostroi.AddStationSign(v)
		Metrostroi.AddStationSignal(v)
	end
	
	-- Add temporary lights
	local entities = ents.FindByClass("gmod_track_switch")
	for k,v in pairs(entities) do
		for k2,v2 in pairs(v.TrackSwitches) do
			local tr = trace(v2:GetPos(),Vector(0,0,384))
			if tr.Hit then
				local light = ents.Create("env_projectedtexture")
				light:SetPos(tr.HitPos - Vector(0,0,16))
				light:SetAngles(tr.HitNormal:Angle())

				-- Set parameters
				light:SetKeyValue("enableshadows", 0)
				light:SetKeyValue("farz", 600)
				light:SetKeyValue("nearz", 16)
				light:SetKeyValue("lightfov", 170)

				-- Set Brightness
				local brightness = 0.3
				light:SetKeyValue("lightcolor",
					Format("%i %i %i 255",
						180*brightness,
						255*brightness,
						255*brightness
					)
				)

				-- Turn light on
				light:Spawn()
				light:Input("SpotlightTexture",nil,nil,"effects/flashlight001")
				table.insert(Metrostroi.Signs,light)			
			end
		end
	end
	
	--17473 20200
	if Metrostroi.Paths[1] then
		for k,v in pairs(Metrostroi.Paths[1]) do
			if (type(v) == "table") and (v.x) and (v.x > 17470) and (v.x < 20200) then
				local tr = trace(v.pos + Vector(0,0,64),Vector(0,0,384)) --384*(v.dir:Angle() + Angle(0,0,90)):Forward())
				if tr.Hit and ((k % 2) == 0) and false then
					local light = ents.Create("env_projectedtexture")
					light:SetPos(tr.HitPos - tr.HitNormal*64)
					light:SetAngles(tr.HitNormal:Angle())

					-- Set parameters
					light:SetKeyValue("enableshadows", 0)
					light:SetKeyValue("farz", 512+192)
					light:SetKeyValue("nearz", 128)
					light:SetKeyValue("lightfov", 160)

					-- Set Brightness
					local brightness = 0.20
					light:SetKeyValue("lightcolor",
						Format("%i %i %i 255",
							180*brightness,
							255*brightness,
							255*brightness
						)
					)

					-- Turn light on
					light:Spawn()
					light:Input("SpotlightTexture",nil,nil,"effects/flashlight001")
					table.insert(Metrostroi.Signs,light)	
				end
			end
		end
	end
end

Metrostroi.InitializeSigns()