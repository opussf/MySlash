MYSLASH_MSG_ADDONNAME = "MySlash"
MYSLASH_MSG_VERSION   = GetAddOnMetadata(MYSLASH_MSG_ADDONNAME,"Version")
MYSLASH_MSG_AUTHOR    = "opussf"

-- Colours
COLOR_RED = "|cffff0000";
COLOR_GREEN = "|cff00ff00";
COLOR_BLUE = "|cff0000ff";
COLOR_PURPLE = "|cff700090";
COLOR_YELLOW = "|cffffff00";
COLOR_ORANGE = "|cffff6d00";
COLOR_GREY = "|cff808080";
COLOR_GOLD = "|cffcfb52b";
COLOR_NEON_BLUE = "|cff4d4dff";
COLOR_END = "|r";

MySlash = {}

MySlash_cmds = {
		["eject"] = {
			desc = "ejects passenger from seat # or all seats",
			vers = 1.1,
			state = on,
			code = {
				"msg = math.floor( tonumber(msg) and tonumber(msg) or 0 )",
				"if msg ~= 0 then",
			    "     EjectPassengerFromSeat( msg )",
				"else",
				"     for x = 1, UnitVehicleSeatCount('player') do",
				"          EjectPassengerFromSeat(x)",
				"     end",
				"end" },
		},

		["xx"] = {
			desc = "attempts to dismount you and leave any vehicle you are in",
			vers = 1.05,
			state = on,
			code = {
				"if UnitInVehicle('player') then",
				"     VehicleExit()",
				"end",
				"if IsMounted() then",
				"     Dismount()",
				"end" },
		},

		["exp"] = {
			desc = "displays your experience and rested experience",
			vers = 1.15,
			state = on,
			code = {
				"local unit = 'player'",
				"if(UnitLevel( unit ) < 110) then",
				"     local XP = UnitXP(unit)",
				"     local MaxXP = UnitXPMax( unit )",
				"     local XPE = GetXPExhaustion()",
				"     print( ('Exp to level: %.2d k'):format( (MaxXP - XP) / 1000))",
				"     print( ('Rested exp: %.2d k'):format( XPE / 1000) )",
				"else",
				"     print('You are at max level.')",
				"end" },
		},

		["quitaftertaxi"] = {
			desc = "quits the game once you land from a taxi flight",
			vers = 1.14,
			alias = "qat",
			state = on,
			code = {
				"msg = string.lower(msg)",
				"if msg == 'cancel' then",
				"     print('Auto-'..(static.logout and 'Logout' or 'Exit')..' after Taxi has been cancelled')",
				"     static.cancel = true",
				"     return",
				"elseif msg == 'logout' then",
				"     static.logout = true",
				"end",
				"if static.cancel then",
				"     table.wipe(static)",
				"     return",
				"end",
				"if not(static.count) or static.count == 3 then",
				"     static.count = 0",
				"end",
				"static.count = static.count + 1",
				"if UnitOnTaxi( 'player' ) then",
				"     static.running = true",
				"     if static.count == 1 then",
				"          print('|cFFFF0000You will '..(static.logout and'Logout of' or 'Exit')..' the game once you land (to cancel type /quitaftertaxi cancel)')",
				"     end",
				"elseif not(static.running) and static.count == 1 then",
				"     print('|cFFFF0000Once you select a flight then land you will '..(static.logout and'Logout of' or 'Exit')..' the game (to cancel type /quitaftertaxi cancel)')",
				"elseif static.running and static.logout then",
				"     Logout()",
				"elseif static.running then",
				"     ForceQuit()",
				"end",
				"BillsUtils.Wait( 5, (MacroEditBox:GetScript('OnEvent')), MacroEditBox, 'EXECUTE_CHAT_LINE', '/quitaftertaxi' )" },
		},

		["popcorn"] = {
			desc = "Pop some popcorn",
			vers = 1.0,
			alias = "pop",
			state = on,
			code = {
				"if( PlayerHasToy( 162539 ) ) then",
				"    print( 'Popping corn' )",
				"    UseToy( 162539 )",
				"end" },
		},

	}


function MySlash.OnLoad()
	SLASH_MYSLASH1 = "/MYSLASH"
	SlashCmdList["MYSLASH"] = MySlash.Command
	MySlash_log = {}
	MySlash_Frame:RegisterEvent( "ADDON_LOADED" )
end
function MySlash.Print( msg, showName)
	-- print to the chat frame
	-- set showName to false to suppress the addon name printing
	if (showName == nil) or (showName) then
		msg = COLOR_YELLOW..MYSLASH_MSG_ADDONNAME.."> "..COLOR_END..msg
	end
	DEFAULT_CHAT_FRAME:AddMessage( msg )
end
function MySlash.Enable( index )
	-- from index ( 'xx' ) need to create:
	-- SLASH_XX1 = "/XX"  Note....  SLASH_XX2 = "/<alias>"
	-- and SlashCmdList["XX"] = funcref
	--print( "index: "..index )

	-- make the cmdList.  string of all commands and aliases, master cmd being first.  All uppercase
	local cmdList = string.upper( index ..( MySlash_cmds[index].alias and " "..MySlash_cmds[index].alias or "" ) )

	-- split this into a table / array to loop through.
	local cmdTable = { strsplit( " ", cmdList ) }

	for x = 1, #cmdTable do
		_G[("SLASH_%s%d"):format( cmdTable[1], x )] = ("/%s"):format( cmdTable[x] )
	end

	-- clean up the code for this command anc create a function reference
	local codeCleanup = { unpack( MySlash_cmds[index].code ) }
	for x = 1, #codeCleanup do
		codeCleanup[x] = codeCleanup[x]:gsub( "^%s*(.-)%s*$", "%1" )
		-- @TODO: do some real comment cleanup, don't just look for "--"
		-- "--" is not a comment  token ...
	end
	local code = table.concat( codeCleanup, " " )

	-- loadstring returns functionRef or nil if error
	fRef, errMsg = loadstring( code )
	if fRef then  -- not an error.  Should maybe actually check if a function?
		SlashCmdList[cmdTable[1]] = fRef  -- assign the function ref to the SlashCmdList table
	else
		MySlash.Print( index.." code errored out with: "..errMsg )
		table.insert( MySlash_log, ("%s code errored out with: %s"):format( index, errMsg ) )
	end
end


function MySlash.ADDON_LOADED()
	MySlash_Frame:UnregisterEvent( "ADDON_LOADED" )
	MySlash.EnableAll()
	MySlash.Print( ("ver:%s loaded. Useage: \"/MySlash help\" for help."):format( MYSLASH_MSG_VERSION ) )
end
function MySlash.EnableAll()
	for index, value in pairs( MySlash_cmds ) do
		if value then
			MySlash.Enable( index )
		end
	end
end

function MySlash.Command( msg )
	MySlash.Print( "COMMAND( "..msg.." )" )
end
MySlash.commandList = {

}