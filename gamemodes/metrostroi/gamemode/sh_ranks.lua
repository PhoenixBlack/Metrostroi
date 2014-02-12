
RANK_GUEST = 1
RANK_3DEG = 2
RANK_2DEG = 3
RANK_1DEG = 4
RANK_DRIVER = 5

local t = {
	"Guests",
	"3rd Degree Drivers",
	"2nd Degree Drivers",
	"1st Degree Drivers",
	"1st Degree Driver-Instructors"
}
function RankToName( i )
	return t[i]
end

team.SetUp(RANK_GUEST,	RankToName(RANK_GUEST),		HSVToColor(0, 0.76, 0.8),		false)
team.SetUp(RANK_3DEG,		RankToName(RANK_3DEG),		HSVToColor(65, 0.76, 0.8),	false)
team.SetUp(RANK_2DEG,		RankToName(RANK_2DEG),		HSVToColor(107, 0.76, 0.8),	false)
team.SetUp(RANK_1DEG,		RankToName(RANK_1DEG),		HSVToColor(172, 0.76, 0.8),	false)
team.SetUp(RANK_DRIVER,	RankToName(RANK_DRIVER),	HSVToColor(237, 0.76, 0.8),	false)


local plymeta = FindMetaTable("Player")
function plymeta:IsSuperAdmin()
	return self:Team() == RANK_DRIVER
end

function plymeta:IsAdmin()
	return (self:Team() == RANK_1DEG) or self:IsSuperAdmin()
end
