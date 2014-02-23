TOOL.Category   = "Metro"
TOOL.Name       = "Signalling Tool"
TOOL.Command    = nil
TOOL.ConfigName = ""
--TOOL.Tab    = "Wire"

if CLIENT then
	language.Add("Tool.signalling.name", "Signalling Tool")
	language.Add("Tool.signalling.desc", "Adds and modifies signalling equipment (ARS/ALS) or signs")
	language.Add("Tool.signalling.0", "Primary: Spawn selected signalling entity (point at the inner side of rail)\nSecondary: Spawn selected sign")
	language.Add("Undone_signalling", "Undone ARS/signalling equipment")
end

TOOL.ClientConVar["sign"] = ""
TOOL.ClientConVar["light"] = 0
TOOL.ClientConVar["light0"] = 0
TOOL.ClientConVar["light1"] = 0
TOOL.ClientConVar["light2"] = 0
TOOL.ClientConVar["light3"] = 0
TOOL.ClientConVar["light4"] = 0
TOOL.ClientConVar["light5"] = 0
TOOL.ClientConVar["light6"] = 0
TOOL.ClientConVar["light7"] = 0

TOOL.ClientConVar["isolated"] = 1
TOOL.ClientConVar["ars0"] = 0
TOOL.ClientConVar["ars1"] = 0
TOOL.ClientConVar["ars2"] = 0
TOOL.ClientConVar["ars3"] = 0
TOOL.ClientConVar["ars4"] = 0
TOOL.ClientConVar["ars5"] = 0
TOOL.ClientConVar["ars_speedwarn"] = 0

function TOOL:LeftClick(trace)
	if CLIENT then return true end
	
	local ply = self:GetOwner()
	if (ply:IsValid()) and (not ply:IsAdmin()) then return false end
	if not trace then return false end
	if trace.Entity and trace.Entity:IsPlayer() then return false end

	local pos,ang = trace.HitPos,trace.HitNormal:Angle() + Angle(0,0,0)
  
	-- Use some code from rerailer
	local tr = Metrostroi.RerailGetTrackData(pos,ang:Right())
	if not tr then return end

	-- Create signal entity
	local ent = ents.Create("gmod_track_signal")
	if IsValid(ent) then
		ent:SetPos(tr.centerpos - ang:Up()*10)
		ent:SetAngles((-tr.right):Angle())
		ent:Spawn()
		ent:SetIsolatingJoint(self:GetClientNumber("isolated") > 0.5)
		
		ent:SetLightsStyle(self:GetClientNumber("light"))
		ent:SetTrafficLight(0,self:GetClientNumber("light0") > 0.5)
		ent:SetTrafficLight(1,self:GetClientNumber("light1") > 0.5)
		ent:SetTrafficLight(2,self:GetClientNumber("light2") > 0.5)
		ent:SetTrafficLight(3,self:GetClientNumber("light3") > 0.5)
		ent:SetTrafficLight(4,self:GetClientNumber("light4") > 0.5)
		ent:SetTrafficLight(5,self:GetClientNumber("light5") > 0.5)
		ent:SetTrafficLight(6,self:GetClientNumber("light6") > 0.5)
		ent:SetTrafficLight(7,self:GetClientNumber("light7") > 0.5)
		
		ent:SetARSSpeedWarning(self:GetClientNumber("ars_speedawrn") > 0.5)
		ent:SetARSSignal(0,self:GetClientNumber("ars0") > 0.5)
		ent:SetARSSignal(1,self:GetClientNumber("ars1") > 0.5)
		ent:SetARSSignal(2,self:GetClientNumber("ars2") > 0.5)
		ent:SetARSSignal(3,self:GetClientNumber("ars3") > 0.5)
		ent:SetARSSignal(4,self:GetClientNumber("ars4") > 0.5)
		ent:SetARSSignal(5,self:GetClientNumber("ars5") > 0.5)
	end

	-- Add to undo
	undo.Create("signalling")
		undo.AddEntity(ent)
		undo.SetPlayer(ply)
	undo.Finish()
	return true
end


function TOOL:RightClick(trace)

end

function TOOL:Reload(trace)
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
		Label = "Isolated joint between rails",
		Command = "signalling_isolated"
	})
	
	panel:AddControl("Label", {Text = "Traffic light configuration:"})
	panel:AddControl("ComboBox", {
		Label = "Style",
		Options = {
			["Inside"]			= { signalling_light = 0 },
			["Outside Pole"]	= { signalling_light = 1 },
			["Outside Box"]		= { signalling_light = 2 },
			["Outside Depot"]	= { signalling_light = 3 },
		}
	})
	panel:AddControl("Checkbox", { Label = "G-R",	Command = "signalling_light0" })
	panel:AddControl("Checkbox", { Label = "Y-R",	Command = "signalling_light1" })
	panel:AddControl("Checkbox", { Label = "Y-G",	Command = "signalling_light2" })
	panel:AddControl("Checkbox", { Label = "B-Y",	Command = "signalling_light3" })
	panel:AddControl("Checkbox", { Label = "R-Y2",	Command = "signalling_light4" })
	panel:AddControl("Checkbox", { Label = "Y2-R",	Command = "signalling_light5" })
	panel:AddControl("Checkbox", { Label = "R-Y-G",	Command = "signalling_light6" })
	panel:AddControl("Checkbox", { Label = "B-Y-G",	Command = "signalling_light7" })

	panel:AddControl("Label", {Text = "ARS signals in the following segment:"})
	panel:AddControl("Checkbox", { Label = "(75  Hz) 80 KM/H", Command = "signalling_ars0" })
	panel:AddControl("Checkbox", { Label = "(125 Hz) 70 KM/H", Command = "signalling_ars1" })
	panel:AddControl("Checkbox", { Label = "(175 Hz) 60 KM/H", Command = "signalling_ars2" })
	panel:AddControl("Checkbox", { Label = "(225 Hz) 40 KM/H", Command = "signalling_ars3" })
	panel:AddControl("Checkbox", { Label = "(275 Hz)  0 KM/H", Command = "signalling_ars4" })
	panel:AddControl("Checkbox", { Label = "(325 Hz) Special", Command = "signalling_ars5" })
	panel:AddControl("Checkbox", {
		Label = "Include signal about speed limit in next segment",
		Command = "signalling_ars_speedwarn"
	})
end
