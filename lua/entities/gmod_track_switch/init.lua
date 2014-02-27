AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/metrostroi/signals/box.mdl")
	Metrostroi.DropToFloor(self)
	
	-- Initial state of the switch
	self.AlternateTrack = false
	self.InhibitSwitching = false
	self.LastSignalTime = 0

	-- Find rotating parts which belong to this switch
	local list = ents.FindInSphere(self:GetPos(),256)
	self.TrackSwitches = {}
	for k,v in pairs(list) do
		if (v:GetClass() == "prop_door_rotating") and (string.find(v:GetName(),"switch")) then
			table.insert(self.TrackSwitches,v)

			timer.Simple(0.05,function()
				debugoverlay.Line(v:GetPos(),self:GetPos(),10,Color(255,255,0),true)
			end)
		end
	end

	Metrostroi.UpdateSignalEntities()
end

function ENT:OnRemove()
	Metrostroi.UpdateSignalEntities()
end

function ENT:SendSignal(index,channel)
	if channel ~= self:GetChannel() then return end
	
	-- Switch to alternate track
	if index == "alt" then self.AlternateTrack = true end
	-- Switch to main track
	if index == "main" then self.AlternateTrack = false end
	
	-- Remember this signal
	self.LastSignalTime = CurTime()
end

function ENT:GetSignal()
	if self.InhibitSwitching and self.AlternateTrack then return 1 end
	if self.AlternateTrack then return 3 end
	return 0
end

function ENT:Think()
	-- Reset
	self.InhibitSwitching = false
	
	-- Check if local section of track is occupied or no
	local pos = self.TrackPosition
	if pos then
		local trackOccupied = Metrostroi.IsTrackOccupied(pos.node1,pos.x,pos.forward)
		if trackOccupied then -- Prevent track switches from working when there's a train on segment
			self.InhibitSwitching = true
		end
	end
	
	-- Force door state state
	if self.AlternateTrack then
		for k,v in pairs(self.TrackSwitches) do v:Fire("Open","","0") end
	else
		for k,v in pairs(self.TrackSwitches) do v:Fire("Close","","0") end
	end
	
	-- Return switch to original position
	if (self.InhibitSwitching == false) and (self.AlternateTrack == true) and 
	   (CurTime() - self.LastSignalTime > 20.0) then
		self:SendSignal("main",self:GetChannel())
	end
	
	-- Process logic
	self:NextThink(CurTime() + 1.0)
	return true
end