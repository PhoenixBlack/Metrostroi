
hook.Add("Initialize", "SetupSQL_Scoring", function()
	--SQLQuery("DROP TABLE IF EXISTS `metroscoring`")
	
	SQLQuery([[
	CREATE TABLE IF NOT EXISTS `metroscoring` (
		`steamid` varchar(19) NOT NULL,
		`score` int(32) NOT NULL,
		`timestamp` int(32) NOT NULL
	)]])
end)

local plymeta = FindMetaTable("Player")
function plymeta:AddMetroScore( am )
	am = math.Clamp(am, -2147483648, 2147483647) -- Clamp it to a 32bit, is this needed?
	
	SQLQuery("INSERT INTO `metroscoring` VALUES('%s', '%i', '%i');", self:SteamID(), am, os.time())
end

function plymeta:GetTotalMetroScore()
	local ret = SQLQuery("SELECT SUM(`score`) as totalscore FROM `metroscoring` WHERE `steamid` = '%s';", self:SteamID())
	
	if ret and ret[1].totalscore != "NULL" then
	 return ret[1].totalscore
	end
	
	return 0
end

local day = 24*60*60
function plymeta:GetDailyMetroScore()
	local dayago = os.time() - day
	local ret = SQLQuery("SELECT SUM(`score`) as dailyscore FROM `metroscoring` WHERE `steamid` = '%s' AND `timestamp` >= '%i';", self:SteamID(), dayago)
	
	if ret and ret[1].dailyscore != "NULL" then
	 return ret[1].dailyscore
	end
	
	return 0
end

