local util = include( "modules/util" )
local simdefs = include("sim/simdefs")
local speechdefs = include( "sim/speechdefs" )

local function onAgentTooltip( tooltip, unit )
 	if unit:getTraits().poisoned then
		tooltip:addAbility( STRINGS.PROGEXTEND.UI.POISON, STRINGS.PROGEXTEND.UI.POISON_DESC,  "gui/icons/daemon_icons/icon-daemon_poison.png" )
	end
end

local function onGuardTooltip( tooltip, unit )
 	if unit:getTraits().uplink then
		tooltip:addAbility( STRINGS.PROGEXTEND.UI.ICEBREAK, STRINGS.PROGEXTEND.UI.ICEBREAK_DESC,  "gui/icons/programs_icons/store_icons/StorePrograms_power_uplink.png" )
	end
 	if unit:getTraits().crossfeed_source then
		tooltip:addAbility( STRINGS.PROGEXTEND.UI.CROSSFEED_SOURCE, STRINGS.PROGEXTEND.UI.CROSSFEED_SOURCE_DESC,  "gui/icons/programs_icons/store_icons/StorePrograms_crossfeed.png" )
	end
 	if unit:getTraits().crossfeed_target then
		tooltip:addAbility( STRINGS.PROGEXTEND.UI.CROSSFEED_TARGET, STRINGS.PROGEXTEND.UI.CROSSFEED_TARGET_DESC,  "gui/icons/programs_icons/store_icons/StorePrograms_crossfeed.png" )
	end
 	if unit:getTraits().flail_target then
		tooltip:addAbility( STRINGS.PROGEXTEND.UI.FLAIL_TARGET, STRINGS.PROGEXTEND.UI.FLAIL_TARGET_DESC,  "gui/icons/programs_icons/store_icons/StorePrograms_flail.png" )
	end
 	if unit:getTraits().teleportGrenade then
		tooltip:addAbility( STRINGS.PROGEXTEND.UI.TRANSLOCATOR_GRENADE, STRINGS.PROGEXTEND.UI.TRANSLOCATOR_GRENADE_DESC, "gui/icons/skills_icons/skills_icon_small/icon-item_reflex_small.png" )
	end
 	if unit:getTraits().snareGrenade then
		tooltip:addAbility( STRINGS.PROGEXTEND.UI.SNARE_GRENADE, STRINGS.PROGEXTEND.UI.SNARE_GRENADE_DESC, "gui/icons/skills_icons/skills_icon_small/icon-item_reflex_small.png" )
	end
end

local function onMainframeTooltip( tooltip, unit )
 	if unit:getTraits().uplink then
		tooltip:addAbility( STRINGS.PROGEXTEND.UI.ICEBREAK, STRINGS.PROGEXTEND.UI.ICEBREAK_DESC,  "gui/icons/programs_icons/store_icons/StorePrograms_power_uplink.png" )
	end
 	if unit:getTraits().crossfeed_source then
		tooltip:addAbility( STRINGS.PROGEXTEND.UI.CROSSFEED_SOURCE, STRINGS.PROGEXTEND.UI.CROSSFEED_SOURCE_DESC,  "gui/icons/programs_icons/store_icons/StorePrograms_crossfeed.png" )
	end
 	if unit:getTraits().crossfeed_target then
		tooltip:addAbility( STRINGS.PROGEXTEND.UI.CROSSFEED_TARGET, STRINGS.PROGEXTEND.UI.CROSSFEED_TARGET_DESC,  "gui/icons/programs_icons/store_icons/StorePrograms_crossfeed.png" )
	end
 	if unit:getTraits().flail_target then
		tooltip:addAbility( STRINGS.PROGEXTEND.UI.FLAIL_TARGET, STRINGS.PROGEXTEND.UI.FLAIL_TARGET_DESC,  "gui/icons/programs_icons/store_icons/StorePrograms_flail.png" )
	end
 	if unit:getTraits().mainframe_no_recapture then
		tooltip:addAbility( STRINGS.PROGEXTEND.UI.FORTIFY, STRINGS.PROGEXTEND.UI.FORTIFY_DESC,  "gui/icons/programs_icons/store_icons/StorePrograms_fortify.png" )
	end
 	if unit:getTraits().mainframe_suppress_range and not unit:getTraits().isDrone and unit:getPlayerOwner() ~= unit:getSim():getPC() then
		tooltip:addAbility( STRINGS.PROGEXTEND.UI.NULL_ZONE, util.sformat(STRINGS.PROGEXTEND.UI.NULL_ZONE_DESC, unit:getTraits().mainframe_suppress_range),  "gui/icons/arrow_small.png" )
	end
 	if unit:getTraits().greedBoost then
		tooltip:addAbility( STRINGS.PROGEXTEND.UI.GREED, util.sformat(STRINGS.PROGEXTEND.UI.GREED_DESC, unit:getTraits().greedBoost or 0),  "gui/icons/cashflow_icons/safes.png" )
	end
end

return 
{
	onAgentTooltip = onAgentTooltip,
	onGuardTooltip = onGuardTooltip,
	onMainframeTooltip = onMainframeTooltip,
}