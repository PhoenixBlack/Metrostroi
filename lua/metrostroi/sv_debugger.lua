local Debugger = {}
Debugger.Clients = {}

util.AddNetworkString("metrostroi-debugger-dataupdate")


--Add a new client to send an entities debugvars to
local function AddClient(ply,ent)
	if not Debugger.Clients[ply] then
		Debugger.Clients[ply]={}
	end
	table.insert(Debugger.Clients[ply],ent)
end

--Handler for adding new ents to listen to
local function cmdinithandler(ply,cmd,args,fullstring)
	local ent = ply:GetEyeTrace().Entity
	if not IsValid(ent) or not ent.GetDebugVars then return end

	AddClient(ply,ent)
end
concommand.Add("metrostroi_debugtrainsystems", cmdinithandler, nil, "Add aimed at entity to debugger")

local function think()

	

	--Loop over clients and their ents and send the collected data
	
	--For every player
	for ply,entlist in pairs(Debugger.Clients) do
	
		--For every entity: Remove reference if invalid
		for k,ent in pairs(entlist) do
			if not IsValid(ent) then
				table.RemoveByValue(entlist,ent)
			end
		end
	
		net.Start("metrostroi-debugger-dataupdate")
			local count = table.Count(entlist)
			net.WriteInt(count,8)
			for k,ent in pairs(entlist) do
				net.WriteTable({ent:EntIndex(),ent:GetDebugVars()})
			end
		net.Send(ply)
	end
	
end
hook.Add("Think","metrostroi-debugger-think",think)
