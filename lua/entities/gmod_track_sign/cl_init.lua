include("shared.lua")

surface.CreateFont("MetrostroiSubway_StationFont1", {
  font = "Arial",
  size = 96,
  weight = 0,
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

surface.CreateFont("MetrostroiSubway_StationFont2", {
  font = "Times New Roman",
  size = 128,
  weight = 0,
  antialias = true,
})

surface.CreateFont("MetrostroiSubway_StationList1", {
  font = "Arial",
  size = 28,
  weight = 1000,
  antialias = true,
})
surface.CreateFont("MetrostroiSubway_StationList2", {
  font = "Arial",
  size = 28,
  weight = 0,
  antialias = true,
})
surface.CreateFont("MetrostroiSubway_StationList3", {
  font = "Arial",
  size = 28,
  weight = 0,
  antialias = true,
})

function ENT:Initialize()
	self:SetRenderBounds(
		Vector(-16,-768,-64),
		Vector(16,768,64))
end

function ENT:Draw()
	local pos = self:LocalToWorld(Vector(4,0,16))
	local ang = self:LocalToWorldAngles(Angle(0,90,90))
	cam.Start3D2D(pos, ang, 0.50)
		--surface.SetDrawColor(255,255,255,255)
		--surface.DrawRect(0, 0, 256, 320)

		draw.Text({
			text = self:GetNWString("Name","Error"),
			font = "MetrostroiSubway_StationFont2",--..self:GetNWInt("Style",1),
			pos = { 0, 0 },
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_CENTER,
			color = Color(0,0,0,255)})
	cam.End3D2D()
	
	local pos = self:LocalToWorld(Vector(4,0,-32))
	local ang = self:LocalToWorldAngles(Angle(0,90,90))
	cam.Start3D2D(pos, ang, 0.25)
		draw.NoTexture()
		
		local N = self:GetNWInt("StationList#")
		local W = 320
		local H = 55
		local P1 = -2
		local P2 = 3
		local X = -N*W*0.5
		local LastColor = nil
		for i=1,N do
			local x = X+W*(i-1)
			local ID = self:GetNWInt("StationList"..i.."[ID]")
			local currentStation = (self:GetNWInt("ID") == ID)
			
			local R1 = self:GetNWInt("StationList"..i.."[R]")
			local G1 = self:GetNWInt("StationList"..i.."[G]")
			local B1 = self:GetNWInt("StationList"..i.."[B]")
			local R2 = 225
			local G2 = 205
			local B2 = 0

			if currentStation then
				local R,G,B = R2,G2,B2
				R2,G2,B2 = R1,G1,B1
				R1,G1,B1 = R,G,B
			end

			LastColor = LastColor or Color(R1,G1,B1,255)
			
			surface.SetDrawColor(0,0,0,255)
			surface.DrawRect(x+P1,0,W-P1*2,H)
			
			surface.SetDrawColor(R1,G1,B1,255)
			surface.DrawRect(x+P1+P2,0+P2,W-P1*2-P2*2,H-P2*2)
			
			draw.Text({
				text = self:GetNWString("StationList"..i.."[ID]"),
				font = "MetrostroiSubway_StationList3",
				pos = { x+W*0.1, 0+H*0.5},
				xalign = TEXT_ALIGN_CENTER,
				yalign = TEXT_ALIGN_CENTER,
				color = Color(0,0,0,255)})
			draw.Text({
				text = self:GetNWString("StationList"..i.."[Name1]"),
				font = "MetrostroiSubway_StationList1",
				pos = { x+W*0.55, 0+H*0.25},
				xalign = TEXT_ALIGN_CENTER,
				yalign = TEXT_ALIGN_CENTER,
				color = Color(0,0,0,255)})
			draw.Text({
				text = self:GetNWString("StationList"..i.."[Name2]"),
				font = "MetrostroiSubway_StationList2",
				pos = { x+W*0.55, 0+H*0.75},
				xalign = TEXT_ALIGN_CENTER,
				yalign = TEXT_ALIGN_CENTER,
				color = Color(0,0,0,255)})
		end
		
		-- Inner part of arrow
		local arrow = {
			{ x = 0,	y = 0 },
			{ x = 0,	y = H },
			{ x = -H/2,	y = H/2 },			
		}
		for k,v in ipairs(arrow) do
			v.x = v.x - (N*0.5)*W - 2
		end
	
		surface.SetDrawColor(Color(0,0,0,255))
		surface.DrawPoly(arrow)
		
		-- Outer part of arrow
		arrow = {
			{ x = -P2,	y = 2*P2 },
			{ x = -P2,	y = H-2*P2 },
			{ x = -H/2+P2,	y = H/2 },
		}
		for k,v in ipairs(arrow) do
			v.x = v.x - (N*0.5)*W
		end
		
		surface.SetDrawColor(LastColor or Color(0,0,0,0))
		surface.DrawPoly(arrow)
	cam.End3D2D()
end