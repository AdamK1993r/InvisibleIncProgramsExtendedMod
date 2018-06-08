local util = include( "modules/util" )

local function FindIndexOf(val, array)
    for k,v in pairs(array) do 
        if v == val then return k end
    end
end

local function earlyInit( modApi )
	local scriptPath = modApi:getScriptPath()
	include( scriptPath .. "/hud" )
end

local function init( modApi )
	local dataPath = modApi:getDataPath()
	local scriptPath = modApi:getScriptPath()
	KLEIResourceMgr.MountPackage( dataPath .. "/gui.kwad", "data" )
	KLEIResourceMgr.MountPackage( dataPath .. "/anims.kwad", "data" )
	KLEIResourceMgr.MountPackage( dataPath .. "/anims2.kwad", "data" )
	modApi:addGenerationOption("extended_programs", STRINGS.PROGEXTEND.OPTIONS.ENABLE_PROGRAMS, STRINGS.PROGEXTEND.OPTIONS.ENABLE_PROGRAMS_TIP,{noUpdate = true, difficulties={{1,false},{2,false},{3,true},{4,true},{5,true},{6,true},{7,true},{8,true}}})
	modApi:addGenerationOption("extended_daemons", STRINGS.PROGEXTEND.OPTIONS.ENABLE_DAEMONS, STRINGS.PROGEXTEND.OPTIONS.ENABLE_DAEMONS_TIP,{noUpdate = true, difficulties={{1,false},{2,false},{3,true},{4,true},{5,true},{6,true},{7,true},{8,true}}})
	modApi:addGenerationOption("extended_algorithms", STRINGS.PROGEXTEND.OPTIONS.ENABLE_ALGORITHMS, STRINGS.PROGEXTEND.OPTIONS.ENABLE_ALGORITHMS_TIP,{noUpdate = true, difficulties={{1,false},{2,false},{3,true},{4,true},{5,true},{6,true},{7,true},{8,true}}})
	modApi:addGenerationOption("extended_alarms", STRINGS.PROGEXTEND.OPTIONS.ENABLE_ALARMS, STRINGS.PROGEXTEND.OPTIONS.ENABLE_ALARMS_TIP,{values = {0,1,2}, value = 0, noUpdate = true, strings = {STRINGS.PROGEXTEND.OPTIONS.ENABLE_ALARMS_FALSE,STRINGS.PROGEXTEND.OPTIONS.ENABLE_ALARMS_TRUE,STRINGS.PROGEXTEND.OPTIONS.ENABLE_ALARMS_TRUE_2}, difficulties={{1,0},{2,0},{3,0},{4,0},{5,0},{6,0},{7,0},{8,0}}})
	modApi:addGenerationOption("shop_programs", STRINGS.PROGEXTEND.OPTIONS.ENABLE_SHOP, STRINGS.PROGEXTEND.OPTIONS.ENABLE_SHOP_TIP,{noUpdate = true, difficulties={{1,false},{2,false},{3,true},{4,true},{5,true},{6,true},{7,true},{8,true}}})
	modApi:addGenerationOption("rarity_rebalance", STRINGS.PROGEXTEND.OPTIONS.ENABLE_RARITY, STRINGS.PROGEXTEND.OPTIONS.ENABLE_RARITY_TIP,{noUpdate = true, difficulties={{1,false},{2,false},{3,true},{4,true},{5,true},{6,true},{7,true},{8,true}}})
	modApi:addGenerationOption("alarm_wheel", STRINGS.PROGEXTEND.OPTIONS.ENABLE_WHEEL, STRINGS.PROGEXTEND.OPTIONS.ENABLE_WHEEL_TIP,{enabled=false, noUpdate = true, difficulties={{1,false},{2,false},{3,false},{4,false},{5,false},{6,false},{7,false},{8,true}}})
	modApi:addGenerationOption("counter_ai", STRINGS.PROGEXTEND.OPTIONS.ENABLE_COUNTER_AI, STRINGS.PROGEXTEND.OPTIONS.ENABLE_COUNTER_AI_TIP,{values={-1,0,1,2,3,4,5}, value = -1, noUpdate = true, strings = { STRINGS.PROGEXTEND.OPTIONS.ENABLE_COUNTER_AI_DISABLED, STRINGS.PROGEXTEND.OPTIONS.ENABLE_COUNTER_AI_OMNI, "1", "2", "3", "4", "5"},difficulties={{1,-1},{2,-1},{3,-1},{4,0},{5,-1},{6,5},{7,-1},{8,1}} })
	modApi:addGenerationOption("endless_daemons", STRINGS.PROGEXTEND.OPTIONS.ENDLESS_DAEMONS, STRINGS.PROGEXTEND.OPTIONS.ENDLESS_DAEMONS_TIP,{values={50,2,4,6,8,10,12,14,16,18}, value = 4, noUpdate = true, strings = { STRINGS.PROGEXTEND.OPTIONS.ENDLESS_DAEMONS_DISABLED, "2", "4", "6", "8", "10", "12", "14", "16", "18"}, difficulties={{1,50},{2,8},{3,4},{4,4},{5,4},{6,4},{7,4},{8,4}} })

	include( scriptPath .. "/W93_translocator_grenade" )

	local alarm_states = include( scriptPath .. "/alarm_states" )
	for i,item in pairs(alarm_states) do    
        	modApi:addAlarmStates(i,item)
	end

    	local logs = include( scriptPath .. "/logs" )
    	for i,log in ipairs(logs) do
        	modApi:addLog(log)
    	end

	modApi.requirements = { "Contingency Plan" }

    	function mod_manager:findModByName( name )
            for i, modData in ipairs(self.mods) do
                if name and mod_manager:getModName( modData.id ) == name then
                        return modData
                end
            end
    	end
end

local function initStrings( modApi )
	local dataPath = modApi:getDataPath()
	local scriptPath = modApi:getScriptPath()

	local DLC_STRINGS = include( scriptPath .. "/strings" )
	modApi:addStrings( dataPath, "PROGEXTEND", DLC_STRINGS )
end

local function load( modApi, options, params, mod_options )
	local scriptPath = modApi:getScriptPath()
	local simdefs = include( "sim/simdefs" )
        local npc_abilities = include( scriptPath .. "/npc_abilities" )
        local mainframe_abilities = include( scriptPath .. "/mainframe_abilities" )
	local commondefs = include( scriptPath .. "/commondefs" )
    	local serverdefs = include( scriptPath .. "/serverdefs" )
	local metadefs = include( scriptPath .. "/metadefs" )
	include( scriptPath .. "/alter" )

	set_colors()
	modApi:addTooltipDef( commondefs )
    	modApi:addAbilityDef( "W93_combatAI_disable", scriptPath .."/W93_combatAI_disable" )
    	modApi:addAbilityDef( "W93_combatAI_delay", scriptPath .."/W93_combatAI_delay" )
    	modApi:addAbilityDef( "W93_combatAI_pwr", scriptPath .."/W93_combatAI_pwr" )
    	modApi:addAbilityDef( "W93_combatAI_scan", scriptPath .."/W93_combatAI_scan" )
    	modApi:addAbilityDef( "jackin", scriptPath .."/jackin" )

        if options["rarity_rebalance"].enabled then
		set_rarity()
		if mod_manager:isInstalled( "dlc1" ) and mod_options["dlc1"].enabled then
			enabled_item = mod_options["dlc1"].options
			if enabled_item.programs and enabled_item.programs.enabled then
				set_rarity_dlc()
			end
		end
    	end

        if options["extended_programs"].enabled then
		for name, ability in pairs(mainframe_abilities.mainframe_abilities) do
			modApi:addMainframeAbility( name, ability )
        	end

		setProgramGfx()
    	end

    	if serverdefs.SELECTABLE_PROGRAMS then   
        if options["extended_programs"].enabled then 
            for i,program in ipairs(serverdefs.SELECTABLE_PROGRAMS[1]) do 
                modApi:addStartingGenerator( program )        
            end
            for i,program in ipairs(serverdefs.SELECTABLE_PROGRAMS[2]) do 
                modApi:addStartingBreaker( program )        
            end        
        end
    	end

    	if metadefs.DLC_INSTALL_REWARDS then  
        for i, reward in ipairs(metadefs.DLC_INSTALL_REWARDS) do                
            if reward.unlockType == metadefs.PROGRAM_UNLOCK and options["extended_programs"].enabled then 
                modApi:addInstallReward( reward )
            end    
        end        
    	end

    	if options["extended_daemons"].enabled then
    		modApi:addAbilityDef( "peek", scriptPath .."/peek" )
        	for name, ability in pairs(npc_abilities) do
            		modApi:addDaemonAbility( name, ability )
        	end    
    	else
		modApi:addDaemonAbility( "W93_alertV2", npc_abilities[ "W93_alertV2" ] )
		modApi:addDaemonAbility( "W93_lockdownV2", npc_abilities[ "W93_lockdownV2" ] )
		modApi:addDaemonAbility( "W93_owlV2", npc_abilities[ "W93_owlV2" ] )
	end

    	if options["extended_algorithms"].enabled then
        	local npc_abilities3 = include( scriptPath .. "/npc_abilities3" )
        	for name, ability in pairs(npc_abilities3) do
            		modApi:addDaemonAbility( name, ability )
        	end    
    	end

    	if options["extended_alarms"].value == 2 then
		simdefs.ALARM_TYPES =
		{
			EASY =  { "booting", "cameras", "firewalls", "guards", "guards", "enforcers", "enforcers", "W93_speed" }, 
			ADVANCED_EASY =   {"booting", "patrols",         "guardBuff_armor",    "increaseFirewalls2", "guardBuff_ko", "enforcers", "enforcers", "W93_speed" },
			NORMAL = { "guards", "firewalls", "guards", "cameras", "enforcers", "W93_speed", "W93_reboot", "W93_lockdown"},
			ADVANCED_NORMAL = { "guards", "increaseFirewalls2", "guards", "W93_owl_speed", "enforcers", "W93_ko_armor", "W93_reboot", "W93_lockdown" },
		}
		simdefs.TRACKER_MAXCOUNT = 32
		simdefs.TRACKER_INCREMENT = 4 
    		simdefs.TRACKER_MAXSTAGE = 8
    	elseif options["extended_alarms"].value == 1 then
		simdefs.ALARM_TYPES =
		{
			EASY =  { "booting", "cameras", "firewalls", "guards", "guards", "enforcers", "enforcers", "W93_speed" }, 
			ADVANCED_EASY =   {"booting", "patrols",         "guardBuff_armor",    "increaseFirewalls2", "guardBuff_ko", "enforcers", "enforcers", "W93_speed" }, 
			NORMAL = { "guards", "firewalls", "guards", "cameras", "enforcers", "W93_speed", "W93_reboot", "W93_lockdown"},
			ADVANCED_NORMAL = { "guards", "increaseFirewalls2", "guards", "W93_owl_speed", "enforcers", "W93_ko_armor", "W93_reboot", "W93_lockdown" },
		}
		simdefs.TRACKER_MAXCOUNT = 40
		simdefs.TRACKER_INCREMENT = 5 
    		simdefs.TRACKER_MAXSTAGE = 8
	elseif options["extended_alarms"].value == 0 then
		simdefs.ALARM_TYPES =
		{
			EASY =  { "booting", "cameras", "firewalls", "guards", "enforcers", "enforcers" },
			ADVANCED_EASY =   {"booting", "patrols",         "guardBuff_armor",    "increaseFirewalls2", "guardBuff_ko", "enforcers"},
			NORMAL = { "cameras", "firewalls", "guards", "guards", "enforcers", "enforcers" },
			ADVANCED_NORMAL = {"patrols", "guardBuff_armor", "increaseFirewalls2", "guardBuff_ko",       "enforcers",    "enforcers"},
		}
		simdefs.TRACKER_MAXCOUNT = 30
		simdefs.TRACKER_INCREMENT = 5 
    		simdefs.TRACKER_MAXSTAGE = 6
	end

        if options["shop_programs"].enabled then
    		local propdefs = include( scriptPath .. "/propdefs" )
    		for i,item in pairs(propdefs) do  
        		modApi:addPropDef( i, item, false )
    		end

		set_shops()
		update_base_programs()
		set_servers()
    	end

	if options["alarm_wheel"] and options["alarm_wheel"].enabled then
		setAlarmGfx()
	else
		resetAlarmGfx()
	end
	if params then
		params.W93_AI = -1
	end
        if options["counter_ai"] and options["counter_ai"].value >= 0 then
		include( scriptPath .. "/alter" )
		if options["counter_ai"].value >= 1 then
			for name, ability in pairs(mainframe_abilities.ai_programs) do
				modApi:addMainframeAbility( name, ability )
        		end
		end
        	local npc_abilities2 = include( scriptPath .. "/npc_abilities2" )
        	for name, ability in pairs(npc_abilities2) do
            		modApi:addDaemonAbility( name, ability )
        	end
		local itemdefs = include( scriptPath .. "/itemdefs" )
		for name, itemDef in pairs(itemdefs) do
        		modApi:addItemDef( name, itemDef )
		end
		if params then
			params.W93_AI = options["counter_ai"].value
		end
    	end
        if options["endless_daemons"] and options["endless_daemons"].value and params then
		local serverdefs_default = include( "modules/serverdefs" )
		params.W93_endless_daemons = options["endless_daemons"].value
	end
end

local function lateLoad( modApi, options, params, mod_options )
	local scriptPath = modApi:getScriptPath()
	local simdefs = include( "sim/simdefs" )
	include( scriptPath .. "/alter" )

	if options["counter_ai"] and options["counter_ai"].enabled then
		local agentdefs = include( "sim/unitdefs/agentdefs" )
		updateAgentAbilityAI( false, agentdefs )
	end
end

local function unload( modApi, options, params, mod_options )
	local scriptPath = modApi:getScriptPath()
	include( scriptPath .. "/alter" )
	local simdefs = include( "sim/simdefs" )
	reset_servers()

	simdefs.ALARM_TYPES =
	{
		EASY =  { "booting", "cameras", "firewalls", "guards", "enforcers", "enforcers" },
		ADVANCED_EASY =   {"booting", "patrols",         "guardBuff_armor",    "increaseFirewalls2", "guardBuff_ko", "enforcers"},
		NORMAL = { "cameras", "firewalls", "guards", "guards", "enforcers", "enforcers" },
		ADVANCED_NORMAL = {"patrols", "guardBuff_armor", "increaseFirewalls2", "guardBuff_ko",       "enforcers",    "enforcers"},
	}
	simdefs.TRACKER_MAXCOUNT = 30
	simdefs.TRACKER_INCREMENT = 5 
    	simdefs.TRACKER_MAXSTAGE = 6
	resetAlarmGfx()
	if params then
		params.W93_AI = -1
		params.W93_endless_daemons = 4
	end
end

local function lateUnload( modApi, options, params, mod_options )
	local scriptPath = modApi:getScriptPath()
	include( scriptPath .. "/alter" )

	if options["counter_ai"] and options["counter_ai"].enabled then
		local agentdefs = include( "sim/unitdefs/agentdefs" )
		updateAgentAbilityAI( true, agentdefs )
	end
end

return {
    earlyInit = earlyInit,
    init = init,
    load = load,
    lateLoad = lateLoad,
    initStrings= initStrings,
    unload = unload,
    lateUnload = lateUnload,
}