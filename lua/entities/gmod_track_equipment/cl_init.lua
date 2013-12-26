include("shared.lua")

CreateClientConVar("metrostroi_drawdebug",0,true)

surface.CreateFont("SubwayTrackSign_A", {
  font = "Trebuchet",
  size = 90,
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

surface.CreateFont("SubwayTrackSign_B", {
  font = "Trebuchet",
  size = 128,
  weight = 500,
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

surface.CreateFont("SubwayTrackSign_C", {
  font = "Wingdings 3",
  size = 128,
  weight = 500,
  blursize = 0,
  scanlines = 0,
  antialias = true,
  underline = false,
  italic = false,
  strikeout = false,
  symbol = true,
  rotary = false,
  shadow = false,
  additive = false,
  outline = false
})

surface.CreateFont("SubwayTrackSign_D", {
  font = "Trebuchet",
  size = 60,
  weight = 500,
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


local modelOffset1 = {
  ["models/props_trainstation/tracksign10.mdl"] =
    { 0.13, Vector(10.5,0,-1), Angle(0,90,90) },
  ["models/props_trainstation/tracksign09.mdl"] =
    { 0.13, Vector(10.5,0,6),  Angle(0,90,90) },
  ["models/props_trainstation/tracksign08.mdl"] =
    { 0.25, Vector(10.5,0,-1), Angle(0,90,90) },
  ["models/props_trainstation/tracksign02.mdl"] =
    { 0.13, Vector(8.5,0,1.5), Angle(73,0,0)  },
  ["models/props_trainstation/tracksign07.mdl"] =
    { 0.25, Vector(2,0,27),    Angle(0,90,90) },
  ["models/props_trainstation/tracksign03.mdl"] =
    { 0.13, Vector(2,0,37),    Angle(0,90,90) },
  ["models/props_trainstation/light_signal001b.mdl"] =
    { 1.00, Vector(27,8.5,83), Angle(0,90,90) },
  ["models/props_trainstation/tracklight01.mdl"] =
    { 1.00, Vector(4,-1.7,15), Angle(0,90,90) },
    
  ["models/metrostroi/props/picket.mdl"] =
    { 0.07, Vector(4.6,-10,0), Angle(0,66,90) },
 
  ["models/metrostroi/props_models/light_2.mdl"] =
    { 0.05, Vector(1,6,60), Angle(0,90,90) },
  ["models/metrostroi/props_models/light_3.mdl"] =
    { 0.05, Vector(1,6,60), Angle(0,90,90) },
  ["models/metrostroi/props_models/light_2_2.mdl"] =
    { 0.05, Vector(1,6,60), Angle(0,90,90) },
  ["models/metrostroi/props_models/light_2_3.mdl"] =
    { 0.05, Vector(1,6,60), Angle(0,90,90) },
  
  ["models/metrostroi/props_models/light_2_outside.mdl"] =
    { 0.05, Vector(1,0,25), Angle(0,90,90) },
  ["models/metrostroi/props_models/light_3_outside.mdl"] =
    { 0.05, Vector(1,-4,110), Angle(0,90,90) },
}
   
local modelOffset2 = {
  ["models/props_trainstation/tracksign02.mdl"] =
    { 0.13, Vector(-7.5,0,1.5), Angle(-73,0,0) },
  ["models/props_trainstation/tracksign03.mdl"] =
    { 0.13, Vector(-2,0,37),   Angle(0,270,90) },
    
  ["models/metrostroi/props/picket.mdl"] =
    { 0.07, Vector(-4.6,-10,0), Angle(0,-66,90) },
}


function ENT:DrawCircle(cx,cy,radius)
  local step = 2*math.pi/12
  local vertexBuffer = { {}, {}, {} }

  for i=1,12 do
    vertexBuffer[1].x = cx + radius*math.sin(step*(i+0))
    vertexBuffer[1].y = cy + radius*math.cos(step*(i+0))
    vertexBuffer[2].x = cx
    vertexBuffer[2].y = cy
    vertexBuffer[3].x = cx + radius*math.sin(step*(i+1))
    vertexBuffer[3].y = cy + radius*math.cos(step*(i+1))
    surface.DrawPoly(vertexBuffer)
  end
end


function ENT:Draw()
  local pos1   = self:LocalToWorld(Vector(0,0,0))
  local ang1   = self:LocalToWorldAngles(Angle(0,0,0))
  local scale1 = 0.13
  local pos2   = pos1
  local ang2   = ang1
  local scale2 = scale1
  
  if LocalPlayer():GetPos():Distance(self:GetPos()) > 4096 then
    return
  end
  
  -- Get information about sign
  local graphic = self:GetNWString("Graphic") or ""
  local var = {
    self:GetNWInt("Value1"),
    self:GetNWInt("Value2"),
    self:GetNWInt("Value3"),
    self:GetNWInt("Value4"),
  }
  local id = self:GetNWInt("ID")
  

  -- Quit drawing pickets that aren't nice
  if GetConVarNumber("metrostroi_drawdebug") == 0 then
    if graphic == "picket" then
      local d1 = tonumber(var[1]) or 0
      local d2 = tonumber(var[2]) or 1000
--      if math.abs(d2-d1) < 25 then return end
    end
  end
  self:DrawModel()

  -- Setup rendering
  local model = self:GetModel()
  if modelOffset1[model] then
    scale1 = modelOffset1[model][1]
    pos1   = self:LocalToWorld(modelOffset1[model][2])
    ang1   = self:LocalToWorldAngles(modelOffset1[model][3])
  end
  if modelOffset2[self:GetModel()] then
    scale2 = modelOffset2[model][1]
    pos2   = self:LocalToWorld(modelOffset2[model][2])
    ang2   = self:LocalToWorldAngles(modelOffset2[model][3])
  end


  -- Draw first surface
  cam.Start3D2D(pos1, ang1, scale1)
    if graphic == "speed_limit" then
      draw.DrawText(var[1], "SubwayTrackSign_B",0,-90,Color(0,0,0,255),TEXT_ALIGN_CENTER)
      draw.DrawText("KM",   "SubwayTrackSign_D",0, 25,Color(0,0,0,255),TEXT_ALIGN_CENTER)
    end
    if graphic == "slope" then
      draw.DrawText(math.abs(var[1]), "SubwayTrackSign_D",-40,-90,Color(0,0,0,255),TEXT_ALIGN_CENTER)
      draw.DrawText(var[2],           "SubwayTrackSign_D",15, 20,Color(0,0,0,255),TEXT_ALIGN_CENTER)
      if var[1] > 0
      then draw.DrawText("k", "SubwayTrackSign_C",0,-70,Color(0,0,0,255),TEXT_ALIGN_CENTER)
      else draw.DrawText("m", "SubwayTrackSign_C",0,-70,Color(0,0,0,255),TEXT_ALIGN_CENTER)
      end
    end
    if graphic == "brake_zone" then
      draw.DrawText("T",    "SubwayTrackSign_B",0,-70,Color(0,0,0,255),TEXT_ALIGN_CENTER)
      draw.DrawText(var[1], "SubwayTrackSign_D",0, 110,Color(0,0,0,255),TEXT_ALIGN_CENTER)
    end
    if graphic == "danger_zone" then
      draw.DrawText("r", "SubwayTrackSign_C",0,-70,Color(0,0,0,255),TEXT_ALIGN_CENTER)
      draw.DrawText("!", "SubwayTrackSign_A",0,-48,Color(0,0,0,255),TEXT_ALIGN_CENTER)
      if var[1] > 0 then
        draw.DrawText(var[1].." m", "SubwayTrackSign_D",0, 110,Color(0,0,0,255),TEXT_ALIGN_CENTER)
      end
    end
    if graphic == "prohibit" then
      draw.DrawText("r",   "SubwayTrackSign_C",0,-65,Color(0,0,0,255),TEXT_ALIGN_CENTER)
      draw.DrawText("!",   "SubwayTrackSign_A",0,-43,Color(0,0,0,255),TEXT_ALIGN_CENTER)
      
      draw.DrawText("NO",  "SubwayTrackSign_D",0,-90,Color(0,0,0,255),TEXT_ALIGN_CENTER)
      draw.DrawText("WAY", "SubwayTrackSign_D",0,35,Color(0,0,0,255),TEXT_ALIGN_CENTER)
    end
    if graphic == "picket" then
      draw.DrawText(var[1], "SubwayTrackSign_B",0,-70,Color(0,0,0,255),TEXT_ALIGN_CENTER)

      if GetConVarNumber("metrostroi_drawdebug") > 0 then
        draw.DrawText("N="..var[3], "SubwayTrackSign_D",0, 25,Color(0,0,0,255),TEXT_ALIGN_CENTER)
      end
    end
    if graphic == "light" then
      local id1 = id % 10
      local id2 = math.floor(id / 10) % 10
      local id3 = math.floor(id / 100) % 10
      
      surface.SetDrawColor(Color(255,255,255))
      surface.DrawRect(-50,0,100,310)
      draw.DrawText(id3, "SubwayTrackSign_B",0,  0,Color(0,0,0,255),TEXT_ALIGN_CENTER)
      draw.DrawText(id2, "SubwayTrackSign_B",0, 90,Color(0,0,0,255),TEXT_ALIGN_CENTER)
      draw.DrawText(id1, "SubwayTrackSign_B",0,180,Color(0,0,0,255),TEXT_ALIGN_CENTER)
    end

  cam.End3D2D()
  
  
  -- Draw second surface
  cam.Start3D2D(pos2, ang2, scale2)
    if graphic == "picket" then
      draw.DrawText(var[2], "SubwayTrackSign_B",0,-70,Color(0,0,0,255),TEXT_ALIGN_CENTER)
--      if GetConVarNumber("metrostroi_drawdebug") > 0 then
--        draw.DrawText("N="..var[3], "SubwayTrackSign_D",0, 20,Color(0,0,0,255),TEXT_ALIGN_CENTER)
--      end
    end
  cam.End3D2D()
  
  if GetConVarNumber("metrostroi_drawdebug") > 0 then
    if graphic == "picket" then
      if self:GetNWVector("next_picket_pos") and (self:GetNWVector("next_picket_pos"):Length() > 0) then
        render.DrawLine(self:GetPos(),self:GetNWVector("next_picket_pos"),Color(255,255,0,255),false)
        render.DrawLine(self:GetPos()+Vector(0,0,16),self:GetPos(),Color(255,255,0,255),false)
        render.DrawLine(self:GetPos()+Vector(0,0,16),self:GetNWVector("next_picket_pos"),Color(255,255,0,255),false)
      end
      if self:GetNWVector("switch_picket_pos") and (self:GetNWVector("switch_picket_pos"):Length() > 0) then
        render.DrawLine(self:GetPos(),self:GetNWVector("switch_picket_pos"),Color(0,255,0,255),false)
        render.DrawLine(self:GetPos()+Vector(0,0,16),self:GetPos(),Color(0,255,0,255),false)
        render.DrawLine(self:GetPos()+Vector(0,0,16),self:GetNWVector("switch_picket_pos"),Color(0,255,0,255),false)
      end
    end
    if self:GetNWVector("nearest_picket_pos") and (self:GetNWVector("nearest_picket_pos"):Length() > 0) then
      render.DrawLine(self:GetPos(),self:GetNWVector("nearest_picket_pos"),Color(255,255,255,255),false)
      render.DrawLine(self:GetPos()+Vector(0,0,32),self:GetPos(),Color(255,255,255,255),false)
      render.DrawLine(self:GetPos()+Vector(0,0,32),self:GetNWVector("nearest_picket_pos"),Color(255,255,255,255),false)
    end
    if (graphic ~= "picket") then
      if self:GetNWVector("nearest_path_pos") and (self:GetNWVector("nearest_path_pos"):Length() > 0) then
        render.DrawLine(self:GetPos(),self:GetNWVector("nearest_path_pos"),Color(0,50,255,255),false)
        render.DrawLine(self:GetPos()+Vector(0,0,16),self:GetPos(),Color(0,50,255,255),false)
        render.DrawLine(self:GetPos()+Vector(0,0,16),self:GetNWVector("nearest_path_pos"),Color(0,50,255,255),false)
      end
    end
  end
end
