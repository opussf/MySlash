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
			enabled = true,
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

		["exp"] = {
			desc = "displays your experience and rested experience",
			vers = 1.15,
			enabled = true,
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
function MySlash.Install( index )
	-- from index ( 'xx' ) need to create:
	-- SLASH_XX1 = "/XX"  Note....  SLASH_XX2 = "/<alias>"
	-- and SlashCmdList["XX"] = funcref
	--print( "Install( "..index.." )" )

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
		MySlash_log[time()] = ("%s code errored out with: %s"):format( index, errMsg )
	end
end
function MySlash.Enable( index )
	if( MySlash_cmds[index] ) then
		MySlash_cmds[index].enabled = true
		MySlash.Install( index )
	end
end


function MySlash.ADDON_LOADED()
	MySlash_Frame:UnregisterEvent( "ADDON_LOADED" )
	MySlash.InstallAll()
	MySlash.Print( ("ver:%s loaded. Useage: \"/MySlash help\" for help."):format( MYSLASH_MSG_VERSION ) )
end
function MySlash.InstallAll()
	for index, value in pairs( MySlash_cmds ) do
		if value and value.enabled then
			MySlash.Install( index )
		end
	end
end

function MySlash.List()
	for index, cmdStruct in pairs( MySlash_cmds ) do
		MySlash.Print( ("%s/%s%s    %s"):format( ( cmdStruct.enabled and COLOR_GREEN or COLOR_RED ), index, COLOR_END, cmdStruct.desc ), false )
	end
end


-----------------------
function MySlash.ParseCmd( msg )
	if msg then
		msg = string.lower( msg )
		local a, b, c = strfind( msg, "(%S+)" )  -- contiguous string of non-space chars.  a = start, b=len, c=str
		if a then
			-- c is the matched string
			return c, strsub( msg, b+2 )
		else
			return ""
		end
	end
end
function MySlash.Command( msg )
	local cmd, param = MySlash.ParseCmd( msg )
	local cmdFunc = MySlash.commandList[ cmd ]
	if cmdFunc then
		cmdFunc.func( param )
	end
end
function MySlash.PrintHelp()
	MySlash.Print( MYSLASH_MSG_ADDONNAME.." ("..MYSLASH_MSG_VERSION..") by "..MYSLASH_MSG_AUTHOR )
	for cmd, info in pairs( MySlash.commandList ) do
		MySlash.Print( ("%s %s %s -> %s"):format( SLASH_MYSLASH1, cmd, info.help[1], info.help[2] ) )
	end
end
MySlash.commandList = {
	["help"] = {
		["func"] = MySlash.PrintHelp,
		["help"] = { "", "Print this help." },
	},
	["list"] = {
		["func"] = MySlash.List,
		["help"] = { "", "List the slash commands." },
	},
}
