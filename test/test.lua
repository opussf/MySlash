#!/usr/bin/env lua

addonData = { ["Version"] = "1.0",
}

require "wowTest"

test.outFileName = "testOut.xml"

-- require the file to test
package.path = "../src/?.lua;" .. package.path
require "MySlash"


-- addon setup

MySlash_cmds["aliasTest"] = {
	desc = "Test of multiple aliases.",
	vers = 1.14,
	alias = "at yarp",
	state = on,
	code = {
		"print( 'AliasTest' )",
	},
}
--[[
function test.before()
	MySlash.ADDON_LOADED()
end
function test.after()
end
function test.test_Command_help()
	MySlash.Command( "help" )
end
function test.test_Command_list()
	MySlash.Command( "list" )
end
function test.test_DefaultExtraCommands_normal()
	assertEquals( "/EJECT", SLASH_EJECT1 )
end
function test.test_DefaultExtraCommands_normal2()
	assertEquals( "/QUITAFTERTAXI", SLASH_QUITAFTERTAXI1 )
end
function test.test_Alias_Normal()
	assertEquals( "/ALIASTEST", SLASH_ALIASTEST1 )
end
function test.test_Alias_Alias1()
	assertEquals( "/AT", SLASH_ALIASTEST2 )
end
function test.test_Alias_Alias2()
	assertEquals( "/YARP", SLASH_ALIASTEST3 )
end
function test.test_DefaultExtraCommands_command()
	assertEquals( "function", type( SlashCmdList["ALIASTEST"]))
end
]]


--SLASH_MYSLASH1 = "/MYSLASH"
--SLASH_MYSLASH2 = "/alias"
--SlashCmdList["MYSLASH"] = MySlash.Command

test.run()
