local mathutil = include( "modules/mathutil" )
local array = include( "modules/array" )
local util = include( "modules/util" )
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local simfactory = include( "sim/simfactory" )
local cdefs = include( "client_defs" )
local serverdefs = include( "modules/serverdefs" )
local mainframe_common = include("sim/abilities/mainframe_common")
local speechdefs = include( "sim/speechdefs" )
local modifiers = include( "sim/modifiers" )
local level = include( "sim/level" )
local mainframe = include( "sim/mainframe" )
-------------------------------------------------------------------------------
-- These are NPC abilities.

local createDaemon = mainframe_common.createDaemon
local createReverseDaemon = mainframe_common.createReverseDaemon
local createCountermeasureInterest = mainframe_common.createCountermeasureInterest

local function guardLooted( script, sim )
	local UI_LOOT_CLOSED =
    	{
        	uiEvent = level.EV_CLOSE_LOOT_UI,
        	fn = function( sim )
            		return true
        	end
	}

	local i, triggerData = script:waitFor(UI_LOOT_CLOSED)
    	script:queue( 1*cdefs.SECONDS )
	sim:triggerEvent( simdefs.TRG_UI_ACTION, level.EV_CLOSE_LOOT_UI )
    	script:addHook( guardLooted, true )
end

local subroutines =
{
	PWR =
	{
		{
			name = STRINGS.PROGEXTEND.AI.ALARM_SYNCHRONIZER,
			desc = STRINGS.PROGEXTEND.AI.ALARM_SYNCHRONIZER_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 1,
			maxDifficulty = 4,

			onTrigger = function( self, sim, evType, evData, userUnit, slot )
				if evType == simdefs.TRG_START_TURN and sim:getCurrentPlayer() == sim:getNPC() then
					local pwr = math.min(sim:getTrackerStage(sim:getTracker())/2, simdefs.TRACKER_MAXSTAGE/2)

					if math.ceil(pwr) > 0 then
						sim:getNPC():addCPUs( math.ceil(pwr) )

						if slot.identified or sim:getNPC():getTraits().showAI then
							sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.ALARM_SYNCHRONIZER_DESC,math.ceil(pwr)), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
						else
							sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
						end
						sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
					end
				end
			end,
		},
		{
			name = STRINGS.PROGEXTEND.AI.FEEDBACK_GRID,
			desc = STRINGS.PROGEXTEND.AI.FEEDBACK_GRID_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 2,
			maxDifficulty = 100,

			onTrigger = function( self, sim, evType, evData, userUnit, slot )
				if evType == simdefs.TRG_START_TURN and sim:getCurrentPlayer() == sim:getNPC() then
					local pwr = 0

					for i, unit in pairs(sim:getAllUnits()) do
						if unit:getTraits().mainframe_status == "active" and unit:getTraits().mainframe_ice and unit:getTraits().mainframe_ice <= 0 then
							pwr = pwr + 0.25
						end
					end

					if math.ceil(pwr) > 0 then
						sim:getNPC():addCPUs( math.ceil(pwr) )

						if slot.identified or sim:getNPC():getTraits().showAI then
							sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.FEEDBACK_GRID_DESC,math.ceil(pwr)), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
						else
							sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
						end
						sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
					end
				end
			end,
		},
		{
			name = STRINGS.PROGEXTEND.AI.LEECH,
			desc = STRINGS.PROGEXTEND.AI.LEECH_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 3,
			maxDifficulty = 100,

			onTrigger = function( self, sim, evType, evData, userUnit, slot )
				if evType == simdefs.TRG_START_TURN and sim:getCurrentPlayer() == sim:getNPC() then
					local pwr = math.min(1,sim:getPC():getCpus())

					if pwr > 0 then
						sim:getNPC():addCPUs( pwr*2 )
						sim:getPC():addCPUs( -pwr )

						if slot.identified or sim:getNPC():getTraits().showAI then
							sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.LEECH_DESC,pwr*2, pwr), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
						else
							sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
						end
						sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
					end
				end
			end,
		},
		{
			name = STRINGS.PROGEXTEND.AI.TERMINAL_LINK,
			desc = STRINGS.PROGEXTEND.AI.TERMINAL_LINK_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 4,
			maxDifficulty = 100,

			onTrigger = function( self, sim, evType, evData, userUnit, slot )
				if evType == simdefs.TRG_START_TURN and sim:getCurrentPlayer() == sim:getNPC() then
					local pwr = 0

					for i, unit in pairs(sim:getAllUnits()) do
						if unit:getTraits().mainframe_console and unit:getTraits().mainframe_status == "active" and not unit:getTraits().hijacked then
							pwr = pwr + 1
						end
					end

					if pwr > 0 then
						sim:getNPC():addCPUs( pwr )

						if slot.identified or sim:getNPC():getTraits().showAI then
							sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.TERMINAL_LINK_DESC, pwr), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
						else
							sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
						end
						sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
					end
				end
			end,
		},
		{
			name = STRINGS.PROGEXTEND.AI.SOUNDWEAVE,
			desc = STRINGS.PROGEXTEND.AI.SOUNDWEAVE_TIP,
			identified = false,
			corp = "sankaku",
			minDifficulty = 2,
			maxDifficulty = 100,

			onTrigger = function( self, sim, evType, evData, userUnit, slot )
				if evType == simdefs.TRG_START_TURN and sim:getCurrentPlayer() == sim:getNPC() then
					local pwr = 0

					for i, unit in pairs(sim:getAllUnits()) do
						if unit:getTraits().hasHearing and not unit:getTraits().isGuard and unit:getTraits().mainframe_status == "active" and unit:getTraits().mainframe_ice and unit:getTraits().mainframe_ice > 0 then
						pwr = pwr + 0.5
						end
					end

					if math.floor(pwr) > 0 then
						sim:getNPC():addCPUs( math.floor(pwr) )

						if slot.identified or sim:getNPC():getTraits().showAI then
							sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.SOUNDWEAVE_DESC,math.floor(pwr)), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
						else
							sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
						end
						sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
					end
				end
			end,
		},
		{
			name = STRINGS.PROGEXTEND.AI.OPTIC_DOWNLINK,
			desc = STRINGS.PROGEXTEND.AI.OPTIC_DOWNLINK_TIP,
			identified = false,
			corp = "ftm",
			minDifficulty = 2,
			maxDifficulty = 100,

			onTrigger = function( self, sim, evType, evData, userUnit, slot )
				if evType == simdefs.TRG_START_TURN and sim:getCurrentPlayer() == sim:getNPC() then
					local pwr = 0

					for i, unit in pairs(sim:getAllUnits()) do
						if unit:getTraits().mainframe_camera and unit:getTraits().mainframe_status == "active" and unit:getTraits().mainframe_ice and unit:getTraits().mainframe_ice <= 0 then
							pwr = pwr + 0.5
						end
					end
					if math.floor(pwr) > 0 then
						sim:getNPC():addCPUs( math.floor(pwr) )

						if slot.identified or sim:getNPC():getTraits().showAI then
							sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.OPTIC_DOWNLINK_DESC,math.floor(pwr)), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
						else
							sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
						end
						sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
					end
				end
			end,
		},
		{
			name = STRINGS.PROGEXTEND.AI.DAEMON_CLUSTER,
			desc = STRINGS.PROGEXTEND.AI.DAEMON_CLUSTER_TIP,
			identified = false,
			corp = "plastech",
			minDifficulty = 2,
			maxDifficulty = 100,

			onTrigger = function( self, sim, evType, evData, userUnit, slot )
				if evType == simdefs.TRG_START_TURN and sim:getCurrentPlayer() == sim:getNPC() then
					local pwr = 0

					for i, unit in pairs(sim:getAllUnits()) do
						if unit:getTraits().mainframe_program and unit:getTraits().mainframe_status == "active" and unit:getTraits().mainframe_ice and unit:getTraits().mainframe_ice > 0 then
						pwr = pwr + 0.334
						end
					end

					if math.ceil(pwr) > 0 then
						sim:getNPC():addCPUs( math.ceil(pwr) )

						if slot.identified or sim:getNPC():getTraits().showAI then
							sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.DAEMON_CLUSTER_DESC,math.ceil(pwr)), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
						else
							sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
						end
						sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
					end
				end
			end,
		},
		{
			name = STRINGS.PROGEXTEND.AI.COUNTERWEIGHT,
			desc = STRINGS.PROGEXTEND.AI.COUNTERWEIGHT_TIP,
			identified = false,
			corp = "neptune",
			minDifficulty = 2,
			maxDifficulty = 100,

			onTrigger = function( self, sim, evType, evData, userUnit, slot )
				if evType == simdefs.TRG_START_TURN and sim:getCurrentPlayer() == sim:getNPC() then
					local pwr = 0

					for i, unit in pairs(sim:getAllUnits()) do
						if unit:getTraits().plateType and unit:getTraits().mainframe_status == "active" and unit:getTraits().mainframe_ice and unit:getTraits().mainframe_ice <= 0 then
							pwr = pwr + 0.5
						end
					end

					if math.ceil(pwr) > 0 then
						sim:getNPC():addCPUs( math.ceil(pwr) )

						if slot.identified or sim:getNPC():getTraits().showAI then
							sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.COUNTERWEIGHT_DESC,math.ceil(pwr)), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
						else
							sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
						end
						sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
					end
				end
			end,
		},
		{
			name = STRINGS.PROGEXTEND.AI.CYCLONE,
			desc = STRINGS.PROGEXTEND.AI.CYCLONE_TIP,
			identified = false,
			corp = "ko",
			minDifficulty = 2,
			maxDifficulty = 100,

			onTrigger = function( self, sim, evType, evData, userUnit, slot )
				if evType == simdefs.TRG_UNIT_WARP and sim:getCurrentPlayer() == sim:getPC() then
					self.CyclonePWR = 0
					for i, unit in pairs(sim:getPC():getUnits()) do
						if unit:getMP() and unit:getMPMax() then
							self.CyclonePWR = self.CyclonePWR + math.floor((unit:getMPMax() - unit:getMP())/5)
						end
					end
				end
				if evType == simdefs.TRG_START_TURN and sim:getCurrentPlayer() == sim:getNPC() and self.CyclonePWR then
					if self.CyclonePWR > 0 then
						sim:getNPC():addCPUs( self.CyclonePWR )

						if slot.identified or sim:getNPC():getTraits().showAI then
							sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.CYCLONE_DESC,self.CyclonePWR), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
						else
							sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
						end
						sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
					end
				end
			end,
		},
		{
			name = STRINGS.PROGEXTEND.AI.DIRECT_FEED,
			desc = STRINGS.PROGEXTEND.AI.DIRECT_FEED_TIP,
			identified = false,
			corp = "omni",
			minDifficulty = 1,
			maxDifficulty = 100,

			onTrigger = function( self, sim, evType, evData, userUnit, slot )
				if evType == simdefs.TRG_ICE_BROKEN and evData.delta then
					local pwr = math.max( -evData.delta, 0)

					if pwr > 0 then
						sim:getNPC():addCPUs( pwr )

						if slot.identified or sim:getNPC():getTraits().showAI then
							sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.DIRECT_FEED_DESC, pwr), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
						else
							sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
						end
						sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
					end
				end
			end,
		},
		{
			name = STRINGS.PROGEXTEND.AI.GENERATOR,
			desc = STRINGS.PROGEXTEND.AI.GENERATOR_TIP,
			identified = false,
			corp = "omni",
			minDifficulty = 1,
			maxDifficulty = 100,

			onTrigger = function( self, sim, evType, evData, userUnit, slot )
				if evType == simdefs.TRG_START_TURN and sim:getCurrentPlayer() == sim:getNPC() then
					sim:getNPC():addCPUs( 2 )

					if slot.identified or sim:getNPC():getTraits().showAI then
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.GENERATOR_DESC, 2), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					else
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					end
					sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
				end
			end,
		},	
	},	

	PROACTIVE =
	{
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.BUCKLER, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.BUCKLER, "?", slot.cooldownMax )
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.BUCKLER_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 1,
			maxDifficulty = 4,

			cooldown = 0,
			cooldownMax = 1,
			pwrCost = 2,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_END_TURN then
					return false
				end

				if sim:getCurrentPlayer() ~= sim:getNPC() then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				if self.activePrograms > 1 and sim:nextRand(sim:getNPC():getCpus(),sim:getNPC():getMaxCpus()) < 15 then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				local device = nil

				for i, unit in pairs(sim:getAllUnits()) do
					if unit:getTraits().mainframe_ice and unit:getTraits().mainframe_ice <= sim:getParams().difficulty and unit:getTraits().mainframe_ice > 0 then
						if device == nil then
							device = unit
						elseif unit:getTraits().mainframe_ice < device:getTraits().mainframe_ice then
							device = unit
						end
					end
				end

				if device then
					sim:getNPC():addCPUs(-slot.pwrCost)
					slot.cooldown = slot.cooldownMax
					device:increaseIce(sim, 1)

					if slot.identified or sim:getNPC():getTraits().showAI then
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.BUCKLER_DESC,device:getName()), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					else
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					end
					sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
				end
			end,
		},
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.HEATER, slot.cooldown, slot.cooldownMax )
				else
					return string.format(STRINGS.PROGEXTEND.AI.HEATER, "?", slot.cooldownMax )
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.HEATER_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 2,
			maxDifficulty = 5,

			cooldown = 0,
			cooldownMax = 2,
			pwrCost = 3,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_END_TURN then
					return false
				end

				if sim:getCurrentPlayer() ~= sim:getNPC() then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				if self.activePrograms > 1 and sim:nextRand(sim:getNPC():getCpus(),sim:getNPC():getMaxCpus()) < 15 then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				local device = nil

				for i, unit in pairs(sim:getAllUnits()) do
					if unit:getTraits().mainframe_ice and unit:getTraits().mainframe_ice <= sim:getParams().difficulty and unit:getTraits().mainframe_ice > 0 then
						if device == nil then
							device = unit
						elseif unit:getTraits().mainframe_ice < device:getTraits().mainframe_ice then
							device = unit
						end
					end
				end

				if device then
					local pwr = math.max(math.ceil(sim:getNPC():getCpus()/5),1)

					sim:getNPC():addCPUs(-slot.pwrCost)
					slot.cooldown = slot.cooldownMax
					device:increaseIce(sim, pwr)

					if slot.identified or sim:getNPC():getTraits().showAI then
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.HEATER_DESC,device:getName(), pwr), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					else
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					end
					sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
				end
			end,
		},
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.KITE, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.KITE, "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.KITE_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 2,
			maxDifficulty = 5,

			cooldown = 0,
			cooldownMax = 2,
			pwrCost = 3,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_END_TURN then
					return false
				end

				if sim:getCurrentPlayer() ~= sim:getNPC() then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				if self.activePrograms > 1 and sim:nextRand(sim:getNPC():getCpus(),sim:getNPC():getMaxCpus()) < 15 then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				local device = nil

				for i, unit in pairs(sim:getAllUnits()) do
					if unit:getTraits().mainframe_ice and unit:getTraits().mainframe_ice <= sim:getParams().difficulty and unit:getTraits().mainframe_ice > 0 then
						if device == nil then
							device = unit
						elseif unit:getTraits().mainframe_ice < device:getTraits().mainframe_ice then
							device = unit
						end
					end
				end

				if device then
					local cellx, celly = device:getLocation()
            				local cells = simquery.rasterCircle( sim, cellx, celly, 3 )
            				for i, x, y in util.xypairs( cells ) do
                				local cell = sim:getCell( x, y )
                				if cell then
                    					for _, cellUnit in ipairs(cell.units) do
								cellUnit:increaseIce(sim, 1)
                            				end
                        			end
                    			end

					sim:getNPC():addCPUs(-slot.pwrCost)
					slot.cooldown = slot.cooldownMax

					if slot.identified or sim:getNPC():getTraits().showAI then
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.KITE_DESC,device:getName()), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					else
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					end
					sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
				end
			end,
		},
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.PAVISE, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.PAVISE, "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.PAVISE_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 4,
			maxDifficulty = 100,

			cooldown = 0,
			cooldownMax = 3,
			pwrCost = 5,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_END_TURN then
					return false
				end

				if sim:getCurrentPlayer() ~= sim:getNPC() then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				if self.activePrograms > 1 and sim:nextRand(sim:getNPC():getCpus(),sim:getNPC():getMaxCpus()) < 15 then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				local device = nil

				for i, unit in pairs(sim:getAllUnits()) do
					if unit:getTraits().mainframe_ice and unit:getTraits().mainframe_ice <= sim:getParams().difficulty and unit:getTraits().mainframe_ice > 0 then
						if device == nil then
							device = unit
						elseif unit:getTraits().mainframe_ice < device:getTraits().mainframe_ice then
							device = unit
						end
					end
				end

				if device then
					sim:getNPC():addCPUs(-slot.pwrCost)
					slot.cooldown = slot.cooldownMax
					device:increaseIce(sim, device:getTraits().mainframe_ice)

					if slot.identified or sim:getNPC():getTraits().showAI then
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.PAVISE_DESC,device:getName()), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					else
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					end
					sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
				end
			end,
		},
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.TARGE, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.TARGE, "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.TARGE_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 4,
			maxDifficulty = 100,

			cooldown = 0,
			cooldownMax = 3,
			pwrCost = 5,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_END_TURN then
					return false
				end

				if sim:getCurrentPlayer() ~= sim:getNPC() then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				if self.activePrograms > 1 and sim:nextRand(sim:getNPC():getCpus(),sim:getNPC():getMaxCpus()) < 15 then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				local device = nil

				for i, unit in pairs(sim:getAllUnits()) do
					if unit:getTraits().mainframe_ice and unit:getTraits().mainframe_ice <= sim:getParams().difficulty and unit:getTraits().mainframe_ice > 0 then
						if device == nil then
							device = unit
						elseif unit:getTraits().mainframe_ice < device:getTraits().mainframe_ice then
							device = unit
						end
					end
				end

				if device then
					for i, unit in pairs(sim:getAllUnits()) do
						if unit:getName() == device:getName() and unit:getTraits().mainframe_ice and unit:getTraits().mainframe_ice > 0 then
							unit:increaseIce(sim, 1)
						end
					end
					sim:getNPC():addCPUs(-slot.pwrCost)
					slot.cooldown = slot.cooldownMax

					if slot.identified or sim:getNPC():getTraits().showAI then
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.TARGE_DESC,device:getName()), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					else
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					end
					sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
				end
			end,
		},
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.PING, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.PING, "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.PING_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 3,
			maxDifficulty = 100,

			cooldown = 0,
			cooldownMax = 3,
			pwrCost = 4,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_END_TURN then
					return false
				end

				if sim:getCurrentPlayer() ~= sim:getNPC() then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				if self.activePrograms > 1 and sim:nextRand(sim:getNPC():getCpus(),sim:getNPC():getMaxCpus()) < 15 then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				for i, unit in pairs(sim:getPC():getUnits()) do
					if unit:getMP() then
						local x,y = unit:getLocation()
						sim:emitSound( simdefs.SOUND_MAINFRAME_PING, x, y, nil, {{ x = x, y = y }} )
						sim:processReactions(unit)
						if slot.identified or sim:getNPC():getTraits().showAI then
							sim:dispatchEvent( simdefs.EV_SCANRING_VIS, { x=x,y=y, range=simdefs.SOUND_MAINFRAME_PING.range } )
						end
					end
				end

				sim:getNPC():addCPUs(-slot.pwrCost)
				slot.cooldown = slot.cooldownMax

				if slot.identified or sim:getNPC():getTraits().showAI then	
					sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.PING_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
				else
					sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
				end
				sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
			end,
		},
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.CHITON, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.CHITON, "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.CHITON_TIP,
			identified = false,
			corp = "ko",
			minDifficulty = 2,
			maxDifficulty = 100,

			cooldown = 0,
			cooldownMax = 4,
			pwrCost = 6,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_END_TURN then
					return false
				end

				if sim:getCurrentPlayer() ~= sim:getNPC() then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				if self.activePrograms > 1 and sim:nextRand(sim:getNPC():getCpus(),sim:getNPC():getMaxCpus()) < 15 then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				local guard = nil
				for i, unit in pairs(sim:getNPC():getUnits()) do
					if unit:getTraits().isGuard and (not unit:getTraits().armor or unit:getTraits().armor <= math.min(sim:getParams().difficulty - 1, 8)) and not unit:isDown() then
						if guard == nil then
							guard = unit
						elseif (not unit:getTraits().armor) or (unit:getTraits().armor and guard:getTraits().armor and unit:getTraits().armor < guard:getTraits().armor) then
							guard = unit
						end
					end
				end
				if guard then
					if not guard:getTraits().armor then
						guard:getTraits().armor = 1
					else				
						unit:getTraits().armor = unit:getTraits().armor + 1
					end

					sim:getNPC():addCPUs(-slot.pwrCost)
					slot.cooldown = slot.cooldownMax

					if slot.identified or sim:getNPC():getTraits().showAI then		
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.CHITON_DESC,guard:getName()), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					else
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					end
					sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
				end
			end,
		},
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.FRACTAL, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.FRACTAL, "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.FRACTAL_TIP,
			identified = false,
			corp = "plastech",
			minDifficulty = 2,
			maxDifficulty = 100,

			cooldown = 0,
			cooldownMax = 3,
			pwrCost = 4,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_END_TURN then
					return false
				end

				if sim:getCurrentPlayer() ~= sim:getNPC() then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				if self.activePrograms > 1 and sim:nextRand(sim:getNPC():getCpus(),sim:getNPC():getMaxCpus()) < 15 then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				for i, unit in pairs(sim:getAllUnits()) do
					if unit:getTraits().mainframe_ice and unit:getTraits().mainframe_ice > 0 and not unit:getTraits().mainframe_program then
						if sim:isVersion("0.17.5") then
							local programList = sim:getIcePrograms()
							unit:getTraits().mainframe_program = programList:getChoice( sim:nextRand( 1, programList:getTotalWeight() ))
						else
							unit:getTraits().mainframe_program = PROGRAM_LIST[ sim:nextRand(1, #PROGRAM_LIST) ]
						end	

						sim:dispatchEvent( simdefs.EV_UNIT_UPDATE_ICE, { unit = unit, ice = unit:getTraits().mainframe_ice, delta = 0} )
						sim:getNPC():addCPUs(-slot.pwrCost)
						slot.cooldown = slot.cooldownMax

						if slot.identified or sim:getNPC():getTraits().showAI then		
							sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.FRACTAL_DESC,unit:getName()), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
						else
							sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
						end
						sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
						break
					end
				end
			end,
		},
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.BLOWFISH, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.BLOWFISH, "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.BLOWFISH_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 2,
			maxDifficulty = 100,

			cooldown = 0,
			cooldownMax = 3,
			pwrCost = 3,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_END_TURN then
					return false
				end

				if sim:getCurrentPlayer() ~= sim:getNPC() then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				if self.activePrograms > 1 and sim:nextRand(sim:getNPC():getCpus(),sim:getNPC():getMaxCpus()) < 15 then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				if sim:getTrackerStage(sim:getTracker()) < simdefs.TRACKER_MAXSTAGE then
					local alarm = 1
					sim:trackerAdvance( alarm )
					sim:getNPC():addCPUs(-slot.pwrCost)
					slot.cooldown = slot.cooldownMax

					if slot.identified or sim:getNPC():getTraits().showAI then		
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.BLOWFISH_DESC,alarm), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					else
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					end
					sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
				end
			end,
		},
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.BLIZZARD, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.BLIZZARD, "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.BLIZZARD_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 3,
			maxDifficulty = 100,

			cooldown = 0,
			cooldownMax = 3,
			pwrCost = 4,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_START_TURN then
					return false
				end

				if sim:getCurrentPlayer() ~= sim:getPC() then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				if self.activePrograms > 1 and sim:nextRand(sim:getNPC():getCpus(),sim:getNPC():getMaxCpus()) < 15 then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				for i, unit in pairs(sim:getPC():getUnits()) do
					if unit:getTraits().mp and unit:getTraits().mp > 5 then
						local x,y = unit:getLocation()
						unit:getTraits().mp = unit:getTraits().mp - 2
						sim:dispatchEvent( simdefs.EV_SCANRING_VIS, { x=x,y=y, range=2 } )
					end
				end

				sim:getNPC():addCPUs(-slot.pwrCost)
				slot.cooldown = slot.cooldownMax

				if slot.identified or sim:getNPC():getTraits().showAI then	
					sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.BLIZZARD_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
				else
					sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
				end
				sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
			end,
		},
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.ECHO, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.ECHO, "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.ECHO_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 3,
			maxDifficulty = 100,

			cooldown = 0,
			cooldownMax = 3,
			pwrCost = 4,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_END_TURN then
					return false
				end

				if sim:getCurrentPlayer() ~= sim:getNPC() then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				if self.activePrograms > 1 and sim:nextRand(sim:getNPC():getCpus(),sim:getNPC():getMaxCpus()) < 15 then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				for i, unit in pairs(sim:getAllUnits()) do
					if unit:getTraits().mainframe_ice and unit:getTraits().mainframe_ice <= 0 then
						sim:triggerEvent(simdefs.TRG_RECAPTURE_DEVICES, { reboots = 1 } )
						sim:getNPC():addCPUs(-slot.pwrCost)
						slot.cooldown = slot.cooldownMax

						if slot.identified or sim:getNPC():getTraits().showAI then		
							sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.ECHO_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
						else
							sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
						end
						sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
						break
					end
				end
			end,
		},
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.REROUTE, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.REROUTE, "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.REROUTE_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 4,
			maxDifficulty = 100,

			cooldown = 0,
			cooldownMax = 7,
			pwrCost = 5,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_END_TURN then
					return false
				end

				if sim:getCurrentPlayer() ~= sim:getNPC() then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				if self.activePrograms > 1 and sim:nextRand(sim:getNPC():getCpus(),sim:getNPC():getMaxCpus()) < 15 then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
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
				sim:getNPC():addCPUs(-slot.pwrCost)
				slot.cooldown = slot.cooldownMax

				if slot.identified or sim:getNPC():getTraits().showAI then
					sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.REROUTE_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
				else
					sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
				end
				sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
			end,
		},
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.SAFE_MODE, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.SAFE_MODE, "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.SAFE_MODE_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 2,
			maxDifficulty = 100,

			cooldown = 0,
			cooldownMax = 5,
			pwrCost = 3,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_END_TURN then
					return false
				end

				if sim:getCurrentPlayer() ~= sim:getNPC() then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				if self.activePrograms > 1 and sim:nextRand(sim:getNPC():getCpus(),sim:getNPC():getMaxCpus()) < 15 then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				local raised = false
				for i, unit in pairs( sim:getAllUnits() ) do
					if unit:getTraits().storeType then
						raised = true
						unit:processEMP( 3, true )
					end
				end

				if raised then
					sim:getNPC():addCPUs(-slot.pwrCost)
					slot.cooldown = slot.cooldownMax

					if slot.identified or sim:getNPC():getTraits().showAI then
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.SAFE_MODE_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					else
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					end
					sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
				end
			end,
		},
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.OBFUSCATE, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.OBFUSCATE, "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.OBFUSCATE_TIP,
			identified = false,
			corp = "neptune",
			minDifficulty = 2,
			maxDifficulty = 100,

			cooldown = 0,
			cooldownMax = 2,
			pwrCost = 0,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_END_TURN then
					return false
				end

				if sim:getCurrentPlayer() ~= sim:getNPC() then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				if self.activePrograms > 1 and sim:nextRand(sim:getNPC():getCpus(),sim:getNPC():getMaxCpus()) < 15 then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				local guard = nil
				for i, unit in pairs( sim:getNPC():getUnits() ) do
					if unit:getTraits().tagged then
						unit:getTraits().tagged = nil

						sim:getNPC():addCPUs(-slot.pwrCost + 1)
						slot.cooldown = slot.cooldownMax

						if slot.identified or sim:getNPC():getTraits().showAI then
							sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.OBFUSCATE_DESC, unit:getName()), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
						else
							sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
						end
						sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
						break
					end
				end
			end,
		},
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.PHASE_SHIFT, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.PHASE_SHIFT, "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.PHASE_SHIFT_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 4,
			maxDifficulty = 100,

			cooldown = 0,
			cooldownMax = 4,
			pwrCost = 4,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_START_TURN then
					return false
				end

				if sim:getCurrentPlayer() ~= sim:getNPC() then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				if self.activePrograms > 1 and sim:nextRand(sim:getNPC():getCpus(),sim:getNPC():getMaxCpus()) < 15 then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				local guards = {}
				for i, unit in pairs( sim:getNPC():getUnits() ) do
					if unit:getBrain() and unit:getBrain():getInterest() then
						table.insert(guards, unit)
					end
				end

				if #guards > 0 then
					local targetUnit = guards[sim:nextRand(1,#guards)]
					local cells = {}

					local x0 = targetUnit:getBrain():getInterest().x
					local y0 = targetUnit:getBrain():getInterest().y
					local cell = sim:getCell( x0, y0 )

					if cell.impass <= 0 and not sim:getQuery().checkDynamicImpass(sim, cell) then
						table.insert(cells, cell)
					end

					for i = 1, #simdefs.OFFSET_NEIGHBOURS, 2 do
    						local dx, dy = simdefs.OFFSET_NEIGHBOURS[i], simdefs.OFFSET_NEIGHBOURS[i+1]
                				local targetCell = sim:getCell( cell.x + dx, cell.y + dy )
                				if simquery.isConnected( sim, cell, targetCell ) and targetCell.impass <= 0 and not sim:getQuery().checkDynamicImpass(sim, targetCell) then
							table.insert( cells, targetCell )
						end
					end

					for j, targetCell in pairs(cells) do
						sim:getNPC():addCPUs(-slot.pwrCost)
						slot.cooldown = slot.cooldownMax
						if slot.identified or sim:getNPC():getTraits().showAI then
							sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.PHASE_SHIFT_DESC, targetUnit:getName()), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
						else
							sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
						end
						sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)

						sim:dispatchEvent( simdefs.EV_UNIT_APPEARED, { unitID = targetUnit:getID(), noSightingFx=true } )
						sim:dispatchEvent( simdefs.EV_TELEPORT, { units={targetUnit}, warpOut = true } )
						sim:warpUnit( targetUnit, targetCell )
						sim:dispatchEvent( simdefs.EV_UNIT_APPEARED, { unitID = targetUnit:getID(), noSightingFx=true } )
						sim:dispatchEvent( simdefs.EV_TELEPORT, { units={targetUnit}, warpOut = false } )
						sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = targetUnit } )
						sim:processReactions( targetUnit )
						break
					end
				end
			end,
		},
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.PINPOINT, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.PINPOINT, "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.PINPOINT_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 3,
			maxDifficulty = 100,

			cooldown = 0,
			cooldownMax = 4,
			pwrCost = 4,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_START_TURN then
					return false
				end

				if sim:getCurrentPlayer() ~= sim:getPC() then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				if self.activePrograms > 1 and sim:nextRand(sim:getNPC():getCpus(),sim:getNPC():getMaxCpus()) < 15 then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				local agents = {}
				for i, unit in pairs( sim:getPC():getUnits() ) do
					if unit:getMP() then
						table.insert(agents, unit)
					end
				end

				if #agents > 0 then
					local targetUnit = agents[sim:nextRand(1,#agents)]
					local x0, y0 = targetUnit:getLocation()
					targetUnit:useMP( math.floor((targetUnit:getMP() or 0)/2), sim )
	            			sim:getNPC():spawnInterest(x0, y0, simdefs.SENSE_RADIO, simdefs.REASON_ALARMEDSAFE, targetUnit)

					sim:getNPC():addCPUs(-slot.pwrCost)
					slot.cooldown = slot.cooldownMax

					if slot.identified or sim:getNPC():getTraits().showAI then
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.PINPOINT_DESC, targetUnit:getName()), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					else
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					end
					sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
				end
			end,
		},
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.NULL_PULSE, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.NULL_PULSE, "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.NULL_PULSE_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 2,
			maxDifficulty = 100,

			cooldown = 0,
			cooldownMax = 5,
			pwrCost = 3,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_END_TURN then
					return false
				end

				if sim:getCurrentPlayer() ~= sim:getNPC() then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				if self.activePrograms > 1 and sim:nextRand(sim:getNPC():getCpus(),sim:getNPC():getMaxCpus()) < 15 then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				local devices = {}
				for i, unit in pairs( sim:getAllUnits() ) do
					if unit:getTraits().mainframe_ice and unit:getTraits().mainframe_ice > 0 and not unit:getTraits().mainframe_suppress_range then
						table.insert(devices, unit)
					end
				end

				if #devices > 0 then
					local targetUnit = devices[sim:nextRand(1,#devices)]
					targetUnit:getTraits().mainframe_suppress_rangeMax = 4
					targetUnit:getTraits().mainframe_suppress_range = 4

					sim:getNPC():addCPUs(-slot.pwrCost)
					slot.cooldown = slot.cooldownMax

					if slot.identified or sim:getNPC():getTraits().showAI then
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.NULL_PULSE_DESC, targetUnit:getName()), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					else
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					end
					sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
				end
			end,
		},
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.TREATY, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.TREATY, "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.TREATY_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 4,
			maxDifficulty = 100,

			cooldown = 0,
			cooldownMax = 4,
			pwrCost = 5,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_START_TURN then
					return false
				end

				if sim:getCurrentPlayer() ~= sim:getPC() then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				if self.activePrograms > 1 and sim:nextRand(sim:getNPC():getCpus(),sim:getNPC():getMaxCpus()) < 15 then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				self.lockdown = 3
				slot.cooldown = slot.cooldownMax
				sim:getNPC():addCPUs(-slot.pwrCost)
				sim:setMainframeLockout( true )

				if slot.identified or sim:getNPC():getTraits().showAI then
					sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.TREATY_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
				else
					sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
				end
				sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
			end,
		},
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.SUPERVISION, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.SUPERVISION, "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.SUPERVISION_TIP,
			identified = false,
			corp = "ftm",
			minDifficulty = 2,
			maxDifficulty = 100,

			cooldown = 0,
			cooldownMax = 3,
			pwrCost = 1,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_START_TURN then
					return false
				end

				if sim:getCurrentPlayer() ~= sim:getNPC() then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				if self.activePrograms > 1 and sim:nextRand(sim:getNPC():getCpus(),sim:getNPC():getMaxCpus()) < 15 then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				local camera = {}
				for i, unit in pairs(sim:getAllUnits()) do
					if unit:getTraits().mainframe_camera and not unit:getTraits().iceImmune then
						table.insert(camera, unit)
					end
				end
				if #camera > 0 then
					self.supervisionUnit = camera[sim:nextRand(1,#camera)]
					self.supervisionUnit:getTraits().iceImmune = true
					self.supervisionCooldown = slot.cooldownMax

					slot.cooldown = slot.cooldownMax
					sim:getNPC():addCPUs(-slot.pwrCost)

					if slot.identified or sim:getNPC():getTraits().showAI then
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.SUPERVISION_DESC, self.supervision:getName()), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					else
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					end
					sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
				end
			end,
		},
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.RECALIBRATE, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.RECALIBRATE, "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.RECALIBRATE_TIP,
			identified = false,
			corp = "sankaku",
			minDifficulty = 2,
			maxDifficulty = 100,

			cooldown = 0,
			cooldownMax = 3,
			pwrCost = 4,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_END_TURN then
					return false
				end

				if sim:getCurrentPlayer() ~= sim:getNPC() then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				if self.activePrograms > 1 and sim:nextRand(sim:getNPC():getCpus(),sim:getNPC():getMaxCpus()) < 15 then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				local captured = {}
				for i, unit in pairs( sim:getAllUnits() ) do
					if unit:getName() == STRINGS.PROPS.SOUND_BUG and unit:getPlayerOwner() == sim:getPC() then
						table.insert(captured, unit)
					end
				end

				if #captured > 0 then
					if slot.identified or sim:getNPC():getTraits().showAI then
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.RECALIBRATE_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					else
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					end
					sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)

					sim:getNPC():addCPUs(-slot.pwrCost)
					slot.cooldown = slot.cooldownMax

					for i, unit in pairs(captured) do
						mainframe.revertIce( sim, unit )
					end
				end
			end,
		},
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.FIEND, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.FIEND, "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.FIEND_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 3,
			maxDifficulty = 100,

			cooldown = 0,
			cooldownMax = 2,
			pwrCost = 2,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_END_TURN then
					return false
				end

				if not sim:getCurrentPlayer():isNPC() then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				if self.activePrograms > 1 and sim:nextRand(sim:getNPC():getCpus(),sim:getNPC():getMaxCpus()) < 15 then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				local disabled = 0
				local done = false

				for i, ability in pairs(sim:getPC():getAbilities()) do
					if not ability.passive and not array.find(sim:getPC():getLockedAbilities(),i) then
						sim:getPC():lockdownMainframeAbility( i )
						done = true
						disabled = i
						break
					end
				end

				if done == true then
					sim:getNPC():addCPUs(-slot.pwrCost)
					slot.cooldown = slot.cooldownMax

					if slot.identified or sim:getNPC():getTraits().showAI then
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.FIEND_DESC,disabled), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					else
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					end
					sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
				end
			end,
		},
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.BUNKER, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.BUNKER, "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.BUNKER_TIP,
			identified = false,
			corp = "omni",
			minDifficulty = 1,
			maxDifficulty = 100,

			cooldown = 0,
			cooldownMax = 4,
			pwrCost = 8,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_END_TURN then
					return false
				end

				if sim:getCurrentPlayer() ~= sim:getNPC() then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				if self.activePrograms > 1 and sim:nextRand(sim:getNPC():getCpus(),sim:getNPC():getMaxCpus()) < 15 then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				local raised = 0
				for i, unit in pairs( sim:getAllUnits() ) do
					unit:increaseIce(sim, 1)
					raised = raised + 1
				end

				if raised > 0 then
					sim:getNPC():addCPUs(-slot.pwrCost)
					slot.cooldown = slot.cooldownMax

					if slot.identified or sim:getNPC():getTraits().showAI then
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.BUNKER_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					else
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					end
					sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
				end
			end,
		},
	},

	REACTIVE =
	{	--[[
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.PAWN, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.PAWN, "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.PAWN_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 1,
			maxDifficulty = 3,

			cooldown = 0,
			cooldownMax = 1,
			pwrCost = 2,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_ICE_BROKEN then
					return false
				end

				if evData.delta and evData.delta >= 0 then
					return false
				end

				if sim:getCurrentPlayer() ~= sim:getPC() then
					return false
				end

				if evData.unit:getTraits().mainframe_ice <= 0 then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				sim:getNPC():addCPUs(-slot.pwrCost)
				slot.cooldown = slot.cooldownMax
				evData.unit:increaseIce(sim, 1)

				if slot.identified or sim:getNPC():getTraits().showAI then
					sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.PAWN_DESC,evData.unit:getName()), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
				else
					sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
				end
				sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
			end,
		},
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.ROOK, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.ROOK, "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.ROOK_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 2,
			maxDifficulty = 5,


			cooldown = 0,
			cooldownMax = 2,
			pwrCost = 3,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_ICE_BROKEN then
					return false
				end

				if evData.delta and evData.delta >= 0 then
					return false
				end

				if sim:getCurrentPlayer() ~= sim:getPC() then
					return false
				end

				if evData.unit:getTraits().mainframe_ice <= 0 then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				local device = nil
				for i, unit in pairs(sim:getAllUnits()) do
					if unit:getTraits().mainframe_ice and unit:getTraits().mainframe_ice > 0 and unit:getTraits().mainframe_ice > evData.unit:getTraits().mainframe_ice then
						if device == nil then
							device = unit
						elseif unit:getTraits().mainframe_ice > device:getTraits().mainframe_ice then
							device = unit
						end
					end
				end

				if device then
					local delta = device:getTraits().mainframe_ice - evData.unit:getTraits().mainframe_ice
					sim:getNPC():addCPUs(-slot.pwrCost)
					slot.cooldown = slot.cooldownMax
					device:increaseIce(sim, -delta)
					evData.unit:increaseIce(sim, delta)

					if slot.identified or sim:getNPC():getTraits().showAI then
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.ROOK_DESC,device:getName()), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					else
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					end
					sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
				end
			end,
		},
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.KNIGHT, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.KNIGHT, "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.KNIGHT_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 3,
			maxDifficulty = 6,


			cooldown = 0,
			cooldownMax = 2,
			pwrCost = 4,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_ICE_BROKEN then
					return false
				end

				if evData.delta and evData.delta >= 0 then
					return false
				end

				if sim:getCurrentPlayer() ~= sim:getPC() then
					return false
				end

				if evData.unit:getTraits().mainframe_ice <= 0 then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				local reinforced = 0
				local cellx, celly = evData.unit:getLocation()
            			local cells = simquery.rasterCircle( sim, cellx, celly, 2 )
            			for i, x, y in util.xypairs( cells ) do
                			local cell = sim:getCell( x, y )
                			if cell then
                    				for _, cellUnit in ipairs(cell.units) do
							cellUnit:increaseIce(sim, 2)
							reinforced = reinforced + 1
                            			end
                        		end
                    		end

				if reinforced > 0 then
					sim:getNPC():addCPUs(-slot.pwrCost)
					slot.cooldown = slot.cooldownMax

					if slot.identified or sim:getNPC():getTraits().showAI then
           					sim:dispatchEvent( simdefs.EV_OVERLOAD_VIZ, {x = cellx, y = celly, units = nil, range = 2 } )		
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.KNIGHT_DESC,evData.unit:getName()), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					else
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					end
					sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
				end
			end,
		},
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.BISHOP, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.BISHOP "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.BISHOP_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 3,
			maxDifficulty = 6,


			cooldown = 0,
			cooldownMax = 3,
			pwrCost = 4,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_ICE_BROKEN then
					return false
				end

				if evData.delta and evData.delta >= 0 then
					return false
				end

				if sim:getCurrentPlayer() ~= sim:getPC() then
					return false
				end

				if evData.unit:getTraits().mainframe_ice <= 0 then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				evData.unit:increaseIce(sim, math.ceil(sim:getNPC():getCpus()/5))

				sim:getNPC():addCPUs(-slot.pwrCost)
				slot.cooldown = slot.cooldownMax

				if slot.identified or sim:getNPC():getTraits().showAI then
					sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.BISHOP_DESC,evData.unit:getName()), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
				else
					sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
				end
				sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
			end,
		},
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.QUEEN, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.QUEEN, "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.QUEEN_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 5,
			maxDifficulty = 100,

			cooldown = 0,
			cooldownMax = 3,
			pwrCost = 5,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_ICE_BROKEN then
					return false
				end

				if evData.delta and evData.delta >= 0 then
					return false
				end

				if sim:getCurrentPlayer() ~= sim:getPC() then
					return false
				end

				if evData.unit:getTraits().mainframe_ice <= 0 then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				local reinforced = 0
				for i, unit in pairs(sim:getAllUnits()) do
					if unit:getName() == evData.unit:getName() and unit:getTraits().mainframe_ice and unit:getTraits().mainframe_ice > 0 then
						unit:increaseIce(sim, 1)
						reinforced = reinforced + 1
					end
				end

				if reinforced > 0 then
					sim:getNPC():addCPUs(-slot.pwrCost)
					slot.cooldown = slot.cooldownMax

					if slot.identified or sim:getNPC():getTraits().showAI then
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.QUEEN_DESC,evData.unit:getName()), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					else
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					end
					sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
				end
			end,
		},
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.KING, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.KING, "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.KING_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 5,
			maxDifficulty = 100,

			cooldown = 0,
			cooldownMax = 3,
			pwrCost = 4,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_ICE_BROKEN then
					return false
				end

				if evData.delta and evData.delta >= 0 then
					return false
				end

				if sim:getCurrentPlayer() ~= sim:getPC() then
					return false
				end

				if evData.unit:getTraits().mainframe_ice <= 0 then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				sim:getNPC():addCPUs(-slot.pwrCost)
				slot.cooldown = slot.cooldownMax
				evData.unit:increaseIce(sim, evData.unit:getTraits().mainframe_ice)

				if slot.identified or sim:getNPC():getTraits().showAI then
					sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.KING_DESC,evData.unit:getName()), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
				else
					sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
				end
				sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
			end,
		},
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.BACKUP_PROTOCOLS, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.BACKUP_PROTOCOLS, "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.BACKUP_PROTOCOLS_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 3,
			maxDifficulty = 100,

			cooldown = 0,
			cooldownMax = 3,
			pwrCost = 5,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if (evType ~= simdefs.TRG_UNIT_ALERTED and evType ~= simdefs.TRG_UNIT_KILLED) then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				sim:getNPC():addCPUs(-slot.pwrCost)
				slot.cooldown = slot.cooldownMax

				local wt = util.weighted_list( sim._patrolGuard )
				local templateName = wt:getChoice( sim:nextRand( 1, wt:getTotalWeight() ))
				sim:getNPC():doTrackerSpawn( sim, 1, templateName, false )

				if slot.identified or sim:getNPC():getTraits().showAI then
					sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.BACKUP_PROTOCOLS_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
				else
					sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
				end
				sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
			end,
		},
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.ELECTROSHOCK, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.ELECTROSHOCK, "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.ELECTROSHOCK_TIP,
			identified = false,
			corp = "neptune",
			minDifficulty = 2,
			maxDifficulty = 100,

			cooldown = 0,
			cooldownMax = 4,
			pwrCost = 6,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_SAFE_LOOTED then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				if evData.unit and evData.unit:getTraits().isAgent then

					local x0,y0 = evData.unit:getLocation()
					sim:dispatchEvent( simdefs.EV_FLASH_VIZ, {x = x0, y = y0, units = nil, range = 2 } )
					if evData.unit:getTraits().canKO then
						evData.unit:setKO(sim,3)
					end

					sim:getNPC():addCPUs(-slot.pwrCost)
					slot.cooldown = slot.cooldownMax

					if slot.identified or sim:getNPC():getTraits().showAI then
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.ELECTROSHOCK_DESC,evData.unit:getName()), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					else
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					end
					sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
				end
			end,
		},
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.HASHED_CRYPTO, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.HASHED_CRYPTO, "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.HASHED_CRYPTO_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 3,
			maxDifficulty = 100,

			cooldown = 0,
			cooldownMax = 0,
			pwrCost = 4,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_SAFE_LOOTED then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType == simdefs.TRG_SAFE_LOOTED then
					local robbed = 0
					for i, unit in pairs(sim:getAllUnits()) do
						if unit:getTraits().safeUnit and unit:getTraits().mainframe_ice and not unit:getTraits().open and unit:getTraits().credits then
							unit:getTraits().credits = math.floor(unit:getTraits().credits / 2)
							robbed = robbed + 1
						end
					end

					if robbed > 0 then
						sim:getNPC():addCPUs(-slot.pwrCost)
						slot.cooldown = slot.cooldownMax

						if slot.identified or sim:getNPC():getTraits().showAI then
							sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.HASHED_CRYPTO_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
						else
							sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
						end
						sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
					end
				end
			end,
		},
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.PAYWALL, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.PAYWALL, "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.PAYWALL_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 2,
			maxDifficulty = 100,

			cooldown = 0,
			cooldownMax = 0,
			pwrCost = 2,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_BUY_ITEM then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType == simdefs.TRG_BUY_ITEM then
					if not sim:getPC():getTraits().shopPenalty then
						sim:getPC():getTraits().shopPenalty = 0.25
					else
						sim:getPC():getTraits().shopPenalty = sim:getPC():getTraits().shopPenalty + 0.25
					end
					sim:getNPC():addCPUs(-slot.pwrCost)
					slot.cooldown = slot.cooldownMax

					if slot.identified or sim:getNPC():getTraits().showAI then
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.PAYWALL_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					else
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					end
				end
			end,
		},
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.CIRCUIT_BREAKER, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.CIRCUIT_BREAKER, "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.CIRCUIT_BREAKER_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 3,
			maxDifficulty = 100,

			cooldown = 0,
			cooldownMax = 1,
			pwrCost = 2,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_UNIT_HIJACKED then
					return false
				end

				if not evData.unit:getTraits().mainframe_console then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType == simdefs.TRG_UNIT_HIJACKED then
    	        			local x0, y0 = evData.unit:getLocation()
	            			sim:getNPC():spawnInterest(x0, y0, simdefs.SENSE_RADIO, simdefs.REASON_ALARMEDSAFE, evData.unit)

					sim:getNPC():addCPUs(-slot.pwrCost)
					slot.cooldown = slot.cooldownMax

					if slot.identified or sim:getNPC():getTraits().showAI then
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.CIRCUIT_BREAKER_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					else
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					end
					sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
				end
			end,
		},
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.SAFEGUARD, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.SAFEGUARD, "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.SAFEGUARD_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 2,
			maxDifficulty = 100,

			cooldown = 0,
			cooldownMax = 1,
			pwrCost = 3,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_UNIT_HIJACKED then
					return false
				end

				if not evData.unit:getTraits().mainframe_console then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				local consoles = {}
				for i, unit in pairs(sim:getAllUnits()) do
					if unit:getTraits().mainframe_console and unit ~= evData.unit and unit:getTraits().mainframe_status == "active" then
						table.insert(consoles, unit)
					end
				end

				if #consoles > 0 then
					local targetUnit = consoles[sim:nextRand(1, #consoles)]

					targetUnit:processEMP( 4, true )

					sim:getNPC():addCPUs(-slot.pwrCost)
					slot.cooldown = slot.cooldownMax

					if slot.identified or sim:getNPC():getTraits().showAI then
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.SAFEGUARD_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					else
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					end
					sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
				end
			end,
		},
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.SUBTERFUGE, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.SUBTERFUGE, "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.SUBTERFUGE_TIP,
			identified = false,
			corp = "ftm",
			minDifficulty = 2,
			maxDifficulty = 100,

			cooldown = 0,
			cooldownMax = 0,
			pwrCost = 4,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_CAUGHT_BY_CAMERA then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				for i, unit in pairs(sim:getAllUnits()) do
					if unit:getTraits().mainframe_camera and unit:getTraits().mainframe_status == "active" and unit:getTraits().mainframe_ice and unit:getTraits().mainframe_ice > 0 then
						for j, agentUnit in pairs(sim:getPC():getUnits()) do
							if sim:canUnitSeeUnit(unit, agentUnit) and agentUnit:getTraits().mp then
								agentUnit:useMP( agentUnit:getMP(), sim )
								sim:getNPC():addCPUs(-slot.pwrCost)
								slot.cooldown = slot.cooldownMax

								if slot.identified or sim:getNPC():getTraits().showAI then
									sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.SUBTERFUGE_DESC, agentUnit:getName()), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
								else
									sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
								end
								sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
							end
						end
					end
				end
			end,
		},
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.VERIFY, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.VERIFY, "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.VERIFY_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 4,
			maxDifficulty = 100,

			cooldown = 0,
			cooldownMax = 3,
			pwrCost = 3,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_UNIT_NEWINTEREST then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				if evData.unit:getMPMax() then
					evData.unit:addMPMax( 1 )
					sim:getNPC():addCPUs(-slot.pwrCost)
					slot.cooldown = slot.cooldownMax

					if slot.identified or sim:getNPC():getTraits().showAI then
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.VERIFY_DESC, evData.unit:getName()), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					else
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					end
					sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
				end
			end,
		},
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.SCANNER_SWEEP, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.SCANNER_SWEEP, "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.SCANNER_SWEEP_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 3,
			maxDifficulty = 100,

			cooldown = 0,
			cooldownMax = 1,
			pwrCost = 2,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_UNIT_NEWINTEREST and evType ~= simdefs.TRG_END_TURN then
					return false
				end

				if slot.cooldown > 0 and evType == simdefs.TRG_UNIT_NEWINTEREST then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost and evType == simdefs.TRG_UNIT_NEWINTEREST then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType == simdefs.TRG_UNIT_NEWINTEREST and not evData.unit:getTraits().refreshingLOS then
					if not evData.unit:getModifiers():has( "LOSperipheralArc", "W93_AI_SCANNER_SWEEP" ) then
						evData.unit:getModifiers():add( "LOSperipheralArc", "W93_AI_SCANNER_SWEEP", modifiers.SET, math.pi )
                    				sim:refreshUnitLOS( evData.unit )
						sim:getNPC():addCPUs(-slot.pwrCost)
						slot.cooldown = slot.cooldownMax

						if slot.identified or sim:getNPC():getTraits().showAI then
							sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.SCANNER_SWEEP_DESC, evData.unit:getName()), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
						else
							sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
						end
						sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
					end
				elseif evType == simdefs.TRG_END_TURN and evData:isNPC() then
					for i, guardUnit in pairs(sim:getNPC():getUnits()) do
                    				if guardUnit:getModifiers():has( "LOSperipheralArc", "W93_AI_SCANNER_SWEEP" ) and not guardUnit:getTraits().refreshingLOS then
							guardUnit:getModifiers():remove( "W93_AI_SCANNER_SWEEP" )
							sim:refreshUnitLOS( guardUnit )
						end
					end
				end
			end,
		},
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.SPEED_BUMP, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.SPEED_BUMP, "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.SPEED_BUMP_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 3,
			maxDifficulty = 100,

			cooldown = 0,
			cooldownMax = 2,
			pwrCost = 3,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_OPEN_DOOR then
					return false
				end

				if not sim:getCurrentPlayer():isPC() then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				if evData.unit then
					evData.unit:useMP( 2, sim )
					sim:getNPC():addCPUs(-slot.pwrCost)
					slot.cooldown = slot.cooldownMax

					if slot.identified or sim:getNPC():getTraits().showAI then
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.SPEED_BUMP_DESC, evData.unit:getName()), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					else
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					end
					sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
				end
			end,
		},
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.BLOCKADE, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.BLOCKADE, "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.BLOCKADE_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 3,
			maxDifficulty = 100,

			cooldown = 0,
			cooldownMax = 4,
			pwrCost = 2,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_OPEN_DOOR then
					return false
				end

				if not sim:getCurrentPlayer():isPC() then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				local guards = {}
				for i, unit in pairs(sim:getNPC():getUnits()) do
					if unit:getBrain() and unit:getBrain():getSituation().ClassType == simdefs.SITUATION_IDLE then
						table.insert(guards, unit)
					end
				end

				if #guards > 0 and evData.unit then
					local x0, y0 = evData.unit:getLocation()
					local guard = guards[sim:nextRand(1,#guards)]
					local idle = sim:getNPC():getIdleSituation()
					idle:generateStationaryPath( guard, x0, y0 )
					guard:getBrain():getSenses():addInterest(x0, y0, simdefs.SENSE_RADIO, simdefs.REASON_PATROLCHANGED, guard)
					sim:processReactions(guard)

					sim:getNPC():addCPUs(-slot.pwrCost)
					slot.cooldown = slot.cooldownMax

					if slot.identified or sim:getNPC():getTraits().showAI then
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.BLOCKADE_DESC, guard:getName()), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					else
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					end
					sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
				end
			end,
		},
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.SENTINEL, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.SENTINEL, "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.SENTINEL_TIP,
			identified = false,
			corp = "ko",
			minDifficulty = 2,
			maxDifficulty = 100,

			cooldown = 0,
			cooldownMax = 2,
			pwrCost = 3,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_UNIT_WARP then
					return false
				end

				if not sim:getCurrentPlayer():isPC() then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				for i, unit in pairs(sim:getAllUnits()) do
					if unit:getTraits().mainframe_turret and evData.unit and evData.to_cell then
						local x1,y1 = evData.unit:getLocation()
						local x2,y2 = unit:getLocation()

						if unit:getPlayerOwner() == nil then
							unit:setPlayerOwner(sim:getNPC())
						end

						if simquery.couldUnitSeeCell(sim, unit, evData.to_cell) and mathutil.dist2d(x1, y1, x2, y2) <= 3 and unit:getPlayerOwner() == sim:getNPC() and unit:getTraits().mainframe_status == "active" then
							sim:getNPC():addCPUs(-slot.pwrCost)
							slot.cooldown = slot.cooldownMax

							if slot.identified or sim:getNPC():getTraits().showAI then
								sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.SENTINEL_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
							else
								sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
							end
							sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)

							unit:turnToFace(x1, y1)
							sim:refreshUnitLOS( unit )
							sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = unit })
						end
					end
				end
			end,
		},	]]
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.FAKEOUT, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.FAKEOUT, "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.FAKEOUT_TIP,
			identified = false,
			corp = "plastech",
			minDifficulty = 2,
			maxDifficulty = 100,

			cooldown = 0,
			cooldownMax = 3,
			pwrCost = 2,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_ICE_BROKEN then
					return false
				end

				if not sim:getCurrentPlayer():isPC() then
					return false
				end

				if evData.unit:getTraits().mainframe_ice > 0 then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				if evData.unit:getTraits().mainframe_program and evData.unit:getTraits().daemon_sniffed and evData.unit:getTraits().daemon_sniffed == true then
					if sim:isVersion("0.17.5") then
						local programList = sim:getIcePrograms()
						evData.unit:getTraits().mainframe_program = programList:getChoice( sim:nextRand( 1, programList:getTotalWeight() ))
					else
						evData.unit:getTraits().mainframe_program = PROGRAM_LIST[ sim:nextRand(1, #PROGRAM_LIST) ]
					end	

					sim:dispatchEvent( simdefs.EV_UNIT_UPDATE_ICE, { unit = evData.unit, ice = evData.unit:getTraits().mainframe_ice, delta = 0} )
					sim:getNPC():addCPUs(-slot.pwrCost)
					slot.cooldown = slot.cooldownMax

					if slot.identified or sim:getNPC():getTraits().showAI then
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.FAKEOUT_DESC,evData.unit:getName()), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					else
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					end
					sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
				end
			end,
		},
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.FAILSAFE, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.FAILSAFE, "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.FAILSAFE_TIP,
			identified = false,
			corp = "sankaku",
			minDifficulty = 2,
			maxDifficulty = 100,

			cooldown = 0,
			cooldownMax = 2,
			pwrCost = 3,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_ICE_BROKEN then
					return false
				end

				if not sim:getCurrentPlayer():isPC() then
					return false
				end

				if not evData.unit:getTraits().isDrone then
					return false
				end

				if evData.unit:getTraits().mainframe_ice > 0 then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
    	        		local x0, y0 = evData.unit:getLocation()
				sim:getNPC():spawnInterestWithReturn(x0, y0, simdefs.SENSE_RADIO, simdefs.REASON_ALARMEDSAFE, evData.unit, { evData.unit:getID() } )
				sim:getNPC():addCPUs(-slot.pwrCost)
				slot.cooldown = slot.cooldownMax

				if slot.identified or sim:getNPC():getTraits().showAI then
					sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.FAILSAFE_DESC,evData.unit:getName()), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
				else
					sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
				end
				sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
			end,
		},
		{
			name = function( self, sim, slot )
				if sim:getNPC():getTraits().showAITemp then
					return string.format(STRINGS.PROGEXTEND.AI.TERMINATE, slot.cooldown, slot.cooldownMax)
				else
					return string.format(STRINGS.PROGEXTEND.AI.TERMINATE, "?", slot.cooldownMax)
				end
			end,
			desc = STRINGS.PROGEXTEND.AI.TERMINATE_TIP,
			identified = false,
			corp = "omni",
			minDifficulty = 1,
			maxDifficulty = 100,

			cooldown = 0,
			cooldownMax = 4,
			pwrCost = 6,

			canUseAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType ~= simdefs.TRG_SET_OVERWATCH then
					return false
				end

				if not evData.unit then
					return false
				end

				if evData.unit:getPlayerOwner() ~= sim:getNPC() then
					return false
				end

				if not evData.unit:getTraits().isAiming then
					return false
				end

				if slot.cooldown > 0 then
					return false
				end

				if sim:getNPC():getCpus() < slot.pwrCost then
					return false
				end

				return true
			end,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				if evData.unit then
					if slot.identified or sim:getNPC():getTraits().showAI then
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.TERMINATE_DESC, evData.unit:getName()), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					else
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					end
					sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)

					sim:getNPC():addCPUs(-slot.pwrCost)
					slot.cooldown = slot.cooldownMax

					evData.unit:getBrain():reset()
					sim:processReactions(evData.unit)
				end
			end,
		},
	},

	UTILITY =
	{
		{
			name = STRINGS.PROGEXTEND.AI.PADLOCK,
			desc = STRINGS.PROGEXTEND.AI.PADLOCK_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 1,
			maxDifficulty = 3,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType == simdefs.TRG_END_TURN and evData:isNPC() then
					local locked = 0
					sim:forEachCell(function( c )
						for i,exit in pairs(c.exits) do
							if not exit.locked and exit.keybits == simdefs.DOOR_KEYS.SECURITY then
								if not exit.closed then
									sim:modifyExit( c, i, simdefs.EXITOP_CLOSE)
								end
								sim:modifyExit( c, i, simdefs.EXITOP_LOCK)
                    						sim:getPC():glimpseExit( c.x, c.y, i )
								locked = locked + 1
							end
						end
					end )
					if locked > 0 then
						if slot.identified or sim:getNPC():getTraits().showAI then
							sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.PADLOCK_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
						else
							sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
						end
						sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
					end
				end
			end,

			removeAbility = function( self, sim )

			end,
		},
		{
			name = STRINGS.PROGEXTEND.AI.JAMMER,
			desc = STRINGS.PROGEXTEND.AI.JAMMER_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 2,
			maxDifficulty = 100,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType == simdefs.TRG_ICE_BROKEN and evData.unit:getTraits().mainframe_ice > 0 then
					for i, unit in pairs(sim:getAllUnits()) do
						if unit:getTraits().iceImmune then
							unit:getTraits().iceImmune = nil
						end
					end

					evData.unit:getTraits().iceImmune = true
					if slot.identified or sim:getNPC():getTraits().showAI then
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.JAMMER_DESC,evData.unit:getName()), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					else
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					end
					sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
				end
			end,

			removeAbility = function( self, sim )
				for i, unit in pairs(sim:getAllUnits()) do
					if unit:getTraits().iceImmune then
						unit:getTraits().iceImmune = nil
					end
				end
			end,
		},
		{
			name = STRINGS.PROGEXTEND.AI.TAG_DOWNLINK,
			desc = STRINGS.PROGEXTEND.AI.TAG_DOWNLINK_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 2,
			maxDifficulty = 100,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType == simdefs.TRG_START_TURN and evData:isPC() then
					local pwr = 0
					for i, unit in pairs(sim:getNPC():getUnits()) do
						if unit:getTraits().tagged then
							pwr = pwr + 1
						end
					end
					if pwr > 0 then
						sim:getPC():addCPUs(-pwr)
						if slot.identified or sim:getNPC():getTraits().showAI then
							sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.TAG_DOWNLINK_DESC,pwr), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
						else
							sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
						end
						sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
					end
				end
			end,

			removeAbility = function( self, sim )

			end,
		},
		{
			name = STRINGS.PROGEXTEND.AI.DEFECTIVE_TAG,
			desc = STRINGS.PROGEXTEND.AI.DEFECTIVE_TAG_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 2,
			maxDifficulty = 100,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType == simdefs.TRG_START_TURN and evData:isPC() then
					for i, unit in pairs(sim:getNPC():getUnits()) do
						if unit:getTraits().mp and unit:getTraits().tagged and not unit:getTraits().defectiveTag then
							unit:addMPMax( 4 )
							unit:getTraits().mp = unit:getTraits().mpMax
							unit:getTraits().defectiveTag = 4
							if slot.identified or sim:getNPC():getTraits().showAI then
								sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.DEFECTIVE_TAG_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
							else
								sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
							end
							sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
						end
						if not unit:getTraits().tagged and unit:getTraits().defectiveTag then
							unit:addMPMax( -unit:getTraits().defectiveTag )
							unit:getTraits().defectiveTag = nil
						end
					end
				end
			end,

			removeAbility = function( self, sim )
				for i, unit in pairs(sim:getNPC():getUnits()) do
					if unit:getTraits().defectiveTag then
						unit:addMPMax( -unit:getTraits().defectiveTag )
						if unit:getTraits().mp > unit:getTraits().mpMax then
							unit:getTraits().mp = unit:getTraits().mpMax
						end
						unit:getTraits().defectiveTag = nil
					end
				end
			end,
		},
		{
			name = STRINGS.PROGEXTEND.AI.TRANSLOCATOR_EQUIPMENT,
			desc = STRINGS.PROGEXTEND.AI.TRANSLOCATOR_EQUIPMENT_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 2,
			maxDifficulty = 100,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType == simdefs.TRG_START_TURN and evData:isPC() then
					local itemdefs = include( "sim/unitdefs/itemdefs" )
					for i, unit in pairs(sim:getNPC():getUnits()) do
						if unit:getTraits().isGuard and not unit:getTraits().isDrone and #unit:getChildren() <= 1 and not unit:hasChild( "W93_item_teleportGrenade" ) then
							local item = simfactory.createUnit( itemdefs.W93_item_teleportGrenade , sim )
							sim:spawnUnit( item )
							unit:addChild( item )
							unit:getTraits().teleportGrenade = true
						end
					end
				end
			end,

			removeAbility = function( self, sim )
				for i, unit in pairs(sim:getAllUnits()) do
					if unit:getTraits().teleportGrenade then
						unit:getTraits().teleportGrenade = nil
						for j, childUnit in pairs(unit:getChildren()) do
							if childUnit:getName() == "WARP GRENADE" then
								unit:removeChild( childUnit )
							end
						end
					end
				end
			end,
		},
		{
			name = STRINGS.PROGEXTEND.AI.PROXIMAL,
			desc = STRINGS.PROGEXTEND.AI.PROXIMAL_TIP,
			identified = false,
			corp = "general",
			minDifficulty = 4,
			maxDifficulty = 100,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType == simdefs.TRG_END_TURN and evData:isNPC() and sim:getTurnCount() <= 1 then
					sim:getLevelScript():addHook( "GUARD LOOTED", guardLooted, true )
				end
				if ( evType == simdefs.TRG_UI_ACTION and evData and evData == level.EV_CLOSE_LOOT_UI ) then
					for i, agent in pairs(sim:getPC():getUnits()) do
						for j, guard in pairs(sim:getNPC():getUnits()) do
							if guard:getTraits().isGuard and agent:getTraits().isAgent and not guard:isDown() then
								local x0,y0 = agent:getLocation()
								local x1,y1 = guard:getLocation()
								local dist = mathutil.dist2d( x0, y0, x1, y1 )
								if dist <= 1 then
									if slot.identified or sim:getNPC():getTraits().showAI then
										sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.AI.PROXIMAL_DESC, guard:getName()), color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
									else
										sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
									end
									sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
									guard:turnToFace(x0, y0)
									break
								end
							end
						end
					end
				end
			end,

			removeAbility = function( self, sim )

			end,
		},
		{
			name = STRINGS.PROGEXTEND.AI.NETWORKED_CONSCIOUSNESS,
			desc = STRINGS.PROGEXTEND.AI.NETWORKED_CONSCIOUSNESS_TIP,
			identified = false,
			corp = "plastech",
			minDifficulty = 3,
			maxDifficulty = 100,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType == simdefs.TRG_START_TURN and evData:isPC() then
					for i, unit in pairs(sim:getNPC():getUnits()) do
						if unit:getTraits().isGuard and not unit:getTraits().isDrone and not unit:getTraits().consciousness_monitor then
							unit:getTraits().consciousness_monitor = true
						end
					end
				end
			end,

			removeAbility = function( self, sim )
				for i, unit in pairs(sim:getAllUnits()) do
					if unit:getTraits().consciousness_monitor then
						unit:getTraits().consciousness_monitor = nil
					end
				end
			end,
		},
		{
			name = STRINGS.PROGEXTEND.AI.EM_SHIELDING,
			desc = STRINGS.PROGEXTEND.AI.EM_SHIELDING_TIP,
			identified = false,
			corp = "sankaku",
			minDifficulty = 3,
			maxDifficulty = 100,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType == simdefs.TRG_START_TURN and evData:isPC() then
					for i, unit in pairs(sim:getAllUnits()) do
						if unit:getTraits().mainframe_ice and not unit:getTraits().magnetic_reinforcement then
							unit:getTraits().magnetic_reinforcement = true
						end
					end
				end
			end,

			removeAbility = function( self, sim )
				for i, unit in pairs(sim:getAllUnits()) do
					if unit:getTraits().mainframe_ice and unit:getTraits().magnetic_reinforcement then
						unit:getTraits().magnetic_reinforcement = nil
					end
				end
			end,
		},
		{
			name = STRINGS.PROGEXTEND.AI.SHOCK_GROUNDING,
			desc = STRINGS.PROGEXTEND.AI.SHOCK_GROUNDING_TIP,
			identified = false,
			corp = "ko",
			minDifficulty = 3,
			maxDifficulty = 100,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType == simdefs.TRG_START_TURN and evData:isPC() then
					for i, unit in pairs(sim:getNPC():getUnits()) do
						if not unit:getTraits().pacifist and unit:getTraits().isGuard and not unit:getTraits().isDrone and unit:getTraits().canKO then
							unit:getTraits().canKO = false
						end
					end
				end
			end,

			removeAbility = function( self, sim )
				for i, unit in pairs(sim:getAllUnits()) do
					if not unit:getTraits().pacifist and unit:getTraits().isGuard and not unit:getTraits().isDrone and not unit:getTraits().canKO then
						unit:getTraits().canKO = true
					end
				end
			end,
		},
		{
			name = STRINGS.PROGEXTEND.AI.VIDEO_COPROCESSORS,
			desc = STRINGS.PROGEXTEND.AI.VIDEO_COPROCESSORS_TIP,
			identified = false,
			corp = "ftm",
			minDifficulty = 3,
			maxDifficulty = 100,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType == simdefs.TRG_START_TURN and evData:isPC() then
					for i, unit in pairs(sim:getNPC():getUnits()) do
						if unit:getTraits().isGuard and not unit:getTraits().isDrone and not unit:getTraits().detect_cloak then
							unit:getTraits().detect_cloak = true
						end
					end
				end
			end,

			removeAbility = function( self, sim )
				for i, unit in pairs(sim:getAllUnits()) do
					if unit:getTraits().detect_cloak then
						unit:getTraits().detect_cloak = nil
					end
				end
			end,
		},
		{
			name = STRINGS.PROGEXTEND.AI.EMERGENCY_SHUTDOWN,
			desc = STRINGS.PROGEXTEND.AI.EMERGENCY_SHUTDOWN_TIP,
			identified = false,
			corp = "neptune",
			minDifficulty = 3,
			maxDifficulty = 100,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType == simdefs.TRG_UNIT_HIJACKED and evData.unit:getTraits().mainframe_console and evData.action then
					evData.unit:getTraits().mainframe_status = "off"
					if slot.identified or sim:getNPC():getTraits().showAI then
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.EMERGENCY_SHUTDOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					else
						sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.AI.UNKNOWN_DESC, color=cdefs.COLOR_AI_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off", icon=self.icon } )
					end
					sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
				end
			end,

			removeAbility = function( self, sim )
				for i, unit in pairs(sim:getAllUnits()) do
					if unit:getTraits().mainframe_console and unit:getTraits().mainframe_status == "off" then
						unit:getTraits().mainframe_status = "active"
					end
				end
			end,
		},
		{
			name = STRINGS.PROGEXTEND.AI.SNARE_EQUIPMENT,
			desc = STRINGS.PROGEXTEND.AI.SNARE_EQUIPMENT_TIP,
			identified = false,
			corp = "omni",
			minDifficulty = 1,
			maxDifficulty = 100,

			executeAbility = function( self, sim, evType, evData, userUnit, slot )
				if evType == simdefs.TRG_START_TURN and evData:isPC() then
					local itemdefs = include( "sim/unitdefs/itemdefs" )
					for i, unit in pairs(sim:getNPC():getUnits()) do
						if unit:getTraits().isGuard and not unit:getTraits().isDrone and #unit:getChildren() <= 1 and not unit:hasChild( "W93_item_snareGrenade" ) then
							local item = simfactory.createUnit( itemdefs.W93_item_snareGrenade , sim )
							sim:spawnUnit( item )
							unit:addChild( item )
							unit:getTraits().snareGrenade = true
						end
					end
				end
			end,

			removeAbility = function( self, sim )
				for i, unit in pairs(sim:getAllUnits()) do
					if unit:getTraits().snareGrenade then
						unit:getTraits().snareGrenade = nil
						for j, childUnit in pairs(unit:getChildren()) do
							if childUnit:getName() == "SNARE GRENADE" then
								unit:removeChild( childUnit )
							end
						end
					end
				end
			end,
		},
	},
}

local npc_abilities2 =
{
	W93_AI_assembly = util.extend( createDaemon( STRINGS.PROGEXTEND.DAEMONS.ASSEMBLY ) )
	{
		icon = "gui/icons/daemon_icons/icon-daemon_AI.png",
		standardDaemon = false,
		reverseDaemon = false,
		premanent = true,

		slotsPWR = {},
		slotsPro = {},
		slotsRea = {},
		slotsUti = {},
		activePrograms = 0,

	     	ENDLESS_DAEMONS = false,
	     	PROGRAM_LIST = false,
	     	OMNI_PROGRAM_LIST_EASY = false,
	     	OMNI_PROGRAM_LIST = false,
	     	REVERSE_DAEMONS = false,

		onSpawnAbility = function( self, sim, player )
			sim:addTrigger( simdefs.TRG_START_TURN, self )
			sim:addTrigger( simdefs.TRG_END_TURN, self )
			sim:addTrigger( simdefs.TRG_UNIT_HIJACKED, self )
			sim:addTrigger( simdefs.TRG_ICE_BROKEN, self )
			sim:addTrigger( simdefs.TRG_UNIT_KILLED, self )
			sim:addTrigger( simdefs.TRG_UNIT_ALERTED, self )
			sim:addTrigger( simdefs.TRG_SAFE_LOOTED, self )
			sim:addTrigger( simdefs.TRG_BUY_ITEM, self )
			sim:addTrigger( simdefs.TRG_UI_ACTION , self )
			sim:addTrigger( simdefs.TRG_UNIT_WARP , self )
			sim:addTrigger( simdefs.TRG_CAUGHT_BY_CAMERA, self )
			sim:addTrigger( simdefs.TRG_UNIT_NEWINTEREST, self )
			sim:addTrigger( simdefs.TRG_OPEN_DOOR, self )
			sim:addTrigger( simdefs.TRG_SET_OVERWATCH, self )

			local choice = {}
			local priority = {}
			self.activePrograms = 0
			sim:getNPC():getTraits().suppressedPWR = 0
			sim:getNPC():getTraits().suppressedPro = 0
			sim:getNPC():getTraits().suppressedRea = 0


			if sim:getParams().world == "sankaku" then	---Format: (Offset, divider, max) x4
				priority = { 0,2,1, 5,5,2, 0,3,2, 0,4,1 }
			elseif sim:getParams().world == "plastech" then
				priority = { 3,5,2, 6,6,2, 0,4,1, 0,3,1 }
			elseif sim:getParams().world == "ftm" then
				priority = { 0,2,1, 1,2,3, 0,6,1, 0,4,1 }
			elseif sim:getParams().world == "ko" then
				priority = { 0,3,1, 0,5,1, 4,6,2, 4,4,2 }
			elseif sim:getParams().world == "neptune" then
				priority = { 0,2,1, 0,6,1, 1,2,3, 0,4,1 }
			else
				priority = { 8,8,2, 8,8,2, 8,8,1, 8,8,2 }
			end

			for i, routine in pairs(subroutines.PWR) do
				if ( routine.corp == sim:getParams().world or ( sim:getParams().world == "omni2" and routine.corp == "omni") or (routine.corp == "general" and not ( sim:getParams().world == "omni" or sim:getParams().world == "omni2" )) ) and sim:getParams().difficulty >= routine.minDifficulty and sim:getParams().difficulty <= routine.maxDifficulty then
					table.insert(choice, routine)
				end
			end
			for i=1, math.min(math.floor((sim:getParams().difficulty + priority[1])/priority[2]),priority[3]) do
				if #choice > 0 then
					local selected = sim:nextRand(1,#choice)
					choice[selected].identified = false
					table.insert(self.slotsPWR,choice[selected])
					table.remove(choice,selected)
				end
			end

			util.tclear(choice)
			for i, routine in pairs(subroutines.PROACTIVE) do
				if ( routine.corp == sim:getParams().world or ( sim:getParams().world == "omni2" and routine.corp == "omni") or (routine.corp == "general" and not ( sim:getParams().world == "omni" or sim:getParams().world == "omni2" )) ) and sim:getParams().difficulty >= routine.minDifficulty and sim:getParams().difficulty <= routine.maxDifficulty then
					table.insert(choice, routine)
				end
			end
			for i=1, math.min(math.floor((sim:getParams().difficulty + priority[4])/priority[5]),priority[6]) do
				if #choice > 0 then
					local selected = sim:nextRand(1,#choice)
					choice[selected].identified = false
					choice[selected].cooldown = 2
					table.insert(self.slotsPro,choice[selected])
					table.remove(choice,selected)
					self.activePrograms = self.activePrograms + 1
				end
			end

			util.tclear(choice)
			for i, routine in pairs(subroutines.REACTIVE) do
				if ( routine.corp == sim:getParams().world or ( sim:getParams().world == "omni2" and routine.corp == "omni") or (routine.corp == "general" and not ( sim:getParams().world == "omni" or sim:getParams().world == "omni2" )) ) and sim:getParams().difficulty >= routine.minDifficulty and sim:getParams().difficulty <= routine.maxDifficulty then
					table.insert(choice, routine)
				end
			end
			for i=1, math.min(math.floor((sim:getParams().difficulty + priority[7])/priority[8]),priority[9]) do
				if #choice > 0 then
					local selected = sim:nextRand(1,#choice)
					choice[selected].identified = false
					choice[selected].cooldown = 0
					table.insert(self.slotsRea,choice[selected])
					table.remove(choice,selected)
					self.activePrograms = self.activePrograms + 1
				end
			end

			util.tclear(choice)
			for i, routine in pairs(subroutines.UTILITY) do
				if ( routine.corp == sim:getParams().world or ( sim:getParams().world == "omni2" and routine.corp == "omni") or (routine.corp == "general" and not ( sim:getParams().world == "omni" or sim:getParams().world == "omni2" )) ) and sim:getParams().difficulty >= routine.minDifficulty and sim:getParams().difficulty <= routine.maxDifficulty then
					table.insert(choice, routine)
				end
			end
			for i=1, math.min(math.floor((sim:getParams().difficulty + priority[10])/priority[11]),priority[12]) do
				if #choice > 0 then
					local selected = sim:nextRand(1,#choice)
					choice[selected].identified = false
					table.insert(self.slotsUti,choice[selected])
					table.remove(choice,selected)
					sim:getNPC():getTraits().hasAIroutine = true
				end
			end

			sim:getNPC():addCPUs( 20 - sim:getParams().difficultyOptions.startingPower )
        	end,

		onDespawnAbility = function( self, sim )
			sim:removeTrigger( simdefs.TRG_START_TURN, self )
			sim:removeTrigger( simdefs.TRG_END_TURN, self )
			sim:removeTrigger( simdefs.TRG_UNIT_HIJACKED, self )
			sim:removeTrigger( simdefs.TRG_ICE_BROKEN, self )
			sim:removeTrigger( simdefs.TRG_UNIT_KILLED, self )
			sim:removeTrigger( simdefs.TRG_UNIT_ALERTED, self )
			sim:removeTrigger( simdefs.TRG_SAFE_LOOTED, self )
			sim:removeTrigger( simdefs.TRG_BUY_ITEM, self )
			sim:removeTrigger( simdefs.TRG_UI_ACTION , self )
			sim:removeTrigger( simdefs.TRG_UNIT_WARP , self )
			sim:removeTrigger( simdefs.TRG_CAUGHT_BY_CAMERA, self )
			sim:removeTrigger( simdefs.TRG_UNIT_NEWINTEREST, self )
			sim:removeTrigger( simdefs.TRG_OPEN_DOOR, self )
			sim:removeTrigger( simdefs.TRG_SET_OVERWATCH, self )
		end,

    		onTrigger = function( self, sim, evType, evData, userUnit )
			if evType == simdefs.TRG_START_TURN and evData:isPC() then
				for i, slot in pairs(self.slotsPro) do
					if sim:getNPC():getTraits().suppressedPro == 0 and slot.cooldown > 0 then
						slot.cooldown = slot.cooldown - 1
					end
				end
				for i, slot in pairs(self.slotsRea) do
					if sim:getNPC():getTraits().suppressedRea == 0 and slot.cooldown > 0 then
						slot.cooldown = slot.cooldown - 1
					end
				end
				if sim:getNPC():getTraits().showAITemp then
					sim:getNPC():getTraits().showAITemp = nil
				end
				if sim:getNPC():getTraits().suppressedPWR > 0 then
					sim:getNPC():getTraits().suppressedPWR = sim:getNPC():getTraits().suppressedPWR - 1
				end
				if sim:getNPC():getTraits().suppressedPro > 0 then
					sim:getNPC():getTraits().suppressedPro = sim:getNPC():getTraits().suppressedPro - 1
				end
				if sim:getNPC():getTraits().suppressedRea > 0 then
					sim:getNPC():getTraits().suppressedRea = sim:getNPC():getTraits().suppressedRea - 1
				end
				if self.lockdown and self.lockdown > 0 then
					self.lockdown = self.lockdown - 1
					if self.lockdown <= 0 then
						self.lockdown = nil
						sim:setMainframeLockout( false )
					end
				end
				if self.supervisionCooldown and self.supervisionCooldown == 0 then
					self.supervisionUnit:getTraits().iceImmune = nil
					self.supervisionUnit = nil
					self.supervisionCooldown = nil
				elseif self.supervisionCooldown and self.supervisionCooldown > 0 then
					self.supervisionCooldown = self.supervisionCooldown - 1
				end
			end

			if evType == simdefs.TRG_UNIT_HIJACKED and evData.unit:getTraits().mainframe_console then
				if not evData.action then
					local scanned = false
					if not scanned then
						for i, routine in pairs(self.slotsPWR) do
							if not routine.identified then
								routine.identified = true
								scanned = true
								break
							end
						end
					end
					if not scanned then
						for i, routine in pairs(self.slotsPro) do
							if not routine.identified then
								routine.identified = true
								scanned = true
								break
							end
						end
					end
					if not scanned then
						for i, routine in pairs(self.slotsRea) do
							if not routine.identified then
								routine.identified = true
								scanned = true
								break
							end
						end
					end
					if not scanned then
						for i, routine in pairs(self.slotsUti) do
							if not routine.identified then
								routine.identified = true
								scanned = true
								break
							end
						end
					end
				elseif evData.action == "scan" then
					sim:getNPC():getTraits().showAITemp = true
				elseif evData.action == "delay" then
					for i, routine in pairs(self.slotsPro) do
						routine.cooldown = routine.cooldown + 1
					end
					for i, routine in pairs(self.slotsRea) do
						routine.cooldown = routine.cooldown + 1
					end
				elseif evData.action == "remove" then
					self.removeAblility(self, sim, evType, evData, userUnit)
				end
			end

			if sim:getNPC():getTraits().suppressedPWR <= 0 then
				for i, routine in pairs(self.slotsPWR) do
					routine.onTrigger(self, sim, evType, evData, userUnit, routine)
				end
			end

			if sim:getNPC():getTraits().suppressedPro <= 0 then
				for i, routine in pairs(self.slotsPro) do
					if routine.canUseAbility(self, sim, evType, evData, userUnit, routine) then
						routine.executeAbility(self, sim, evType, evData, userUnit, routine)
					end
				end
			end

			if sim:getNPC():getTraits().suppressedRea <= 0 then
				for i, routine in pairs(self.slotsRea) do
					if routine.canUseAbility(self, sim, evType, evData, userUnit, routine) then
						routine.executeAbility(self, sim, evType, evData, userUnit, routine)
					end
				end
			end

			for i, routine in pairs(self.slotsUti) do
				routine.executeAbility(self, sim, evType, evData, userUnit, routine)
			end
     		end,

		onTooltip = function( self, hud, sim, player )
			local tooltip = util.tooltip( hud._screen )
			local section = tooltip:addSection()

			section:addLine( self.name )
			if sim:getNPC():getTraits().showAITemp then
				section:addLine( string.format(STRINGS.PROGEXTEND.AI.PWR, sim:getNPC():getCpus(), sim:getNPC():getMaxCpus()) )
			else
				section:addLine( STRINGS.PROGEXTEND.AI.PWR_UNKNOWN )
			end

			if sim:getNPC():getTraits().suppressedPWR <= 0 then
				for i, routine in pairs(self.slotsPWR) do
					if routine.identified or sim:getNPC():getTraits().showAI then
	   					section:addAbility( routine.name, routine.desc, "gui/icons/action_icons/Action_icon_Small/icon-action_chargeweapon_small.png" )
					else
	   					section:addAbility( STRINGS.PROGEXTEND.AI.UNKNOWN, STRINGS.PROGEXTEND.AI.UNKNOWN_TIP, "gui/icons/action_icons/Action_icon_Small/icon-action_chargeweapon_small.png" )
					end
				end
			else
				for i, routine in pairs(self.slotsPWR) do
	   				section:addAbility( STRINGS.PROGEXTEND.AI.SUPPRESSED, STRINGS.PROGEXTEND.AI.SUPPRESSED_DESC, "gui/icons/action_icons/Action_icon_Small/icon-action_chargeweapon_small.png" )
					break
				end
			end
			if sim:getNPC():getTraits().suppressedPro <= 0 then
				for i, routine in pairs(self.slotsPro) do
					if routine.identified or sim:getNPC():getTraits().showAI then
	   					section:addAbility( routine.name(self, sim, routine), routine.desc, "gui/icons/thought_icons/status_channeling.png" )
					else
	   					section:addAbility( STRINGS.PROGEXTEND.AI.UNKNOWN, STRINGS.PROGEXTEND.AI.UNKNOWN_TIP, "gui/icons/thought_icons/status_channeling.png" )
					end
				end
			else
				for i, routine in pairs(self.slotsPro) do
	   				section:addAbility( STRINGS.PROGEXTEND.AI.SUPPRESSED, STRINGS.PROGEXTEND.AI.SUPPRESSED_DESC, "gui/icons/thought_icons/status_channeling.png" )
					break
				end
			end
			if sim:getNPC():getTraits().suppressedRea <= 0 then
				for i, routine in pairs(self.slotsRea) do
					if routine.identified or sim:getNPC():getTraits().showAI then
	   					section:addAbility( routine.name(self, sim, routine), routine.desc, "gui/icons/thought_icons/status_hunt.png" )
					else
	   					section:addAbility( STRINGS.PROGEXTEND.AI.UNKNOWN, STRINGS.PROGEXTEND.AI.UNKNOWN_TIP, "gui/icons/thought_icons/status_hunt.png" )
					end
				end
			else
				for i, routine in pairs(self.slotsRea) do
	   				section:addAbility( STRINGS.PROGEXTEND.AI.SUPPRESSED, STRINGS.PROGEXTEND.AI.SUPPRESSED_DESC, "gui/icons/thought_icons/status_hunt.png" )
					break
				end
			end
			for i, routine in pairs(self.slotsUti) do
				if routine.identified or sim:getNPC():getTraits().showAI then
	   				section:addAbility( routine.name, routine.desc, "gui/icons/thought_icons/status_action.png" )
				else
	   				section:addAbility( STRINGS.PROGEXTEND.AI.UNKNOWN, STRINGS.PROGEXTEND.AI.UNKNOWN_TIP, "gui/icons/thought_icons/status_action.png" )
				end
			end
			if self.dlcFooter then
				section:addFooter(self.dlcFooter[1], self.dlcFooter[2])
			end	        

			return tooltip
		end,

		removeAblility = function(self, sim, evType, evData, userUnit)
			local select = sim:nextRand(1, #self.slotsUti)
			self.slotsUti[select].removeAbility( self, sim )
			table.remove(self.slotsUti, select)
			if #self.slotsUti <= 0 then
				sim:getNPC():getTraits().hasAIroutine = nil
			end
		end,
	},
}

return npc_abilities2