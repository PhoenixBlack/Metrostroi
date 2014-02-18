
local plymeta = FindMetaTable("Player")
function plymeta:AddCount() end
function plymeta:CheckLimit() end
function plymeta:GetCount() end
function plymeta:LimitHit() end
function plymeta:AddCleanup() end
function plymeta:SendHint() end
function plymeta:SuppressHint() end

if CLIENT then
	function plymeta:GetTool( mode )

		local wep
		for _, ent in pairs( ents.FindByClass( "gmod_tool" ) ) do
			if ( ent:GetOwner() == self ) then wep = ent break end
		end
		if (!wep || !wep:IsValid()) then return nil end
		
		local tool = wep:GetToolObject( mode )
		if (!tool) then return nil end
		
		return tool

	end
end
