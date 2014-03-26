--------------------------------------------------------------------------------
-- Schedule generator
--------------------------------------------------------------------------------
-- List of all unique routes that can be used in schedule generation
-- 		{ station, platform }
Metrostroi.ScheduleRoutes = {
	["Line1_Platform1"] = {
		{111,1},
		{112,1},
		{113,1},
		{114,1},
		{116,1},
	},
	["Line1_Platform2"] = {
		{116,2},
		{114,2},
		{113,2},
		{112,2},
		{111,2},
	},
}

-- List of all time intervals in which schedules must be generated
-- 		{ start_time, end_time, route_name, train_interval, 
Metrostroi.ScheduleConfiguration = {
	{ 7*60 + 0, 8*60 + 0, "Line1_Platform1", 1*60 + 30 },
	{ 7*60 + 0, 8*60 + 0, "Line1_Platform2", 1*60 + 30 },
}

-- List of all train starting points
--		{ station_id, train_count }
Metrostroi.ScheduleStartingPoints = {
	["Point1"] = { 111, 2 },
	["Point2"] = { 114, 2 },
	["Point3"] = { 116, 2 },
}

-- Pool of all schedules
Metrostroi.Schedules = {}

-- Used for generating schedules and storing where trains are
local TrainPositions = {}
-- Used for giving unique ID's to schedules
local GlobalPathID = 0




--------------------------------------------------------------------------------
local function fixRouteData(routeData,name)
	-- Prepare general route information
	routeData.Duration = 0
	routeData.Name = name

	-- Fix up every station
	for i,stationID in ipairs(routeData) do
		routeData[i].ID = i
		routeData[i].TimeOffset = routeData.Duration
		if routeData[i+1] then
			if not Metrostroi.Stations[routeData[i][1]]						then print(Format("No station %d",routeData[i][1])) return end
			if not Metrostroi.Stations[routeData[i][1]][routeData[i][2]]	then print(Format("No platform %d for station %d",routeData[i][2],routeData[i][1])) return end
			if not Metrostroi.Stations[routeData[i+1][1]]					then print(Format("No station %d",routeData[i+1][1])) return end
			if not Metrostroi.Stations[routeData[i+1][1]][routeData[i][2]]	then print(Format("No platform %d for station %d",routeData[i+1][2],routeData[i+1][1])) return end
			
			-- Calculate travel time between two nodes
			local travelTime,travelDistance = Metrostroi.GetTravelTime(
				Metrostroi.Stations[routeData[i  ][1]][routeData[i  ][2]].node_end,
				Metrostroi.Stations[routeData[i+1][1]][routeData[i+1][2]].node_start)
			-- Add time for startup and slowdown
			travelTime = travelTime + 20
			
			-- Remember stats
			routeData.Duration = routeData.Duration + travelTime
			routeData[i].TravelTime = travelTime
			routeData[i].TravelDistance = travelDistance
	
			-- Print debug information
			print(Format("\t\t[%03d-%d]->[%03d-%d]  %02d:%02d min  %4.0f m  %4.1f km/h",
				routeData[i][1],routeData[i][2],
				routeData[i+1][1],routeData[i+1][2],
				math.floor(travelTime/60),math.floor(travelTime)%60,travelDistance,(travelDistance/travelTime)*3.6))
		else
			routeData.LastID = i
			routeData.LastStation = routeData[i][1]
		end
	end
	
	-- Add a quick lookup
	routeData.Lookup = {}
	for i,_ in ipairs(routeData) do
		routeData.Lookup[routeData[i][1]] = routeData[i]
	end
end

local function findFreeTrain(scheduleConfiguration)
	-- Find a train already on this route somewhere
	local routeName = scheduleConfiguration[3]
	local route = Metrostroi.ScheduleRoutes[routeName]
	
	-- It must be at least this far away from other trains
	local minInterval = scheduleConfiguration[4]
	
	-- Try find a train that can execute schedule
	for k,v in pairs(TrainPositions) do
		if (not v.busy) and (v.wait_time == 0) and (v.station ~= route.LastStation) then
			for _,routeData in ipairs(route) do
				if routeData[1] == v.station then -- Train on one of the stations
					--print("FOUND TRAIN",k,"AT STATION",v.station)
					--print("TIME OFFSET",route.Lookup[v.station].TimeOffset)
					
					-- Now check if this train is sufficiently spaced from other trains doing this route
					local fitsByInterval = true
					for k2,v2 in pairs(TrainPositions) do
						if v2.busy and (v2.route == route) and fitsByInterval then
							local freeTrainTime = route.Lookup[v.station].TimeOffset
							local busyTrainTime = route.Lookup[v2.station].TimeOffset + (v2.travel_time)

							local timeDelta = math.abs(freeTrainTime - busyTrainTime)
							
							--print("Trying to send",k,"but",k2,"is on path, dT = ",timeDelta,minInterval)
							if timeDelta < minInterval then fitsByInterval = false end
						end
					end
					
					-- If fits by interval, this is a train to use
					if fitsByInterval then
						return k,route
					end
				end
			end
		end
	end
	
	-- No free train available
end

function Metrostroi.GenerateSchedules()
	print("Metrostroi: Preparing routes...")
	for routeName,routeData in pairs(Metrostroi.ScheduleRoutes) do
		print(Format("\tTravel distances for preset route '%s':",routeName))
		fixRouteData(routeData,routeName)
		print(Format("\t\tTotal duration: %02d:%02d min",math.floor(routeData.Duration/60),math.floor(routeData.Duration)%60))
	end
	
	-- Generate schedules themselves
	print("Metrostroi: Generating schedules...")
	
	-- Calculate number of trains
	TrainPositions = {}
	local trainsCount = 0
	for k,v in pairs(Metrostroi.ScheduleStartingPoints) do
		trainsCount = trainsCount + v[2]
		for i=1,v[2] do
			TrainPositions[#TrainPositions+1] = { 
				station = v[1],
				busy = false,
				route = nil,
				wait_time = 0,
			}
		end
	end
	print(Format("\tTotal number of trains: %d",trainsCount))
	
	-- Start with opening time (7:00)
	local currentTime = 7*60 + 0
	-- End with closing time (24:00)
	local endTime = 24*60 + 0
	
	-- Start creating schedule pool
	while currentTime < endTime do
		-- Timestep for the calculations
		local dT = 5 -- seconds
		
		-- Current time as string
		local currentTimeStr = Format("%02d:%02d:%02d",
				math.floor(currentTime/60),
				math.floor(currentTime)%60,
				math.floor(currentTime*60)%60)

		-- Try to get trains to move
		local noTrainsMoved = false
		while not noTrainsMoved do
			noTrainsMoved = true
			for _,scheduleConfiguration in pairs(Metrostroi.ScheduleConfiguration) do
				if (currentTime >= scheduleConfiguration[1]) and (currentTime < scheduleConfiguration[2]) then
					-- Make all trains busy if possible
					local freeTrain,route = findFreeTrain(scheduleConfiguration)
					
					-- Make this train busy
					if freeTrain then
						local train = TrainPositions[freeTrain]
						train.busy = true
						train.route = route
						train.travel_time = 0
						
						-- Start a new schedule
						local newID = #Metrostroi.Schedules+1
						Metrostroi.Schedules[newID] = {
							ScheduleID = newID,
							TrainID = freeTrain,
							StartTime = currentTime,
							StartStation = train.station,
							{ currentTime, train.station, arrivalTimeStr = currentTimeStr },
						}
						train.schedule = Metrostroi.Schedules[newID]
						
						-- Keep moving trains out of their holding ends
						noTrainsMoved = false
							
						--print(Format("[%s][+] Train #%d departs from %03d",currentTimeStr,freeTrain,train.station))
					end
				end
			end
		end
		
		-- Print total state of all trains right now
		--print(Format("[SCHEDULE] %02d:%02d:%02d:",math.floor(currentTime/60),math.floor(currentTime)%60,math.floor(currentTime*60)%60))
		--[[for k,v in pairs(TrainPositions) do
			if v.busy then
				local travelTime = v.route.Lookup[v.station].TravelTime
				print(Format("\t#%d at %03d, driving route %s for %d/%d seconds",
					k,v.station,v.route.Name,v.travel_time,travelTime or 0))
			else
				print(Format("\t#%d at %03d, holding",
					k,v.station))
			end
		end]]--
		
		-- Update movement of trains
		for k,v in pairs(TrainPositions) do
			if v.wait_time > 0 then -- Process wait time
				v.wait_time = math.max(0,v.wait_time - dT)
			elseif v.busy then -- If busy, process driving
				local travelTime = v.route.Lookup[v.station].TravelTime
				local nextStation = v.route[v.route.Lookup[v.station].ID + 1]
				v.travel_time = v.travel_time + dT
				
				if travelTime then
					if v.travel_time > travelTime then
						v.station = nextStation[1]
						v.travel_time = 0
						
						-- Record that train arrives to station
						table.insert(v.schedule, { currentTime, v.station, arrivalTimeStr = currentTimeStr })
						
						-- Process end stations
						if not v.route.Lookup[v.station].TravelTime then
							v.busy = false
							v.wait_time = 4*60
							--print(Format("[%s][-] Train #%d arrives to last station %03d",currentTimeStr,k,v.station))
							
							v.schedule.EndStation = v.station
							v.schedule.EndTime = currentTime
							v.schedule.Duration = v.schedule.StartTime - v.schedule.EndTime
						else
							v.wait_time = 20
							--print(Format("[%s][-] Train #%d arrives to %03d",currentTimeStr,k,v.station))						
						end
					end
				end
			end			
		end
		
		-- Move to next time step
		currentTime = currentTime + dT/60
		currentTime = math.floor(currentTime*12 + 0.5)/12
	end
	
	-- Clean up incomplete schedules
	for k,v in ipairs(Metrostroi.Schedules) do
		if not v.EndStation then
			print("Incomplete schedule #"..v.ScheduleID)
			v.EndStation = v[#v][2]
			v.EndTime = v[#v][1]
			v.Duration = v.StartTime - v.EndTime
		end
	end
	
	-- Print result
	print(Format("Metrostroi: Generated %d schedules:",#Metrostroi.Schedules))
	for k,v in ipairs(Metrostroi.Schedules) do
		print(Format("--- %03d --- From %03d to %03d ------- #%02d ------",
			v.ScheduleID,v.StartStation,v.EndStation,v.TrainID))
		for i,d in ipairs(v) do
			print(Format("\t%03d   %s",d[2],d.arrivalTimeStr))
		end
		if v.ScheduleID == 1 then return end
	end
end

Metrostroi.GenerateSchedules()