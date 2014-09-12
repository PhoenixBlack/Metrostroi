--------------------------------------------------------------------------------
-- Assign train IDs
--------------------------------------------------------------------------------
if not Metrostroi.WagonID then
	Metrostroi.WagonID = 1
end
function Metrostroi.NextWagonID()
	local id = Metrostroi.WagonID
	Metrostroi.WagonID = Metrostroi.WagonID + 1
	if Metrostroi.WagonID > 99 then Metrostroi.WagonID = 1 end
	return id
end

if not Metrostroi.EquipmentID then
	Metrostroi.EquipmentID = 1
end
function Metrostroi.NextEquipmentID()
	local id = Metrostroi.EquipmentID
	Metrostroi.EquipmentID = Metrostroi.EquipmentID + 1
	return id
end




--------------------------------------------------------------------------------
-- Custom drop to floor that only checks origin and not bounding box
--------------------------------------------------------------------------------
function Metrostroi.DropToFloor(ent)
	local result = util.TraceLine({
		start = ent:GetPos(),
		endpos = ent:GetPos() - Vector(0,0,256),
		mask = -1,
		filter = { ent },
	})
	if result.Hit then ent:SetPos(result.HitPos) end
end




--------------------------------------------------------------------------------
-- Get random number that is same over a period of 1 minute
--------------------------------------------------------------------------------
local randomPeriodStart = 0
local randomPeriodNumber = math.random()
function Metrostroi.PeriodRandomNumber()
	if (CurTime() - randomPeriodStart) > 60 then
		randomPeriodNumber = math.random()
	end
	
	-- Refresh the period
	randomPeriodStart = CurTime()

	-- Return number
	return randomPeriodNumber
end




--------------------------------------------------------------------------------
-- Joystick controls
-- Author: HunterNL
--------------------------------------------------------------------------------
if not Metrostroi.JoystickValueRemap then
	Metrostroi.JoystickValueRemap = {}
	Metrostroi.JoystickSystemMap = {}
end

function Metrostroi.RegisterJoystickInput (uid,analog,desc,min,max) 
	if not joystick then
		Error("Joystick Input registered without joystick addon installed, get it at https://github.com/MattJeanes/Joystick-Module") 
	end
	--If this is only called in a JoystickRegister hook it should never even happen
	
	if #uid > 20 then 
		print("Metrostroi Joystick UID too long, trimming") 
		local uid = string.Left(uid,20)
	end
	
	
	local atype 
	if analog then
		atype = "analog"
	else
		atype = "digital"
	end
	
	local temp = {
		uid = uid,
		type = atype,
		description = desc,
		category = "Metrostroi" --Just Metrostroi for now, seperate catagories for different trains later?
		--Catergory is also checked in subway base, don't just change
	}
	
	
	--Joystick addon's build-in remapping doesn't work so well, so we're doing this instead
	if min ~= nil and max ~= nil and analog then
		Metrostroi.JoystickValueRemap[uid]={min,max}
	end
	
	jcon.register(temp)
end

-- Wrapper around joystick get to implement our own remapping
function Metrostroi.GetJoystickInput(ply,uid) 
	local remapinfo = Metrostroi.JoystickValueRemap[uid]
	local jvalue = joystick.Get(ply,uid)
	if remapinfo == nil then
		return jvalue
	elseif jvalue ~= nil then
		return math.Remap(joystick.Get(ply,uid),0,255,remapinfo[1],remapinfo[2])
	else
		return jvalue
	end
end




--------------------------------------------------------------------------------
-- Player meta table magic
-- Author: HunterNL
--------------------------------------------------------------------------------
local Player = FindMetaTable("Player")

function Player:CanDriveTrains()
	return IsValid(self:GetWeapon("train_kv_wrench")) or self:IsAdmin()
end

function Player:GetTrain()
	local seat = self:GetVehicle()
	if seat then 
		return seat:GetNWEntity("TrainEntity")
	end
end




--------------------------------------------------------------------------------
-- Train count
--------------------------------------------------------------------------------
function Metrostroi.TrainCount()
	local N = 0
	for k,v in pairs(Metrostroi.TrainClasses) do
		N = N + #ents.FindByClass(v)
	end
	return N
end


concommand.Add("metrostroi_train_count", function(ply, _, args)
	print("Trains on server: "..Metrostroi.TrainCount())
	if CPPI then
		local N = {}
		for k,v in pairs(Metrostroi.TrainClasses) do
			local ents = ents.FindByClass(v)
			for k2,v2 in pairs(ents) do
				N[v2:CPPIGetOwner() or "(disconnected)"] = (N[v2:CPPIGetOwner() or "(disconnected)"] or 0) + 1
			end
		end
		for k,v in pairs(N) do
			print(k,"Trains count: "..v)
		end
	end
end)

concommand.Add("metrostroi_time", function(ply, _, args)
	if IsValid(ply) then
		ply:PrintMessage(HUD_PRINTCONSOLE, "Time on server is "..
			Format("%02d:%02d:%02d",
				math.floor(os.time()/3600)%24,
				math.floor(os.time()/60)%60,
				math.floor(os.time())%60))

		local t = (os.time()/60)%(60*24)
		local printed = false
		local train = ply:GetTrain()
		if IsValid(train) and train.Schedule then
			for k,v in ipairs(train.Schedule) do
				local prefix = ""
				if (not printed) and (t < v[3]) then
					prefix = ">>>>"
					printed = true
				end
				ply:PrintMessage(HUD_PRINTCONSOLE, 
					Format(prefix.."\t[%03d][%s] %02d:%02d:%02d",v[1],
						Metrostroi.StationNames[v[1]] or "N/A",
						math.floor(v[3]/60)%24,
						math.floor(v[3])%60,
						math.floor(v[3]*60)%60))
				
			end
		end
	end
end)




--------------------------------------------------------------------------------
-- Simple hack to get a driving schedule
--------------------------------------------------------------------------------
concommand.Add("metrostroi_get_schedule", function(ply, _, args)
	if not IsValid(ply) then return end
	local train = ply:GetTrain()

	local pos = Metrostroi.TrainPositions[train]
	if pos and pos[1] then
		local id = tonumber(args[1]) or pos[1].path.id

		print("Generating schedule for user")
		train.Schedule = Metrostroi.GenerateSchedule("Line1_Platform"..id)
		if train.Schedule then
			train:SetNWInt("_schedule_id",train.Schedule.ScheduleID)
			train:SetNWInt("_schedule_duration",train.Schedule.Duration)
			train:SetNWInt("_schedule_interval",train.Schedule.Interval)
			train:SetNWInt("_schedule_N",#train.Schedule)
			train:SetNWInt("_schedule_path",id)
			for k,v in ipairs(train.Schedule) do
				train:SetNWInt("_schedule_"..k.."_1",v[1])
				train:SetNWInt("_schedule_"..k.."_2",v[2])
				train:SetNWInt("_schedule_"..k.."_3",v[3])
				train:SetNWInt("_schedule_"..k.."_4",v[4])
				train:SetNWString("_schedule_"..k.."_5",Metrostroi.StationNames[v[1]] or v[1])
			end
		end
	end
end)




--------------------------------------------------------------------------------
-- Failures related stuff
--------------------------------------------------------------------------------
concommand.Add("metrostroi_failures", function(ply, _, args)
	local i = 0
	for _,class in pairs(Metrostroi.TrainClasses) do
		local trains = ents.FindByClass(class)
		for _,train in pairs(trains) do
			timer.Simple(0.1+i*0.2,function()
				print("Failures for train "..train:EntIndex())
				train:TriggerInput("FailSimStatus",1)
			end)
			i = i + 1
		end
	end
end)

concommand.Add("metrostroi_fail", function(ply, _, args)
	local trainList = {}
	if not IsValid(ply) then
		for _,class in pairs(Metrostroi.TrainClasses) do
			local trains = ents.FindByClass(class)
			for _,train in pairs(trains) do
				table.insert(trainList,train)
			end
		end
	else
		local train = ply:GetTrain()
		if IsValid(train) then
			train:UpdateWagonList()
			for k,v in pairs(train.WagonList) do
				trainList[k] = v
			end
		end
	end
	
	local train = table.Random(trainList)
	if train then
		if IsValid(ply) then
			ply:PrintMessage(HUD_PRINTCONSOLE,"Generating random failure in your train!")
			print("Player generated random failure in train "..train:EntIndex())
		else
			print("Generating random failure in train "..train:EntIndex())
		end		
		train:TriggerInput("FailSimFail",1)
	else
		if IsValid(ply) then
			ply:PrintMessage(HUD_PRINTCONSOLE,"You must be inside a train to generate a failure!")
		end
	end
end)




--------------------------------------------------------------------------------
-- Electric consumption stats
--------------------------------------------------------------------------------
-- Load total kWh
timer.Create("Metrostroi_TotalkWhTimer",5.00,0,function()
	file.Write("metrostroi_data/total_kwh.txt",Metrostroi.TotalkWh or 0)
end)
Metrostroi.TotalkWh = Metrostroi.TotalkWh or tonumber(file.Read("metrostroi_data/total_kwh.txt") or "") or 0
Metrostroi.TotalRateWatts = Metrostroi.TotalRateWatts or 0

local prevTime
hook.Add("Think", "Metrostroi_ElectricConsumptionThink", function()
	-- Change in time
	prevTime = prevTime or CurTime()
	local deltaTime = (CurTime() - prevTime)
	prevTime = CurTime()
	
	-- Calculate total rate
	Metrostroi.TotalRateWatts = 0
	for _,class in pairs(Metrostroi.TrainClasses) do
		local trains = ents.FindByClass(class)
		for _,train in pairs(trains) do
			if train.Electric then
				Metrostroi.TotalRateWatts = Metrostroi.TotalRateWatts + math.max(0,(train.Electric.EnergyChange or 0))
			end
		end
	end
	
	-- Calculate total kWh
	Metrostroi.TotalkWh = Metrostroi.TotalkWh + (Metrostroi.TotalRateWatts/(3.6e6))*deltaTime
end)

concommand.Add("metrostroi_electric", function(ply, _, args)
	local m = Format("[%25s] %010.3f kWh (%.2f$), current: %.3f kW","<total>",Metrostroi.TotalkWh,Metrostroi.GetEnergyCost(Metrostroi.TotalkWh),Metrostroi.TotalRateWatts*1e-3)
	if IsValid(ply) 
	then ply:PrintMessage(HUD_PRINTCONSOLE,m)
	else print(m)
	end
			
	if CPPI then
		local U = {}
		local D = {}
		for _,class in pairs(Metrostroi.TrainClasses) do
			local trains = ents.FindByClass(class)
			for _,train in pairs(trains) do
				local owner = "(disconnected)"
				if train:CPPIGetOwner() then
					owner = train:CPPIGetOwner():GetName()
				end
				if train.Electric then
					U[owner] = (U[owner] or 0) + train.Electric.ElectricEnergyUsed
					D[owner] = (D[owner] or 0) + train.Electric.ElectricEnergyDissipated
				end
			end
		end
		for player,_ in pairs(U) do --, n=%.0f%%
			--local m = Format("[%20s] %08.1f KWh (lost %08.1f KWh)",player,U[player]/(3.6e6),D[player]/(3.6e6)) --,100*D[player]/U[player]) --,D[player])
			local m = Format("[%25s] %010.3f kWh (%.2f$)",player,U[player]/(3.6e6),Metrostroi.GetEnergyCost(U[player]/(3.6e6)))
			if IsValid(ply) 
			then ply:PrintMessage(HUD_PRINTCONSOLE,m)
			else print(m)
			end
		end
	end
end)

timer.Create("Metrostroi_ElectricConsumptionTimer",0.5,0,function()
	if CPPI then
		local U = {}
		local D = {}
		for _,class in pairs(Metrostroi.TrainClasses) do
			local trains = ents.FindByClass(class)
			for _,train in pairs(trains) do
				local owner = train:CPPIGetOwner()
				if owner and (train.Electric) then
					U[owner] = (U[owner] or 0) + train.Electric.ElectricEnergyUsed
					D[owner] = (D[owner] or 0) + train.Electric.ElectricEnergyDissipated
				end
			end
		end
		for player,_ in pairs(U) do
			if IsValid(player) then
				player:SetDeaths(10*U[player]/(3.6e6))
			end
		end
	end
end)



--------------------------------------------------------------------------------
-- Does current map have any sort of metrostroi support
--------------------------------------------------------------------------------
function Metrostroi.MapHasFullSupport()
	return (#Metrostroi.Paths > 0)
end