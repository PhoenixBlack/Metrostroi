--------------------------------------------------------------------------------
-- Rail network handling and ARS simulation
--------------------------------------------------------------------------------
if not Metrostroi.Paths then
	-- Definition of paths used in runtime
	Metrostroi.Paths = {}
	-- Spatial lookup for nodes
	Metrostroi.SpatialLookup = {}
end




--------------------------------------------------------------------------------
-- Size of spatial cells into which all the 3D space is divided
local SPATIAL_CELL_WIDTH = 1024
local SPATIAL_CELL_HEIGHT = 256

-- Return spatial cell indexes for given XYZ
local function spatialPosition(pos)
	return math.floor(pos.x/SPATIAL_CELL_WIDTH),
		   math.floor(pos.y/SPATIAL_CELL_WIDTH),
		   math.floor(pos.z/SPATIAL_CELL_HEIGHT)
end

-- Return list of nodes in spatial cell kx,ky,kz
local empty_table = {}
local function spatialNodes(kx,ky,kz)
	if Metrostroi.SpatialLookup[kz] then
		if Metrostroi.SpatialLookup[kz][kx] then
			return Metrostroi.SpatialLookup[kz][kx][ky] or empty_table
		else
			return empty_table
		end
	else
		return empty_table
	end
end


--------------------------------------------------------------------------------
-- for nodeID,node in Metrostroi.NearestNodes(pos) do ... end
--------------------------------------------------------------------------------
function Metrostroi.NearestNodes(pos)
	local kx,ky,kz = spatialPosition(pos)
	local t = {}
	for x=-1,1 do for y=-1,1 do for z=-1,1 do
		table.insert(t,spatialNodes(kx+x,ky+y,kz+z))
	end end end
	
	local i,j = 0,1
	return function ()
		-- Find next set of nodes that's not empty
		while (j <= #t) and (i >= #t[j]) do 
			j = j + 1; i = 0 
		end
		-- Should iterator end
		if j > #t then return nil end
		
		-- Iterate table like normal
		i = i + 1
		if i <= #t[j] then return t[j][i].id,t[j][i] end
	end
end


--------------------------------------------------------------------------------
-- Return position on track for target XYZ
--------------------------------------------------------------------------------
function Metrostroi.GetPositionOnTrack(pos,ang)
	-- Angle can be specified to determine if facing forward or backward
	ang = ang or Angle(0,0,0)
	
	-- Size of box which envelopes region of space that counts as being on track
	local X_PAD = 0
	local Y_PAD = 384
	local Z_PAD = 256
	
	-- Find position on any track
	local results = {}
	for nodeID,node in Metrostroi.NearestNodes(pos) do
		-- Get local coordinate system of a section
		local forward = node.dir
		local up = Vector(0,0,1)
		local right = forward:Cross(up)

		-- Transform position into local coordinates
		local local_pos = pos - node.pos
		local local_x = local_pos:Dot(forward)
		local local_y = local_pos:Dot(right)
		local local_z = local_pos:Dot(up)
		local yz_delta = math.sqrt(local_y^2 + local_z^2)

		-- Determine if facing forward or backward
		local local_dir = ang:Forward()
		local dir_delta = local_dir:Dot(forward)
		local dir_forward = dir_delta > 0
		
		-- If this position resides on track, add it to results
		if ((local_x > -X_PAD) and (local_x < node.vec:Length()+X_PAD) and
			(local_y > -Y_PAD) and (local_y < Y_PAD) and
			(local_z > -Z_PAD) and (local_z < Z_PAD)) then
			table.insert(results,{
				node1 = node,
				node2 = node.next,
				path = node.path,
				
				forward = dir_forward,			-- Is facing forward relative to track
				x = local_x*0.01905 + node.x,	-- Local coordinates in track curvilinear coordinates
				y = local_y*0.01905,			--
				z = local_z*0.01905,			--
				
				distance = yz_delta,			-- Distance to path axis
			})
		end	
	end
	
	-- Return list of positions
	return results
end




--------------------------------------------------------------------------------
-- Load track definition and sign definitions
--------------------------------------------------------------------------------
function Metrostroi.Load(name)
	name = name or game.GetMap()
	if not file.Exists(string.format("metrostroi_data/track_%s.txt",name),"DATA") then
		print("Track definition file not found: metrostroi_data/track_"..name..".txt")
		return
	end
	--if not file.Exists(string.format("metrostroi_data/signs_%s.txt",name),"DATA") then
		--print("Sign definition file not found: metrostroi_data/signs_"..name..".txt")
		--return
	--end

	-- Load data
	print("Metrostroi: Loading signs and track definition...")
	local paths = util.JSONToTable(file.Read(string.format("metrostroi_data/track_%s.txt",name)))
	if not paths then
		print("Parse error in track definition JSON")
		paths = {}
	end
	
	-- Prepare spatial lookup table
	Metrostroi.SpatialLookup = {}
	local function addLookup(node)
		local kx,ky,kz = spatialPosition(node.pos)
		
		Metrostroi.SpatialLookup[kz] = Metrostroi.SpatialLookup[kz] or {}
		Metrostroi.SpatialLookup[kz][kx] = Metrostroi.SpatialLookup[kz][kx] or {}
		Metrostroi.SpatialLookup[kz][kx][ky] = Metrostroi.SpatialLookup[kz][kx][ky] or {}
		table.insert(Metrostroi.SpatialLookup[kz][kx][ky],node)
	end
	
	-- Create paths definition
	Metrostroi.Paths = {}
	for pathID,path in pairs(paths) do
		local currentPath = { id = pathID }
		Metrostroi.Paths[pathID] = currentPath
		
		-- Count length of path and offset in every node
		currentPath.length = 0
		local prevPos,prevNode
		for nodeID,nodePos in pairs(path) do
			-- Count distance
			local distance = 0
			if prevPos then 
				distance = prevPos:Distance(nodePos)*0.01905
				currentPath.length = currentPath.length + distance				
			end
			
			-- Add a node
			currentPath[nodeID] = {
				id = nodeID,
				path = currentPath,
				
				pos = nodePos,
				x = currentPath.length,
				prev = prevNode,
			}
			if prevNode then
				prevNode.next = currentPath[nodeID] 
				prevNode.dir = (nodePos - prevNode.pos):GetNormalized()
				prevNode.vec = nodePos - prevNode.pos
				prevNode.length = distance
			end

			-- Add to spatial lookup
			addLookup(currentPath[nodeID])
			prevPos = nodePos
			prevNode = currentPath[nodeID] 
		end
		
		if prevNode then
			prevNode.next = nil
			prevNode.dir = Vector(0,0,0)
			prevNode.vec = Vector(0,0,0)
			prevNode.length = 0
		end
	end
	
	-- Print info
	Metrostroi.PrintStatistics()
end


--------------------------------------------------------------------------------
-- Save track & sign definitions
--------------------------------------------------------------------------------
function Metrostroi.Save()

end


--------------------------------------------------------------------------------
-- Concommands and automatic loading of rail network
--------------------------------------------------------------------------------
hook.Add("Initialize", "Metrostroi_MapInitialize", function()
	Metrostroi.Load("metrostroi_signs/"..game.GetMap()..".txt")
end)

concommand.Add("metrostroi_save", function(ply, _, args)
	if (ply:IsValid()) and (not ply:IsAdmin()) then return end
	Metrostroi.Save()
end)

concommand.Add("metrostroi_load", function(ply, _, args)
	if (ply:IsValid()) and (not ply:IsAdmin()) then return end
	Metrostroi.Load()
end)

concommand.Add("metrostroi_pos_info", function(ply, _, args)
	if (ply:IsValid()) and (not ply:IsAdmin()) then return end
	
	-- Draw nearest nodes
	timer.Simple(0.05,function()
		for k,v in Metrostroi.NearestNodes(ply:GetPos()) do
			debugoverlay.Cross(v.pos,10,10,Color(0,0,255),true)
			debugoverlay.Line(v.pos,ply:GetPos(),10,Color(0,0,255),true)
		end
	end)
	
	-- Print interesting information
	local results = Metrostroi.GetPositionOnTrack(ply:GetPos(),ply:GetAimVector():Angle())
	for k,v in pairs(results) do
		print(Format("\t[%d] Path #%d: (%.2f x %.2f x %.2f) m  Facing %s",k,v.path.id,v.x,v.y,v.z,v.forward and "forward" or "backward"))
	end
end)




--------------------------------------------------------------------------------
-- Print statistics and information about the loaded rail network
--------------------------------------------------------------------------------
function Metrostroi.PrintStatistics()
	local totalLength = 0
	for pathNo,path in pairs(Metrostroi.Paths) do
		totalLength = totalLength + path.length
	end
	
	print(Format("Metrostroi: Total %.3f km of paths defined:",totalLength/1000))
	for pathNo,path in pairs(Metrostroi.Paths) do
		print(Format("\t[%d] %.3f km (%d nodes)",path.id,path.length/1000,#path))	
	end
	
	local count = #Metrostroi.SpatialLookup
	local cells = {}
	for _,z in pairs(Metrostroi.SpatialLookup) do
		count = count + #z
		for _,x in pairs(z) do
			count = count + #x
			for _,y in pairs(x) do
				table.insert(cells,#y)
			end
		end
	end
	print(Format("Metrostroi: %d tables used for spatial lookup (%d cells)",count,#cells))
	local maxn,avgn = 0,0
	for k,v in pairs(cells) do maxn = math.max(maxn,v) avgn = avgn + v end
	print(Format("Metrostroi: Most nodes in cell: %d, average nodes in cell: %.2f",maxn,avgn/#cells))
end




Metrostroi.Load()