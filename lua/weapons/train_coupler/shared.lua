if (SERVER) then
	AddCSLuaFile("shared.lua")
	
	SWEP.Weight				= 1
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
	util.AddNetworkString("traintoolnotify") 
end

if (CLIENT) then
	SWEP.PrintName			= "Train Engineering Tool"
	SWEP.Slot = 3
	SWEP.SlotPos = 1
	SWEP.DrawAmmo			= false
	SWEP.DrawCrosshair		= true
	
	net.Receive("traintoolnotify", function( length, client )
		notification.AddLegacy(net.ReadString(),net.ReadInt(4),net.ReadInt(4))
	end)
	
end

SWEP.Author		= "TP Hunter NL"
SWEP.Contact		= "http://facepunch.com/showthread.php?t=1328089"
SWEP.Purpose		= "Coupling, decoupling, switching"
SWEP.Instructions	= "Click on 1 bogey, then click on another. Right click decouples, reload cancels"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/c_crowbar.mdl"
SWEP.WorldModel			= "models/weapons/w_crowbar.mdl"
SWEP.UseHands = true //Fancy GM13 hands

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"



function SWEP:Initialize()
	
	self:SetWeaponHoldType("melee")
	
	self.ValidBogeys = {
		["models/myproject/81-717_bogey.mdl"] = Vector(-162,0,13)
	}
	self.NextReloadTime = CurTime() + .2
	
end

//Check if the ent is valid and model matches
function SWEP:IsValidBogey(s)
	if not IsValid(s) then return false end
	local s = s:GetModel() or s
	return self.ValidBogeys[s] != nil
end

function SWEP:GetSwitchPicket(ent)
	if !IsValid(ent) then return false end
	if ent:GetClass() != "prop_door_rotating" then return false end
	local picketlist = self:SortEntTableByDistance(ents.FindByClass("gmod_track_equipment"),ent:GetPos())
	for k,v in pairs(picketlist) do
		if v.TrackSwitchName == ent:GetName() then return v end
	end
end

//Apply the ballsocket
function SWEP:Finalize(ent1,ent2)
	if constraint.CanConstrain(ent1,0) and constraint.CanConstrain(ent2,0) then
		if IsValid(constraint.AdvBallsocket(
			ent1,
			ent2,
			0, //bone
			0, //bone
			self.ValidBogeys[ent1:GetModel()],
			self.ValidBogeys[ent2:GetModel()],
			0, //forcelimit
			0, //torquelimit
			-180, //xmin
			-180, //ymin
			-180, //zmin
			180, //xmax
			180, //ymax
			180, //zmax
			0, //xfric
			0, //yfric
			0, //zfric
			0, //rotonly
			1 //nocollide
		)) then
			sound.Play("buttons/lever2.wav",(ent1:GetPos()+ent2:GetPos())/2)
			self:SendNotification("Coupled",0,3)
		else
			self:SendNotification("Constraint error",1,4)
		end
	else
		self:SendNotification("Constraint error",1,4)
	end
end


//0=generic 1=error 2=undo 3=hint 4=cleanup
//Message, type, delay
function SWEP:SendNotification(s,e,n)
	net.Start("traintoolnotify")
	net.WriteString(s)
	net.WriteInt(e,4)
	net.WriteInt(n,4)
	net.Send(self.Owner)
end

//Checks the offset table of given entities and returns distance
function SWEP:GetCouplerDistance(ent1,ent2)
	return ent1:LocalToWorld(self.ValidBogeys[ent1:GetModel()]):Distance(ent2:LocalToWorld(self.ValidBogeys[ent2:GetModel()]))
end

//Checks if there's an advballsocket between two entities
function SWEP:AreCoupled(ent1,ent2)
	local constrainttable = constraint.FindConstraints(ent1,"AdvBallsocket")
	local coupled = false
	for k,v in pairs(constrainttable) do
		if v.Type == "AdvBallsocket" then 
			if( (v.Ent1 == ent1 or v.Ent1 == ent2) and (v.Ent2 == ent1 or v.Ent2 == ent2)) then
				coupled = true
			end
		end
	end
	
	return coupled
end

function SWEP:SortEntTableByDistance(tbl,pos)
	local newtable = {}
	for k,v in pairs(tbl) do
		if IsValid(v) then
			table.insert(newtable,v)
		else 
			Error("Table contains non-entity")
		end
	end
	
	table.sort(newtable, function( ent1, ent2 )
		return ent1:GetPos():Distance(pos) < ent2:GetPos():Distance(pos)
	end)
	
	return newtable
	
end

//Get the most likely canidate for a connection
//Returns nil if none
function SWEP:GetBogeyBuddy(ent)
	local enttable = ents.FindInSphere(ent:GetPos(),360)
	local filteredtable = {}
	for k,v in pairs(enttable) do
		if self:IsValidBogey(v) and v != ent then
			table.insert(filteredtable,v)
		end
	end
	table.sort(filteredtable, function( ent1, ent2 )
		return self:GetCouplerDistance(ent,ent1) < self:GetCouplerDistance(ent,ent2)
	end)
	
	return filteredtable[1]
end

function SWEP:IsWithinActionDistance(trace)
	return trace.StartPos:Distance(trace.HitPos) < 512
end

//Releases breaks, sometime later in development
function SWEP:Reload()
	if CurTime() > self.NextReloadTime then
		self.NextReloadTime = CurTime() + .2
		self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER) 
		self.Owner:SetAnimation( PLAYER_ATTACK1 );
		if CLIENT then return end
		
		local ent = self.Owner:GetEyeTrace().Entity
		if !self:IsValidBogey(ent) then return end
		
		local train = ent
                if ent.IsSubwayTrain ~= true then
                  train = ent:GetNWEntity("TrainEntity")
                end
		
		if train and IsValid(train) then
			train:ReleaseBrakes()
		end
	end
end


//Couple
function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + .2)
	self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER) 
	self.Owner:SetAnimation( PLAYER_ATTACK1 );
	
	if CLIENT then return end
	
	if !self:IsWithinActionDistance(self.Owner:GetEyeTrace()) then return end
	
	local ent1 = self.Owner:GetEyeTrace().Entity
	if self:IsValidBogey(ent1) then 
		local ent2 = self:GetBogeyBuddy(ent1)
		if IsValid(ent2) then
			if self:GetCouplerDistance(ent1,ent2) < 20 then
				if !self:AreCoupled(ent1,ent2) then
					self:Finalize(ent1,ent2) 
				else
					self:SendNotification("Already coupled",0,4)
				end
			else
				self:SendNotification("Too far",1,3)
			end
		else
			self:SendNotification("No other bogeys nearby",0,5)
		end
	else
		local picket = self:GetSwitchPicket(ent1)
		if IsValid(picket) then
			picket:SetTrackSwitchState(true)
		end
		
	end
end

//Decouple
function SWEP:SecondaryAttack()
	self.Weapon:SetNextSecondaryFire(CurTime() + .2)
	self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
	if CLIENT then return end
	
	if !self:IsWithinActionDistance(self.Owner:GetEyeTrace()) then return end
	
	local ent = self.Owner:GetEyeTrace().Entity
	
	if self:IsValidBogey(ent) then
		local constrainttable = constraint.FindConstraints(ent,"AdvBallsocket")
		local didsomething = false
		local ent1,ent2 = nil
		
		for k,v in pairs(constrainttable) do
			if self:IsValidBogey(v.Ent1) and self:IsValidBogey(v.Ent2) then
				v.Constraint:Remove()
				didsomething = true
				ent1=v.Ent1
				ent2=v.Ent2
			end
		end
		
		if didsomething then 
			self:SendNotification("Decoupled",0,3) 
			sound.Play("buttons/lever8.wav",(ent1:GetPos()+ent2:GetPos())/2)
		end
	else
		local picket = self:GetSwitchPicket(ent)
		if IsValid(picket) then
			picket:SetTrackSwitchState(false)
		end
	end
end

function SWEP:Deploy()
   self.Weapon:SendWeaponAnim(ACT_VM_DRAW);
end


function SWEP:Think()
--I am not clever SWEP
end


