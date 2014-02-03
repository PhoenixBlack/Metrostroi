Metrostroi.Lang = {}
Metrostroi.Lang.Languages = {}

CreateClientConVar("metrostroi_language","EN",true,false)

Metrostroi.Lang.Languages["EN"] = {
	Head_lights = "Head lights",
	Speed_indicator = "Speed indicator",
	
	Speed_limit = "speed limit %1 kph",
	
	Speed = "Speed",
	Overspeed = "overspeed",
	Train = "train",
	Metro = "metro",
	Error = "error",
}

Metrostroi.Lang.Languages["RU"] = {
	Head_lights = "ходовые фары",
	Speed_indicator = "Индикатор скорости",
	
	Speed_limit = "Ограничение скорости %1 км/ч",
	
	--Just debugging values :V
	Speed = "speedska",
	Overspeed = "overspeedski",
	Train = "trainya",
	Metro = "metrov",
	Error = "faultka",
}

-- For forward compatabilty
function Metrostroi.Lang.GetCurrentLanguage()
	return GetConVarString("metrostroi_language")
end

function Metrostroi.Lang.Get(id)
	return Metrostroi.Lang.Languages[GetConVarString("metrostroi_language")][id] 
end

local function gsubhelper(pattern,args)
	return args[tonumber(string.Right(string.len(pattern)-1))]
end

function Metrostroi.Lang.Format(id,args)
	return string.gsub(Metrostroi.Lang.Get(id),"%%%d+",function(sub) gsubhelper(sub,args) end)
end