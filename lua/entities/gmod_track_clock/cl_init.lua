include("shared.lua")

surface.CreateFont("SubwayClock_Font", {
  font = "blocks",
  size = 100,
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

surface.CreateFont("SubwayClock_FontGlow", {
  font = "blocks",
  size = 100,
  weight = 0,
  blursize = 8,
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

local digit_bitmap = {
  [10] = {
   0,0,0,0,
   0,0,0,0,
   0,0,0,0,
   0,0,0,0,
   0,0,0,0,
   0,0,0,0,
   0,0,0,0},
  ["."] = {
   0,0,0,0,
   0,0,0,0,
   0,0,0,0,
   0,0,0,0,
   0,0,0,0,
   0,0,0,0,
   0,0,1,0},
   
  [1] = {
   0,0,0,1,
   0,0,0,1,
   0,0,0,1,
   0,0,0,1,
   0,0,0,1,
   0,0,0,1,
   0,0,0,1},
  [2] = {
   1,1,1,1,
   0,0,0,1,
   0,0,0,1,
   1,1,1,1,
   1,0,0,0,
   1,0,0,0,
   1,1,1,1},
  [3] = {
   1,1,1,1,
   0,0,0,1,
   0,0,0,1,
   1,1,1,1,
   0,0,0,1,
   0,0,0,1,
   1,1,1,1},
  [4] = {
   1,0,0,1,
   1,0,0,1,
   1,0,0,1,
   1,1,1,1,
   0,0,0,1,
   0,0,0,1,
   0,0,0,1},
  [5] = {
   1,1,1,1,
   1,0,0,0,
   1,0,0,0,
   1,1,1,1,
   0,0,0,1,
   0,0,0,1,
   1,1,1,1},
  [6] = {
   1,1,1,1,
   1,0,0,0,
   1,0,0,0,
   1,1,1,1,
   1,0,0,1,
   1,0,0,1,
   1,1,1,1},
  [7] = {
   1,1,1,1,
   0,0,0,1,
   0,0,0,1,
   0,0,0,1,
   0,0,0,1,
   0,0,0,1,
   0,0,0,1},
  [8] = {
   1,1,1,1,
   1,0,0,1,
   1,0,0,1,
   1,1,1,1,
   1,0,0,1,
   1,0,0,1,
   1,1,1,1},
  [9] = {
   1,1,1,1,
   1,0,0,1,
   1,0,0,1,
   1,1,1,1,
   0,0,0,1,
   0,0,0,1,
   0,0,0,1},
  [0] = {
   1,1,1,1,
   1,0,0,1,
   1,0,0,1,
   1,0,0,1,
   1,0,0,1,
   1,0,0,1,
   1,1,1,1},
}

function ENT:DrawDigit(cx,cy,digit)
  local bitmap = digit_bitmap[digit]
  if not bitmap then return end
  
  local w=12
  local p=8
  for i=1,4*7 do
    local x = (i-1)%4
    local y = math.floor((i-1)/4)
    if bitmap[i] == 1 then
      for z=1,6,1 do
       surface.SetDrawColor(Color(255,60,0,math.max(0,30-1*z*z)))
        surface.DrawRect(cx+x*w-z, cy+y*w-z, p+2*z, p+2*z)
      end
      
      surface.SetDrawColor(Color(255,240,0,255))
      surface.DrawRect(cx+x*w, cy+y*w, p, p)
    end
  end
end

function ENT:Draw()
  self:DrawModel()
  
  local pos = self:LocalToWorld(Vector(3,0,0))
  local ang = self:LocalToWorldAngles(Angle(0,90,90))
  
  cam.Start3D2D(pos, ang, 0.25)
    local outdoor = self:GetNWBool("OutdoorClock",false)
    local x,y = -192,-64
    local x2,y2 = -450,-64
    if outdoor then
      x2 = -192
      y2 = 64
    end
    
    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawRect( x, y, 450, 120)
    surface.DrawRect(x2,y2, 240, 120)

    local digits = { 1,2,3,4,5,6, 7,8,9 }
    
    -- Fill out digits
    local os_time = os.time() --self:GetNWInt("ServerTime",os.time()-1386187182)+1386187182
    if self.PrevOSTime ~= os_time then
      self.Interval = CurTime() - self:GetNWFloat("IntervalResetTime",0)
      self.PrevOSTime = os_time
    end
    local i = self.Interval or -1e9
    local d = os.date("!*t",os_time)
    digits[1] = math.floor(d.hour / 10)
    digits[2] = math.floor(d.hour % 10)
    digits[3] = math.floor(d.min / 10)
    digits[4] = math.floor(d.min % 10)
    digits[5] = math.floor(d.sec / 10)
    digits[6] = math.floor(d.sec % 10)

    if (i <= (9*60+59)) and (i >= 0) then
      digits[7] = math.floor(i/60)
      digits[8] = math.floor((i%60)/10)
      digits[9] = math.floor((i%60)%10)
    else
      digits[7] = nil
      digits[8] = nil
      digits[9] = nil
    end

    for i,v in ipairs(digits) do
      local j = i-1
      local x_offset = x+40+55*j+25*math.floor(j/2)
      local y_offset = y+20
      if i > 6 then
        x_offset = x2-345+55*j+25*math.floor((j-1)/2)
        y_offset = y2+20
      end
--      if v == 1 then x_offset = x_offset+30 end

      self:DrawDigit(x_offset,y_offset,v)
--      draw.DrawText(v, "SubwayClock_FontGlow", x_offset,y_offset,gcolor)
--      draw.DrawText(v, "SubwayClock_Font", x_offset,y_offset,dcolor)
    end
    self:DrawDigit(x+40+90,y+20,".")
    self:DrawDigit(x2+70,y2+20,".")
--    draw.DrawText(".","SubwayClock_FontGlow", x+40+112,y+20,gcolor)
--    draw.DrawText(".","SubwayClock_Font", x+40+112,y+20,dcolor)
    
--    draw.DrawText(".","SubwayClock_FontGlow", x2+90,y2+20,gcolor)
--    draw.DrawText(".","SubwayClock_Font", x2+90,y2+20,dcolor)
  cam.End3D2D()
end
