TOOL.Category   = "Metro"
TOOL.Name       = "ARS/ALS/Signalling"
TOOL.Command    = nil
TOOL.ConfigName = ""
--TOOL.Tab    = "Wire"

if CLIENT then
	language.Add("Tool.ars.name", "Track Equipment Tool")
	language.Add("Tool.ars.desc", "Adds and modifies ARS/ALS and signalling equipment, signs")
	language.Add("Tool.ars.0", "Primary: Spawn selected entity")
	language.Add("Undone_ars_signalling", "Undone ARS/signalling equipment")
end

TOOL.ClientConVar["entity"] = "isolated_join"

local spawnFunctions = {
	["isolated_join"] = function(ply,pos,ang,trace)
		-- Use some code from rerailer
		local tr = Metrostroi.RerailGetTrackData(pos,ang:Right())
		if not tr then return end

		local ent = ents.Create("gmod_track_ars")
		if IsValid(ent) then
			ent:SetPos(tr.centerpos - ang:Up()*10)
			ent:SetAngles((-tr.right):Angle())
			ent:Spawn()
			ent:SetIsolatingJoint(true)
			return ent
		end
	end,
}

function TOOL:LeftClick(trace)
	if CLIENT then return true end
	
	local ply = self:GetOwner()
	if (ply:IsValid()) and (not ply:IsAdmin()) then return false end
	if not trace then return false end
	if trace.Entity and trace.Entity:IsPlayer() then return false end

	local pos,ang = trace.HitPos,trace.HitNormal:Angle() + Angle(0,0,0)
  
	-- Added players angle
	--if pole_mount == true then
		--local player_angle = player:GetAngles().y
		--player_angle = math.floor(player_angle / 11.25 + 0.5) * 11.25
		--ang.y = ang.y + player_angle
	--end

	-- Spawn track equipment
	local ent
	if spawnFunctions[self:GetClientInfo("entity")] then
		ent = spawnFunctions[self:GetClientInfo("entity")](ply,pos,ang,trace)
	end

	-- Add to undo
	if ent then
		undo.Create("ars_signalling")
			undo.AddEntity(ent)
			undo.SetPlayer(ply)
		undo.Finish()
	end
	return true
end


function TOOL:RightClick(trace)

end

function TOOL:Reload(trace)
	return true
end

function TOOL.BuildCPanel(panel)
	panel:AddControl("Header", { Text = "#Tool.ars.name", Description = "#Tool.track_equipment.desc" })

	panel:AddControl("ComboBox", {
		Label = "Entity to spawn",
		Options = {
			["Isolated join"]		= { ars_entity = "isolated_join" },
		}
	})

	panel:AddControl("Label", {Text = "Quick entity reference"})
	panel:AddControl("Label", {Text = "Isolated join: prevents any signals from crossing this section of track"})
end
