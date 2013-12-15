AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
util.AddNetworkString("gmod_track_dispatcher-setupmessage")
util.AddNetworkString("gmod_track_dispatcher-updatemessage")


function ENT:Initialize()
	self:SetModel("models/props/cs_office/TV_plasma.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	
	net.Start("gmod_track_dispatcher-setupmessage")
	
	local function getSignDataAsTable(sign)
		return {
			["Index"] = sign.Index, 
			["AlternateIndex"] = sign.AlternateIndex,
			["NextIndex"] = sign.NextIndex,
			["PreviousIndex"] = sign.PreviousIndex,
			["Pos"] = sign:GetPos()
		}
	end
	
	local r = {}
	
	//For every sign, indexed by section
	for section, sign in pairs(Metrostroi.PicketSignByIndex) do
		r[section] = getSignDataAsTable(sign)
		
	end
	
	//PicketSignByIndex
	net.WriteTable(r)
	
	
	//Paths
	local r = {}
	
	//For every path
	for k,v in ipairs(Metrostroi.Paths) do
		r[k]={}
		r[k].Loops=v.Loops
		r[k].Length=v.Length
		
		r[k].Signs={}
		
		//For every sign
		for signindex, sign in pairs(v.Signs) do
			r[k].Signs[signindex]= sign.Index 
			//Only send the index, the client can get the full data from signByIndex
		end
	end
	
	net.WriteTable(r)
	
	//Boring tables
	net.WriteTable(Metrostroi.SectionLength)
	net.WriteTable(Metrostroi.SectionOffset)
	
	net.Broadcast()
	-------------------------------------
	/*
	Metrostroi.PositionCallbacks["dispatcher_update"] = function( ent, pos)
		//net.Start("gmod_track_dispatcher-updatemessage")
		//net.WriteTable(pos)``
		PrintTable(ent:GetTable())
		print(ent)
		print("Received callback")
	end
	print("Registered callback")
	*/
	
end

function ENT:Think()
	self:NextThink(CurTime () + 2.0)
	
	local trains = {}
	for k,v in pairs(Metrostroi.TrainPositions) do
		trains[v.section] = true
	end
	
	local signs = {}
	for k,v in pairs(Metrostroi.PicketSigns) do
		if v.AlternateIndex then
			signs[v.Index]=v:GetTrackSwitchState() //True for alternative path
		end
	end
	
	net.Start("gmod_track_dispatcher-updatemessage")
	net.WriteTable(trains)
	net.WriteTable(signs)
	net.SendPVS(self:GetPos())
	
	
	return true
end

function ENT:Use( activator, caller )
	//PrintTable(Metrostroi.PicketSigns)
	
	/*
	for k,v in pairs(Metrostroi.PicketSigns) do
		if v.AlternateIndex then
			print(v:GetTrackSwitchState()) //True for alternative path
		end
	end
	*/
end
