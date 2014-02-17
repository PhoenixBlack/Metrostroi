AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")


--------------------------------------------------------------------------------
-- Initialize the platform data
--------------------------------------------------------------------------------
function ENT:Initialize()
	-- Get platform parameters
	self.VMF = self.VMF or {}
	self.PlatformStart		= ents.FindByName(self.VMF.PlatformStart or "")[1]
	self.PlatformEnd		= ents.FindByName(self.VMF.PlatformEnd or "")[1]
	self.StationIndex		= tonumber(self.VMF.StationIndex) or 100
	self.PopularityIndex	= self.VMF.PopularityIndex or 1.0
	self.PlatformLast		= (self.VMF.PlatformLast == "yes")
	self.PlatformX0			= self.VMF.PlatformX0 or 0.80
	self.PlatformSigma		= self.VMF.PlatformSigma or 0.25
	
	if not self.PlatformStart then
		self.VMF.PlatformStart 	= "station"..self.StationIndex.."_"..(self.VMF.PlatformStart or "")
		self.PlatformStart		= ents.FindByName(self.VMF.PlatformStart or "")[1]
	end
	if not self.PlatformEnd then
		self.VMF.PlatformEnd 	= "station"..self.StationIndex.."_"..(self.VMF.PlatformEnd or "")
		self.PlatformEnd		= ents.FindByName(self.VMF.PlatformEnd or "")[1]
	end
	
	-- Drop to floor
	self:DropToFloor()
	if IsValid(self.PlatformStart) then self.PlatformStart:DropToFloor() end
	if IsValid(self.PlatformEnd) then self.PlatformEnd:DropToFloor() end
	
	-- Positions
	if IsValid(self.PlatformStart) then
		self.PlatformStart = self.PlatformStart:GetPos()
	else
		self.PlatformStart = Vector(0,0,0)
	end
	if IsValid(self.PlatformEnd) then
		self.PlatformEnd = self.PlatformEnd:GetPos()
	else
		self.PlatformEnd = Vector(0,0,0)
	end

	-- Initial platform pool configuration
	self.WindowStart = 0  -- Increases when people board train
	self.WindowEnd = 0 -- Increases naturally over time
	
	-- Send things to client
	self:SetNWFloat("X0",self.PlatformX0)
	self:SetNWFloat("Sigma",self.PlatformSigma)
	self:SetNWInt("WindowStart",self.WindowStart)
	self:SetNWInt("WindowEnd",self.WindowEnd)
	self:SetNWVector("PlatformStart",self.PlatformStart)
	self:SetNWVector("PlatformEnd",self.PlatformEnd)
	self:SetNWVector("StationCenter",self:GetPos())
	
	-- FIXME make this nicer
	for i=1,32 do self:SetNWVector("TrainDoor"..i,Vector(0,0,0)) end
	self:SetNWInt("TrainDoorCount",0)
end


--------------------------------------------------------------------------------
-- Load key-values defined in VMF
--------------------------------------------------------------------------------
function ENT:KeyValue(key, value)
	self.VMF = self.VMF or {}
	self.VMF[key] = value
end


--------------------------------------------------------------------------------
-- Process platform logic
--------------------------------------------------------------------------------
function erf(x)
	local a1 =  0.254829592
	local a2 = -0.284496736
	local a3 =  1.421413741
	local a4 = -1.453152027
	local a5 =  1.061405429
	local p  =  0.3275911

	-- Save the sign of x
	sign = 1
	if x < 0 then sign = -1 end
	x = math.abs(x)

	-- A&S formula 7.1.26
	t = 1.0/(1.0 + p*x)
	y = 1.0 - (((((a5*t + a4)*t) + a3)*t + a2)*t + a1)*t*math.exp(-x*x)

    return sign*y
end
local function CDF(x,x0,sigma) return 0.5 * (1 + erf((x - x0)/math.sqrt(2*sigma^2))) end
local function merge(t1,t2) for k,v in pairs(t2) do t1[k] = v end end

function ENT:Think()
	-- Find all potential trains
	local trains = {}
	for k,v in pairs(Metrostroi.TrainClasses) do
		merge(trains,ents.FindByClass(v)) 
	end
	
	-- Update window
	self.TotalCount = self.WindowEnd - self.WindowStart
	if self.WindowStart > self.WindowEnd then self.TotalCount = (self:PoolSize() - self.WindowStart) + self.WindowEnd end	
	-- Send update to client
	self:SetNWInt("WindowStart",self.WindowStart)
	self:SetNWInt("WindowEnd",self.WindowEnd)
	
	-- Check if any trains are at the platform
	local platformStart	= self.PlatformStart
	local platformEnd	= self.PlatformEnd
	local platformDir   = platformEnd-platformStart
	local platformNorm	= platformDir:GetNormalized()

	local boardingDoorList = {}
	for k,v in pairs(trains) do
		local platform_distance	= ((platformStart-v:GetPos()) - ((platformStart-v:GetPos()):Dot(platformNorm))*platformNorm):Length()
		local train_start		= (v:GetPos() + v:GetAngles():Forward()*480 - platformStart):Dot(platformDir) / (platformDir:Length()^2)
		local train_end			= (v:GetPos() - v:GetAngles():Forward()*480 - platformStart):Dot(platformDir) / (platformDir:Length()^2)
		local left_side			= train_start > train_end
		local doors_open 		= (left_side and v.LeftDoorsOpen) or ((not left_side) and v.RightDoorsOpen)
		
		if (train_start < 0) and (train_end < 0) then doors_open = false end
		if (train_start > 1) and (train_end > 1) then doors_open = false end
		
		if (platform_distance < 256) and (doors_open) then
			-- Limit train to platform	
			train_start = math.max(0,math.min(1,train_start))
			train_end = math.max(0,math.min(1,train_end))
		
			-- Check if this was the last stop
			if v.LastPlatform ~= self then v.LastPlatform = self end
			
			-- Calculate number of passengers near the train
			local passenger_density = math.abs(CDF(train_start,self.PlatformX0,self.PlatformSigma) - CDF(train_end,self.PlatformX0,self.PlatformSigma))
			local passenger_count = passenger_density * self.TotalCount
			
			-- Get number of doors
			local door_count = #v.LeftDoorPositions
			if not left_side then door_count = #v.RightDoorPositions end
			
			-- Get maximum boarding rate for normal russian subway train doors
			local max_boarding_rate = 2.5 * door_count
			-- Get boarding rate based on passenger density
			local boarding_rate = math.min(max_boarding_rate,passenger_count)
			if self.PlatformLast then boarding_rate = 0 end
			-- Get rate of leaving
			local leaving_rate = 0
			if self.PlatformLast then leaving_rate = 2*max_boarding_rate end
			
			-- Board these passengers into train
			local passenger_delta = 
				math.min(math.max(1,math.floor(boarding_rate+0.5)),self.TotalCount) - 
				math.min(math.max(1,math.floor(leaving_rate+0.5)),v:GetPassengerCount())				
			if v:GetPassengerCount() < v:PassengerCapacity() then
				v:SetPassengerCount(v:GetPassengerCount() + passenger_delta)
			end
			if passenger_delta > 0 then
				self.WindowStart = (self.WindowStart + passenger_delta) % self:PoolSize()
			end
			
			if left_side then
				for k,vec in pairs(v.LeftDoorPositions) do table.insert(boardingDoorList,v:LocalToWorld(vec)) end
			else
				for k,vec in pairs(v.RightDoorPositions) do table.insert(boardingDoorList,v:LocalToWorld(vec)) end
			end
			-- Add doors to boarding list
			--print("BOARDING",boarding_rate,"DELTA = "..passenger_delta,self.PlatformLast,v:GetPassengerCount())
		end
	end
	
	-- Add passengers
	if (not self.PlatformLast) and (#boardingDoorList == 0) then
		local target = 300
		if self.StationIndex == 111 then target = 100 end
		if self.StationIndex == 112 then target = 150 end
		if self.StationIndex == 113 then target = 150 end
		if self.StationIndex == 114 then target = 50 end
		if self.StationIndex == 115 then target = 0 end
		if self.StationIndex == 116 then target = 200 end
		
		local growthDelta = math.max(0,(target-self.TotalCount)*0.005)
		if growthDelta < 1.0 then
			self.Accum = (self.Accum or 0) + growthDelta
			if self.Accum > 1.0 then
				growthDelta = 1
				self.Accum = 0
			end
		end
		self.WindowEnd = (self.WindowEnd + math.floor(growthDelta+0.5)) % self:PoolSize()
		--print("BORNS",self,growthDelta)
	end
	
	-- Send boarding list FIXME make this nicer
	for k,v in ipairs(boardingDoorList) do
		self:SetNWVector("TrainDoor"..k,v)
	end
	self:SetNWInt("TrainDoorCount",#boardingDoorList)
	self:NextThink(CurTime() + 1.00)
	return true
end
