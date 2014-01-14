if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 1
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if (CLIENT) then
	SWEP.PrintName			= "Train Reverser Wrench"
	SWEP.Slot = 3
	SWEP.SlotPos = 2
	SWEP.DrawAmmo			= false
	SWEP.DrawCrosshair		= true
	
end

SWEP.Author		= "TP Hunter NL"
SWEP.Contact		= "http://facepunch.com/showthread.php?t=1328089"
SWEP.Purpose		= "Not much of anything really"
SWEP.Instructions	= "Swing it"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true



--Crowbar
SWEP.ViewModel			= "models/weapons/c_crowbar.mdl"
SWEP.WorldModel			= "models/weapons/w_crowbar.mdl"
SWEP.UseHands = true --Fancy GM13 hands

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

function SWEP:Precache()
	util.PrecacheSound("weapons/iceaxe/iceaxe_swing1.wav")
end


function SWEP:Initialize()
	self:SetWeaponHoldType("melee")
end

function SWEP:Reload()
--
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + .2)
	self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER) 
	self.Owner:SetAnimation( PLAYER_ATTACK1 );
	self.Weapon:EmitSound("weapons/iceaxe/iceaxe_swing1.wav")
end

function SWEP:SecondaryAttack()
	self.Weapon:SetNextSecondaryFire(CurTime() + .2)
	self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self.Weapon:EmitSound("weapons/iceaxe/iceaxe_swing1.wav")
end

function SWEP:Deploy()
   self.Weapon:SendWeaponAnim(ACT_VM_DRAW);
end


function SWEP:Think()
--I am not clever SWEP
end


