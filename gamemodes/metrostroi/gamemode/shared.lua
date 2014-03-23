GM.Name = "Metrostroi"
GM.Author = "HunterNL, Black Phoenix"
GM.Email = "N/A"
GM.Website = "N/A"

function GM:Initialize()
	self.BaseClass.Initialize( self )
end 

function GM:PlayerNoClip(ply)
	return ply:IsAdmin()
end

local cols = {
	Color(230,0,3),
	Color(0,151,54),
	Color(0,68,151)
}
function LineColorFromID( id )
	return cols[id]
end

function StationNameFromID( id )
	return "Station "..id
end
