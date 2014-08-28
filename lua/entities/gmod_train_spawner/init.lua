AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString "MetrostroiTrainSpawner"
local function ShowWindowOnCL(ply, id)
	net.Start "MetrostroiTrainSpawner"
	net.Send(ply)
end

function ENT:SpawnFunction(ply, tr)
	ShowWindowOnCL(ply)
end