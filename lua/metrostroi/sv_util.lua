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