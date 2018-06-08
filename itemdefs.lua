local util = include( "modules/util" )
local commondefs = include( "sim/unitdefs/commondefs" )
local simdefs = include( "sim/simdefs" )

local item_templates =
{
	W93_item_teleportGrenade = util.extend( commondefs.npc_grenade_template )
	{
    		type = "W93_translocator_grenade",
		name = "WARP GRENADE",
		desc = "You probably shouldn't see this tooltip",
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_smoke_grenade_small.png",	
		profile_icon_100 = "gui/icons/item_icons/icon-item_smoke_grenade.png",	
		kanim = "kanim_stickycam",		
		sounds = {activate="SpySociety/Grenades/stickycam_deploy", bounce="SpySociety/Grenades/bounce"},
		traits = { guardBeacon = true, disposable = false, range = 4, aimRange = 3, cooldown = 0, cooldownMax = 1, keepPathing=true },
		value = 600,
		floorWeight = 2, 				
	},

	W93_item_snareGrenade = util.extend( commondefs.npc_grenade_template )
	{
    		type = "W93_translocator_grenade",
		name = "SNARE GRENADE",
		desc = "You probably shouldn't see this tooltip",
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_smoke_grenade_small.png",	
		profile_icon_100 = "gui/icons/item_icons/icon-item_smoke_grenade.png",	
		kanim = "kanim_scangrenade",		
		sounds = {activate="SpySociety/Grenades/stickycam_deploy", explode="SpySociety/Actions/Engineer/wireless_emitter", bounce="SpySociety/Grenades/bounce"},
		traits = { snareGrenade = true, scan = true, explodes = 0, range = 3, aimRange = 3, cooldown = 0, cooldownMax = 1, keepPathing=true, throwUnit="W93_item_snareGrenade", disposable = false },
		value = 1,
		floorWeight = 2, 			
	},
}

for id, template in pairs(item_templates) do
	template.id = id
end

return item_templates
