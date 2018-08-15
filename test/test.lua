#!/usr/bin/env lua

addonData = { ["Version"] = "1.0",
}

require "wowTest"

test.outFileName = "testOut.xml"

MySlash_Frame = CreateFrame( "Frame" )

-- require the file to test
package.path = "../src/?.lua;" .. package.path
require "MySlash"


-- addon setup

MySlash_cmds["aliasTest"] = {
	desc = "Test of multiple aliases.",
	vers = 1.14,
	alias = "at yarp",
	enabled = true,
	code = {
		"print( 'AliasTest' )",
	},
}
MySlash_cmds["notactive"] = {
	desc = "Not active",
	vers = 1,
	enabled = false,
	code = {
		"print( \"Oh yeah\" )",
	},
}

function test.before()
	MySlash_cmds["notactive"].enabled=false
	SLASH_NOTACTIVE1 = nil
	MySlash.OnLoad()
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
function test.test_NotActive()
	assertIsNil( SLASH_NOTACTIVE1 )
end
function test.test_Enable()
	MySlash.Enable( "notactive" )
	assertEquals( "/NOTACTIVE", SLASH_NOTACTIVE1 )
end




--SLASH_MYSLASH1 = "/MYSLASH"
--SLASH_MYSLASH2 = "/alias"
--SlashCmdList["MYSLASH"] = MySlash.Command

test.run()
