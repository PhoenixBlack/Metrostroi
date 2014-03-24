AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_jobs.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "sh_ranks.lua" )
AddCSLuaFile( "playerclass.lua" )

include( "shared.lua" )
include( "chat.lua" )
include( "trainspawner.lua" )
include( "sh_ranks.lua" )
include( "sv_ranks.lua" )
include( "sv_scoring.lua" )
include( "playerclass.lua" )

CreateConVar("metro_motd_overrideurl","",{FCVAR_ARCHIVE,FCVAR_REPLICATED},"Override URL for MOTD, set to number to completely disable")


-- Uses some odd sandbox code to spawn this as you would with the spawnmenu
local function AdminSpawnCMD(ply,cmd,args,fullstring)
	local entname = "gmod_subway_ezh3"
	local sent = scripted_ents.GetStored( entname ).t
	local SpawnFunction = scripted_ents.GetMember( entname, "SpawnFunction" )
	if ( !SpawnFunction ) then return end
	entity = SpawnFunction( sent, ply, ply:GetEyeTrace(), entname )
end
concommand.Add("metro_admin_spawntrain",AdminSpawnCMD,nil,"Spawn a 508")
-------------------------------------------------------------------------

function GM:PlayerInitialSpawn(ply)
	ply:ConCommand("metro_showmotd")
end

function GM:PlayerSpawn(ply)
	player_manager.SetPlayerClass( ply, "player_metrostroi" )
	player_manager.OnPlayerSpawn( ply )
	player_manager.RunClass( ply, "Spawn" )
	player_manager.RunClass( ply, "SetModel" )
	player_manager.RunClass( ply, "Loadout" )
end

local function SetKeyState(ply,key,state)
	ply.keystate = ply.keystate or {}
	ply.keystate[key]=state
end

function GM:PlayerButtonDown(ply,key)
	SetKeyState(ply,key,true)
end

function GM:PlayerButtonUp(ply,key)
	SetKeyState(ply,key,nil)
end