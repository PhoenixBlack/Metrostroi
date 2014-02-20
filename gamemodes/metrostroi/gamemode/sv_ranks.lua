
function SQLQuery( str, ... )
	str = string.format(str, ...)
	
	local ret = sql.Query(str)
	if ret == false then
		MsgN("[SQL Error] "..sql.LastError())
		MsgN("In query \"" .. str .. "\"")
		debug.Trace()
	end
	
	return ret
end

hook.Add("Initialize", "SetupSQL", function()
	SQLQuery("DROP TABLE IF EXISTS `metroplayerdata`")
	
	SQLQuery([[
	CREATE TABLE IF NOT EXISTS `metroplayerdata` (
		`steamid` varchar(19) NOT NULL,
		`rank` tinyint(1) NOT NULL DEFAULT '1',
		`ip` varchar(21) NOT NULL,
		`nick` varchar(32) NOT NULL DEFAULT '',
		`playtime` int(32) NOT NULL DEFAULT '0',
		PRIMARY KEY (`steamid`))
	]])
end)

hook.Add("PlayerInitialSpawn", "LoadSQL", function(ply)
	
	local sid = ply:SteamID()
	local nick = sql.SQLStr(ply:Nick())
	local ipport = ply:IPAddress()
	if ipport == "loopback" then ipport = "74.125.232.102:fart" end -- use google's ip incase its singleplayer
	local ip = sql.SQLStr(string.Explode(":", ipport)[1]) -- Gets ip and not ip:port
	
	local ret = SQLQuery("SELECT * FROM `metroplayerdata` WHERE `steamid` = '%s'", sid)
	if not ret then -- Incase we don't have a record of him already
	
		SQLQuery("INSERT INTO `metroplayerdata` (`steamid`, `nick`, `ip`) VALUES('%s', %s, %s);", sid, nick, ip)
		
		ply.playtime = 0
		ply:SetTeam(RANK_GUEST)
		
	else -- We do have a record already!
		SQLQuery("UPDATE `metroplayerdata` SET `nick` = %s, `ip` = %s WHERE `steamid` = '%s'", nick, ip, sid) -- Update our stored nickname and ip
		
		ply:SetTeam(ret[1].rank)
		ply.playtime = ret[1].playtime
		
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

