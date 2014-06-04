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
				N[v2:CPPIGetOwner()] = (N[v2:CPPIGetOwner()] or 0) + 1
			end
		end
		for k,v in pairs(N) do
			print(k,"Trains count: "..v)
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
-- Does current map have any sort of metrostroi support
--------------------------------------------------------------------------------
function Metrostroi.MapHasFullSupport()
	return (#Metrostroi.Paths > 0)
end