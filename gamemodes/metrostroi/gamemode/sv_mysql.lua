
--[[
MySQL module, idea by some guy on Facepunch, modified by Donkie

Uses a queueing system to prevent queries going lost incase we lose connection to the database.
Functions:
	string	SQLEscape(str)									-- Escapes a string to make it safe for queries
	
	void		SQLQuery(query, callback(data))	-- Queries the database. Argument #2 is a function, 
																				it'll be called with 1 argument, a table, with the returned data.
]]

require("mysqloo")

local ip = ""
local acc = ""
local pass = ""
local db = ""

local drawdebug = false
if not mysqloo then
	MsgN("MYSQLOO not initialized!")
	
	SQLEscape = function(str) return str end
	SQLQuery = function()end
else
	local queue = {}
	local db = mysqloo.connect( ip, acc, pass, db, 3306 )
	local haserrored = false
	function db:onConnected()
		MsgN("DB connected!")
		for k,v in pairs(queue) do
			SQLQuery(v[1], v[2])
		end
		queue = {}
	end
	
	function db:onConnectionFailed( err )
		MsgN("Couldn't connect to mysql database! \""..err.."\"")
		haserrored = true
	end
	db:connect()
	
	function SQLEscape( str )
		if not db then return str end
		return db:escape(str)
	end
	
	function SQLQuery( str, callback )
		if haserrored then return end
		
		callback = callback or function()end
		
		if drawdebug then MsgN("Executing query \""..str.."\"") end
		local q = db:query(str)
		if not q then
			if db:status() == mysqloo.DATABASE_NOT_CONNECTED then
				table.insert(queue, {str, callback})
				db:connect()
			end
			
			return
		end
		
		function q:onSuccess( data )
			if drawdebug then 
				MsgN("Query successfull!")
				if data and type(data) == "table" then PrintTable(data) end
			end
			callback(data)
		end
		
		function q:onError( err, str )
			if db:status() == mysqloo.DATABASE_NOT_CONNECTED then
				table.insert(queue, {str, callback})
				db:connect()
				return
			end
			
			MsgN("Query error! \""..err.."\"")
			MsgN("In query \""..str.."\"")
		end
		q:start()
	end
end
