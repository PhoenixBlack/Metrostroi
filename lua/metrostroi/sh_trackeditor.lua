--------------------------------------------------------------------------------
-- Track definition generator
--------------------------------------------------------------------------------
Metrostroi.TrackEditor = Metrostroi.TrackEditor or {} 
Metrostroi.TrackEditor.Paths = Metrostroi.TrackEditor.Paths or {}

local ANGLE_LIMIT = 10 -- At what difference from last node do we make a new node
local MAX_NODE_DISTANCE = 512 -- When do we force a new node regardless of angle difference

local MIN_NODE_DISTANCE = 100 -- Minimal distance between nodes

ANGLE_LIMIT = math.cos(math.rad(ANGLE_LIMIT))
MAX_NODE_DISTANCE = MAX_NODE_DISTANCE ^ 2
MIN_NODE_DISTANCE = MIN_NODE_DISTANCE ^ 2

local CurrentPath
local Active = false
local LastNode
local LastDir
local Train 

local function DebugLine(p1,p2)
	debugoverlay.Line(p1,p2,10,Color(0,0,255),true)
end


local function DrawPath(path)
	local lastnode
	for k,v in pairs(path) do
		debugoverlay.Cross(v,10,10,Color(255,0,0),true)
		if lastnode then
			DebugLine(lastnode,v)
		end
		lastnode = v
	end
end

local function ShowAll()
	local paths = Metrostroi.TrackEditor.Paths
	if not paths or #paths == 0 then return end
	
	for _,path in pairs(paths) do
		if #path > 0 then
			DrawPath(path)
		end
	end
end
	
local function ShowStatus()
	local paths = Metrostroi.TrackEditor.Paths
	if paths and #paths > 0 then
		print(string.format("%d Paths:",#paths))
		for k,path in pairs(paths) do
			local suffix = ""
			
			if path == CurrentPath then
				suffix = "<<< Active"
			end
		
			if #path > 0 then
				print(string.format("\t %d: %d nodes %s",k,#path,suffix))
			else
				print("Errous empty path?!")
			end
		end
	else
		print("No recorded paths")
	end
end

local function DrawPathID(args)
	local paths = Metrostroi.TrackEditor.Paths
	local path = paths[tonumber(args[1])]
	if not path then 
		print("Path not found")
		return
	else
		DrawPath(path)
	end
	
end

local function RemovePath(args)
	local id = tonumber(args[1])
	local path = Metrostroi.TrackEditor.Paths[id]
	if path == CurrentPath then
		FinishPath()
	end
	table.remove(Metrostroi.TrackEditor.Paths,id)
end


local function Mark(ent)
	Train = ent
	print(Train," marked")
end

local function NextNode()
	print("New node")
	local pos = Train:GetPos()
	if LastNode then
		DebugLine(pos,LastNode,10,Color(0,0,255),true)
		LastDir = (pos - LastNode):GetNormalized()
	end
	debugoverlay.Cross(pos,10,10,Color(0,100,255),true)
	table.insert(CurrentPath,pos)
	
	LastNode = pos
	--Metrostroi.TrackEditor.Paths[CurrentPath][table.insert(Metrostroi.TrackEditor.Paths[CurrentPathID],self.Train:GetPos())]
	--Lets not do that 
	--PrintTable(self.Paths)
end

local function Think()
	if not Active then return end
	
	local pos = Train:GetPos()
	
	if LastNode then
		CurrentDir = (pos-LastNode):GetNormalized()
	end
	
	
	if (LastDir:Dot(CurrentDir) < ANGLE_LIMIT)
	and (LastNode:DistToSqr(pos) > MIN_NODE_DISTANCE) 
	then
		print("Angle limit")
		NextNode()
	end
	
	if LastNode:DistToSqr(pos) > MAX_NODE_DISTANCE then
		print("Distance limit")
		NextNode()
	end
end
-- Unused
local function ClientDraw()
	if GetConVarNumber("metrostroi_drawdebug") <= 0 then return end

	if #Metrostroi.TrackEditor.Paths == 0 then return end
	
	local lastpos
	
	for _,path in pairs(Metrostroi.TrackEditor.Paths) do
		if #path > 0 then
			local drawcolor
			if path == CurrentPath then
				drawcolor = {0,255,0}
			else
				drawcolor = {0,0,255}
			end
			
			for k,node in pairs(path) do
				if lastpos then
					render.DrawLine(lastpos,node,drawcolor,false)
				end
				render.DrawWireframeSphere(node,10,2,2,drawcolor,false)
				lastpos = node
			end
		end
	end 
end

local function FinishPath()
	NextNode()
	CurrentPath = nil
	LastNode = nil
	LastDir = nil
	print("Path ended")
end

--Takes forward direction
local function StartPath(forward)
	print("New Path")
	
	local forward = forward or Train and Train:GetAngles():Forward()
	local ID = table.insert(Metrostroi.TrackEditor.Paths,{})
	
	CurrentPath = Metrostroi.TrackEditor.Paths[ID]
	LastDir = forward*-1
	
	NextNode()
end


local function Start()
	if Train then
		StartPath()
		Active = true
		print("Started")
	else
		print("No train!")
	end
end

local function Stop()
	FinishPath()
	Active = false
end

local function Save(args)
	if not file.Exists("metrostroi_data","DATA") then
		file.CreateDir("metrostroi_data")
	end
	local name = args[1] or ("track_"..game.GetMap())
	local data = util.TableToJSON(Metrostroi.TrackEditor.Paths)
	file.Write(string.format("metrostroi_data/%s.txt",name),data)
	print("Saved to "..name..".txt")
end

local function Load(args)
	local name = args[1] or ("track_"..game.GetMap())
	if not file.Exists(string.format("metrostroi_data/%s.txt",name),"DATA") then print("File not found: "..name..".txt") return end
	print("Loading from "..name..".txt")
	
	local tbl = util.JSONToTable(file.Read(string.format("metrostroi_data/%s.txt",name)))
	if tbl == nil then
		print("JSON Parse error")
	else
		Metrostroi.TrackEditor.Paths = tbl -- Maybe requires hardcopy?
	end
end


hook.Add("Think","metrostroi track editor",Think)

if SERVER then
	concommand.Add("metrostroi_trackeditor_mark",function(ply,cmd,args,fullstring) Mark(ply:GetEyeTrace().Entity) end,nil,"Mark currently aimed at entity as track editing source")
	concommand.Add("metrostroi_trackeditor_start",function(ply,cmd,args,fullstring) Start() end,nil,"Start recording")
	concommand.Add("metrostroi_trackeditor_stop",function(ply,cmd,args,fullstring) Stop() end,nil,"Stop recording")
	concommand.Add("metrostroi_trackeditor_drawall",function(ply,cmd,args,fullstring) ShowAll() end,nil,"Draw all paths")
	concommand.Add("metrostroi_trackeditor_status",function(ply,cmd,args,fullstring) ShowStatus() end,nil,"Show path status")
	concommand.Add("metrostroi_trackeditor_drawpath",function(ply,cmd,args,fullstring) DrawPathID(args) end,nil,"Draw single path")
	concommand.Add("metrostroi_trackeditor_removepath",function(ply,cmd,args,fullstring) RemovePath(args) end,nil,"Remove a path")
	concommand.Add("metrostroi_trackeditor_save",function(ply,cmd,args,fullstring) Save(args) end,nil,"Save track")
	concommand.Add("metrostroi_trackeditor_load",function(ply,cmd,args,fullstring) Load(args) end,nil,"Load track")
end