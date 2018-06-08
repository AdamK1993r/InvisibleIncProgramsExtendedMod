local mathutil = include( "modules/mathutil" )
local array = include( "modules/array" )
local util = include( "modules/util" )
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local cdefs = include( "client_defs" )
local serverdefs = include( "modules/serverdefs" )
local mainframe_common = include("sim/abilities/mainframe_common")
local speechdefs = include( "sim/speechdefs" )
local modifiers = include( "sim/modifiers" )

-------------------------------------------------------------------------------
-- These are NPC abilities.

local createDaemon = mainframe_common.createDaemon
local createReverseDaemon = mainframe_common.createReverseDaemon
local createCountermeasureInterest = mainframe_common.createCountermeasureInterest

local npc_abilities =
{
	W93_alert = util.extend( createDaemon( STRINGS.PROGEXTEND.DAEMONS.ALERT ) )
	{
		icon = "gui/icons/daemon_icons/icon-daemon_alert.png",
		standardDaemon = true,
		reverseDaemon = false,
		premanent = false,
		alerted = 0,

	     	ENDLESS_DAEMONS = false,
	     	PROGRAM_LIST = true,
	     	OMNI_PROGRAM_LIST_EASY = false,
	     	OMNI_PROGRAM_LIST = true,
	     	REVERSE_DAEMONS = false,

		onSpawnAbility = function( self, sim, player )
			self.duration = self.getDuration(self, sim, sim:nextRand(3,5))
			sim:dispatchEvent( simdefs.EV_SHOW_DAEMON, { name = self.name, icon=self.icon, txt = util.sformat(self.activedesc, self.duration ) } )

			for _, unit in ipairs(sim:getNPC():getUnits() ) do
				if not unit:getTraits().pacifist then
					if not unit:getTraits().alert_bonus then
						unit:getTraits().alert_bonus = 0
					end
					unit:getTraits().alert_bonus = unit:getTraits().alert_bonus + 1
					if unit:getTraits().mp and unit:getTraits().mpMax then
						unit:getTraits().mp = unit:getTraits().mp + 4
						unit:getTraits().mpMax = unit:getTraits().mpMax + 4
					end
				end
			end

			for _, unit in ipairs(sim:getNPC():getUnits() ) do
				if not unit:getTraits().pacifist and not unit:isAlerted() and self.alerted == 0 then
					unit:setAlerted(true)
    	        			local x0, y0 = unit:getLocation()
	            			sim:getNPC():spawnInterest(x0, y0, simdefs.SENSE_RADIO, simdefs.REASON_HUNTING, unit)
					sim:dispatchEvent( simdefs.EV_UNIT_ALERTED, { unitID = unit:getID() } )
					unit:getSim():emitSpeech( unit, speechdefs.HUNT_NOISE)
					self.alerted = 1
				end
			end		

			sim:addTrigger( simdefs.TRG_START_TURN, self )
			sim:addTrigger( simdefs.TRG_END_TURN, self )
        	end,

		onDespawnAbility = function( self, sim )
			sim:removeTrigger( simdefs.TRG_START_TURN, self )
			sim:removeTrigger( simdefs.TRG_END_TURN, self )
			for _, unit in ipairs(sim:getNPC():getUnits() ) do
				if unit:getTraits().alert_bonus then
					if unit:getTraits().alert_bonus > 0 then
						unit:getTraits().alert_bonus = unit:getTraits().alert_bonus - 1
						if unit:getTraits().mpMax then
							unit:getTraits().mpMax = unit:getTraits().mpMax - 4
						end
					end 
					if unit:getTraits().alert_bonus <= 0 then
						unit:getTraits().alert_bonus = nil
					end
				end
			end
		end,

    		onTrigger = function( self, sim, evType, evData, userUnit )
			mainframe_common.DEFAULT_ABILITY_DAEMON.onTrigger( self, sim, evType, evData, userUnit )
			if evType == simdefs.TRG_START_TURN then
				for _, unit in ipairs(sim:getNPC():getUnits() ) do
					if not unit:getTraits().pacifist and not unit:getTraits().alert_bonus and self.duration > 1 then
						unit:getTraits().alert_bonus = 1
						if unit:getTraits().mp and unit:getTraits().mpMax then
							unit:getTraits().mp = unit:getTraits().mp + 4
							unit:getTraits().mpMax = unit:getTraits().mpMax + 4
						end
					end
				end
     			end
     		end,

		executeTimedAbility = function( self, sim )
			sim:getNPC():removeAbility(sim, self )
		end,		
	},

	W93_alertV2 = util.extend( createDaemon( STRINGS.PROGEXTEND.DAEMONS.ALERTV2 ) )
	{
		icon = "gui/icons/daemon_icons/icon-daemon_alert.png",
		standardDaemon = false,
		reverseDaemon = false,
		premanent = false,

	     	ENDLESS_DAEMONS = false,
	     	PROGRAM_LIST = false,
	     	OMNI_PROGRAM_LIST_EASY = false,
	     	OMNI_PROGRAM_LIST = false,
	     	REVERSE_DAEMONS = false,

		onSpawnAbility = function( self, sim, player )
			sim:dispatchEvent( simdefs.EV_SHOW_DAEMON, { name = self.name, icon=self.icon, txt = self.activedesc } )

			for _, unit in ipairs(sim:getNPC():getUnits() ) do
				if not unit:getTraits().pacifist then
					if not unit:getTraits().alert_bonus then
						unit:getTraits().alert_bonus = 0
					end
					unit:getTraits().alert_bonus = unit:getTraits().alert_bonus + 1
					if unit:getTraits().mp and unit:getTraits().mpMax then
						unit:getTraits().mp = unit:getTraits().mp + 6
						unit:getTraits().mpMax = unit:getTraits().mpMax + 6
					end
				end
			end		

			sim:addTrigger( simdefs.TRG_START_TURN, self )
        	end,

		onDespawnAbility = function( self, sim )
			sim:removeTrigger( simdefs.TRG_START_TURN, self )
			for _, unit in ipairs(sim:getNPC():getUnits() ) do
				if unit:getTraits().alert_bonus then
					if unit:getTraits().alert_bonus > 0 then
						unit:getTraits().alert_bonus = unit:getTraits().alert_bonus - 1
						if unit:getTraits().mpMax then
							unit:getTraits().mpMax = unit:getTraits().mpMax - 6
						end
					end 
					if unit:getTraits().alert_bonus <= 0 then
						unit:getTraits().alert_bonus = nil
					end
				end
			end
		end,

    		onTrigger = function( self, sim, evType, evData, userUnit )
			if evType == simdefs.TRG_START_TURN then
				for _, unit in ipairs(sim:getNPC():getUnits() ) do
					if not unit:getTraits().pacifist and not unit:getTraits().alert_bonus then
						unit:getTraits().alert_bonus = 1
						if unit:getTraits().mp and unit:getTraits().mpMax then
							unit:getTraits().mp = unit:getTraits().mp + 6
							unit:getTraits().mpMax = unit:getTraits().mpMax + 6
						end
					end
				end
     			end
     		end,		
	},

	W93_blindfold = util.extend( createDaemon( STRINGS.PROGEXTEND.DAEMONS.BLINDFOLD ) )
	{
		icon = "gui/icons/daemon_icons/icon-daemon_blindfold.png",
		standardDaemon = true,
		reverseDaemon = false,
		premanent = false,

	     	ENDLESS_DAEMONS = false,
	     	PROGRAM_LIST = true,
	     	OMNI_PROGRAM_LIST_EASY = false,
	     	OMNI_PROGRAM_LIST = true,
	     	REVERSE_DAEMONS = false,

		onSpawnAbility = function( self, sim, player )
			self.duration = self.getDuration(self, sim, sim:nextRand(3,5))
			sim:dispatchEvent( simdefs.EV_SHOW_DAEMON, { name = self.name, icon=self.icon, txt = util.sformat(self.activedesc, self.duration ) } )	

            		for i, unit in pairs(sim:getPC():getUnits()) do
		        	if not unit:getTraits().blindfold_penalty and unit:getTraits().isAgent and not unit:getTraits().isDrone then
					unit:getTraits().blindfold_penalty = 1
					--unit:getTraits().LOSrange = 4
				elseif unit:getTraits().isAgent and not unit:getTraits().isDrone then
					unit:getTraits().blindfold_penalty = unit:getTraits().blindfold_penalty + 1
				end
		        end

			sim:addTrigger( simdefs.TRG_START_TURN, self )
			sim:addTrigger( simdefs.TRG_END_TURN, self )	
		end,

		onDespawnAbility = function( self, sim )
            		for i, unit in pairs(sim:getPC():getUnits()) do
				if unit:getTraits().blindfold_penalty then
		        		if unit:getTraits().blindfold_penalty > 0 then
						unit:getTraits().blindfold_penalty = unit:getTraits().blindfold_penalty - 1
					end
					if unit:getTraits().blindfold_penalty <= 0 then
						--unit:getTraits().LOSrange = nil
						unit:getTraits().blindfold_penalty = nil
					end
				end
			end
			sim:removeTrigger( simdefs.TRG_START_TURN, self )
			sim:removeTrigger( simdefs.TRG_END_TURN, self )
		end,

    		onTrigger = function( self, sim, evType, evData, userUnit )
			mainframe_common.DEFAULT_ABILITY_DAEMON.onTrigger( self, sim, evType, evData, userUnit )
			if evType == simdefs.TRG_START_TURN then
            			for i, unit in pairs(sim:getPC():getUnits()) do
		        		if not unit:getTraits().blindfold_penalty and unit:getTraits().isAgent and self.duration > 1 and not unit:getTraits().isDrone then
						unit:getTraits().blindfold_penalty = 1
						--unit:getTraits().LOSrange = 4
					end
		        	end
     			end
     		end,

		executeTimedAbility = function( self, sim )
			sim:getNPC():removeAbility(sim, self )
		end	
	},

	W93_chain = util.extend( createDaemon( STRINGS.PROGEXTEND.DAEMONS.CHAIN ) )
	{
		icon = "gui/icons/daemon_icons/icon-daemon_chain.png",
		standardDaemon = true,
		reverseDaemon = false,
		premanent = false,

	     	ENDLESS_DAEMONS = false,
	     	PROGRAM_LIST = true,
	     	OMNI_PROGRAM_LIST_EASY = false,
	     	OMNI_PROGRAM_LIST = true,
	     	REVERSE_DAEMONS = false,

		onSpawnAbility = function( self, sim, player )
			self.duration = self.getDuration(self, sim, sim:nextRand(4,6))
			sim:dispatchEvent( simdefs.EV_SHOW_DAEMON, { showMainframe=true, name = self.name, icon=self.icon, txt = util.sformat(self.activedesc, self.duration ) } )

			for _, unit in ipairs(sim:getNPC():getUnits() ) do
				if not unit:getTraits().chain_bonus then
					unit:getTraits().chain_bonus = 0
				end
				unit:getTraits().chain_bonus = unit:getTraits().chain_bonus + 1
			end

			sim:addTrigger( simdefs.TRG_UNIT_ALERTED, self )
			sim:addTrigger( simdefs.TRG_UNIT_KILLED, self )
			sim:addTrigger( simdefs.TRG_START_TURN, self )
			sim:addTrigger( simdefs.TRG_END_TURN, self )
        	end,

		onDespawnAbility = function( self, sim )
			for _, unit in ipairs(sim:getNPC():getUnits() ) do
				if unit:getTraits().chain_bonus then
					if unit:getTraits().chain_bonus > 0 then
						unit:getTraits().chain_bonus = unit:getTraits().chain_bonus - 1
					end
					if unit:getTraits().chain_bonus <= 0 then
						unit:getTraits().chain_bonus = nil
					end
				end
			end

			sim:removeTrigger( simdefs.TRG_UNIT_ALERTED, self )
			sim:removeTrigger( simdefs.TRG_UNIT_KILLED, self )
			sim:removeTrigger( simdefs.TRG_START_TURN, self )
			sim:removeTrigger( simdefs.TRG_END_TURN, self )
		end,

    		onTrigger = function( self, sim, evType, evData, userUnit )
			mainframe_common.DEFAULT_ABILITY_DAEMON.onTrigger( self, sim, evType, evData, userUnit )
			if (evType == simdefs.TRG_UNIT_ALERTED or evType == simdefs.TRG_UNIT_KILLED) and evData["unit"]:getTraits().isGuard then
					local daemon = nil
					if sim:isVersion("0.17.5") then
						daemon = sim:getIcePrograms():getChoice( sim:nextRand( 1, sim:getIcePrograms():getTotalWeight() ))
					else
						daemon = programList[sim:nextRand(1, #serverdefs.PROGRAM_LIST)]			
					end	

					sim:getNPC():addMainframeAbility( sim, daemon )
     			end
			if evType == simdefs.TRG_START_TURN then
				for _, unit in ipairs(sim:getNPC():getUnits() ) do
					if not unit:getTraits().chain_bonus and self.duration > 1 then
						unit:getTraits().chain_bonus = 1
					end
				end
			end 
     		end,

		executeTimedAbility = function( self, sim )
			sim:getNPC():removeAbility(sim, self )
		end,		
	},

	W93_chainV2 = util.extend( createDaemon( STRINGS.PROGEXTEND.DAEMONS.CHAINV2 ) )
	{
		icon = "gui/icons/daemon_icons/icon-daemon_chain.png",
		standardDaemon = false,
		reverseDaemon = false,
		premanent = true,

	     	ENDLESS_DAEMONS = true,
	     	PROGRAM_LIST = false,
	     	OMNI_PROGRAM_LIST_EASY = false,
	     	OMNI_PROGRAM_LIST = false,
	     	REVERSE_DAEMONS = false,

		onSpawnAbility = function( self, sim, player )
			sim:dispatchEvent( simdefs.EV_SHOW_DAEMON, { showMainframe=true, name = self.name, icon=self.icon, txt = self.activedesc } )

			for _, unit in ipairs(sim:getNPC():getUnits() ) do
				if not unit:getTraits().chain_bonus then
					unit:getTraits().chain_bonus = 0
				end
				unit:getTraits().chain_bonus = unit:getTraits().chain_bonus + 1
			end

			sim:addTrigger( simdefs.TRG_UNIT_ALERTED, self )
			sim:addTrigger( simdefs.TRG_UNIT_KILLED, self )
			sim:addTrigger( simdefs.TRG_START_TURN, self )
        	end,

		onDespawnAbility = function( self, sim )
			for _, unit in ipairs(sim:getNPC():getUnits() ) do
				if unit:getTraits().chain_bonus then
					if unit:getTraits().chain_bonus > 0 then
						unit:getTraits().chain_bonus = unit:getTraits().chain_bonus - 1
					end
					if unit:getTraits().chain_bonus <= 0 then
						unit:getTraits().chain_bonus = nil
					end
				end
			end

			sim:removeTrigger( simdefs.TRG_UNIT_ALERTED, self )
			sim:removeTrigger( simdefs.TRG_UNIT_KILLED, self )
			sim:removeTrigger( simdefs.TRG_START_TURN, self )
		end,

    		onTrigger = function( self, sim, evType, evData, userUnit )
			mainframe_common.DEFAULT_ABILITY_DAEMON.onTrigger( self, sim, evType, evData, userUnit )
			if (evType == simdefs.TRG_UNIT_ALERTED or evType == simdefs.TRG_UNIT_KILLED) and evData["unit"]:getTraits().isGuard then
					local daemon = nil
					if sim:isVersion("0.17.5") then
						daemon = sim:getIcePrograms():getChoice( sim:nextRand( 1, sim:getIcePrograms():getTotalWeight() ))
					else
						daemon = programList[sim:nextRand(1, #serverdefs.PROGRAM_LIST)]			
					end	

					sim:getNPC():addMainframeAbility( sim, daemon )
     			end
			if evType == simdefs.TRG_START_TURN then
				for _, unit in ipairs(sim:getNPC():getUnits() ) do
					if not unit:getTraits().chain_bonus then
						unit:getTraits().chain_bonus = 1
					end
				end
			end 
     		end,	
	},

	W93_clock = util.extend( createDaemon( STRINGS.PROGEXTEND.DAEMONS.CLOCK ) )
	{
		icon = "gui/icons/daemon_icons/icon-daemon_clock.png",
		standardDaemon = true,
		reverseDaemon = false,
		premanent = false,
		
	     	ENDLESS_DAEMONS = false,
	     	PROGRAM_LIST = true,
	     	OMNI_PROGRAM_LIST_EASY = false,
	     	OMNI_PROGRAM_LIST = true,
	     	REVERSE_DAEMONS = false,

		onSpawnAbility = function( self, sim, player )
			self.duration = self.getDuration(self, sim, sim:nextRand(4,8))
			sim:dispatchEvent( simdefs.EV_SHOW_DAEMON, { name = self.name, icon=self.icon, txt = util.sformat(self.activedesc, self.duration) } )
			for i, ability in ipairs(sim:getPC():getAbilities())do
				if not ability.coolDownMod then
					ability.coolDownMod = 0
				end
				if not ability.clock_penalty then
					ability.clock_penalty = 0
				end
				ability.coolDownMod = ability.coolDownMod + 1
				ability.clock_penalty = ability.clock_penalty + 1
				break
			end
			sim:addTrigger( simdefs.TRG_END_TURN, self )	
		end,

		onDespawnAbility = function( self, sim, unit )
			sim:removeTrigger( simdefs.TRG_END_TURN, self )
			for i, ability in ipairs(sim:getPC():getAbilities())do
				if ability.coolDownMod and ability.clock_penalty then
					ability.coolDownMod = ability.coolDownMod - 1
					ability.clock_penalty = ability.clock_penalty - 1
					if ability.clock_penalty <= 0 then
						ability.clock_penalty = nil
					end
				end
			end
		end,

		executeTimedAbility = function( self, sim )
			sim:getNPC():removeAbility(sim, self )
		end	
	},

	W93_clockV2 = util.extend( createDaemon( STRINGS.PROGEXTEND.DAEMONS.CLOCKV2 ) )
	{
		icon = "gui/icons/daemon_icons/icon-daemon_clock.png",
		standardDaemon = false,
		reverseDaemon = false,
		premanent = true,

	     	ENDLESS_DAEMONS = true,
	     	PROGRAM_LIST = false,
	     	OMNI_PROGRAM_LIST_EASY = false,
	     	OMNI_PROGRAM_LIST = false,
	     	REVERSE_DAEMONS = false,

		onSpawnAbility = function( self, sim, player )
			sim:dispatchEvent( simdefs.EV_SHOW_DAEMON, { name = self.name, icon=self.icon, txt = self.activedesc } )
			for i, ability in ipairs(sim:getPC():getAbilities())do
				if not ability.coolDownMod then
					ability.coolDownMod = 0
				end
				if not ability.clock_penalty then
					ability.clock_penalty = 0
				end
				ability.coolDownMod = ability.coolDownMod + 1
				ability.clock_penalty = ability.clock_penalty + 1
				break
			end	
		end,

		onDespawnAbility = function( self, sim, unit )
			for i, ability in ipairs(sim:getPC():getAbilities())do
				if ability.coolDownMod and ability.clock_penalty then
					ability.coolDownMod = ability.coolDownMod - 1
					ability.clock_penalty = ability.clock_penalty - 1
					if ability.clock_penalty <= 0 then
						ability.clock_penalty = nil
					end
				end
			end
		end,	
	},

	W93_disarm = util.extend( createDaemon( STRINGS.PROGEXTEND.DAEMONS.DISARM ) )
	{
		icon = "gui/icons/daemon_icons/icon-daemon_disarm.png",
		standardDaemon = true,
		reverseDaemon = false,
		premanent = false,

	     	ENDLESS_DAEMONS = false,
	     	PROGRAM_LIST = true,
	     	OMNI_PROGRAM_LIST_EASY = false,
	     	OMNI_PROGRAM_LIST = true,
	     	REVERSE_DAEMONS = false,

		onSpawnAbility = function( self, sim, player )
			self.duration = self.getDuration(self, sim, sim:nextRand(3,5))
			sim:dispatchEvent( simdefs.EV_SHOW_DAEMON, { showMainframe=true, name = self.name, icon=self.icon, txt = util.sformat(self.activedesc, self.duration ) } )


			for i, unit in ipairs(sim:getPC():getUnits())do
				if unit:hasTrait("ap") then
					if unit:getTraits().ap > 0 then
						unit:getTraits().ap = unit:getTraits().ap - 1
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
							unit:getTraits().ap = unit:getTraits().ap - 1
						end
					end
				end
			end 
     		end,

		executeTimedAbility = function( self, sim )
			sim:getNPC():removeAbility(sim, self )
		end,		
	},

	W93_disarmV2 = util.extend( createDaemon( STRINGS.PROGEXTEND.DAEMONS.DISARMV2 ) )
	{
		icon = "gui/icons/daemon_icons/icon-daemon_disarm.png",
		standardDaemon = false,
		reverseDaemon = false,
		premanent = true,

	     	ENDLESS_DAEMONS = true,
	     	PROGRAM_LIST = false,
	     	OMNI_PROGRAM_LIST_EASY = false,
	     	OMNI_PROGRAM_LIST = false,
	     	REVERSE_DAEMONS = false,

		onSpawnAbility = function( self, sim, player )
			sim:dispatchEvent( simdefs.EV_SHOW_DAEMON, { showMainframe=true, name = self.name, icon=self.icon, txt = self.activedesc } )

			for i, unit in ipairs(sim:getPC():getUnits())do
				if unit:hasTrait("ap") then
					if unit:getTraits().ap > 0 then
						unit:getTraits().ap = unit:getTraits().ap - 1
					end
				end
			end
			sim:addTrigger( simdefs.TRG_START_TURN, self )
        	end,

		onDespawnAbility = function( self, sim )
			sim:removeTrigger( simdefs.TRG_START_TURN, self )
		end,

    		onTrigger = function( self, sim, evType, evData, userUnit )
			if evType == simdefs.TRG_START_TURN and sim:getCurrentPlayer():isPC() then
				for i, unit in ipairs(sim:getPC():getUnits())do
					if unit:hasTrait("ap") then
						if unit:getTraits().ap > 0 then
							unit:getTraits().ap = unit:getTraits().ap - 1
						end
					end
				end
			end 
     		end,
	},

	W93_gatekeeper = util.extend( createDaemon( STRINGS.PROGEXTEND.DAEMONS.GATEKEEPER ) )
	{
		icon = "gui/icons/daemon_icons/icon-daemon_gatekeeper.png",
		standardDaemon = true,
		reverseDaemon = false,
		premanent = false,

	     	ENDLESS_DAEMONS = false,
	     	PROGRAM_LIST = true,
	     	OMNI_PROGRAM_LIST_EASY = false,
	     	OMNI_PROGRAM_LIST = false,
	     	REVERSE_DAEMONS = false,

		onSpawnAbility = function( self, sim, player )
			self.duration = self.getDuration(self, sim, math.max(2 + simdefs.TRACKER_MAXSTAGE - sim:getTrackerStage( sim:getTracker() ),2 ))
			sim:dispatchEvent( simdefs.EV_SHOW_DAEMON, { name = self.name, icon=self.icon, txt = util.sformat(self.activedesc, self.duration ) } )
		
			if not sim:getPC():getTraits().gatekeeper then
				sim:getPC():getTraits().gatekeeper = 1
				sim:forEachCell(function( c )
					for i, exit in pairs( c.exits ) do
						if exit.door and not exit.closed and (exit.keybits == simdefs.DOOR_KEYS.ELEVATOR or exit.keybits == simdefs.DOOR_KEYS.ELEVATOR_INUSE)  then
						
							local reverseExit = exit.cell.exits[ simquery.getReverseDirection( i ) ]
							exit.keybits = simdefs.DOOR_KEYS.ELEVATOR_INUSE						
							reverseExit.keybits = simdefs.DOOR_KEYS.ELEVATOR_INUSE
							sim._elevator_inuse = self.duration
							sim:modifyExit( c, i, simdefs.EXITOP_CLOSE )
							sim:modifyExit( c, i, simdefs.EXITOP_LOCK )
							sim:dispatchEvent( simdefs.EV_EXIT_MODIFIED, {cell=c, dir=i} )
						elseif exit.door and not exit.closed and exit.keybits == simdefs.DOOR_KEYS.FINAL_LEVEL then 
							sim:modifyExit( c, i, simdefs.EXITOP_CLOSE )
							sim:modifyExit( c, i, simdefs.EXITOP_LOCK )
							sim:dispatchEvent( simdefs.EV_EXIT_MODIFIED, {cell=c, dir=i} )
						end
					end
				end )
			else
				sim:getPC():getTraits().gatekeeper = sim:getPC():getTraits().gatekeeper + 1
				if sim._elevator_inuse and sim._elevator_inuse < self.duration then
					sim._elevator_inuse = self.duration
				end
			end
			sim:addTrigger( simdefs.TRG_END_TURN, self )
        	end,

		onDespawnAbility = function( self, sim )
			sim:getPC():getTraits().gatekeeper = sim:getPC():getTraits().gatekeeper - 1
			if sim:getPC():getTraits().gatekeeper <= 0 then
				sim:getPC():getTraits().gatekeeper = nil
			end
			sim:removeTrigger( simdefs.TRG_END_TURN, self )
		end,

		executeTimedAbility = function( self, sim )
			sim:getNPC():removeAbility(sim, self )
		end,		
	},

	W93_inspect = util.extend( createDaemon( STRINGS.PROGEXTEND.DAEMONS.INSPECT ) )
	{
		icon = "gui/icons/daemon_icons/icon-daemon_inspect.png",
		standardDaemon = true,
		reverseDaemon = false,
		premanent = false,

	     	ENDLESS_DAEMONS = false,
	     	PROGRAM_LIST = false,
	     	OMNI_PROGRAM_LIST_EASY = false,
	     	OMNI_PROGRAM_LIST = true,
	     	REVERSE_DAEMONS = false,

		onSpawnAbility = function( self, sim, player )
			sim:dispatchEvent( simdefs.EV_SHOW_DAEMON, { showMainframe=true, name = self.name, icon=self.icon, txt = self.activedesc } )

			local idle = sim:getNPC():getIdleSituation()
			local guards = sim:getNPC():getUnits()

			for i,guard in ipairs(guards) do
				if guard:getBrain() and guard:getBrain():getSituation().ClassType == simdefs.SITUATION_IDLE then
					idle:generatePatrolPath( guard )
					if guard:getTraits().patrolPath and #guard:getTraits().patrolPath > 1 then
						local firstPoint = guard:getTraits().patrolPath[1]
						guard:getBrain():getSenses():addInterest(firstPoint.x, firstPoint.y, simdefs.SENSE_RADIO, simdefs.REASON_PATROLCHANGED, guard)
					end
				end
			end
			sim:processReactions()

			sim:getNPC():removeAbility(sim, self )
        	end,

		onDespawnAbility = function( self, sim )
		end,
	},

	W93_lockdown = util.extend( createDaemon( STRINGS.PROGEXTEND.DAEMONS.LOCKDOWN ) )
	{
		icon = "gui/icons/daemon_icons/icon-daemon_lockdown.png",
		standardDaemon = true,
		reverseDaemon = false,
		premanent = false,

	     	ENDLESS_DAEMONS = false,
	     	PROGRAM_LIST = true,
	     	OMNI_PROGRAM_LIST_EASY = false,
	     	OMNI_PROGRAM_LIST = true,
	     	REVERSE_DAEMONS = false,

		onSpawnAbility = function( self, sim, player )
			self.duration = self.getDuration(self, sim, 3)
			sim:dispatchEvent( simdefs.EV_SHOW_DAEMON, { name = self.name, icon=self.icon, txt = util.sformat(self.activedesc, self.duration ) } )

			sim:addTrigger( simdefs.TRG_OPEN_DOOR, self )
			sim:addTrigger( simdefs.TRG_END_TURN, self )
        	end,

		onDespawnAbility = function( self, sim )
			sim:removeTrigger( simdefs.TRG_OPEN_DOOR, self )
			sim:removeTrigger( simdefs.TRG_END_TURN, self )
		end,

    		onTrigger = function( self, sim, evType, evData, userUnit )
			mainframe_common.DEFAULT_ABILITY_DAEMON.onTrigger( self, sim, evType, evData, userUnit )
			if evType == simdefs.TRG_OPEN_DOOR and sim:getCurrentPlayer():isPC() and evData.unit then
    	        		local x0, y0 = evData.unit:getLocation()
	            		sim:getNPC():spawnInterest(x0, y0, simdefs.SENSE_RADIO, simdefs.REASON_DOOR, evData.unit)
	            		sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.DAEMONS.LOCKDOWN.WARNING, color=cdefs.COLOR_CORP_WARNING, sound = "SpySociety/Actions/mainframe_deterrent_action" } )
				sim:trackerAdvance( 1 )
			end 
     		end,

		executeTimedAbility = function( self, sim )
			sim:getNPC():removeAbility(sim, self )
		end,		
	},

	W93_lockdownV2 = util.extend( createDaemon( STRINGS.PROGEXTEND.DAEMONS.LOCKDOWNV2 ) )
	{
		icon = "gui/icons/daemon_icons/icon-daemon_lockdownV2.png",
		standardDaemon = false,
		reverseDaemon = false,
		premanent = true,

	     	ENDLESS_DAEMONS = false,
	     	PROGRAM_LIST = false,
	     	OMNI_PROGRAM_LIST_EASY = false,
	     	OMNI_PROGRAM_LIST = false,
	     	REVERSE_DAEMONS = false,

		onSpawnAbility = function( self, sim, player )
			sim:dispatchEvent( simdefs.EV_SHOW_DAEMON, { name = self.name, icon=self.icon, txt = self.activedesc } )

			sim:addTrigger( simdefs.TRG_UNIT_USEDOOR, self )
			sim:addTrigger( simdefs.TRG_START_TURN, self )

			for i, unit in ipairs(sim:getPC():getUnits()) do
				if unit:hasTrait("ap") then
					if unit:getTraits().ap > 0 then
						unit:getTraits().ap = unit:getTraits().ap - 1
					end
				end
			end
        	end,

		onDespawnAbility = function( self, sim )
			sim:removeTrigger( simdefs.TRG_UNIT_USEDOOR, self )
			sim:removeTrigger( simdefs.TRG_START_TURN, self )
		end,

    		onTrigger = function( self, sim, evType, evData, userUnit )
			if evType == simdefs.TRG_UNIT_USEDOOR and sim:getCurrentPlayer():isPC() and evData.unit then
    	        		local x0, y0 = evData.unit:getLocation()
	            		sim:getNPC():spawnInterest(x0, y0, simdefs.SENSE_RADIO, simdefs.REASON_DOOR, evData.unit)
	            		sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.DAEMONS.LOCKDOWNV2.WARNING, color=cdefs.COLOR_CORP_WARNING, sound = "SpySociety/Actions/mainframe_deterrent_action" } )
			end

			if evType == simdefs.TRG_START_TURN and sim:getCurrentPlayer():isPC() then
				for i, unit in ipairs(sim:getPC():getUnits())do
					if unit:hasTrait("ap") then
						if unit:getTraits().ap > 0 then
							unit:getTraits().ap = unit:getTraits().ap - 1
						end
					end
				end
			end 
     		end,		
	},

	W93_owl = util.extend( createDaemon( STRINGS.PROGEXTEND.DAEMONS.OWL ) )
	{
		icon = "gui/icons/daemon_icons/icon-daemon_owl.png",
		standardDaemon = true,
		reverseDaemon = false,
		premanent = false,

	     	ENDLESS_DAEMONS = false,
	     	PROGRAM_LIST = true,
	     	OMNI_PROGRAM_LIST_EASY = false,
	     	OMNI_PROGRAM_LIST = true,
	     	REVERSE_DAEMONS = false,

		onSpawnAbility = function( self, sim, player )
			sim:dispatchEvent( simdefs.EV_SHOW_DAEMON, { name = self.name, icon=self.icon, txt = self.activedesc } )

			for _, unit in ipairs(sim:getNPC():getUnits() ) do
				if unit:getTraits().hasSight and unit:getTraits().isGuard then
					if unit:getTraits().LOSarc and unit:getTraits().LOSarc < math.pi then
						unit:getTraits().LOSarc = math.min(unit:getTraits().LOSarc + (math.pi / 6), math.pi)
					end
					if unit:getTraits().LOSperipheralArc and unit:getTraits().LOSperipheralArc < math.pi then
						unit:getTraits().LOSperipheralArc = math.min(unit:getTraits().LOSperipheralArc + (math.pi / 6), math.pi)
					end
					if unit:getTraits().LOSrange and unit:getTraits().LOSrange > 1 then
						unit:getTraits().LOSrange = unit:getTraits().LOSrange + 3
					end
					if unit:getTraits().LOSperipheralRange and unit:getTraits().LOSperipheralRange > 1 then
						unit:getTraits().LOSperipheralRange = unit:getTraits().LOSperipheralRange + 3
					end
					sim:refreshUnitLOS( unit )
				end
			end
			sim:getNPC():removeAbility(sim, self)
        	end,		
	},

	W93_owlV2 = util.extend( createDaemon( STRINGS.PROGEXTEND.DAEMONS.OWLV2 ) )
	{
		icon = "gui/icons/daemon_icons/icon-daemon_owl.png",
		standardDaemon = false,
		reverseDaemon = false,
		premanent = false,

	     	ENDLESS_DAEMONS = false,
	     	PROGRAM_LIST = false,
	     	OMNI_PROGRAM_LIST_EASY = false,
	     	OMNI_PROGRAM_LIST = false,
	     	REVERSE_DAEMONS = false,

		onSpawnAbility = function( self, sim, player )
			sim:dispatchEvent( simdefs.EV_SHOW_DAEMON, { name = self.name, icon=self.icon, txt = self.activedesc } )
			sim:addTrigger( simdefs.TRG_START_TURN, self )

			for _, unit in ipairs(sim:getNPC():getUnits()) do
				if unit:getTraits().hasSight and unit:getTraits().isGuard then
					if not unit:getModifiers():has( "LOSarc", "owl" ) then
						unit:getModifiers():add( "LOSarc", "owl", modifiers.ADD, math.pi/4 )
					end
					if not unit:getModifiers():has( "LOSperipheralArc", "owl" ) then
						unit:getModifiers():add( "LOSperipheralArc", "owl", modifiers.ADD, math.pi/4 )
					end
					if not unit:getModifiers():has( "LOSrange", "owl" ) then
						unit:getModifiers():add( "LOSrange", "owl", modifiers.ADD, 2 )
					end
					if not unit:getModifiers():has( "LOSperipheralRange", "owl" ) then
						unit:getModifiers():add( "LOSperipheralRange", "owl", modifiers.ADD, 2 )
					end
					sim:refreshUnitLOS( unit )
					sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = unit } )
				end
			end
        	end,

		onDespawnAbility = function( self, sim )
			sim:removeTrigger( simdefs.TRG_START_TURN, self )
			for _, unit in ipairs(sim:getAllUnits()) do
				if unit:getModifiers():remove( "owl" ) then
                        		sim:refreshUnitLOS( unit )
					sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = unit } )
				end
			end
		end,

    		onTrigger = function( self, sim, evType, evData, userUnit )
			mainframe_common.DEFAULT_ABILITY_DAEMON.onTrigger( self, sim, evType, evData, userUnit )
			if evType == simdefs.TRG_START_TURN then
				for _, unit in ipairs(sim:getNPC():getUnits()) do
					if unit:getTraits().hasSight and unit:getTraits().isGuard then
						if not unit:getModifiers():has( "LOSarc", "owl" ) then
							unit:getModifiers():add( "LOSarc", "owl", modifiers.ADD, math.pi/4 )
						end
						if not unit:getModifiers():has( "LOSperipheralArc", "owl" ) then
							unit:getModifiers():add( "LOSperipheralArc", "owl", modifiers.ADD, math.pi/4 )
						end
						if not unit:getModifiers():has( "LOSrange", "owl" ) then
							unit:getModifiers():add( "LOSrange", "owl", modifiers.ADD, 2 )
						end
						if not unit:getModifiers():has( "LOSperipheralRange", "owl" ) then
							unit:getModifiers():add( "LOSperipheralRange", "owl", modifiers.ADD, 2 )
						end
						sim:refreshUnitLOS( unit )
						sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = unit } )
					end
				end
			end 
     		end,		
	},

	W93_poison = util.extend( createDaemon( STRINGS.PROGEXTEND.DAEMONS.POISON ) )
	{
		icon = "gui/icons/daemon_icons/icon-daemon_poison.png",
		standardDaemon = true,
		reverseDaemon = false,
		premanent = false,
		KOtime = 3,
		agent = nil,

	     	ENDLESS_DAEMONS = false,
	     	PROGRAM_LIST = true,
	     	OMNI_PROGRAM_LIST_EASY = false,
	     	OMNI_PROGRAM_LIST = true,
	     	REVERSE_DAEMONS = false,

		onSpawnAbility = function( self, sim, player )
			self.duration = self.getDuration(self, sim, 3)

			sim:dispatchEvent( simdefs.EV_SHOW_DAEMON, { name = self.name, icon=self.icon, txt = util.sformat(self.activedesc, self.duration) } )	
			sim:addTrigger( simdefs.TRG_END_TURN, self )

			local agents = sim:getPC():getAgents()
			for i, unit in ipairs(agents) do
	    			self.agent = agents[sim:nextRand( 1, #agents )]
				if not self.agent:getTraits().poisoned then
					self.agent:getTraits().poisoned = self.KOtime
					break
				end
			end
		end,

		onDespawnAbility = function( self, sim, unit )
			if self.agent then
				self.agent:setKO( sim, self.agent:getTraits().poisoned, "emp" )
				self.agent:getTraits().poisoned = nil
				sim:dispatchEvent( simdefs.EV_PLAY_SOUND, "SpySociety/Actions/mainframe_lightning_strike" )
			end			
			sim:removeTrigger( simdefs.TRG_END_TURN, self )	
		end,

		executeTimedAbility = function( self, sim )
			sim:getNPC():removeAbility(sim, self )
		end	
	},

	W93_poisonV2 = util.extend( createDaemon( STRINGS.PROGEXTEND.DAEMONS.POISONV2 ) )
	{
		icon = "gui/icons/daemon_icons/icon-daemon_poison.png",
		standardDaemon = false,
		reverseDaemon = false,
		premanent = true,
		KOtime = 3,
		agent = nil,

	     	ENDLESS_DAEMONS = true,
	     	PROGRAM_LIST = false,
	     	OMNI_PROGRAM_LIST_EASY = false,
	     	OMNI_PROGRAM_LIST = false,
	     	REVERSE_DAEMONS = false,

		onSpawnAbility = function( self, sim, player )
			sim:dispatchEvent( simdefs.EV_SHOW_DAEMON, { name = self.name, icon=self.icon, txt = util.sformat(self.activedesc) } )	
			sim:addTrigger( simdefs.TRG_ALARM_STATE_CHANGE, self )

	    		local agents = sim:getPC():getAgents()
			for i, unit in ipairs(agents) do
	    			self.agent = agents[ sim:nextRand( 1, #agents ) ]
				if not self.agent:getTraits().poisoned then
					self.agent:getTraits().poisoned = self.KOtime
					break
				end
			end
		end,

		onDespawnAbility = function( self, sim, unit )			
			sim:removeTrigger( simdefs.TRG_ALARM_STATE_CHANGE, self )	
		end,

		onTrigger = function( self, sim, evType, evData, userUnit )
			if evType == simdefs.TRG_ALARM_STATE_CHANGE then
				if self.agent then
					self.agent:setKO( sim, self.agent:getTraits().poisoned, "emp" )
					self.agent:getTraits().poisoned = nil
					sim:dispatchEvent( simdefs.EV_PLAY_SOUND, "SpySociety/Actions/mainframe_lightning_strike" )
				end

				local agents = sim:getPC():getAgents()
				for i, unit in ipairs(agents) do
	    				self.agent = agents[ sim:nextRand( 1, #agents ) ]
					if not self.agent:getTraits().poisoned then
						self.agent:getTraits().poisoned = self.KOtime
						break
					end
				end
			end
		end,
	
	},

	W93_pulse = util.extend( createDaemon( STRINGS.PROGEXTEND.DAEMONS.PULSE ) )
	{
		icon = "gui/icons/daemon_icons/icon-daemon_pulse.png",
		standardDaemon = true,
		reverseDaemon = false,
		premanent = false,

	     	ENDLESS_DAEMONS = false,
	     	PROGRAM_LIST = true,
	     	OMNI_PROGRAM_LIST_EASY = false,
	     	OMNI_PROGRAM_LIST = true,
	     	REVERSE_DAEMONS = false,

		onSpawnAbility = function( self, sim, player )
			self.duration = self.getDuration(self, sim, sim:nextRand(5,7))
			local pcplayer = sim:getPC()
			self.items = {}

			sim:dispatchEvent( simdefs.EV_SHOW_DAEMON, { name = self.name, icon=self.icon, txt = util.sformat(self.activedesc, self.duration) } )	

			local pcplayer = sim:getPC()
			for i, unit in pairs( pcplayer:getUnits() ) do 
				for i, item in pairs( unit:getChildren() ) do 
					table.insert( self.items, item )
				end 
			end 

			for _, item in ipairs(self.items) do
				if item:getTraits().cooldownMax then 
					item:getTraits().cooldownMax = item:getTraits().cooldownMax + 3
				end 
			end

			sim:addTrigger( simdefs.TRG_END_TURN, self )	
		end,

		onDespawnAbility = function( self, sim, unit )
			for _, item in ipairs(self.items) do
				if item:getTraits().cooldownMax then 
					item:getTraits().cooldownMax = item:getTraits().cooldownMax - 3
				end 
			end
			sim:removeTrigger( simdefs.TRG_END_TURN, self )	
		end,

		executeTimedAbility = function( self, sim )
			sim:getNPC():removeAbility(sim, self )
		end	
	},

	W93_shackles = util.extend( createDaemon( STRINGS.PROGEXTEND.DAEMONS.SHACKLES ) )
	{
		icon = "gui/icons/daemon_icons/icon-daemon_schackles.png",

		standardDaemon = true,
		reverseDaemon = false,
		premanent = false,

	     	ENDLESS_DAEMONS = false,
	     	PROGRAM_LIST = true,
	     	OMNI_PROGRAM_LIST_EASY = false,
	     	OMNI_PROGRAM_LIST = true,
	     	REVERSE_DAEMONS = false,

		onSpawnAbility = function( self, sim, player )
			self.duration = self.getDuration(self, sim, sim:nextRand(3,4))
			sim:dispatchEvent( simdefs.EV_SHOW_DAEMON, { name = self.name, icon=self.icon, txt = util.sformat(self.activedesc, self.duration ) } )
			sim:addTrigger( simdefs.TRG_END_TURN, self )
			sim:getPC():getTraits().shackleDaemon = true
		end,

		onDespawnAbility = function( self, sim )		
			sim:removeTrigger( simdefs.TRG_END_TURN, self )
			sim:getPC():getTraits().shackleDaemon = nil	
		end,
	
		executeTimedAbility = function( self, sim )
			sim:getNPC():removeAbility(sim, self )
		end,	
	},

	W93_short = util.extend( createDaemon( STRINGS.PROGEXTEND.DAEMONS.SHORT ) )
	{
		icon = "gui/icons/daemon_icons/icon-daemon_short.png",

		standardDaemon = true,
		reverseDaemon = false,
		premanent = false,
		short_amount = 12,

	     	ENDLESS_DAEMONS = false,
	     	PROGRAM_LIST = true,
	     	OMNI_PROGRAM_LIST_EASY = false,
	     	OMNI_PROGRAM_LIST = true,
	     	REVERSE_DAEMONS = false,

		onSpawnAbility = function( self, sim, player )
			self.duration = self.getDuration(self, sim, sim:nextRand(4,6))
			self.desc = util.sformat(STRINGS.PROGEXTEND.DAEMONS.SHORT.DESC2,self.short_amount)
			if not sim:getPC():getTraits().PWRmaxBouns then
				sim:getPC():getTraits().PWRmaxBouns = 0
			end
			sim:getPC():getTraits().PWRmaxBouns = sim:getPC():getTraits().PWRmaxBouns - self.short_amount
			sim:getPC():addCPUs( 0, sim )
			sim:dispatchEvent( simdefs.EV_SHOW_DAEMON, { name = self.name, icon=self.icon, txt = util.sformat(self.activedesc, self.duration, self.short_amount ) } )
			sim:addTrigger( simdefs.TRG_END_TURN, self )	
		end,

		onDespawnAbility = function( self, sim )		
			sim:removeTrigger( simdefs.TRG_END_TURN, self )	
			sim:getPC():getTraits().PWRmaxBouns = sim:getPC():getTraits().PWRmaxBouns + self.short_amount
		end,
	
		executeTimedAbility = function( self, sim )
			sim:getNPC():removeAbility(sim, self )
		end,	
	},

	W93_shortV2 = util.extend( createDaemon( STRINGS.PROGEXTEND.DAEMONS.SHORTV2 ) )
	{
		icon = "gui/icons/daemon_icons/icon-daemon_short.png",

		standardDaemon = false,
		reverseDaemon = false,
		premanent = true,
		short_amount = 10,

	     	ENDLESS_DAEMONS = true,
	     	PROGRAM_LIST = false,
	     	OMNI_PROGRAM_LIST_EASY = false,
	     	OMNI_PROGRAM_LIST = false,
	     	REVERSE_DAEMONS = false,

		onSpawnAbility = function( self, sim, player )
			if not sim:getPC():getTraits().PWRmaxBouns then
				sim:getPC():getTraits().PWRmaxBouns = 0
			end
			sim:getPC():getTraits().PWRmaxBouns = sim:getPC():getTraits().PWRmaxBouns - self.short_amount
			sim:getPC():addCPUs( 0, sim )
			sim:dispatchEvent( simdefs.EV_SHOW_DAEMON, { name = self.name, icon=self.icon, txt = self.activedesc } )
			sim:addTrigger( simdefs.TRG_START_TURN, self )	
		end,

		onDespawnAbility = function( self, sim )		
			sim:getPC():getTraits().PWRmaxBouns = sim:getPC():getTraits().PWRmaxBouns + self.short_amount
			sim:removeTrigger( simdefs.TRG_START_TURN, self )
		end,
	
    		onTrigger = function( self, sim, evType, evData, userUnit )
			if evType == simdefs.TRG_START_TURN and sim:getCurrentPlayer():isPC() then
				sim:getPC():getTraits().PWRmaxBouns = sim:getPC():getTraits().PWRmaxBouns + self.short_amount
				self.short_amount = 10 + math.min(sim:getTrackerStage(sim:getTracker()),simdefs.TRACKER_MAXSTAGE)
				sim:getPC():getTraits().PWRmaxBouns = sim:getPC():getTraits().PWRmaxBouns - self.short_amount
				sim:getPC():addCPUs( 0, sim )
     			end
     		end,
	},

	W93_sleep = util.extend( createDaemon( STRINGS.PROGEXTEND.DAEMONS.SLEEP ) )
	{
		icon = "gui/icons/daemon_icons/icon-daemon_sleep.png",
		standardDaemon = true,
		reverseDaemon = false,
		premanent = true,

	     	ENDLESS_DAEMONS = false,
	     	PROGRAM_LIST = true,
	     	OMNI_PROGRAM_LIST_EASY = false,
	     	OMNI_PROGRAM_LIST = true,
	     	REVERSE_DAEMONS = false,

		onSpawnAbility = function( self, sim, player )
			sim:dispatchEvent( simdefs.EV_SHOW_DAEMON, { name = self.name, icon=self.icon, txt = self.activedesc } )

			sim:addTrigger( simdefs.TRG_START_TURN, self )
        	end,

		onDespawnAbility = function( self, sim )
			sim:removeTrigger( simdefs.TRG_START_TURN, self )
			sim:endTurn()
			--sim._players[1]:onStartTurn( sim )
			--sim:triggerEvent(simdefs.TRG_START_TURN, sim._players[1] )
			--sim._players[1]:prioritiseUnits()
			--sim._players[1]:tickAllBrains()
			for _,unit in pairs(sim._players[1]:getUnits() ) do
				if unit:getBrain() then
					unit:getBrain():reset()
				end
			end
			sim._players[1]:thinkHard( sim )
			sim:getPC():getTraits().sleep = nil
		end,

    		onTrigger = function( self, sim, evType, evData, userUnit )
			if evType == simdefs.TRG_START_TURN and sim:getCurrentPlayer():isPC() and not sim:getPC():getTraits().sleep then
				sim:getPC():getTraits().sleep = true
				sim:getNPC():removeAbility( sim, self )
     			end
     		end,
	},
}

return npc_abilities