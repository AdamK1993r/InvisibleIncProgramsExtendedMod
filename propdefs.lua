local util = include( "modules/util" )
local simdefs = include( "sim/simdefs" )
local commondefs = include("sim/unitdefs/commondefs")
local tool_templates = include("sim/unitdefs/itemdefs")

-------------------------------------------------------------
--

local MAINFRAME_TRAITS = commondefs.MAINFRAME_TRAITS
local SAFE_TRAITS = commondefs.SAFE_TRAITS

local onMainframeTooltip = commondefs.onMainframeTooltip
local onSoundBugTooltip = commondefs.onSoundBugTooltip
local onBeamTooltip = commondefs.onBeamTooltip
local onConsoleTooltip = commondefs.onConsoleTooltip
local onStoreTooltip = commondefs.onStoreTooltip
local onDeviceTooltip = commondefs.onDeviceTooltip
local onSafeTooltip = commondefs.onSafeTooltip

local prop_templates =
{
	extra_server_terminal = 
	{
		type = "store", 
		name =  STRINGS.PROGEXTEND.PROPS.EXTRA_SERVER_TERMINAL,
		rig ="corerig",
		onWorldTooltip = onDeviceTooltip,
		kanim = "kanim_serverTerminal", 
		abilities = { "showItemStore" },
		traits = util.extend( MAINFRAME_TRAITS )
		{
			moveToDevice=true,
			sightable=true,
			cover = true,
			impass = {0,0},
			storeType="extraserver",
			noMandatoryItems = true,
			bigshopcat = true,
			recap_icon = "big_program_shop",
		},
		sounds = {appeared="SpySociety/HUD/gameplay/peek_positive",spot="SpySociety/Objects/shopcat" }
	},
}

-- Reassign key name to value table.
for id, template in pairs(prop_templates) do
	template.id = id
end

return prop_templates