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




--[[
function MeToo.BuildMountSpells()
	-- Build a table of [spellID] = "mountName"
	-- This needs to be expired or rebuilt when a new mount is learned.
	MeToo.mountSpells = {}
	local mountIDs = C_MountJournal.GetMountIDs()
	for _, mID in pairs(mountIDs) do
		--print( mID )
		mName, mSpellID = C_MountJournal.GetMountInfoByID( mID )
		MeToo.mountSpells[ mSpellID ] = mName
	end
end
function MeToo.GetMountID( unit )
	-- return the current mount ID...
	-- match this against the mounts you know.
	for an=1,40 do  -- scan ALL of the auras...  :(
		aName, _, aIcon, _, aType, _, _, _, _, aID = UnitAura( unit, an )
		if( aName and MeToo.mountSpells[aID] and MeToo.mountSpells[aID] == aName ) then
			--print( unit.." is on: "..aName )
			return aID, aName
		end
	end
end
function MeToo.PerformMatch()
	if( UnitIsBattlePetCompanion( "target" ) ) then  -- target is battle pet
		speciesID = UnitBattlePetSpeciesID( "target" )
		petType = UnitBattlePetType( "target" )

		isOwned = ( C_PetJournal.GetOwnedBattlePetString( speciesID ) and true or nil )
		-- returns a string of how many you have or nil if you have none.   Convert this to 1 - nil for

		if isOwned then
			petName = C_PetJournal.GetPetInfoBySpeciesID( speciesID )  -- get the petName
			_, petID = C_PetJournal.FindPetIDByName( petName )  -- == speciesID from the petName

			currentPet = C_PetJournal.GetSummonedPetGUID()  -- get your current pet

			if( currentPet ) then -- you have one summoned
				currentSpeciesID = C_PetJournal.GetPetInfoByPetID( currentPet )  -- get the speciesID of your current pet
			end

			-- summon pet if
				-- no current pet ( currentPet == nil )
				-- or
					-- currentPet
					-- AND
					-- speciesID != currentSpeciesID
			if( (not currentPet) or
					( currentPet and speciesID ~= currentSpeciesID ) ) then
				-- no current pet
				-- or current pet, and species do not match
				C_PetJournal.SummonPetByGUID( petID )
				if( MeToo_options.companionSuccess_doEmote and strlen( MeToo_options.companionSuccess_emote ) > 0 ) then
					DoEmote( MeToo_options.companionSuccess_emote, "player" )
				end
			else
				--MeToo.Print( "Pets are the same" )
			end
		else
			if( MeToo_options.companionFailure_doEmote and strlen( MeToo_options.companionFailure_emote ) > 0 ) then
				DoEmote( MeToo_options.companionFailure_emote, "player" )
			end
		end
	elseif( UnitIsPlayer( "target" ) ) then
		_, unitSpeed = GetUnitSpeed( "target" )
		--print( "Target unitSpeed: "..unitSpeed )
		if( unitSpeed ~= 7 ) then  -- there is no IsMounted( unitID ), use the UnitSpeed to guess if they are mounted.
			myMountID = nil
			if( not MeToo.mountSpells ) then  -- build the mount spell list here
				MeToo.BuildMountSpells()
			end
			if( IsMounted() ) then  -- if you are mounted, scan and find your mount ID
				myMountID, myMountName = MeToo.GetMountID( "player" )
			end
			theirMountID, theirMountName = MeToo.GetMountID( "target" )   --

			if( theirMountID and theirMountID ~= myMountID ) then  -- not the same mount
				mountSpell = C_MountJournal.GetMountFromSpell( theirMountID )

				_, _, _, _, isUsable = C_MountJournal.GetMountInfoByID( mountSpell ) -- isUsable = can mount

				if( isUsable ) then
					if( MeToo_options.mountSuccess_doEmote and strlen( MeToo_options.mountSuccess_emote ) > 0 ) then
						DoEmote( MeToo_options.mountSuccess_emote, MeToo_options.mountSuccess_useTarget and "target" or "player" )
					end
					if( not IsFlying() ) then  -- only do this if you are NOT flying...
						C_MountJournal.SummonByID( mountSpell )
					else
						MeToo.Print( "You are flying. Not going to try to change mounts." )
					end
				else
					if( MeToo_options.mountFailure_doEmote and strlen( MeToo_options.mountFailure_emote ) > 0 ) then
						DoEmote( MeToo_options.mountFailure_emote, MeToo_options.mountFailure_useTarget and "target" or "player" )
					end
				end
			end
		end
	else
		-- MeToo.Print( "Target is NOT a battle pet or player." )
	end
end
-----

function MeToo.ParseCmd( msg )
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
function MeToo.Command( msg )
	local cmd, param = MeToo.ParseCmd( msg )
	--MeToo.Print( "cl:"..cmd.." p:"..(param or "nil") )
	local cmdFunc = MeToo.commandList[cmd]
	if cmdFunc then
		cmdFunc.func( param )
	else
		MeToo.PerformMatch()
	end
end
function MeToo.PrintHelp()
	MeToo.Print( METOO_MSG_ADDONNAME.." ("..METOO_MSG_VERSION..") by "..METOO_MSG_AUTHOR )
	MeToo.Print( "Use: /METOO or /M2 targeting a player or companion pet." )
	for cmd, info in pairs( MeToo.commandList ) do
		MeToo.Print( string.format( "%s %s %s -> %s",
				SLASH_METOO1, cmd, info.help[1], info.help[2] ) )
	end
end
MeToo.commandList = {
	["help"] = {
		["func"] = MeToo.PrintHelp,
		["help"] = { "", "Print this help."}
	},
	["options"] = {
		["func"] = function() InterfaceOptionsFrame_OpenToCategory( METOO_MSG_ADDONNAME ) end,
		["help"] = { "", "Open the options panel." }
	},
}
]]
