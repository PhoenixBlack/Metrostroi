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
	timer.Simple(0.01,function()
		local t = 3
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
		local pos = (platformStart + platformDir*X[i]) + Vector(0,0,64) + platformN*96
		local tr = trace(pos,platformN*384)
		
		local sign = ents.Create("gmod_track_sign")
		if IsValid(sign) then
			if tr.Hit then
				sign:SetPos(tr.HitPos)
				sign:SetAngles(tr.HitNormal:Angle())
			else
				sign:SetPos(tr.HitPos)
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
end

Metrostroi.InitializeSigns()
