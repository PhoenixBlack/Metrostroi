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