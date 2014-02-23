ENT.Type			= "anim"
ENT.PrintName		 = "Signalling Element"
ENT.Category		= "Metrostroi (utility)"

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

ENT.TrafficLightModels = {}
ENT.RenderOffset = {}
ENT.BasePosition = Vector(-112,32,0)

-- Light indexes
local L_GR	= 1
local L_YR	= 2
local L_YG	= 3
local L_BY	= 4
local L_RY2	= 5
local L_Y2R	= 6
local L_RYG	= 7
local L_BYG	= 8

-- 1 Red
-- 2 Yellow
-- 3 Green
-- 4 Blue
-- 5 Second yellow (flashing yellow)
-- 6 White


--------------------------------------------------------------------------------
-- Inside
--------------------------------------------------------------------------------
ENT.RenderOffset[0] = Vector(0,0,112+32)
ENT.TrafficLightModels[0] = {
	["m1"]	= "models/metrostroi/signals/box.mdl",
	["m2"]	= "models/metrostroi/signals/pole_2.mdl",
	[L_GR]	= { 32, "models/metrostroi/signals/light_2.mdl", {
				[1] = { Vector(8,5,14), Color(255,0,0) },
				[3] = { Vector(8,5,25), Color(0,255,0) }, } },
	[L_YR]	= { 32, "models/metrostroi/signals/light_2.mdl", {
				[1] = { Vector(8,5,14), Color(255,0,0) },
				[2] = { Vector(8,5,25), Color(255,255,0) }, } },
	[L_YG]	= { 32, "models/metrostroi/signals/light_2.mdl", {
				[2] = { Vector(8,5,14), Color(255,255,0) },
				[3] = { Vector(8,5,25), Color(0,255,0) }, } },
	[L_BY]	= { 32, "models/metrostroi/signals/light_2.mdl", {
				[2] = { Vector(8,5,14), Color(255,255,0) },
				[4] = { Vector(8,5,25), Color(32,0,255) }, } },
	[L_RY2]	= { 32, "models/metrostroi/signals/light_2.mdl", {
				[1] = { Vector(8,5,25), Color(255,0,0) },
				[5] = { Vector(8,5,14), Color(255,255,0) }, } },
	[L_Y2R]	= { 32, "models/metrostroi/signals/light_2.mdl", {
				[1] = { Vector(8,5,14), Color(255,0,0) },
				[5] = { Vector(8,5,25), Color(255,255,0) }, } },
	[L_RYG]	= { 40, "models/metrostroi/signals/light_3.mdl", {
				[1] = { Vector(8,5,35), Color(255,0,0) },
				[2] = { Vector(8,5,25), Color(255,255,0) },				
				[3] = { Vector(8,5,14), Color(0,255,0) }, } },
	[L_BYG]	= { 40, "models/metrostroi/signals/light_3.mdl", {
				[4] = { Vector(8,5,35), Color(32,0,255) },
				[2] = { Vector(8,5,25), Color(255,255,0) },				
				[3] = { Vector(8,5,14), Color(0,255,0) }, } },

	--[3] = { 24, "models/metrostroi/signals/light_path.mdl" },
}


--------------------------------------------------------------------------------
-- Outside
--------------------------------------------------------------------------------
ENT.RenderOffset[1] = Vector(-2,0,264)
ENT.TrafficLightModels[1] = {
	["m1"]	= "models/metrostroi/signals/pole_1.mdl",
	[L_GR]	= { 52, "models/metrostroi/signals/light_outside_2.mdl", {
				[1] = { Vector(0,15, 9), Color(255,0,0) },
				[3] = { Vector(0,15,20), Color(0,255,0) }, } },
	[L_YR]	= { 52, "models/metrostroi/signals/light_outside_2.mdl", {
				[1] = { Vector(8,5, 9), Color(255,0,0) },
				[2] = { Vector(8,5,20), Color(255,255,0) }, } },
	[L_YG]	= { 52, "models/metrostroi/signals/light_outside_2.mdl", {
				[2] = { Vector(8,5, 9), Color(255,255,0) },
				[3] = { Vector(8,5,20), Color(0,255,0) }, } },
	[L_BY]	= { 52, "models/metrostroi/signals/light_outside_2.mdl", {
				[2] = { Vector(8,5, 9), Color(255,255,0) },
				[4] = { Vector(8,5,20), Color(32,0,255) }, } },
	[L_RY2]	= { 52, "models/metrostroi/signals/light_outside_2.mdl", {
				[1] = { Vector(8,5,20), Color(255,0,0) },
				[5] = { Vector(8,5, 9), Color(255,255,0) }, } },
	[L_Y2R]	= { 52, "models/metrostroi/signals/light_outside_2.mdl", {
				[1] = { Vector(8,5, 9), Color(255,0,0) },
				[5] = { Vector(8,5,20), Color(255,255,0) }, } },
	[L_RYG]	= { 64, "models/metrostroi/signals/light_outside_3.mdl", {
				[1] = { Vector(0,15,31), Color(255,0,0) },
				[2] = { Vector(0,15,20), Color(255,255,0) },				
				[3] = { Vector(0,15, 9), Color(0,255,0) }, } },
	[L_BYG]	= { 64, "models/metrostroi/signals/light_outside_3.mdl", {
				[4] = { Vector(0,15,31), Color(32,0,255) },
				[2] = { Vector(0,15,20), Color(255,255,0) },				
				[3] = { Vector(0,15, 9), Color(0,255,0) }, } },

	--[3] = { 24, "models/metrostroi/signals/light_path.mdl" },
}


--------------------------------------------------------------------------------
-- Outside box
--------------------------------------------------------------------------------
ENT.RenderOffset[2] = Vector(0,0,112+40)
ENT.TrafficLightModels[2] = {
	["m1"]	= "models/metrostroi/signals/box_outside.mdl",
	["m2"]	= "models/metrostroi/signals/pole_3.mdl",
	[L_GR]	= { 40, "models/metrostroi/signals/light_outside2_2.mdl", {
				[1] = { Vector(10,4,16), Color(255,0,0) },
				[3] = { Vector(10,4,27), Color(0,255,0) }, } },
	[L_YR]	= { 40, "models/metrostroi/signals/light_outside2_2.mdl", {
				[1] = { Vector(10,4,16), Color(255,0,0) },
				[2] = { Vector(10,4,27), Color(255,255,0) }, } },
	[L_YG]	= { 40, "models/metrostroi/signals/light_outside2_2.mdl", {
				[2] = { Vector(10,4,16), Color(255,255,0) },
				[3] = { Vector(10,4,27), Color(0,255,0) }, } },
	[L_BY]	= { 40, "models/metrostroi/signals/light_outside2_2.mdl", {
				[2] = { Vector(10,4,16), Color(255,255,0) },
				[4] = { Vector(10,4,27), Color(32,0,255) }, } },
	[L_RY2]	= { 40, "models/metrostroi/signals/light_outside2_2.mdl", {
				[1] = { Vector(10,4,27), Color(255,0,0) },
				[5] = { Vector(10,4,16), Color(255,255,0) }, } },
	[L_Y2R]	= { 40, "models/metrostroi/signals/light_outside2_2.mdl", {
				[1] = { Vector(10,4,16), Color(255,0,0) },
				[5] = { Vector(10,4,27), Color(255,255,0) }, } },
	[L_RYG]	= { 50, "models/metrostroi/signals/light_outside2_3.mdl", {
				[1] = { Vector(10,4,39), Color(255,0,0) },
				[2] = { Vector(10,4,27), Color(255,255,0) },				
				[3] = { Vector(10,4,16), Color(0,255,0) }, } },
	[L_BYG]	= { 50, "models/metrostroi/signals/light_outside2_3.mdl", {
				[4] = { Vector(10,4,39), Color(32,0,255) },
				[2] = { Vector(10,4,27), Color(255,255,0) },				
				[3] = { Vector(10,4,16), Color(0,255,0) }, } },

	--[3] = { 24, "models/metrostroi/signals/light_path.mdl" },
}




--------------------------------------------------------------------------------
function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "IsolatingJoint", { KeyName = "k1", Edit = {
		title = "Isolating joint",
		category = "Parameters",
		type = "Boolean" } } )
		
	self:NetworkVar("Bool", 1, "ARSSpeedWarning", { KeyName = "k2", Edit = {
		title = "Warn about next limit",
		category = "ARS/ALS",
		type = "Boolean" } } )
		
	self:NetworkVar("Int", 0, "ARSSignals", { KeyName = "k3", Edit = {
		title = "ARS Signals (bits)",
		category = "ARS/ALS",
		type = "Integer" } } )
		
	self:NetworkVar("Int", 1, "TrafficLights", { KeyName = "k4", Edit = {
		title = "Traffic Lights",
		category = "Parameters",
		type = "Integer" } } )
		
	self:NetworkVar("Int", 2, "TrafficLamps")
		
	self:NetworkVar("Int", 3, "LightsStyle", { KeyName = "k6", Edit = {
		title = "Lights Style",
		category = "Parameters",
		type = "Integer" } } )
end

function ENT:CanEditVariables(ply)
	return ply:IsAdmin()
end

function ENT:SetARSSignal(idx,value)
	local packed_value = bit.lshift(value and 1 or 0,idx)
	local mask = bit.bnot(bit.lshift(1,idx))
	self:SetARSSignals(bit.bor(bit.band(self:GetARSSignals(),mask),packed_value))
end

function ENT:GetARSSignal(idx)
	local mask = bit.lshift(1,idx)
	return bit.band(self:GetARSSignals(),mask) ~= 0
end

function ENT:SetTrafficLight(idx,value)
	local packed_value = bit.lshift(value and 1 or 0,idx)
	local mask = bit.bnot(bit.lshift(1,idx))
	self:SetTrafficLights(bit.bor(bit.band(self:GetTrafficLights(),mask),packed_value))
end

function ENT:GetTrafficLight(idx)
	local mask = bit.lshift(1,idx)
	return bit.band(self:GetTrafficLights(),mask) ~= 0
end

function ENT:SetTrafficLamp(idx,value)
	local packed_value = bit.lshift(value and 1 or 0,idx)
	local mask = bit.bnot(bit.lshift(1,idx))
	self:SetTrafficLamps(bit.bor(bit.band(self:GetTrafficLamps(),mask),packed_value))
end

function ENT:GetTrafficLamp(idx)
	local mask = bit.lshift(1,idx)
	return bit.band(self:GetTrafficLamps(),mask) ~= 0
end