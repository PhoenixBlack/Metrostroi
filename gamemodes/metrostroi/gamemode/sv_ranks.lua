
function SQLQuery( str, ... )
	str = string.format(str, ...)
	
	local ret = sql.Query(str)
	if ret == false then
		MsgN("[SQL Error] "..sql.LastError())
	end
	
	return ret
end

hook.Add("Initialize", "SetupSQL", function()
	sql.Query([[
	CREATE TABLE IF NOT EXISTS `metroplayerdata` (
		`steamid` varchar(19) CHARACTER SET ascii NOT NULL,
		`rank` tinyint(1) unsigned NOT NULL DEFAULT '1',
		`nick` varchar(32) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
		`nationality` char(2) CHARACTER SET ascii NOT NULL DEFAULT '',
		`playtime` int(32) unsigned NOT NULL DEFAULT '0',
		PRIMARY KEY (`steamid`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	]])
end)

hook.Add("PlayerInitialSpawn", "LoadSQL", function(ply)
	
	local sid = ply:SteamID()
	local nick = sql.SQLStr(ply:Nick())
	local ipport = ply:IPAddress()
	if ipport == "loopback" then ipport = "74.125.232.102:fart" end -- use google's ip incase its singleplayer
	local ip = string.Explode(":", ipport)[1] -- Gets ip and not ip:port
	
	
	local ret = SQLQuery("SELECT * FROM `metroplayerdata` WHERE `steamid` = '%s'", sid)
	if not ret then -- Incase we don't have a record of him already
	
		--Fetch nation from IP.
		local function complete(jsondata)
			local nationality = "US" -- Default to US
			if jsondata and not game.SinglePlayer() then
				local jsontbl = util.JSONToTable(jsondata) or {}
				nationality = sql.SQLStr(jsontbl["countryCode"] or "US")
			end
			
			SQLQuery("INSERT INTO `metroplayerdata` (`steamid`, `nick`, `nationality`) VALUES('%s', '%s', '%s');", sid, nick, nationality)
			hook.Run("PlayerDataReceived", ply)
		end
		http.Fetch(string.format("http://ip-api.com/json/%s", ip),complete,complete)
		
		ply.playtime = 0
		ply:SetTeam(RANK_GUEST)
		
	else -- We do have a record already!
		SQLQuery("UPDATE `metroplayerdata` SET `nick` = '%s' WHERE `steamid` = '%s'", nick, sid) -- Update our stored nickname
		
		ply:SetTeam(ret.rank)
		ply.playtime = ret.playtime
		
		hook.Run("PlayerDataReceived", ply)
	end
end)

hook.Add("PlayerDataReceived", "Blaha", function(ply)
	ply.datasetup = true
end)

local plymeta = FindMetaTable("Player")
function plymeta:SetDriversRank( rank )
	if not self.datasetup then MsgN("Can't set rank this early!") return end
	
	rank = math.Clamp(rank, 1, 5)
	self:SetTeam(rank)
	SQLQuery("UPDATE `metroplayerdata` SET `rank` = '%i' WHERE `steamid` = '%s'", rank, self:SteamID())
	
	MsgN(self:Nick().."'s rank has been set to "..RankToName(rank))
end

