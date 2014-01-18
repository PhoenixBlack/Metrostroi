local Debugger = {}
Debugger.Clients = {}

util.AddNetworkString("metrostroi-debugger-dataupdate")
util.AddNetworkString("metrostroi-debugger-entremoved")
CreateConVar("metroistroi-debugger-updaterate",1,0,"Seconds between debugger data messages")

--Add a new client to send an entities debugvars to
local function AddClient(ply,ent)
	if not Debugger.Clients[ply] then
		Debugger.Clients[ply]={}
	end
	table.insert(Debugger.Clients[ply],ent)
end

local function RemoveEnt(ply,ent)
	if ply and Debugger.Clients[ply] then
		if ent then
			table.RemoveByValue(Debugger.Clients[ply],ent)
		else
			Debugger.Clients[ply]=nil
		end
	else
		for k,v in pairs(Debugger.Clients) do
			table.RemoveByValue(v,ent)
		end
	end
end

--Handler for adding new ents to listen to
local function cmdinithandler(ply,cmd,args,fullstring)
	local ent = ply:GetEyeTrace().Entity
	if not IsValid(ent) or not ent.GetDebugVars then return end

	AddClient(ply,ent)
end
concommand.Add("metrostroi_debugtrainsystems", cmdinithandler, nil, "Add aimed at entity to debugger")

-- Automatically engage debugger for train owner
function Metrostroi.DebugTrain(train,ply)
	if not ply then ply = train:GetOwner() end
	if (not IsValid(train)) or (not IsValid(ply)) then return end

	AddClient(ply,train)
end

local nextthink = 0
local function think()
	if CurTime() < nextthink then return end
	nextthink = CurTime() + GetConVarNumber("metroistroi-debugger-updaterate")
	--Loop over clients and their ents and send the collected data
	
	--For every player
	for ply,entlist in pairs(Debugger.Clients) do
	
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

local function OnEntRemove(ent)
	RemoveEnt(nil,ent)
	
	--Client doesn't get all removed ents, broadcast it manually to all
	net.Start("metrostroi-debugger-entremoved")
	net.WriteInt(ent:EntIndex(),16)
	net.Broadcast()
end

hook.Add("EntityRemoved","metrostroi-debugger-cleanup",OnEntRemove)
hook.Add("PlayerDisconnected","metrstroi-debugger-plycleanup",RemoveEnt)
