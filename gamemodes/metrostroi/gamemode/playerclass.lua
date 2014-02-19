
DEFINE_BASECLASS( "player_default" )

local PLAYER = {}
PLAYER.DisplayName			= "Trainman"

PLAYER.WalkSpeed 			= 200		-- How fast to move when not running
PLAYER.RunSpeed				= 250		-- How fast to move when running
PLAYER.CrouchedWalkSpeed 	= 0.3		-- Multiply move speed by this when crouching
PLAYER.DuckSpeed			= 0.3		-- How fast to go from not ducking, to ducking
PLAYER.UnDuckSpeed			= 0.3		-- How fast to go from ducking, to not ducking
PLAYER.JumpPower			= 200		-- How powerful our jump should be
PLAYER.CanUseFlashlight     = true		-- Can we use the flashlight
PLAYER.MaxHealth			= 100		-- Max health we can have
PLAYER.StartHealth			= 100		-- How much health we start with
PLAYER.StartArmor			= 0			-- How much armour we start with
PLAYER.DropWeaponOnDie		= false		-- Do we drop our weapon when we die
PLAYER.TeammateNoCollide 	= true		-- Do we collide with teammates or run straight through them
PLAYER.AvoidPlayers			= true		-- Automatically swerves around other players
PLAYER.UseVMHands			= true		-- Uses viewmodel hands


function PLAYER:Loadout()
	self.Player:Give( "weapon_physgun" )

	self.Player:SwitchToDefaultWeapon()
end

local ranktomdl = {
	[RANK_GUEST]	= {}, -- Citizens
	[RANK_3DEG]		= {}, -- Hostages
	[RANK_2DEG]		= {}, -- Rebels
	[RANK_1DEG]		= {"models/player/breen.mdl"},
	[RANK_DRIVER]	= {"models/player/barney.mdl"}
}
for i=1,10 do
	if i <= 4 then
		table.insert(ranktomdl[RANK_3DEG], "models/player/hostage/hostage_0"..i..".mdl")
	end
	
	if i <= 6 then
		table.insert(ranktomdl[RANK_GUEST], "models/player/group01/female_0"..i..".mdl")
		table.insert(ranktomdl[RANK_2DEG], "models/player/group03/female_0"..i..".mdl")
	end
	
	if i <= 9 then
		table.insert(ranktomdl[RANK_GUEST], "models/player/group01/male_0"..i..".mdl")
		table.insert(ranktomdl[RANK_2DEG], "models/player/group03/male_0"..i..".mdl")
	end
end

function PLAYER:SetModel()
	local mdl = table.Random(ranktomdl[self.Player:Team()])
	self.Player:SetModel(mdl)
end

player_manager.RegisterClass( "player_metrostroi", PLAYER, "player_default" )
