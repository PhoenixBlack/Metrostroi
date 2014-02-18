
--[[
This file contains a bunch of stuff we need defined from sandbox that base gamemode doesn't have.
]]

-- Init.lua
function GM:PlayerFrozeObject( ply, entity, physobject )
	local effectdata = EffectData()
		effectdata:SetOrigin( physobject:GetPos() )
		effectdata:SetEntity( entity )
	util.Effect( "phys_freeze", effectdata, true, true )
end
function GM:PlayerUnfrozeObject( ply, entity, physobject )
	local effectdata = EffectData()
		effectdata:SetOrigin( physobject:GetPos() )
		effectdata:SetEntity( entity )
	util.Effect( "phys_unfreeze", effectdata, true, true )	
end
function GM:OnPhysgunFreeze( weapon, phys, ent, ply )
	BaseClass.OnPhysgunFreeze( self, weapon, phys, ent, ply )
end
function GM:OnPhysgunReload( weapon, ply )
	local num = ply:PhysgunUnfreeze()
	
	if ( num > 0 ) then
		ply:SendLua( "GAMEMODE:UnfrozeObjects("..num..")" )
	end
end

--Player.lua
function GM:PlayerButtonDown( ply, btn ) 
	numpad.Activate( ply, btn )
end
function GM:PlayerButtonUp( ply, btn ) 
	numpad.Deactivate( ply, btn )
end

local plymeta = FindMetaTable("Player")
function plymeta:GetTool( mode )

	local wep = self:GetWeapon( "gmod_tool" )
	if (!wep || !wep:IsValid()) then return nil end
	
	local tool = wep:GetToolObject( mode )
	if (!tool) then return nil end
	
	return tool

end
