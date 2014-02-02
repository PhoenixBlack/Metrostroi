local TALK_RANGE = 1024
local COMMAND_PREFIX = "/"

-------------------------------------------------------------------------

local PREFIX_LENGTH = string.len(COMMAND_PREFIX)

local function HasPrefix(str) 
	return string.Left(str,PREFIX_LENGTH)==COMMAND_PREFIX
end

local function StripPrefix(str)
	return string.Right(str,string.len(str)-PREFIX_LENGTH)
end

local function GetCommand(str)
	if not HasPrefix(str) then return false end
	return string.Explode(" ",StripPrefix(str))[1]
end

local function AreInTalkRange(listener,speaker)
	return listener:GetShootPos():Distance(speaker:GetShootPos()) < TALK_RANGE
end

function GM:PlayerSay(sender,text,teamonly)
	if HasPrefix(text) then
		return ""
	end
end
--[[
function GM:PlayerSay(sender,text,teamonly)
	if HasPrefix(text) then 
		local cmd = GetCommand(text)
		
		if not cmd then
			sender:ChatPrint("Invalid command")
			return ""
		end
		
		if cmd == "all" then
			return "[GLOBAL]"..StripPrefix(text)
		end
		
		sender:ChatPrint("Invalid command")
		return ""
	end
end
--]]

function GM:PlayerCanSeePlayersChat(text,teamonly,listener,speaker)
	-- Admin command TODO:Don't show the prefix somehow
	if string.left(text,PREFIX_LENGTH) == "/a" and ply:IsAdmin() then
		return true
	end
	
	return AreInTalkRange(listener,speaker),true
end

function GM:PlayerCanHearPlayersVoice(listener,speaker)
	return AreInTalkRange(listener,speaker),true
end