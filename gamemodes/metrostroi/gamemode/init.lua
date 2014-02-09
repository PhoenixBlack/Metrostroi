AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )
include( "chat.lua" )

CreateConVar("metro_motd_overrideurl","",{FCVAR_ARCHIVE,FCVAR_REPLICATED},"Override URL for MOTD, set to number to completely disable")



local function AdminSpawnCMD(ply,cmd,args,fullstring)
	local entname = "gmod_subway_em508"
	local sent = scripted_ents.GetStored( entname ).t
	local SpawnFunction = scripted_ents.GetMember( entname, "SpawnFunction" )
	if ( !SpawnFunction ) then return end
	entity = SpawnFunction( sent, ply, ply:GetEyeTrace(), entname )
end


concommand.Add("metro_admin_spawntrain",AdminSpawnCMD,nil,"Spawn a 508")
-------------------------------------------------------------------------

function GM:PlayerInitialSpawn(ply)
	ply:SetTeam( TEAM_UNASSIGNED ) --Not used by GM atm, other scripts might use it
	ply:ConCommand("metro_showmotd")
end

