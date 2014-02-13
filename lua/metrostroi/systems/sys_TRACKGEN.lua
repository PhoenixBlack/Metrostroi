--------------------------------------------------------------------------------
-- Генератор путь трек
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("TRACKGEN")

local ANGLE_LIMIT = 10 -- At what difference from last node do we make a new node
local MAX_NODE_DISTANCE = 512 -- When do we force a new node regardless of angle difference




ANGLE_LIMIT = math.cos(math.rad(ANGLE_LIMIT))
MAX_NODE_DISTANCE = MAX_NODE_DISTANCE ^ 2

function TRAIN_SYSTEM:Initialize()
	self.Active = true
	self.Paths = {}
end

function TRAIN_SYSTEM:Think()
	if not self.Active then return end
	
	local pos = self.Train:GetPos()
	
	if not self.CurrentPath then
		self:NextPath()
	end
	
	if not self.LastNode then
		self:NextNode()
	end
	
	local currentdir = (pos-self.LastNode):GetNormalized()
	
	if self.LastDir then
		print(self.LastDir:Dot(currentdir))
	end
	
	if self.LastNode:DistToSqr(pos) > MAX_NODE_DISTANCE then
		self:NextNode()
	end
	
	if SERVER then return end
	
	if not (GetConVarNumber("metrostroi_drawdebug") > 0) then return end
	
	local lastpos
	
	for _,path in pairs(self.Paths) do
		for k,node in pairs(path) do
			if lastnode then
				render.DrawLine(lastnode,node,{0,0,255},false)
			end
			render.DrawSphere(node,10,1,1,{0,100,255})
			lastnode = node
		end
	end
end

function TRAIN_SYSTEM:NextPath()
	local count = table.Count(self.Paths)
	self.Paths[count+1]={}
	self.CurrentPath = self.Paths[count+1]
end

function TRAIN_SYSTEM:NextNode()
	local pos = self.Train:GetPos()
	if self.LastNode then
		self.LastDir = (pos - self.LastNode):GetNormalized()
	end
	self.LastNode = self.CurrentPath[table.insert(self.CurrentPath,self.Train:GetPos())]
end