include("shared.lua")
surface.CreateFont("testtext", {
  font = "Trebuchet",
  size = 30,
  weight = 1000,
  blursize = 0,
  scanlines = 0,
  antialias = true,
  underline = false,
  italic = false,
  strikeout = false,
  symbol = false,
  rotary = false,
  shadow = false,
  additive = false,
  outline = false
})

function ENT:Initialize()
	//Register initial setup function
	net.Receive("gmod_track_dispatcher-setupmessage", function( length, client )
	
	self.PathData={}
	self.PathData.PicketSignByIndex=net.ReadTable()
	self.PathData.Paths=net.ReadTable()
	self.PathData.SectionLength=net.ReadTable()
	self.PathData.SectionOffset=net.ReadTable()
	end)
	
	//Register updated info function
	net.Receive("gmod_track_dispatcher-updatemessage", function ( length, client ) 
		if self.PathData != nil then
		
			self.PathData.OccupiedSections = net.ReadTable()
			
			local signs = net.ReadTable()
			for k,v in pairs(signs) do
				self.PathData.PicketSignByIndex[k].Switchstate=v
			end
			
		end
	end)
	
	//Setup tables to save drawing data
	self.DrawData={}
	self.DrawData.Switches={}
end


function ENT:Draw()

	local function SetColorForSection(id)
		if self.PathData.OccupiedSections[id] != nil then
			surface.SetDrawColor(255,0,0)
		//elseif sign.Switchstate then
		//	surface.SetDrawColor(255,255,0)
		else
			surface.SetDrawColor(255,255,255)
		end
	end
	
	//ATTN: Doesn't fully replicate arguments, works more like x1,y1,directionX,directionY and draws a set length
	local function DrawDashedLine(x1,y1,x2,y2)
		local length = math.sqrt(math.pow(math.abs(x1-x2),2),math.pow(math.abs(y1-y2),2))
		local xdir = (x2-x1)/length
		local ydir = (y2-y1)/length
		local len = 0
		local size = 3
		while len < 35 do
			surface.DrawLine(x1+xdir*len,y1+ydir*len,x1+xdir*(len+size),y1+ydir*(len+size))
			len=len+4
		end
	end


	self:DrawModel()
	local pos = self:LocalToWorld(Vector(6.1,-27.9,35.3))
	local ang = self:LocalToWorldAngles(Angle(0,90,90))
	
	------------------------------------
	//Change these
	
	local screenX=894
	local screenY=524
	
	local marginTop=30
	local marginBottom=30
	local marginLeft=50
	local marginRight=50
	
	local rowSize=30
	local trackScale=0.7
	local alttracklength=30
	
	-----------------------------------
	//Dont change these
	local currentX=marginLeft
	local currentRow=0
	
	cam.Start3D2D(pos, ang, 0.0625)
		surface.SetDrawColor(20,20,33)
		//surface.SetDrawColor(0,0,0)
		surface.DrawRect(0,0,screenX,screenY)
		
		//If we didn't get initial data or updates, draw an error
		if !self.PathData then
			draw.DrawText("NO TRACK DATA","testtext",screenX/2,screenY/2-16,Color(255,0,0,255),TEXT_ALIGN_CENTER)
			cam.End3D2D()
			return 
		elseif !self.PathData.OccupiedSections then 
			draw.DrawText("NO TRACK DATA","testtext",screenX/2,screenY/2-16,Color(255,0,0,255),TEXT_ALIGN_CENTER)
			cam.End3D2D()
			return
		end
		
		//For every path
		for k,path in pairs(self.PathData.Paths) do
			
			//Looping front section
			if path.Loops then
				local section = self.PathData.PicketSignByIndex[path.Signs[1]].PreviousIndex
				if section then
					SetColorForSection(section)
					DrawDashedLine(marginLeft,marginTop+currentRow*rowSize,0,marginTop+currentRow*rowSize)
				end
			end
			
			//For every sign
			for k2,signidx in pairs(path.Signs) do
				local sign = self.PathData.PicketSignByIndex[signidx]
				
				
				local function GetSwitchOrientation(sign)
					//If we don't have data already
					if !self.DrawData.Switches[sign.Index] then
						//Find out what way the switch is facing
						local trackdirection = (self.PathData.PicketSignByIndex[sign.NextIndex].Pos-sign.Pos):Angle().y
						local altdirection = (self.PathData.PicketSignByIndex[sign.AlternateIndex].Pos-sign.Pos):Angle().y
						local difference = math.AngleDifference(trackdirection,altdirection)
						
						
						//Forward or backward
						local dir = 1
						if math.abs(difference) > 90 then
							dir = -1
						else 
							dir = 1
						end
						
						//Seperate logic for joining signs
						if dir < 0 then
							
							//If there's a previous section, find out the direction by comparing the tracks leading TO the current sign
							if sign.PreviousIndex then
								trackdirection = (sign.Pos-self.PathData.PicketSignByIndex[sign.PreviousIndex].Pos):Angle().y
								altdirection = (sign.Pos-self.PathData.PicketSignByIndex[sign.AlternateIndex].Pos):Angle().y
							end
						end
						
						//Left or right
						local side = 1
						if difference > 0 then
							side = -1
						else
							side = 1
						end
						
						//Save data as table
						self.DrawData.Switches[sign.Index] = { ["side"] = side, ["dir"] = dir }
					end
					return self.DrawData.Switches[sign.Index]
				end
				
				//Get length of track on screen
				local trackScreenLength=self.PathData.SectionLength[sign.Index]*trackScale
				
				//Go to next line if we're hitting the margin
				if trackScreenLength+currentX+marginRight > screenX then
					currentRow = currentRow + 1
					currentX=marginLeft
				end
				
				//Get current Y coord for current line
				local y=marginTop+currentRow*rowSize
				
				//Basic line elements
				SetColorForSection(sign.Index)
				surface.DrawLine(currentX,y-3,currentX,y+3) //Initial vertical line
				surface.DrawLine(currentX,y,currentX+trackScreenLength,y) //Main track line
				//surface.DrawLine(currentX,y-3,currentX,y+3) //Closing vertical line, ATM done by following path
				
				
				
				if sign.AlternateIndex then
					if sign.NextIndex then
						//Switch
						
						SetColorForSection(sign.AlternateIndex)
						//Get switch orientation
						local r = GetSwitchOrientation(sign)
						side=r.side
						dir=r.dir
						//Can this be done nicer?
						
						//Draw the alternate path origin
						surface.DrawLine(
							currentX+trackScreenLength*.5,
							y,
							currentX+trackScreenLength/2+trackScreenLength*.5*dir
							,y-rowSize*.3*side
						)
						//Vertical line
						surface.DrawLine(
							currentX+trackScreenLength/2+trackScreenLength*.5*dir,
							y-rowSize*.3*side-3,
							currentX+trackScreenLength/2+trackScreenLength*.5*dir,
							y-rowSize*.3*side+3
						)
						
						//Draw the following section
						DrawDashedLine(
							currentX+trackScreenLength/2+trackScreenLength*.5*dir,
							y-rowSize*.3*side,
							currentX+trackScreenLength/2+(trackScreenLength*.5+alttracklength)*dir,
							y-rowSize*.3*side
						)
					else
						//Merger
						
					end
				end 
				
				//Advance the X coordinate
				currentX=currentX+trackScreenLength

			end //Of section
			
			
			//Draw final vertical line
			local y=marginTop+currentRow*rowSize
			surface.DrawLine(currentX,y-3,currentX,y+3)
			
			//Draw looping section
			if path.Loops then
				local section = self.PathData.PicketSignByIndex[path.Signs[#path.Signs]].NextIndex
				if section then
					SetColorForSection(section)
					DrawDashedLine(currentX,marginTop+currentRow*rowSize,screenX,marginTop+currentRow*rowSize)
				end
			end
			
			//Reset for next row
			currentRow = currentRow + 2
			currentX = marginLeft
			
		end //Of path
		
		
		//draw.DrawText("I AM JUST REFERENCE CODE","testtext",0,0,Color(255,0,0,255),TEXT_ALIGN_LEFT)
	cam.End3D2D()
end


