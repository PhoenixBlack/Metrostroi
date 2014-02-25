TOOL.Category   = "Metro"
TOOL.Name       = "Signalling Tool"
TOOL.Command    = nil
TOOL.ConfigName = ""
--TOOL.Tab    = "Wire"

if CLIENT then
	language.Add("Tool.signalling.name", "Signalling Tool")
	language.Add("Tool.signalling.desc", "Adds and modifies signalling equipment (ARS/ALS) or signs")
	language.Add("Tool.signalling.0", "Primary: Spawn/update selected signalling entity (point at the inner side of rail)\nReload: Update only ARS/light settings\nSecondary: Spawn selected sign")
	language.Add("Undone_signalling", "Undone ARS/signalling equipment")
end

TOOL.ClientConVar["sign"] = ""
TOOL.ClientConVar["light_style"] = 0
for i=0,31 do
	TOOL.ClientConVar["light"..i] = 0
end
for i=0,31 do
	TOOL.ClientConVar["settings"..i] = 0
end

function TOOL:SpawnEnt(ply,trace,param)
	local pos = trace.HitPos
  
	-- Use some code from rerailer --
	local tr = Metrostroi.RerailGetTrackData(pos,ply:GetAimVector())
	if not tr then return end

	-- Create signal entity
	local ent
	local found = false
	local entlist = ents.FindInSphere(pos,64)
	for k,v in pairs(entlist) do
		if v:GetClass() == "gmod_track_signal" then
			ent = v
			found = true
		end
	end	
	if not ent then ent = ents.Create("gmod_track_signal") end
	if IsValid(ent) then
		if param ~= 2 then 
			ent:SetPos(tr.centerpos - tr.up * 9.5)
			ent:SetAngles((-tr.right):Angle())
		end
		if not found then ent:Spawn() end

		if param ~= 2 then 
			ent:SetLightsStyle(self:GetClientNumber("light_style"))
		end
		for i=0,31 do
			if param ~= 2 then 
				ent:SetTrafficLightsBit(i,self:GetClientNumber("light"..i) > 0.5)
			end
		end
		for i=0,31 do
			ent:SetSettingsBit(i,self:GetClientNumber("settings"..i) > 0.5)
		end
	end
	return ent
end

function TOOL:LeftClick(trace)
	if CLIENT then return true end
	
	local ply = self:GetOwner()
	if (ply:IsValid()) and (not ply:IsAdmin()) then return false end
	if not trace then return false end
	if trace.Entity and trace.Entity:IsPlayer() then return false end

	local ent = self:SpawnEnt(ply,trace)

	-- Add to undo
	undo.Create("signalling")
		undo.AddEntity(ent)
		undo.SetPlayer(ply)
	undo.Finish()
	return true
end


function TOOL:RightClick(trace)
	if CLIENT then return true end
	
	local ply = self:GetOwner()
	if (ply:IsValid()) and (not ply:IsAdmin()) then return false end
	if not trace then return false end
	if trace.Entity and trace.Entity:IsPlayer() then return false end

	local entlist = ents.FindInSphere(trace.HitPos,64)
	for k,v in pairs(entlist) do
		if v:GetClass() == "gmod_track_signal" then
			if v then SafeRemoveEntity(v) end
		end
	end	
	return true
end

function TOOL:Reload(trace)
	if CLIENT then return true end
	
	local ply = self:GetOwner()
	if (ply:IsValid()) and (not ply:IsAdmin()) then return false end
	if not trace then return false end
	if trace.Entity and trace.Entity:IsPlayer() then return false end

	local ent = self:SpawnEnt(ply,trace,2)

	-- Add to undo
	undo.Create("signalling")
		undo.AddEntity(ent)
		undo.SetPlayer(ply)
	undo.Finish()
	return true
end

function TOOL.BuildCPanel(panel)
	panel:AddControl("Header", { Text = "#Tool.signalling.name", Description = "#Tool.signalling.desc" })

	panel:AddControl("ComboBox", {
		Label = "Sign (right click spawn)",
		Options = {
			["60 KM/H"]		= { signalling_sign = "a" },
		}
	})
	
	panel:AddControl("Checkbox", {
		Label = "Isolated joint for traffic lights",
		Command = "signalling_settings16"
	})
	panel:AddControl("Checkbox", {
		Label = "Isolated joint for track switches",
		Command = "signalling_settings17"
	})
	
	panel:AddControl("Label", {Text = "Traffic lights configuration:"})
	panel:AddControl("ComboBox", {
		Label = "Style",
		Options = {
			["Inside"]			= { signalling_light_style = 0 },
			["Outside Pole"]	= { signalling_light_style = 1 },
			["Outside Box"]		= { signalling_light_style = 2 },
			["Outside Depot"]	= { signalling_light_style = 3 },
		}
	})
	panel:AddControl("Checkbox", { Label = "Red-Green",			Command = "signalling_light0" })
	panel:AddControl("Checkbox", { Label = "Red-Yellow",		Command = "signalling_light1" })
	panel:AddControl("Checkbox", { Label = "Green-Yellow",		Command = "signalling_light2" })
	panel:AddControl("Checkbox", { Label = "Blue-Yellow",		Command = "signalling_light3" })
	panel:AddControl("Checkbox", { Label = "Red-Yellow2",		Command = "signalling_light4" })
	panel:AddControl("Checkbox", { Label = "Yellow2-Red",		Command = "signalling_light5" })
	panel:AddControl("Checkbox", { Label = "Red-Yellow-Green",	Command = "signalling_light6" })
	panel:AddControl("Checkbox", { Label = "Blue-Yellow-Green",	Command = "signalling_light7" })
	
	panel:AddControl("Label", {Text = "Common configurations:"})
	panel:AddControl("Label", {Text = "[B-Y-G R-Y2] Track Switch"})
	panel:AddControl("Label", {Text = "[B-Y R-G] Station departure"})
	
	panel:AddControl("Label", {Text = "Traffic lights settings:"})
	panel:AddControl("Checkbox", { Label = "Always red (OP)", Command = "signalling_settings8" })
	panel:AddControl("Checkbox", { Label = "Red when alternate track", Command = "signalling_settings9" })
	panel:AddControl("Checkbox", { Label = "Red when main track", Command = "signalling_settings10" })

	panel:AddControl("Label", {Text = "ARS signals in the following segment:"})
	panel:AddControl("Checkbox", { Label = "(75  Hz) 80 KM/H", Command = "signalling_settings0" })
	panel:AddControl("Checkbox", { Label = "(125 Hz) 70 KM/H", Command = "signalling_settings1" })
	panel:AddControl("Checkbox", { Label = "(175 Hz) 60 KM/H", Command = "signalling_settings2" })
	panel:AddControl("Checkbox", { Label = "(225 Hz) 40 KM/H", Command = "signalling_settings3" })
	panel:AddControl("Checkbox", { Label = "(275 Hz)  0 KM/H", Command = "signalling_settings4" })
	panel:AddControl("Checkbox", { Label = "(325 Hz) Special", Command = "signalling_settings5" })
	--[[panel:AddControl("Checkbox", {
		Label = "Include signal about speed limit in next segment",
		Command = "signalling_settings17"
	})]]--
end
