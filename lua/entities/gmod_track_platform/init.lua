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
	self.StationIndex		= self.VMF.StationIndex or 100
	self.PopularityIndex	= self.VMF.PopularityIndex or 1.0
	self.PlatformLast		= (self.VMF.PlatformLast == "yes")
	
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
	self:SetNWInt("WindowStart",self.WindowStart)
	self:SetNWInt("WindowEnd",self.WindowEnd)
	self:SetNWVector("PlatformStart",self.PlatformStart)
	self:SetNWVector("PlatformEnd",self.PlatformEnd)
	self:SetNWVector("StationCenter",self:GetPos())
end


--------------------------------------------------------------------------------
-- Load key-values defined in VMF
--------------------------------------------------------------------------------
function ENT:KeyValue(key, value)
  self.VMF = self.VMF or {}
  self.VMF[key] = value
  print("Station",key,"=",value)
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
	merge(trains,ents.FindByClass("gmod_subway_em508")) 
	merge(trains,ents.FindByClass("gmod_subway_em509"))
	merge(trains,ents.FindByClass("gmod_subway_ema"))
	
	-- Update window
	self.WindowStart = 0
	self.WindowEnd = 200
	self.TotalCount = self.WindowEnd - self.WindowStart
	if self.WindowStart > self.WindowEnd then self.TotalCount = (self:PoolSize() - self.WindowStart) + self.WindowEnd end
	
	-- Parameters of platform distribution
	local x0 = 0.50
	local sigma = 0.25
	
	-- Check if any trains are at the platform
	local platformStart	= self.PlatformStart
	local platformEnd	= self.PlatformEnd
	local platformDir   = platformEnd-platformStart
	local platformNorm	= platformDir:GetNormalized()
	
	for k,v in pairs(trains) do
		local platform_distance	= ((platformStart-v:GetPos()) - ((platformStart-v:GetPos()):Dot(platformNorm))*platformNorm):Length()
		local train_start		= (v:GetPos() + v:GetAngles():Forward()*480 - platformStart):Dot(platformDir) / (platformDir:Length()^2)
		local train_end			= (v:GetPos() - v:GetAngles():Forward()*480 - platformStart):Dot(platformDir) / (platformDir:Length()^2)
		local left_side			= train_start > train_end
		
		if platform_distance < 256 then
			local doors_open = (left_side and v.LeftDoorsOpen) or ((not left_side) and v.RightDoorsOpen)
			local passenger_density = math.abs(CDF(train_start,x0,sigma) - CDF(train_end,x0,sigma))
			local passenger_count = math.floor(0.5 + passenger_density * self.TotalCount)
			print("People",self.TotalCount,passenger_count)
			print(v,doors_open,platform_distance,train_start,train_end)
		end
	end
	
	
	--[[self.WindowEnd = (CurTime()*1) % self:PoolSize()
	local v = self.WindowEnd - 50 -- 200*math.floor(math.abs(math.sin(CurTime()*0.1)))
	if v < 0 then v = v + self:PoolSize() end
	self.WindowStart = (v) % self:PoolSize()
	
	-- Send things to client
	self:SetNWInt("WindowStart",self.WindowStart)
	self:SetNWInt("WindowEnd",self.WindowEnd)
	print(self.WindowStart,self.WindowEnd)]]--
	
	self:SetNWInt("WindowStart",self.WindowStart)
	self:SetNWInt("WindowEnd",self.WindowEnd)
	
	self:NextThink(CurTime() + 1.00)
	return true
end
