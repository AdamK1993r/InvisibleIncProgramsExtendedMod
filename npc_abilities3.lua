local mathutil = include( "modules/mathutil" )
local array = include( "modules/array" )
local util = include( "modules/util" )
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local cdefs = include( "client_defs" )
local serverdefs = include( "modules/serverdefs" )
local mainframe_common = include("sim/abilities/mainframe_common")

-------------------------------------------------------------------------------
-- These are NPC abilities.

local createReverseDaemon = mainframe_common.createReverseDaemon

local npc_abilities3 =
{
	W93_aggression = util.extend( createReverseDaemon( STRINGS.PROGEXTEND.REVERSE_DAEMONS.AGGRESSION ) )
	{
		icon = "gui/icons/daemon_icons/icon-daemon_aggression.png",
		standardDaemon = false,
		reverseDaemon = true,
		premanent = false,

	     	ENDLESS_DAEMONS = false,
	     	PROGRAM_LIST = false,
	     	OMNI_PROGRAM_LIST_EASY = false,
	     	OMNI_PROGRAM_LIST = false,
	     	REVERSE_DAEMONS = true,

		onSpawnAbility = function( self, sim, player )
			self.duration = 4
			sim:dispatchEvent( simdefs.EV_SHOW_REVERSE_DAEMON, { showMainframe=true, name = self.name, icon=self.icon, txt = util.sformat(self.activedesc, self.duration ) } )

			for i, unit in ipairs(sim:getPC():getUnits())do
				if unit:hasTrait("ap") then
					if unit:getTraits().ap > 0 then
						unit:getTraits().ap = unit:getTraits().ap + 1
					end
				end
			end
			sim:addTrigger( simdefs.TRG_START_TURN, self )		
			sim:addTrigger( simdefs.TRG_END_TURN, self )
        	end,

		onDespawnAbility = function( self, sim )
			sim:removeTrigger( simdefs.TRG_START_TURN, self )
			sim:removeTrigger( simdefs.TRG_END_TURN, self )
		end,

    		onTrigger = function( self, sim, evType, evData, userUnit )
			mainframe_common.DEFAULT_ABILITY_DAEMON.onTrigger( self, sim, evType, evData, userUnit )
			if evType == simdefs.TRG_START_TURN and sim:getCurrentPlayer():isPC() then
				for i, unit in ipairs(sim:getPC():getUnits())do
					if unit:hasTrait("ap") then
						if unit:getTraits().ap > 0 then
							unit:getTraits().ap = unit:getTraits().ap + 1
						end
					end
				end
			end 
     		end,

		executeTimedAbility = function( self, sim )
			sim:getNPC():removeAbility(sim, self )
		end,		
	},

	W93_battery = util.extend( createReverseDaemon( STRINGS.PROGEXTEND.REVERSE_DAEMONS.BATTERY ) )
	{
		icon = "gui/icons/daemon_icons/icon-daemon_battery.png",

		standardDaemon = false,
		reverseDaemon = true,
		premanent = true,

	     	ENDLESS_DAEMONS = false,
	     	PROGRAM_LIST = false,
	     	OMNI_PROGRAM_LIST_EASY = false,
	     	OMNI_PROGRAM_LIST = false,
	     	REVERSE_DAEMONS = true,

		onSpawnAbility = function( self, sim, player )
			if not sim:getPC():getTraits().PWRmaxBouns then
				sim:getPC():getTraits().PWRmaxBouns = 0
			end
			sim:getPC():getTraits().PWRmaxBouns = sim:getPC():getTraits().PWRmaxBouns + 5
			sim:getPC():addCPUs( 4, sim )
			sim:dispatchEvent( simdefs.EV_SHOW_REVERSE_DAEMON, { name = self.name, icon=self.icon, txt = self.activedesc } )
			player:removeAbility(sim, self)
		end,

		onDespawnAbility = function( self, sim )			
		end,
	},

	W93_charger = util.extend( createReverseDaemon( STRINGS.PROGEXTEND.REVERSE_DAEMONS.CHARGER ) )
	{
		icon = "gui/icons/daemon_icons/icon-daemon_recharge.png",
		standardDaemon = false,
		reverseDaemon = true,
		premanent = false,

	     	ENDLESS_DAEMONS = false,
	     	PROGRAM_LIST = false,
	     	OMNI_PROGRAM_LIST_EASY = false,
	     	OMNI_PROGRAM_LIST = false,
	     	REVERSE_DAEMONS = true,

		onSpawnAbility = function( self, sim, player )
			self.duration = 4
			local pcplayer = sim:getPC()
			self.items = {}

			sim:dispatchEvent( simdefs.EV_SHOW_REVERSE_DAEMON, { name = self.name, icon=self.icon, txt = util.sformat(self.activedesc, self.duration) } )	

			local pcplayer = sim:getPC()
			for i, unit in pairs( pcplayer:getUnits() ) do 
				for i, item in pairs( unit:getChildren() ) do 
					table.insert( self.items, item )
				end 
			end 

			for _, item in ipairs(self.items) do
				if item:getTraits().cooldownMax and item:getTraits().cooldownMax > 2 then
					item:getTraits().cooldownMax = item:getTraits().cooldownMax - 1
				elseif item:getTraits().cooldownMax and item:getTraits().cooldownMax <= 2 then
					if not item:getTraits().cooldown_check then
						item:getTraits().cooldown_check = 0
					end
					item:getTraits().cooldown_check = item:getTraits().cooldown_check + 1
				end 
			end

			sim:addTrigger( simdefs.TRG_END_TURN, self )	
		end,

		onDespawnAbility = function( self, sim, unit )
			for _, item in ipairs(self.items) do
				if item:getTraits().cooldownMax then
					if not item:getTraits().cooldown_check then
						item:getTraits().cooldownMax = item:getTraits().cooldownMax + 1
					else
						item:getTraits().cooldown_check = item:getTraits().cooldown_check - 1
						if item:getTraits().cooldown_check <= 0 then
							item:getTraits().cooldown_check = nil
						end
					end
				end 
			end
			sim:removeTrigger( simdefs.TRG_END_TURN, self )	
		end,

		executeTimedAbility = function( self, sim )
			sim:getNPC():removeAbility(sim, self )
		end	
	},

	W93_confusion = util.extend( createReverseDaemon( STRINGS.PROGEXTEND.REVERSE_DAEMONS.CONFUSION ) )
	{
		icon = "gui/icons/daemon_icons/icon-daemon_confusion.png",
		standardDaemon = false,
		reverseDaemon = true,
		premanent = true,

	     	ENDLESS_DAEMONS = false,
	     	PROGRAM_LIST = false,
	     	OMNI_PROGRAM_LIST_EASY = false,
	     	OMNI_PROGRAM_LIST = false,
	     	REVERSE_DAEMONS = true,

		onSpawnAbility = function( self, sim, player )
			sim:dispatchEvent( simdefs.EV_SHOW_REVERSE_DAEMON, { name = self.name, icon=self.icon, txt = self.activedesc } )
			sim:addTrigger( simdefs.TRG_END_TURN, self )
        	end,

		onDespawnAbility = function( self, sim )
			sim:removeTrigger( simdefs.TRG_END_TURN, self )
			if sim:getParams().difficultyOptions.autoAlarm then
				sim:trackerAdvance(1, STRINGS.UI.ALARM_INCREASE )
			end
			sim._players[1]:updateTracker(sim)
			sim:endTurn()
			sim:getPC():getTraits().confusion = nil
		end,

    		onTrigger = function( self, sim, evType, evData, userUnit )
			if evType == simdefs.TRG_END_TURN and sim:getCurrentPlayer():isPC() and not sim:getPC():getTraits().confusion and not sim:getPC():getTraits().sleep then
				sim:getPC():getTraits().confusion = true
				sim:getNPC():removeAbility( sim, self )
     			end
     		end,
	},

	W93_optimize = util.extend( createReverseDaemon( STRINGS.PROGEXTEND.REVERSE_DAEMONS.OPTIMIZE ) )
	{
		icon = "gui/icons/daemon_icons/icon-daemon_optimize.png",
		standardDaemon = false,
		reverseDaemon = true,
		premanent = false,

	     	ENDLESS_DAEMONS = false,
	     	PROGRAM_LIST = false,
	     	OMNI_PROGRAM_LIST_EASY = false,
	     	OMNI_PROGRAM_LIST = false,
	     	REVERSE_DAEMONS = true,

		onSpawnAbility = function( self, sim, player )
			self.duration = 3
			sim:dispatchEvent( simdefs.EV_SHOW_REVERSE_DAEMON, { name = self.name, icon=self.icon, txt = util.sformat(self.activedesc, self.duration) } )
			for i, ability in ipairs(sim:getPC():getAbilities())do
				if not ability.coolDownMod then
					ability.coolDownMod = 0
				end
				if not ability.optimize_bonus then
					ability.optimize_bonus = 0
				end
				ability.coolDownMod = ability.coolDownMod - 1
				ability.optimize_bonus = ability.optimize_bonus + 1
				break
			end
			sim:addTrigger( simdefs.TRG_END_TURN, self )	
		end,

		onDespawnAbility = function( self, sim, unit )
			sim:removeTrigger( simdefs.TRG_END_TURN, self )
			for i, ability in ipairs(sim:getPC():getAbilities())do
				if ability.coolDownMod and ability.optimize_bonus then
					ability.coolDownMod = ability.coolDownMod + 1
					ability.optimize_bonus = ability.optimize_bonus - 1
					if ability.optimize_bonus <= 0 then
						ability.optimize_bonus = nil
					end
				end
			end
		end,

		executeTimedAbility = function( self, sim )
			sim:getNPC():removeAbility(sim, self )
		end	
	},

	W93_rollback = util.extend( createReverseDaemon( STRINGS.PROGEXTEND.REVERSE_DAEMONS.ROLLBACK ) )
	{
		icon = "gui/icons/daemon_icons/icon-daemon_rollback.png",

		standardDaemon = false,
		reverseDaemon = true,
		premanent = true,

	     	ENDLESS_DAEMONS = false,
	     	PROGRAM_LIST = false,
	     	OMNI_PROGRAM_LIST_EASY = false,
	     	OMNI_PROGRAM_LIST = false,
	     	REVERSE_DAEMONS = true,

		onSpawnAbility = function( self, sim, player )
			sim:dispatchEvent( simdefs.EV_SHOW_REVERSE_DAEMON, { name = self.name, icon=self.icon, txt = self.activedesc } )
			sim:trackerDecrement( 2 )
			player:removeAbility(sim, self)
		end,

		onDespawnAbility = function( self, sim )			
		end,
	},

	W93_smokescreen = util.extend( createReverseDaemon( STRINGS.PROGEXTEND.REVERSE_DAEMONS.SMOKESCREEN ) )
	{
		icon = "gui/icons/daemon_icons/icon-daemon_smokescreen.png",
		standardDaemon = false,
		reverseDaemon = true,
		premanent = false,

	     	ENDLESS_DAEMONS = false,
	     	PROGRAM_LIST = false,
	     	OMNI_PROGRAM_LIST_EASY = false,
	     	OMNI_PROGRAM_LIST = false,
	     	REVERSE_DAEMONS = true,

		onSpawnAbility = function( self, sim, player )
			sim:dispatchEvent( simdefs.EV_SHOW_REVERSE_DAEMON, { name = self.name, icon=self.icon, txt = self.activedesc } )

			for _, unit in ipairs(sim:getNPC():getUnits() ) do
				if unit:getTraits().hasSight and unit:getTraits().isGuard then
					if unit:getTraits().LOSrange and unit:getTraits().LOSrange > 4 then
						unit:getTraits().LOSrange = math.max(unit:getTraits().LOSrange - 2, 4)
					end
					if unit:getTraits().LOSperipheralRange and unit:getTraits().LOSperipheralRange > 4 then
						unit:getTraits().LOSperipheralRange = math.max(unit:getTraits().LOSperipheralRange - 2, 4)
					end
					sim:refreshUnitLOS( unit )
				end
			end
			sim:getNPC():removeAbility(sim, self)	
        	end,	
	},

	W93_turbine = util.extend( createReverseDaemon( STRINGS.PROGEXTEND.REVERSE_DAEMONS.TURBINE ) )
	{
		icon = "gui/icons/daemon_icons/icon-daemon_turbine.png",
		standardDaemon = false,
		reverseDaemon = true,
		premanent = false,

	     	ENDLESS_DAEMONS = false,
	     	PROGRAM_LIST = false,
	     	OMNI_PROGRAM_LIST_EASY = false,
	     	OMNI_PROGRAM_LIST = false,
	     	REVERSE_DAEMONS = true,

		onSpawnAbility = function( self, sim, player )
			self.duration = 4
			sim:dispatchEvent( simdefs.EV_SHOW_REVERSE_DAEMON, { name = self.name, icon=self.icon, txt = util.sformat(self.activedesc, self.duration) } )
			sim:addTrigger( simdefs.TRG_START_TURN, self )
			sim:addTrigger( simdefs.TRG_END_TURN, self )
			sim:getCurrentPlayer():addCPUs( 2, sim )
			sim:dispatchEvent( simdefs.EV_PLAY_SOUND, "SpySociety/Actions/mainframe_run_fusion" )
			sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.REVERSE_DAEMONS.TURBINE.WARNING, color=cdefs.COLOR_PLAYER_WARNING, sound = "SpySociety/Actions/mainframe_gainCPU",icon=self.icon } )
		end,

		onDespawnAbility = function( self, sim, unit )
			sim:removeTrigger( simdefs.TRG_START_TURN, self )
			sim:removeTrigger( simdefs.TRG_END_TURN, self )
		end,

    		onTrigger = function( self, sim, evType, evData, userUnit )
			mainframe_common.DEFAULT_ABILITY_DAEMON.onTrigger( self, sim, evType, evData, userUnit )
			if evType == simdefs.TRG_START_TURN and evData:isPC() then
				sim:getCurrentPlayer():addCPUs( 2, sim )
				sim:dispatchEvent( simdefs.EV_PLAY_SOUND, "SpySociety/Actions/mainframe_run_fusion" )
				sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.REVERSE_DAEMONS.TURBINE.WARNING, color=cdefs.COLOR_PLAYER_WARNING, sound = "SpySociety/Actions/mainframe_gainCPU",icon=self.icon } )
     			end
     		end,

		executeTimedAbility = function( self, sim )
			sim:getNPC():removeAbility(sim, self )
		end	
	},
}

return npc_abilities3