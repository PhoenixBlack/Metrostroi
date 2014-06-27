TOOL.Category   = "Metro"
TOOL.Name       = "Train Feature Editor"
TOOL.Command    = nil
TOOL.ConfigName = ""

if CLIENT then
	language.Add("Tool.switch.name", "Train Feature Editor")
	language.Add("Tool.switch.desc", "Change features of the target train")
	language.Add("Tool.switch.0", "Primary: Apply selected features to the train")
end

TOOL.ClientConVar["ars"] = 0
TOOL.ClientConVar["skin"] = 0
TOOL.ClientConVar["valve"] = 0
TOOL.ClientConVar["model"] = 0

function TOOL:LeftClick(trace)
	if CLIENT then return true end
	
	local ply = self:GetOwner()
	if (ply:IsValid()) and (not ply:IsAdmin()) then return false end
	if not trace then return false end
	if trace.Entity and trace.Entity:IsPlayer() then return false end
	if not Metrostroi.IsTrainClass[trace.Entity:GetClass()] then return false end
	
	local train = trace.Entity
	train:SetSkin(self:GetClientNumber("skin"))
	train.Pneumatic.ValveType = (self:GetClientNumber("valve") == 0) and 1 or 2
	train.ARSType = self:GetClientNumber("ars")+1
	train:SetNWInt("ARSType",train.ARSType)
	
	if train:GetClass() == "gmod_subway_81-717" then
		train.TrainModel = 1+self:GetClientNumber("model")
		if train.TrainModel == 1 then
			train:SetModel("models/metrostroi/81/81-717a.mdl")
		else
			train:SetModel("models/metrostroi/81/81-717b.mdl")
		end
	end
	
	--Entity:SetSkin(
	--[[local entlist = ents.FindInSphere(trace.HitPos,64)
	for k,v in pairs(entlist) do
		if v:GetClass() == "gmod_track_switch" then
			v:SetChannel(1)
			print("Set channel 1")
		end
	end]]--
	return true
end

function TOOL:RightClick(trace)
	return true
end

function TOOL.BuildCPanel(panel)
	panel:AddControl("Header", { Text = "#Tool.switch.name", Description = "#Tool.switch.desc" })

	panel:AddControl("ComboBox", {
		Label = "ARS panel type",
		Options = {
			["Moscow/default"]	= { train_edit_ars = 0 },
			["Classic"]			= { train_edit_ars = 1 },
			["Petersburg/Kyiv"]	= { train_edit_ars = 2 },
		}
	})

	panel:AddControl("ComboBox", {
		Label = "Train skin",
		Options = {
			["Default (Moscow)"]	= { train_edit_skin = 0 },
			["Alternative 1"]		= { train_edit_skin = 1 },
			["Alternative 2"]		= { train_edit_skin = 2 },
		}
	})

	panel:AddControl("ComboBox", {
		Label = "Drivers valve type",
		Options = {
			["334"]	= { train_edit_valve = 0 },
			["013"]	= { train_edit_valve = 1 },
		}
	})

	panel:AddControl("ComboBox", {
		Label = "81-717 front mask type",
		Options = {
			["1-4-1"]	= { train_edit_model = 0 },
			["2-2-2"]	= { train_edit_model = 1 },
		}
	})
end
