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
MySlash.Frame = CreateFrame( "Frame" )
MySlash.Frame:RegisterEvent( "ADDON_LOADED" )
MySlash.Frame:SetScript( "OnEvent", MySlash[event] )

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

		["gfx"] = {
			desc = "restart the gfx engine",
			vers = 1,
			state = on,
			code = {
				"RestartGx()" },
		},

		["fquit"] ={
			desc = "fast quit / force quit",
			vers = 1,
			state = on,
			code = {
				"ForceQuit()" },
		},

		["tele"] = {
			desc = "teleport in/out of lfg dungeon",
			vers = 1,
			state = on,
			code = {
				"LFGTeleport(IsInInstance())" },
		},

		["p2r"] = {
			desc = "convert your party to a raid",
			vers = 1,
			state = on,
			code = {
				"ConvertToRaid()" },
		},

		["r2p"] = {
			desc = "convert your raid to a party",
			vers = 1,
			state = on,
			code = {
				"ConvertToParty()" },
		},

		["clear"] = {
			desc = "clear all world markers (smoke bombs)",
			vers = 1,
			state = on,
			code =  {
				"ClearRaidMarker()" },
		},

		["cloak"] = {
			desc = "toggle your cloak visibility",
			vers = 1,
			state = on,
			code = {
				"ShowCloak( not(ShowingCloak()) )" },
		},

		["helm"] = {
			desc = "toggle your helm visibility",
			vers = 1,
			state = on,
			code = {
				"ShowHelm( not(ShowingHelm()) )" },
		},

		["lvgrp"] = {
			desc = "will leave your group",
			vers = 1.05,
			state = on,
			code = {
				"LeaveParty()" },
		},

		["passloot"] = {
			desc = "will toggle pass on loot",
			vers = 1.05,
			state = on,
			code = {
				"local passing = GetOptOutOfLoot()",
				"if passing then",
				"     SetOptOutOfLoot()",
				"     print('You are no longer passing on all loot')",
				"else",
				"     SetOptOutOfLoot(1)",
				"     print('You are now passing on all loot')",
				"end" },
		},

		["in"] = {
			desc = "will run a slash command in a set amount of time \"/in ## /whatever\" or \"/in #:## /whatever\" (not all slash commands can be delayed)",
			vers = 3.02,
			state = on,
			code = {
				"local delay, what = string.split(' ', msg, 2)",
				"if string.find( delay, ':' ) then",
				"     local mins, secs = string.split(':', delay)",
				"     mins = tonumber(mins)",
				"     secs = tonumber(secs)",
				"     delay = (mins * 60) + secs",
				"else",
				"     delay = tonumber(delay)",
				"end",
				"if delay <= 0 then",
				"     print('/in delay must be greater than 0')",
				"     return",
				"end",
				"BillsUtils.Wait( delay, (MacroEditBox:GetScript('OnEvent')), MacroEditBox, 'EXECUTE_CHAT_LINE', what )" },
		},

		["ready"] = {
			desc = "initiate a ready check",
			vers = 1.1,
			state = on,
			code = {
				"DoReadyCheck()" },
		},

		["role"] = {
			desc = "initiates a role check",
			vers = 1.1,
			state = on,
			code = {
				"InitiateRolePoll()" },
		},

		["sha"] = {
			desc = "checks to see if you did the \"Sha of Anger\"",
			vers = 1.25,
			state = on,
			code = {
				"if ( IsQuestFlaggedCompleted(32099) ) then",
				"     print(\"You have completed \\\"Sha of Anger\\\" this week.\")",
				"else",
				"     print(\"You haven\'t completed \\\"Sha of Anger\\\" this week.\")",
				"end" },
		},

		["exp"] = {
			desc = "displays your experience and rested experience",
			vers = 1.15,
			state = on,
			code = {
				"local unit = 'player'",
				"if(UnitLevel( unit ) < 90) then",
				"     local XP = UnitXP(unit)",
				"     local MaxXP = UnitXPMax( unit )",
				"     local XPE = GetXPExhaustion()",
				"     print( ('Exp to level: %.2d k'):format( (MaxXP - XP) / 1000))",
				"     print( ('Rested exp: %.2d k'):format( XPE / 1000) )",
				"else",
				"     print('You are at max level.')",
				"end" },
		},

		["toast"] = {
			desc = "sets or clears your Battle-Net toast message",
			vers = 1,
			state = on,
			 code = {
				"if msg ~= '' then",
				"     BNSetCustomMessage( msg )",
				"     print('Toast message set to: '..msg)",
				"else",
				"     BNSetCustomMessage( '' )",
				"     print('Toast message cleared' )",
				"end" },
		},

		["names"] = {
			desc = "toggles the display of names in the 3d world",
			vers = 1.3,
			state = on,
			code = {
				"if InCombatLockdown() then",
				"     print('You can no longer toggle names while in combat')",
				"     return",
				"end",
				"if type(saved.showing) ~= 'boolean' then",
				"     saved.showing = true",
				"end",
				"local what = { 'UnitNameEnemyGuardianName', 'UnitNameEnemyPetName', 'UnitNameEnemyPlayerName', 'UnitNameEnemyTotemName',",
				"     'UnitNameFriendlyGuardianName', 'UnitNameFriendlyPetName', 'UnitNameFriendlyPlayerName', 'UnitNameFriendlySpecialNPCName',",
				"     'UnitNameFriendlyTotemName', 'UnitNameGuildTitle', 'UnitNameHostleNPC', 'UnitNameNPC',",
				"     'UnitNameNonCombatCreatureName', 'UnitNameOwn', 'UnitNamePlayerGuild', 'UnitNamePlayerPVPTitle',",
				"     'nameplateShowEnemies', 'nameplateShowEnemyGuardians', 'nameplateShowEnemyPets', 'nameplateShowEnemyTotems',",
				"     'nameplateShowFriendlyGuardians', 'nameplateShowFriendlyPets', 'nameplateShowFriendlyTotems', 'nameplateShowFriends',",
				"     }",
				"if saved.showing then",
				"     for x = 1, #what do",
				"          saved[what[x]] = GetCVar(what[x])",
				"          SetCVar( what[x], '0')",
				"     end",
				"     saved.showing = false",
				"else",
				"     for x = 1, #what do",
				"          SetCVar( what[x], saved[what[x]])",
				"     end",
				"     saved.showing = true",
				"end" },
		},

		["cdown"] = {
			desc = "counts down from passed number by optional second passed number",
			vers = 1.1,
			state = on,
			code = {
				"local delay, by = string.split(' ', msg)",
				"delay = tonumber(delay)",
				"by = tonumber(by)",
				"if not(by) then by = 1 end",
				"if delay then",
				"	for x = delay, 0, -by do",
				"		BillsUtils.Wait( delay, SendChatMsg, tostring(x), 'SAY' )",
				"	end",
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

		["mount"] = {
			desc = "summons the first mount matching the passed string (attempts flying mounts first)",
			vers = 2.04,
			state = on,
			code = {
				"msg = string.lower(msg)",
				"if InCombatLockdown() then",
				"     print('You cannot summon a mount this way while in combat')",
				"     return",
				"elseif msg == '' then",
				"     print('proper usage is /mount partialmountname')",
				"     return",
				"elseif msg == 'random' then",
				"     C_MountJournal.Summon(0)",
				"     print('Trying to summon a random favorite mount for you')",
				"     return",
				"end",
				"local flyable = IsFlyableArea()",
				"local Match, Name",
				"for x = 1, C_MountJournal.GetNumMounts() do",
				"     local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, hideOnChar, isCollected = C_MountJournal.GetMountInfo(x)",
				"     if not( hideOnChar ) and isUsable and isCollected then",
				"          local creatureDisplayID, descriptionText, sourceText, isSelfMount, mountType = C_MountJournal.GetMountInfoExtra(x)",
				"          if string.find( string.lower(creatureName), msg, nil, true ) then",
				"               if (flyable and (mountType == 247 or mountType == 248)) or not(flyable) then",
				"                    Match, Name = x, creatureName",
				"                    break",
				"               elseif not( Match ) then",
				"                    Match, Name = x, creatureName",
				"               end",
				"          end",
				"     end",
				"end",
				"if Match then",
				"     C_MountJournal.Summon(Match)",
				"     print('Summoning '..Name)",
				"else",
				"     print('No usable mount matching \\\"'..msg..'\\\" was found.')",
				"end" },
		},

		["critter"] = {
			desc = "summons the first vanity pet matching the passed string (attempts favorite pets first)",
			vers = 1.22,
			alias = "vpet",
			state = on,
			code = {
				"msg = string.lower(msg)",
				"if InCombatLockdown() then",
				"     print('You cannot summon a pet this way while in combat')",
				"     return",
				"elseif msg == '' then",
				"     print('proper usage is /critter PartialPetName')",
				"     return",
				"end",
				"local numPets, numOwned = C_PetJournal.GetNumPets()",
				"local Match, Name",
				"for x = 1, numPets do",
				"     local petID, speciesID, owned, customName, level, favorite, isRevoked, speciesName, icon, petType, companionID, tooltip, description, isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoByIndex(x)",
				"     if owned and ( string.find( (string.lower(customName and customName or '')), msg, nil, true ) or string.find( (string.lower(speciesName)), msg, nil, true )  )then",
				"          if favorite then",
				"               Match, Name = petID, string.find( string.lower(customName and customName or ''), msg, nil, true) and customName or speciesName",
				"               break",
				"          elseif not( Match ) then",
				"               Match, Name = petID, string.find( string.lower(customName and customName or ''), msg, nil, true) and customName or speciesName",
				"          end",
				"     end",
				"end",
				"if Match then",
				"     C_PetJournal.SummonPetByGUID(Match)",
				"     print('Summoning '..Name)",
				"else",
				"     print('No owned vanity pet matching \\\"'..msg..'\\\" was found.')",
				"end" },
		},

		["wboss"] = {
			desc = "Are the weekly world bosses/quests done?",
			vers = 1.2,
			alias = "weekly",
			state = on,
			code = {
				"local completed, uncomplete = {}, {}",
				"local wb = { 	Ordos = 33118,",
				"     ['Trove of the Thunder King'] = 32609,",
				"     Celestials = 33117,",
				"     Galleon = 32098,",
				"     Nalak = 32518,",
				"     Oondasta = 32519,",
				"     ['Sha of Anger'] = 32099,",
				"     ['Victory In Wintergrasp'] = {13181, 13183},",
				"     ['Victory In Tol Barad'] = {28882, 28884},",
				"     ['Empowering the Hourglass'] = 33338,",
				"     ['Strong Enough To Survive'] = 33334,",
				"}",
				"for k, v in pairs( wb ) do",
				"     if (type(v) == 'table' and (IsQuestFlaggedCompleted(v[1]) or IsQuestFlaggedCompleted(v[2]))) or (type(v) == 'number' and IsQuestFlaggedCompleted(v)) then",
				"          completed[#completed + 1] = k",
				"     else",
				"          uncomplete[#uncomplete + 1] = k",
				"     end",
				"end",
				"table.sort(completed)",
				"table.sort(uncomplete)",
				"print('Weekly world bosses / quest complete?')",
				"if #completed > 0 then",
				"     print('\\n|cFF66CC00Completed:')",
				"     for x = 1, #completed do",
				"          print('|cff80FF00      '..completed[x])",
				"     end",
				"end",
				"if #uncomplete > 0 then",
				"     print('\\n|cFFFF3333Uncomplete:')",
				"     for x = 1, #uncomplete do",
				"          print('|cFFFF6666      '..uncomplete[x])",
				"     end",
				"end" },
		},

		["dboss"] = {
			desc = "Are the daily world bosses/quests done?",
			vers = 1.15,
			alias = "daily",
			state = on,
			code = {
				"local completed, uncomplete = {}, {}",
				"local db = { 	['Path of the Mistwalker'] = 33374,",
				"     ['Timeless Trivia'] = 33211,",
				"     ['Neverending Spritewood'] = 32961,",
				"     Zarhym = 32962,",
				"     ['Archiereus of Flame'] = 333112,",
				"     ['Blingtron 4000'] = 31752,",
				"}",
				"for k, v in pairs( db ) do",
				"     if (type(v) == 'table' and (IsQuestFlaggedCompleted(v[1]) or IsQuestFlaggedCompleted(v[2]))) or (type(v) == 'number' and IsQuestFlaggedCompleted(v)) then",
				"          completed[#completed + 1] = k",
				"     else",
				"          uncomplete[#uncomplete + 1] = k",
				"     end",
				"end",
				"table.sort(completed)",
				"table.sort(uncomplete)",
				"print('Daily world bosses / quest complete?')",
				"if #completed > 0 then",
				"     print('\\n|cFF66CC00Completed:')",
				"     for x = 1, #completed do",
				"          print('|cff80FF00      '..completed[x])",
				"     end",
				"end",
				"if #uncomplete > 0 then",
				"     print('\\n|cFFFF3333Uncomplete:')",
				"     for x = 1, #uncomplete do",
				"          print('|cFFFF6666      '..uncomplete[x])",
				"     end",
				"end" },
		},

	}

function MySlash.Print( msg, showName)
	-- print to the chat frame
	-- set showName to false to suppress the addon name printing
	if (showName == nil) or (showName) then
		msg = COLOR_YELLOW..MYSLASH_MSG_ADDONNAME.."> "..COLOR_END..msg
	end
	DEFAULT_CHAT_FRAME:AddMessage( msg )
end
function MySlash.Enable( index )

	local cmdKey = "SLASH_%s"
	cmdName = cmdKey:format( string.upper( index ) )  -- build the cmdName "SLASH_cmd" base
		_G[("%s1"):format( cmdName )] = ("/%s"):format( string.upper( index ) )  -- assign this to the global variable
	--RunScript( ('SLASH_%s1 = "/%s"'):format( cmdName, string.lower( index ) ) )
	local codeCleanup = { unpack( MySlash_cmds[index].code ) }
	for x = 1, #codeCleanup do
		codeCleanup[x] = codeCleanup[x]:gsub( "^%s*(.-)%s*$", "%1" )
		-- @TODO: do some real comment cleanup, don't just look for "--"
		-- "--" is not a comment  token ...
	end

	local code = table.concat( codeCleanup, " " )

	if MySlash_cmds[index].alias then
		--print( "there is an alias: "..MySlash_cmds[index].alias )
		local aliases = { strsplit( " ", MySlash_cmds[index].alias ) }
		for x = 1, #aliases do
			_G[("%s%d"):format( cmdName, x+1 )] = ("/%s"):format( string.upper( aliases[x] ) )
			thing = ("%s%d"):format( cmdName, x+1 )
			--print( thing )
		end
	end
	--SlashCmdList[cmdName] = string.format( "function(msg) %s end", code )
	print("RunScript: "..index )
	RunScript( ('SlashCmdList["%s"] = function(msg) %s end'):format( cmdName, code ) )
	--[[


	if CMDS[index] then
		local cmdName = cmdKey:format(strupper(index))
		local CodeCleanup = {unpack(CODE[index])}
		for x = 1, #CodeCleanup do
			CodeCleanup[x] = string.trim( CodeCleanup[x]) -- removes excess spaces at start / end
			local found = string.find( CodeCleanup[x], "--", 1, true) -- removes comments
			if found then
				if found == 1 then
					CodeCleanup[x] = ""
				else
					CodeCleanup[x] = string.sub(CodeCleanup[x], 1, found - 1)
				end
			end
		end
		local code = string.join(" ", unpack(CodeCleanup) )
		code = string.format("local saved = SlashMagic_CmdVars['%s'] local static = SlashMagicStaticValues['%s'] ", index, index) .. code
		RunScript( ('SLASH_%s1 = "/%s"'):format( cmdName, strlower(index) ) )
		if ALIAS[index] then
			local aliases = { string.split(" ", ALIAS[index]) }
			for x = 1, #aliases do
				RunScript( ('SLASH_%s%d = "/%s"'):format( cmdName, x+1, strlower(aliases[x]) ) )
			end
		end
		RunScript( ('SlashCmdList["%s"] = function(msg) %s end'):format( cmdName, code) )
	end

	]]

end


function MySlash.ADDON_LOADED()
	MySlash.Frame:UnregisterEvent( "ADDON_LOADED" )
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

SLASH_MYSLASH1 = "/MYSLASH"
SlashCmdList["MYSLASH"] = MySlash.Command



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
