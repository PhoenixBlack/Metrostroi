--------------------------------------------------------------------------------
-- Clientside utility functions
--------------------------------------------------------------------------------
local bitmap_font_1 = {
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



--------------------------------------------------------------------------------
-- Draw bitmap digit
function Metrostroi.DrawClockDigit(cx,cy,scale,digit)
	local bitmap = bitmap_font_1[digit]
	if not bitmap then return end

	local w=12*scale
	local p=8*scale
	for i=1,4*7 do
		local x = (i-1)%4
		local y = math.floor((i-1)/4)
		if bitmap[i] == 1 then
			for z=1,6,1 do
				surface.SetDrawColor(Color(255,60,0,math.max(0,30-1*z*z)))
				surface.DrawRect(cx+x*w-z*scale, cy+y*w-z*scale, p+2*z*scale, p+2*z*scale)
			end

			surface.SetDrawColor(Color(255,240,0,255))
			surface.DrawRect(cx+x*w, cy+y*w, p, p)
		end
	end
end





function Metrostroi.PositionFromPanel(panel,button_id_or_vec,z)
	local self = ENT
	local panel = self.ButtonMap[panel]
	if not panel then return Vector(0,0,0) end
	if not panel.buttons then return Vector(0,0,0) end
	
	-- Find button or read position
	local vec
	if type(button_id_or_vec) == "string" then
		local button
		for k,v in pairs(panel.buttons) do
			if v.ID == button_id_or_vec then
				button = v
				break
			end
		end
		vec = Vector(button.x,button.y,z or 0)
	else
		vec = button_id_or_vec
	end

	-- Convert to global coords
	vec.y = -vec.y
	vec:Rotate(panel.ang)
	return panel.pos + vec * panel.scale
end

function Metrostroi.AngleFromPanel(panel,ang)
	local self = ENT
	local panel = self.ButtonMap[panel]
	if not panel then return Vector(0,0,0) end
	local true_ang = panel.ang + Angle(0,0,0)
	true_ang:RotateAroundAxis(panel.ang:Up(),ang or -90)
	return true_ang
end

function Metrostroi.ClientPropForButton(prop_name,config)
	local self = ENT
	self.ClientProps[prop_name] = {
		model = config.model or "models/metrostroi/81-717/button07.mdl",
		pos = Metrostroi.PositionFromPanel(config.panel,config.button or config.pos,(config.z or 0.2)),
		ang = Metrostroi.AngleFromPanel(config.panel,config.ang)
	}
end