local hud = include( "hud/hud" )
local mathutil = include( "modules/mathutil" )
local array = include( "modules/array" )
local util = include( "client_util" )
local simability = include( "sim/simability" )
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local cdefs = include( "client_defs" )
local mainframe = include( "sim/mainframe" )
local modifiers = include( "sim/modifiers" )
local mission_util = include( "sim/missions/mission_util" )
local serverdefs = include("modules/serverdefs")
local mainframe_common = include("sim/abilities/mainframe_common")
local mainframe_abilities_base = include("sim/abilities/mainframe_abilities")
local nonbreakIceTooltip = include( "hud/tooltip_nonbreakice" )

local booster_tooltip = class(nonbreakIceTooltip)

function booster_tooltip:init( mainframePanel, targetWidget, unit, reason )
	util.tooltip.init( self, mainframePanel._hud._screen )
	self._targetWidget = targetWidget
	self.mainframePanel = mainframePanel

	local localPlayer = mainframePanel._hud._game:getLocalPlayer()
	local equippedProgram = nil
	if localPlayer then 
		equippedProgram = localPlayer:getEquippedProgram()
		if equippedProgram then
			local programWidget = mainframePanel._panel.binder.programsPanel:findWidget( equippedProgram:getID() )		
			if programWidget and programWidget:isVisible() then            	
				self._ux0, self._uy0 = programWidget.binder.btn:getAbsolutePosition()
				if equippedProgram:canUseAbility( mainframePanel._hud._game.simCore, localPlayer ) then
					self.programWidget = programWidget
					self.equippedProgram = equippedProgram
				end
			end
		end
	end

	local section = self:addSection()
	section:addLine( "<ttheader>"..util.sformat( "TARGET {1}", unit:getName() ).."</>" )

	if equippedProgram then
		section:addAbility( string.format(STRINGS.UI.TOOLTIPS.CURRENTLY_EQUIPPED, equippedProgram:getDef().name), util.sformat(equippedProgram:getDef().tipdesc, equippedProgram:getCpuCost()),  "gui/icons/arrow_small.png" )
	end 

	if reason then
		section:addRequirement( reason )
	end
end

-------------------------------------------------------------------------------
-- These are PC mainframe abilities.  They are owned and executed by the player.
local DEFAULT_ABILITY = mainframe_common.DEFAULT_ABILITY

local mainframe_abilities =
{
	W93_axe = util.extend( DEFAULT_ABILITY )
	{
		name = STRINGS.PROGEXTEND.PROGRAMS.AXE.NAME,
		desc = STRINGS.PROGEXTEND.PROGRAMS.AXE.DESC,
		huddesc = STRINGS.PROGEXTEND.PROGRAMS.AXE.HUD_DESC,
		shortdesc = STRINGS.PROGEXTEND.PROGRAMS.AXE.SHORT_DESC,
		tipdesc = STRINGS.PROGEXTEND.PROGRAMS.AXE.TIP_DESC,

		icon = "gui/icons/programs_icons/icon-program_axe.png",
		icon_100 = "gui/icons/programs_icons/store_icons/StorePrograms_axe.png",
		cpu_cost = 5,
		break_firewalls = 1,
		cooldown = 0,
		maxCooldown = 3,
		value = 600,
		range = 4,

		PROGRAM_LIST = 10,	

		acquireTargets = function( self, targets, game, sim, unit )
            		local targetHandler = targets.areaCellTarget( game, self.range, sim, sim:getPC() )
            		targetHandler:setUnitPredicate(
                		function( u )
                    			return mainframe.canBreakIce( sim, u, self )
                		end )
            		targetHandler:setHiliteColor( { 0.33, 0.33, 0.33, 0.33 } )
            		return targetHandler
		end, 

        	startTargeting = function( self, sim, unit, userUnit, targetCell )
    			MOAIFmodDesigner.playSound( "SpySociety/Actions/mainframe_datablast_select" )
        	end,

        	getTargetUnits = function( self, sim, cellx, celly )
            		local cells = simquery.rasterCircle( sim, cellx, celly, self.range )
            		local units = {}
            		for i, x, y in util.xypairs( cells ) do
                		local cell = sim:getCell( x, y )
                		if cell then
                    			for _, cellUnit in ipairs(cell.units) do
                        			if sim:getCurrentPlayer():getLastKnownCell( sim, x, y ) ~= nil then
                            				if mainframe.canBreakIce( sim, cellUnit, self ) then
                                				table.insert( units, cellUnit )
                            				end
                        			end
                    			end
                		end
            		end
            		return units
        	end,

		executeAbility = function( self, sim, unit, userUnit, targetCell )
			
			local player = sim:getCurrentPlayer()
            		local currentProgram = player:getEquippedProgram()

    			player:equipProgram( sim, self:getID() )

			local cellx, celly = unpack(targetCell)
            		sim:dispatchEvent( simdefs.EV_PLAY_SOUND, "SpySociety/Actions/mainframe_datablast_use" )

            		local targetUnits = self:getTargetUnits( sim, cellx, celly )

           		sim:dispatchEvent( simdefs.EV_OVERLOAD_VIZ, {x = cellx, y = celly, units = targetUnits, range = self.range } )		

            		local daemonUnits = {}
            		for _, unit in ipairs(targetUnits) do
                		local daemonProgram = unit:getTraits().mainframe_program

                		unit:getTraits().mainframe_program = nil
				self.break_firewalls = math.max(math.floor(unit:getTraits().mainframe_ice/2),1)
	        		if sim:getPC():getTraits().firewallBreakPenalty then
	        			self.break_firewalls = math.max(self.break_firewalls - sim:getPC():getTraits().firewallBreakPenalty, 1 )
	       			end
                		mainframe.breakIce( sim, unit, self.break_firewalls )
				self.break_firewalls = 1
                		unit:getTraits().mainframe_program = daemonProgram

                		if daemonProgram and unit:getTraits().mainframe_ice <= 0 then
                    			table.insert( daemonUnits, unit )
                		end
	        	end

            		self:useCPUs( sim )
			self:setCooldown( sim )
    			player:equipProgram( sim, currentProgram and currentProgram:getID() )

            		for i, unit in ipairs( daemonUnits ) do
                		mainframe.invokeDaemon( sim, unit )
            		end
		end,
	},

	W93_breach = util.extend( DEFAULT_ABILITY )
	{

		name = STRINGS.PROGEXTEND.PROGRAMS.BREACH.NAME,
		desc = STRINGS.PROGEXTEND.PROGRAMS.BREACH.DESC,
		huddesc = STRINGS.PROGEXTEND.PROGRAMS.BREACH.HUD_DESC,
		shortdesc = STRINGS.PROGEXTEND.PROGRAMS.BREACH.SHORT_DESC,
		tipdesc = STRINGS.PROGEXTEND.PROGRAMS.BREACH.TIP_DESC,

		icon = "gui/icons/programs_icons/icon-program_breach.png",
		icon_100 = "gui/icons/programs_icons/store_icons/StorePrograms_breach.png",
		cpu_cost = 3,
		break_firewalls = 1, 
		equip_program = true, 
		equipped = false, 
		value = 400,

		PROGRAM_LIST = 10,	

		executeAbility = function( self, sim, targetUnit )
			DEFAULT_ABILITY.executeAbility(self, sim, targetUnit)
			self.break_firewalls = self.break_firewalls + 1
			self.tipdesc = string.format(STRINGS.PROGEXTEND.PROGRAMS.BREACH.TIP_DESC2,self.break_firewalls)
		end,

		onTrigger = function( self, sim, evType, evData )
			DEFAULT_ABILITY.onTrigger( self, sim, evType, evData )

			if evType == simdefs.TRG_START_TURN then
				self.break_firewalls = 1
				self.tipdesc = STRINGS.PROGEXTEND.PROGRAMS.BREACH.TIP_DESC
			end
		end,
	},

	W93_breach_2 = util.extend( DEFAULT_ABILITY )
	{

		name = STRINGS.PROGEXTEND.PROGRAMS.BREACH_2.NAME,
		desc = STRINGS.PROGEXTEND.PROGRAMS.BREACH_2.DESC,
		huddesc = STRINGS.PROGEXTEND.PROGRAMS.BREACH_2.HUD_DESC,
		shortdesc = STRINGS.PROGEXTEND.PROGRAMS.BREACH_2.SHORT_DESC,
		tipdesc = STRINGS.PROGEXTEND.PROGRAMS.BREACH_2.TIP_DESC,

		icon = "gui/icons/programs_icons/icon-program_breach_2.png",
		icon_100 = "gui/icons/programs_icons/store_icons/StorePrograms_breach_2.png",
		cpu_cost = 2,
		break_firewalls = 1, 
		equip_program = true, 
		equipped = false, 
		value = 800,

		PROGRAM_LIST = 5,	

		executeAbility = function( self, sim, targetUnit )
			DEFAULT_ABILITY.executeAbility(self, sim, targetUnit)
			self.break_firewalls = self.break_firewalls + 1
			self.tipdesc = string.format(STRINGS.PROGEXTEND.PROGRAMS.BREACH_2.TIP_DESC2,self.break_firewalls)
		end,

		onTrigger = function( self, sim, evType, evData )
			DEFAULT_ABILITY.onTrigger( self, sim, evType, evData )

			if evType == simdefs.TRG_START_TURN then
				self.break_firewalls = 1
				self.tipdesc = STRINGS.PROGEXTEND.PROGRAMS.BREACH_2.TIP_DESC
			end
		end,
	},

	W93_condense = util.extend( DEFAULT_ABILITY )
	{
		name = STRINGS.PROGEXTEND.PROGRAMS.CONDENSE.NAME,
		desc = STRINGS.PROGEXTEND.PROGRAMS.CONDENSE.DESC,
		huddesc = STRINGS.PROGEXTEND.PROGRAMS.CONDENSE.HUD_DESC,
		shortdesc = STRINGS.PROGEXTEND.PROGRAMS.CONDENSE.SHORT_DESC,
		icon = "gui/icons/programs_icons/icon-program_condense.png",
		icon_100 = "gui/icons/programs_icons/store_icons/StorePrograms_condense.png",
		cpu_cost = 0,
	        cooldown = 0,        
        	maxCooldown = 3, 
		value = 550,
	
		PROGRAM_NO_BREAKER_LIST = 10,

		executeAbility = function( self, sim )
			if sim:getPC():getTraits().PWRmaxBouns then
				sim:getPC():getTraits().PWRmaxBouns = sim:getPC():getTraits().PWRmaxBouns - 5
				sim:getPC():addCPUs( 10 )
			end
			self:setCooldown( sim )
            		self:useCPUs( sim )
		end,

		canUseAbility = function( self, sim, abilityOwner )
			local player = sim:getCurrentPlayer()
			if player ~= abilityOwner or player == nil then
				return false
			end

			if sim:getPC():getMaxCpus() <= 5 then
				return false, STRINGS.PROGEXTEND.PROGRAMS.CONDENSE.WARNING
			end

			return DEFAULT_ABILITY.canUseAbility( self, sim, abilityOwner )
		end,

    		onSpawnAbility = function( self, sim, player )
    			DEFAULT_ABILITY.onSpawnAbility( self, sim )
			if not player:getTraits().PWRmaxBouns then
				player:getTraits().PWRmaxBouns = 0
			end
			player:getTraits().PWRmaxBouns = player:getTraits().PWRmaxBouns + 5
    		end,
	},

	W93_crossfeed = util.extend( DEFAULT_ABILITY )
	{

		name = STRINGS.PROGEXTEND.PROGRAMS.CROSSFEED.NAME,
		desc = STRINGS.PROGEXTEND.PROGRAMS.CROSSFEED.DESC,
		huddesc = STRINGS.PROGEXTEND.PROGRAMS.CROSSFEED.HUD_DESC,
		shortdesc = STRINGS.PROGEXTEND.PROGRAMS.CROSSFEED.SHORT_DESC,
		tipdesc = STRINGS.PROGEXTEND.PROGRAMS.CROSSFEED.TIP_DESC,

		icon = "gui/icons/programs_icons/icon-program_crossfeed.png",
		icon_100 = "gui/icons/programs_icons/store_icons/StorePrograms_crossfeed.png",
		cpu_cost = 1,
	        cooldown = 0,        
        	maxCooldown = 0, 
        	value = 800,
		equip_program = true, 
		equipped = false, 
		mode = 0,
		crossfeed_source = nil,
		crossfeed_target = nil,

		PROGRAM_NO_BREAKER_LIST = 10,

		onSpawnAbility = function( self, sim )
			DEFAULT_ABILITY.onSpawnAbility( self, sim )
			sim:addTrigger( simdefs.TRG_UNIT_EMP, self )
			sim:addTrigger( simdefs.TRG_ICE_BROKEN, self )
			sim:addTrigger( simdefs.TRG_UNIT_KILLED, self )
		end, 

    		onDespawnAbility = function( self, sim, player )
    			DEFAULT_ABILITY.onDespawnAbility( self, sim )
			sim:removeTrigger( simdefs.TRG_UNIT_EMP, self )
			sim:removeTrigger( simdefs.TRG_ICE_BROKEN, self )
			sim:removeTrigger( simdefs.TRG_UNIT_KILLED, self )	
    		end,

		onTrigger = function( self, sim, evType, evData )
			if evType == simdefs.TRG_START_TURN and evData:isPC() then
				if self.crossfeed_source and self.crossfeed_target then
					sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.PROGRAMS.CROSSFEED.WARNING, color=cdefs.COLOR_PLAYER_WARNING, sound = "SpySociety/Actions/mainframe_gainCPU",icon=self.icon } )
					evData:addCPUs( 2 )
					self.crossfeed_target:increaseIce(sim,1)
					mainframe.breakIce( sim, self.crossfeed_source, 1 )

					if self.crossfeed_source and self.crossfeed_source:getTraits().mainframe_ice > 0 then
						self.maxCooldown = self.crossfeed_source:getTraits().mainframe_ice
						self.cooldown = self.crossfeed_source:getTraits().mainframe_ice
					else
						if self.crossfeed_source then
							self.crossfeed_source:getTraits().crossfeed_source = nil
						end
						self.crossfeed_source = nil
						if self.crossfeed_target then
							self.crossfeed_target:getTraits().crossfeed_target = nil
						end
						self.crossfeed_target = nil
						self.cooldown = 0
						self.maxCooldown = 0
					end
				end
			end
			if evType == simdefs.TRG_UNIT_EMP or evType == simdefs.TRG_ICE_BROKEN then
				if self.crossfeed_source and (self.crossfeed_source:getTraits().mainframe_ice <= 0 or self.crossfeed_source:getTraits().mainframe_booting) then
					if self.crossfeed_target then
						self.crossfeed_target:getTraits().crossfeed_target = nil
						self.crossfeed_target = nil
					end
					self.crossfeed_source:getTraits().crossfeed_source = nil
					self.crossfeed_source = nil
					self.cooldown = 0
					self.maxCooldown = 0
				end
				if self.crossfeed_target and (self.crossfeed_target:getTraits().mainframe_ice <= 0 or self.crossfeed_target:getTraits().mainframe_booting) then
					if self.crossfeed_source then
						self.crossfeed_source:getTraits().crossfeed_source = nil
						self.crossfeed_source = nil
					end
					self.crossfeed_target:getTraits().crossfeed_target = nil
					self.crossfeed_target = nil
					self.cooldown = 0
					self.maxCooldown = 0
				end
			end
			if evType == simdefs.TRG_ICE_BROKEN and self.crossfeed_source and self.crossfeed_source:getTraits().mainframe_ice > 0 then
				self.maxCooldown = self.crossfeed_source:getTraits().mainframe_ice
				self.cooldown = self.crossfeed_source:getTraits().mainframe_ice
			end
			if evType == simdefs.TRG_UNIT_KILLED and (evData.unit == self.crossfeed_source or evData.unit == self.crossfeed_target) then
				if self.crossfeed_source then
					self.crossfeed_source:getTraits().crossfeed_source = nil
					self.crossfeed_source = nil
				end
				if self.crossfeed_target then
					self.crossfeed_target:getTraits().crossfeed_target = nil
					self.crossfeed_target = nil
				end
				self.cooldown = 0
				self.maxCooldown = 0
			end
		end,

		executeAbility = function( self, sim, targetUnit )
        		if targetUnit and self.mode == 0 and not self.crossfeed_source then
				if not targetUnit:getTraits().crossfeed_target then
					sim:dispatchEvent( simdefs.EV_PLAY_SOUND, simdefs.SOUND_HOST_PARASITE.path )
					self.mode = 1
					self.maxCooldown = targetUnit:getTraits().mainframe_ice
					targetUnit:getTraits().crossfeed_source = true 
					sim:dispatchEvent( simdefs.EV_PLAY_SOUND, "SpySociety/Actions/mainframe_parasite_installed")
					self.crossfeed_source = targetUnit
					self.huddesc = STRINGS.PROGEXTEND.PROGRAMS.CROSSFEED.HUD_DESC2
					self.shortdesc = STRINGS.PROGEXTEND.PROGRAMS.CROSSFEED.SHORT_DESC2
					self.tipdesc = STRINGS.PROGEXTEND.PROGRAMS.CROSSFEED.TIP_DESC2
				else
					targetUnit:getTraits().crossfeed_target = nil
					self.crossfeed_target = nil
				end
			elseif targetUnit and self.mode == 0 and self.crossfeed_source then
				self.maxCooldown = 0
				targetUnit:getTraits().crossfeed_source = nil
				self.crossfeed_source = nil
        		elseif targetUnit and self.mode == 1 and not self.crossfeed_target then
				if not targetUnit:getTraits().crossfeed_source then
					sim:dispatchEvent( simdefs.EV_PLAY_SOUND, simdefs.SOUND_HOST_PARASITE.path )
					self.mode = 0
					targetUnit:getTraits().crossfeed_target = true 
					sim:dispatchEvent( simdefs.EV_PLAY_SOUND, "SpySociety/Actions/mainframe_parasite_installed")
					self.crossfeed_target = targetUnit
					self.huddesc = STRINGS.PROGEXTEND.PROGRAMS.CROSSFEED.HUD_DESC
					self.shortdesc = STRINGS.PROGEXTEND.PROGRAMS.CROSSFEED.SHORT_DESC
					self.tipdesc = STRINGS.PROGEXTEND.PROGRAMS.CROSSFEED.TIP_DESC
				else
					targetUnit:getTraits().crossfeed_source = nil
					self.crossfeed_source = nil
					self.maxCooldown = 0
				end
			elseif targetUnit and self.mode == 1 and self.crossfeed_target then
				targetUnit:getTraits().crossfeed_target = nil
				self.crossfeed_target = nil
			end

			if self.crossfeed_source and self.crossfeed_target then
				self:setCooldown( sim )
            			self:useCPUs( sim )
			end
		end,
	},

	W93_fade = util.extend( DEFAULT_ABILITY )
	{
		name = STRINGS.PROGEXTEND.PROGRAMS.FADE.NAME,
		desc = STRINGS.PROGEXTEND.PROGRAMS.FADE.DESC,
		huddesc = STRINGS.PROGEXTEND.PROGRAMS.FADE.HUD_DESC,
		shortdesc = STRINGS.PROGEXTEND.PROGRAMS.FADE.SHORT_DESC,
		tipdesc = STRINGS.PROGEXTEND.PROGRAMS.FADE.TIP_DESC,

		icon = "gui/icons/programs_icons/icon-program_fade.png",
		icon_100 = "gui/icons/programs_icons/store_icons/StorePrograms_fade.png",
		cpu_cost = 3,
		cooldown = 0,
		maxCooldown = 9,
        	value = 850,
		equip_program = true, 
		equipped = false, 
		targetingIcon = "gui/icons/item_icons/items_icon_small/icon-item_invisicloak_small.png",
		targetingDisabledColor = util.color(0.45,0.45,0.5,0.6),
		targetingColor = util.color( 120/255, 244/255, 255/255 ),
		targetingHoverColor = util.color( 188/255, 250/255, 255/255 ),
		targetRawUnit = true,

		PROGRAM_NO_BREAKER_LIST = 5,

		customTargetTooltip = function( mainframePanel, widget, unit, reason )
			return booster_tooltip( mainframePanel, widget, unit, reason )
		end,

		canUseAbility = function( self, sim, abilityOwner, targetUnit )
			if targetUnit then
				if not targetUnit:getTraits().isAgent then 				
					return false
				end
				
				if targetUnit:getTraits().isGuard then 				
					return false
				end

				if targetUnit:getPlayerOwner() ~= sim:getPC() then
					return false
				end

				if not sim:canPlayerSeeUnit( sim:getPC(), targetUnit ) then
					return false
				end

				if targetUnit:isGhost() then
					return false
				end

				if targetUnit:getTraits().invisible then
					return false
				end
			end

			local player = sim:getCurrentPlayer()
			if player == nil or player ~= abilityOwner then
				return false
			end

			if self.cooldown > 0 then 
				return false, STRINGS.UI.REASON.EQUIPPED_ON_COOLDOWN
			end

			if player:getCpus() < self:getCpuCost() then 
				return false, STRINGS.UI.REASON.NOT_ENOUGH_PWR
			end

			if sim:getMainframeLockout() then 
				return false, STRINGS.UI.REASON.INCOGNITA_LOCKED_DOWN
			end 

			return true	
		end,

		executeAbility = function( self, sim, targetUnit )
			targetUnit:setInvisible(true, 1)
			targetUnit:resetAllAiming()
			sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = targetUnit  } )
			sim:processReactions(targetUnit)

            		self:useCPUs( sim )
			self:setCooldown( sim )
		end,
	},

	W93_fission = util.extend( DEFAULT_ABILITY )
	{
		name = STRINGS.PROGEXTEND.PROGRAMS.FISSION.NAME,
		desc = STRINGS.PROGEXTEND.PROGRAMS.FISSION.DESC,
		huddesc = STRINGS.PROGEXTEND.PROGRAMS.FISSION.HUD_DESC,
		shortdesc = STRINGS.PROGEXTEND.PROGRAMS.FISSION.SHORT_DESC,
		icon = "gui/icons/programs_icons/icon-program_fission.png",
		icon_100 = "gui/icons/programs_icons/store_icons/StorePrograms_fission.png",
		cpu_cost = 0,
	        cooldown = 0,        
        	maxCooldown = 8, 
        	value = 550,

		PROGRAM_NO_BREAKER_LIST = 10,

		onSpawnAbility = function( self, sim )
			DEFAULT_ABILITY.onSpawnAbility( self, sim )
			sim:addTrigger( simdefs.TRG_ICE_BROKEN, self )	
		end, 

    		onDespawnAbility = function( self, sim, player )
    			DEFAULT_ABILITY.onDespawnAbility( self, sim )
			sim:removeTrigger( simdefs.TRG_ICE_BROKEN, self )	
    		end,

		onTrigger = function( self, sim, evType, evData )
			DEFAULT_ABILITY.onTrigger( self, sim, evType, evData )
			if evType == simdefs.TRG_ICE_BROKEN and evData["unit"]:getTraits().mainframe_ice <= 0 then
				if self.cooldown >= 1 then
					self.cooldown = self.cooldown - 1
				end
			end
		end,

		executeAbility = function( self, sim, targetUnit )
			DEFAULT_ABILITY.executeAbility(self, sim)
			sim:getCurrentPlayer():addCPUs( 6, sim )
			sim:dispatchEvent( simdefs.EV_PLAY_SOUND, "SpySociety/Actions/mainframe_run_fusion" )
			sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.PROGRAMS.FISSION.WARNING, color=cdefs.COLOR_PLAYER_WARNING, sound = "SpySociety/Actions/mainframe_gainCPU",icon=self.icon } )
		end,
	},

	W93_flail = util.extend( DEFAULT_ABILITY )
	{
		name = STRINGS.PROGEXTEND.PROGRAMS.FLAIL.NAME,
		desc = STRINGS.PROGEXTEND.PROGRAMS.FLAIL.DESC,
		huddesc = STRINGS.PROGEXTEND.PROGRAMS.FLAIL.HUD_DESC,
		shortdesc = STRINGS.PROGEXTEND.PROGRAMS.FLAIL.SHORT_DESC,
		tipdesc = STRINGS.PROGEXTEND.PROGRAMS.FLAIL.TIP_DESC,

		icon = "gui/icons/programs_icons/icon-program_flail.png",
		icon_100 = "gui/icons/programs_icons/store_icons/StorePrograms_flail.png",
		cpu_cost = 0,
        	value = 550,
		equip_program = true, 
		equipped = false, 
		mode = 0,
		flail_target = nil,

		PROGRAM_LIST = 20,

		onSpawnAbility = function( self, sim )
			DEFAULT_ABILITY.onSpawnAbility( self, sim )
			sim:addTrigger( simdefs.TRG_UNIT_EMP, self )
			sim:addTrigger( simdefs.TRG_ICE_BROKEN, self )
			sim:addTrigger( simdefs.TRG_UNIT_KILLED, self )
		end, 

    		onDespawnAbility = function( self, sim, player )
    			DEFAULT_ABILITY.onDespawnAbility( self, sim )
			sim:removeTrigger( simdefs.TRG_UNIT_EMP, self )
			sim:removeTrigger( simdefs.TRG_ICE_BROKEN, self )
			sim:removeTrigger( simdefs.TRG_UNIT_KILLED, self )	
    		end,

		onTrigger = function( self, sim, evType, evData )
			DEFAULT_ABILITY.onTrigger( self, sim, evType, evData )
			if evType == simdefs.TRG_UNIT_EMP or evType == simdefs.TRG_ICE_BROKEN then
				if self.flail_target and (self.flail_target:getTraits().mainframe_ice <= 0 or self.flail_target:getTraits().mainframe_booting) then
					self.huddesc = STRINGS.PROGEXTEND.PROGRAMS.FLAIL.HUD_DESC
					self.shortdesc = STRINGS.PROGEXTEND.PROGRAMS.FLAIL.SHORT_DESC
					self.tipdesc = STRINGS.PROGEXTEND.PROGRAMS.FLAIL.TIP_DESC
					self.flail_target:getTraits().flail_target = nil
					self.flail_target = nil
					self.cpu_cost = 0
					self.mode = 0
				end
			end
			if evType == simdefs.TRG_START_TURN and self.flail_target then
				self.flail_target:getTraits().flail_target = nil
				self.flail_target = nil
				self.cpu_cost = 0
				self.mode = 0
				self.huddesc = STRINGS.PROGEXTEND.PROGRAMS.FLAIL.HUD_DESC
				self.shortdesc = STRINGS.PROGEXTEND.PROGRAMS.FLAIL.SHORT_DESC
				self.tipdesc = STRINGS.PROGEXTEND.PROGRAMS.FLAIL.TIP_DESC
			end
			if evType == simdefs.TRG_UNIT_KILLED and evData.unit == self.flail_target then
				self.flail_target:getTraits().flail_target = nil
				self.flail_target = nil
				self.cpu_cost = 0
				self.mode = 0
				self.huddesc = STRINGS.PROGEXTEND.PROGRAMS.FLAIL.HUD_DESC
				self.shortdesc = STRINGS.PROGEXTEND.PROGRAMS.FLAIL.SHORT_DESC
				self.tipdesc = STRINGS.PROGEXTEND.PROGRAMS.FLAIL.TIP_DESC
			end
		end,

		executeAbility = function( self, sim, targetUnit )
        		if targetUnit and self.mode == 0 and not self.flail_target then
				self.cpu_cost = math.ceil(targetUnit:getTraits().mainframe_ice * 1.5)
				if self:getCpuCost() > sim:getCurrentPlayer():getCpus() then
					self.cpu_cost = 0
					return
				end
				sim:dispatchEvent( simdefs.EV_PLAY_SOUND, simdefs.SOUND_HOST_PARASITE.path )
				sim:dispatchEvent( simdefs.EV_PLAY_SOUND, "SpySociety/Actions/mainframe_parasite_installed")
				self.mode = 1
				targetUnit:getTraits().flail_target = true 
				self.flail_target = targetUnit
				self.huddesc = STRINGS.PROGEXTEND.PROGRAMS.FLAIL.HUD_DESC2
				self.shortdesc = STRINGS.PROGEXTEND.PROGRAMS.FLAIL.SHORT_DESC2
				self.tipdesc = STRINGS.PROGEXTEND.PROGRAMS.FLAIL.TIP_DESC2
			elseif targetUnit and self.mode == 0 and self.flail_target then
				self.flail_target:getTraits().flail_target = nil
				self.flail_target = nil
				self.cpu_cost = 0
        		elseif targetUnit and self.mode == 1 and (not self.flail_target or (self.flail_target and targetUnit:getTraits().flail_target)) then
				targetUnit:getTraits().flail_target = nil
				self.flail_target = nil
				self.cpu_cost = 0
				self.mode = 0
				self.huddesc = STRINGS.PROGEXTEND.PROGRAMS.FLAIL.HUD_DESC
				self.shortdesc = STRINGS.PROGEXTEND.PROGRAMS.FLAIL.SHORT_DESC
				self.tipdesc = STRINGS.PROGEXTEND.PROGRAMS.FLAIL.TIP_DESC
			elseif targetUnit and self.mode == 1 and not targetUnit:getTraits().flail_target and self.flail_target then
            			self:useCPUs( sim )
				self:setCooldown( sim )
				mainframe.breakIce( sim, self.flail_target, math.max(targetUnit:getTraits().mainframe_ice - (sim:getPC():getTraits().firewallBreakPenalty or 0), 1) )
				if self.flail_target then
					self.flail_target:getTraits().flail_target = nil
					self.flail_target = nil
				end
				self.cpu_cost = 0
				self.mode = 0
				self.huddesc = STRINGS.PROGEXTEND.PROGRAMS.FLAIL.HUD_DESC
				self.shortdesc = STRINGS.PROGEXTEND.PROGRAMS.FLAIL.SHORT_DESC
				self.tipdesc = STRINGS.PROGEXTEND.PROGRAMS.FLAIL.TIP_DESC
			end
		end,
	},

	W93_fortify = util.extend( DEFAULT_ABILITY ) 
	{
		name = STRINGS.PROGEXTEND.PROGRAMS.FORTIFY.NAME,
		desc = STRINGS.PROGEXTEND.PROGRAMS.FORTIFY.DESC,
		huddesc = STRINGS.PROGEXTEND.PROGRAMS.FORTIFY.HUD_DESC,
		shortdesc = STRINGS.PROGEXTEND.PROGRAMS.FORTIFY.SHORT_DESC,
		cpu_cost = 1,

		icon = "gui/icons/programs_icons/icon-program_fortify.png",
		icon_100 = "gui/icons/programs_icons/store_icons/StorePrograms_fortify.png",
		value = 450,

		PROGRAM_NO_BREAKER_LIST = 5,

		canUseAbility = function( self, sim )
			return false 	
		end,

		onSpawnAbility = function( self, sim, player  )	
			sim:addTrigger( simdefs.TRG_ICE_BROKEN, self )
		end,

    		onDespawnAbility = function( self, sim, player )	
			sim:removeTrigger( simdefs.TRG_ICE_BROKEN, self )
    		end,

		onTrigger = function( self, sim, evType, evData )
			if evType == simdefs.TRG_ICE_BROKEN and evData["unit"]:getTraits().mainframe_ice <= 0 and not evData["unit"]:getTraits().isGuard and sim:getCurrentPlayer():getCpus() >= self:getCpuCost() then
				evData["unit"]:getTraits().mainframe_no_recapture = true
				local x0, y0 = evData["unit"]:getLocation()
				self:useCPUs( sim )
				sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, {txt=util.sformat(STRINGS.PROGEXTEND.UI.FORTIFY),x=x0,y=y0,color={r=1,g=1,b=41/255,a=1}} )
				sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.PROGRAMS.FORTIFY.WARNING, color=cdefs.COLOR_PLAYER_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off",icon=self.icon } )
			end
		end,


	},

	W93_greed = util.extend( DEFAULT_ABILITY )
	{
		name = STRINGS.PROGEXTEND.PROGRAMS.GREED.NAME,
		desc = STRINGS.PROGEXTEND.PROGRAMS.GREED.DESC,
		huddesc = STRINGS.PROGEXTEND.PROGRAMS.GREED.HUD_DESC,
		shortdesc = STRINGS.PROGEXTEND.PROGRAMS.GREED.SHORT_DESC,
		tipdesc = STRINGS.PROGEXTEND.PROGRAMS.GREED.TIP_DESC,

		icon = "gui/icons/programs_icons/icon-program_greed.png",
		icon_100 = "gui/icons/programs_icons/store_icons/StorePrograms_greed.png",
		cpu_cost = 4,
		cooldown = 0,
		maxCooldown = 6,
        	value = 800,
		equip_program = true, 
		equipped = false, 
		targetingIcon = "gui/icons/cashflow_icons/safes.png",
		targetingDisabledColor = util.color(0.45,0.45,0.5,0.6),
		targetingColor = util.color( 120/255, 244/255, 255/255 ),
		targetingHoverColor = util.color( 188/255, 250/255, 255/255 ),
		targetRawUnit = true,

		PROGRAM_NO_BREAKER_LIST = 5,

		customTargetTooltip = function( mainframePanel, widget, unit, reason )
			return booster_tooltip( mainframePanel, widget, unit, reason )
		end,

		canUseAbility = function( self, sim, abilityOwner, targetUnit )
			if targetUnit then
				if not targetUnit:getTraits().safeUnit then 				
					return false
				end

				if targetUnit:getTraits().open then 				
					return false
				end

				if not targetUnit:getTraits().credits then
					return false
				end

				if targetUnit:getTraits().greedBoost then
					return false
				end
			end

			local player = sim:getCurrentPlayer()
			if player == nil or player ~= abilityOwner then
				return false
			end

			if self.cooldown > 0 then 
				return false, STRINGS.UI.REASON.EQUIPPED_ON_COOLDOWN
			end

			if player:getCpus() < self:getCpuCost() then 
				return false, STRINGS.UI.REASON.NOT_ENOUGH_PWR
			end

			if sim:getMainframeLockout() then 
				return false, STRINGS.UI.REASON.INCOGNITA_LOCKED_DOWN
			end 

			return true	
		end,

		executeAbility = function( self, sim, targetUnit )
			local x1, y1 = targetUnit:getLocation()

			targetUnit:getTraits().credits = targetUnit:getTraits().credits * (sim:getTrackerStage() * 0.2 + 1)
			targetUnit:getTraits().greedBoost = sim:getTrackerStage() * 20
			sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, {txt=STRINGS.PROGEXTEND.UI.GREED_BOOST,x=x1,y=y1,color={r=1,g=1,b=1,a=1}} )

            		self:useCPUs( sim )
			self:setCooldown( sim )
		end,
	},

	W93_heartbreaker = util.extend( DEFAULT_ABILITY )
	{
		name = STRINGS.PROGEXTEND.PROGRAMS.HEARTBREAKER.NAME,
		desc = STRINGS.PROGEXTEND.PROGRAMS.HEARTBREAKER.DESC,
		huddesc = STRINGS.PROGEXTEND.PROGRAMS.HEARTBREAKER.HUD_DESC,
		shortdesc = STRINGS.PROGEXTEND.PROGRAMS.HEARTBREAKER.SHORT_DESC,
		tipdesc = STRINGS.PROGEXTEND.PROGRAMS.HEARTBREAKER.TIP_DESC,

		icon = "gui/icons/programs_icons/icon-program_heartbreaker.png",
		icon_100 = "gui/icons/programs_icons/store_icons/StorePrograms_heartbreaker.png",
		cpu_cost = 1,
		cooldown = 0,
		maxCooldown = 4,
        	value = 300,
		equip_program = true,
		equipped = false, 
		targetingIcon = "gui/icons/item_icons/items_icon_small/icon-item_heart_monitor_small.png",
		targetingDisabledColor = util.color(0.45,0.45,0.5,0.6),
		targetingColor = util.color( 120/255, 244/255, 255/255 ),
		targetingHoverColor = util.color( 188/255, 250/255, 255/255 ),
		targetRawUnit = true,

		PROGRAM_NO_BREAKER_LIST = 5,

		customTargetTooltip = function( mainframePanel, widget, unit, reason )
			return booster_tooltip( mainframePanel, widget, unit, reason )
		end,

		canUseAbility = function( self, sim, abilityOwner, targetUnit )
			if targetUnit then
				if not sim:canPlayerSeeUnit( sim:getPC(), targetUnit ) then
					return false
				end

				if targetUnit:isGhost() then
					return false
				end

				if not targetUnit:getTraits().isGuard then 				
					return false
				end
				
				if targetUnit:getTraits().isDrone then 				
					return false
				end
				
				if targetUnit:isDown() then 				
					return false
				end

				if not targetUnit:getTraits().heartMonitor then
					return false
				end 
			end

			local player = sim:getCurrentPlayer()
			if player == nil or player ~= abilityOwner then
				return false
			end

			if self.cooldown > 0 then 
				return false, STRINGS.UI.REASON.EQUIPPED_ON_COOLDOWN
			end

			if player:getCpus() < self:getCpuCost() then 
				return false, STRINGS.UI.REASON.NOT_ENOUGH_PWR
			end

			if sim:getMainframeLockout() then 
				return false, STRINGS.UI.REASON.INCOGNITA_LOCKED_DOWN
			end 

			return true	
		end,

		executeAbility = function( self, sim, targetUnit )
			local x1, y1 = targetUnit:getLocation()
			if targetUnit:hasAbility( "improved_heart_monitor_passive" ) then
				targetUnit:removeAbility( sim, "improved_heart_monitor_passive" )
				sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, {txt=STRINGS.PROGEXTEND.UI.MONITOR_DOWNGRADED,x=x1,y=y1,color={r=1,g=1,b=1,a=1}} )
			else
				targetUnit:getTraits().heartMonitor = nil
				sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, {txt=STRINGS.UI.FLY_TXT.MONITOR_DISABLED,x=x1,y=y1,color={r=1,g=1,b=1,a=1}} )
			end

            		self:useCPUs( sim )
			self:setCooldown( sim )
		end,
	},

	W93_lottery = util.extend( DEFAULT_ABILITY )
	{
		name = STRINGS.PROGEXTEND.PROGRAMS.LOTTERY.NAME,
		desc = STRINGS.PROGEXTEND.PROGRAMS.LOTTERY.DESC,
		huddesc = STRINGS.PROGEXTEND.PROGRAMS.LOTTERY.HUD_DESC,
		shortdesc = STRINGS.PROGEXTEND.PROGRAMS.LOTTERY.SHORT_DESC,
		icon = "gui/icons/programs_icons/icon-program_lottery.png",
		icon_100 = "gui/icons/programs_icons/store_icons/StorePrograms_lottery.png",
		cpu_cost = 1,
	        cooldown = 0,        
        	maxCooldown = 8, 
		value = 250,	
		PROGRAM_NO_BREAKER_LIST = 20,

		executeAbility = function( self, sim )

			local ability = simability.create( serverdefs.REVERSE_DAEMONS[ sim:nextRand( 1, #serverdefs.REVERSE_DAEMONS ) ] )
			table.insert( sim:getNPC():getAbilities(), ability )
			ability:spawnAbility( sim, sim:getNPC(), nil )
			--sim:getNPC():addMainframeAbility( sim, serverdefs.REVERSE_DAEMONS[sim:nextRand(1, #serverdefs.REVERSE_DAEMONS)] )
			DEFAULT_ABILITY.executeAbility(self, sim)	
		end,
	},

	W93_nosferatu = util.extend( DEFAULT_ABILITY )
	{
		name = STRINGS.PROGEXTEND.PROGRAMS.NOSFERATU.NAME,
		desc = STRINGS.PROGEXTEND.PROGRAMS.NOSFERATU.DESC,
		huddesc = STRINGS.PROGEXTEND.PROGRAMS.NOSFERATU.HUD_DESC,
		shortdesc = STRINGS.PROGEXTEND.PROGRAMS.NOSFERATU.SHORT_DESC,
		icon = "gui/icons/programs_icons/icon-program_nosferatu.png",
		icon_100 = "gui/icons/programs_icons/store_icons/StorePrograms_nosferatu.png",
        	value = 550,
		passive = true,
		PROGRAM_NO_BREAKER_LIST = 10,

		canUseAbility = function( self, sim )
			return false 	
		end,

		onTrigger = function( self, sim, evType, evData )
			if evType == simdefs.TRG_START_TURN and evData:isPC() then
				local power = 0
				local units = sim:getPC():getUnits()
				for i, unit in ipairs(units) do
					local cell = sim:getCell( unit:getLocation() )
					if cell then
						for i, cellUnit in ipairs(cell.units) do
							if cellUnit:isKO() and not cellUnit:isDead() and not unit:isKO() then
								power = power + 1
							end
						end
					end
				end
				if power > 0 then
					sim:getCurrentPlayer():addCPUs( power + 1, sim )
					sim:dispatchEvent( simdefs.EV_PLAY_SOUND, "SpySociety/Actions/mainframe_run_fusion" )
					sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.PROGRAMS.NOSFERATU.WARNING,power + 1), color=cdefs.COLOR_PLAYER_WARNING, sound = "SpySociety/Actions/mainframe_gainCPU",icon=self.icon } )
				end
			end
		end,
	},

	W93_omniwrench = util.extend( DEFAULT_ABILITY )
	{

		name = STRINGS.PROGEXTEND.PROGRAMS.OMNIWRENCH.NAME,
		desc = STRINGS.PROGEXTEND.PROGRAMS.OMNIWRENCH.DESC,
		huddesc = STRINGS.PROGEXTEND.PROGRAMS.OMNIWRENCH.HUD_DESC,
		shortdesc = STRINGS.PROGEXTEND.PROGRAMS.OMNIWRENCH.SHORT_DESC,
		tipdesc = STRINGS.PROGEXTEND.PROGRAMS.OMNIWRENCH.TIP_DESC,

		icon = "gui/icons/programs_icons/icon-program-wrench.png",
		icon_100 = "gui/icons/programs_icons/store_icons/StorePrograms_wrench.png",
		cpu_cost = 0,
		break_firewalls = 1,
		cooldown = 0,
		maxCooldown = 1,
		equip_program = true, 
		equipped = false, 
		value = 1000,

		PROGRAM_LIST = 5,	

		executeAbility = function( self, sim, targetUnit )

			self.cpu_cost = targetUnit:getTraits().mainframe_ice

			if targetUnit then
			if sim:getPC():getTraits().program_cost_modifier then
				if self.cpu_cost + sim:getPC():getTraits().program_cost_modifier <= sim:getCurrentPlayer():getCpus() then
					mainframe.breakIce( sim, targetUnit, math.max(targetUnit:getTraits().mainframe_ice - (sim:getPC():getTraits().firewallBreakPenalty or 0), 1))
					self:setCooldown( sim )
					self:useCPUs( sim )
				end
			else
				if self.cpu_cost <= sim:getCurrentPlayer():getCpus() then
					mainframe.breakIce( sim, targetUnit, math.max(targetUnit:getTraits().mainframe_ice - (sim:getPC():getTraits().firewallBreakPenalty or 0), 1))
					self:setCooldown( sim )
					self:useCPUs( sim )
				end
			end
			end

			self.cpu_cost = 0
			self.break_firewalls = 1
		end,
	},

	W93_overview = util.extend( DEFAULT_ABILITY )
	{
		name = STRINGS.PROGEXTEND.PROGRAMS.OVERVIEW.NAME,
		desc = STRINGS.PROGEXTEND.PROGRAMS.OVERVIEW.DESC,
		huddesc = string.format(STRINGS.PROGEXTEND.PROGRAMS.OVERVIEW.HUD_DESC, STRINGS.PROGEXTEND.PROGRAMS.OVERVIEW.WARNING),
		shortdesc = STRINGS.PROGEXTEND.PROGRAMS.OVERVIEW.SHORT_DESC,
		tipdesc = STRINGS.PROGEXTEND.PROGRAMS.OVERVIEW.TIP_DESC,
		icon = "gui/icons/programs_icons/icon-program_overview.png",
		icon_100 = "gui/icons/programs_icons/store_icons/StorePrograms_overview.png",
		cpu_cost = 1,
		cooldown = 0,
		maxCooldown = 4,
        	value = 250,
		equip_program = true, 
		equipped = false, 
		targetingIcon = "gui/icons/item_icons/items_icon_small/icon-item_Sticky_Cam_small.png",
		targetingDisabledColor = util.color(0.45,0.45,0.5,0.6),
		targetingColor = util.color( 120/255, 244/255, 255/255 ),
		targetingHoverColor = util.color( 188/255, 250/255, 255/255 ),
		targetRawUnit = true,
		targetUnit = nil,
		cameraUnit = nil,

		PROGRAM_NO_BREAKER_LIST = 5,

		customTargetTooltip = function( mainframePanel, widget, unit, reason )
			return booster_tooltip( mainframePanel, widget, unit, reason )
		end,

		spawnCamera = function( self, sim, targetUnit )
			local x0, y0 = targetUnit:getLocation()
			local cell = sim:getCell( x0, y0 )
			local eyeball = include( "sim/units/eyeball" )
			local eyeballUnit = eyeball.createEyeball( sim )
			eyeballUnit:setPlayerOwner( sim:getPC() )
			eyeballUnit:setFacing( targetUnit:getFacing() )
			eyeballUnit:getTraits().LOSarc = math.pi
			sim:spawnUnit( eyeballUnit )
			sim:warpUnit( eyeballUnit, cell )
			self.cameraUnit = eyeballUnit
			self.targetUnit = targetUnit
			self.huddesc = string.format(STRINGS.PROGEXTEND.PROGRAMS.OVERVIEW.HUD_DESC, targetUnit:getName())
		end,

		onSpawnAbility = function( self, sim, player  )	
			sim:addTrigger( simdefs.TRG_START_TURN, self )
			sim:addTrigger( simdefs.TRG_UNIT_WARP, self )
			sim:addTrigger( simdefs.TRG_UNIT_KO, self )
			sim:addTrigger( simdefs.TRG_UNIT_KILLED, self )
		end,

    		onDespawnAbility = function( self, sim, player )
			sim:removeTrigger( simdefs.TRG_START_TURN, self )
			sim:removeTrigger( simdefs.TRG_UNIT_WARP, self )	
			sim:removeTrigger( simdefs.TRG_UNIT_KO, self )
			sim:removeTrigger( simdefs.TRG_UNIT_KILLED, self )
    		end,

		onTrigger = function( self, sim, evType, evData )
			DEFAULT_ABILITY.onTrigger( self, sim, evType, evData )

			if evType == simdefs.TRG_UNIT_WARP or evType == simdefs.TRG_UNIT_KO or evType == simdefs.TRG_UNIT_KILLED then
				if evData.unit == self.targetUnit and self.cameraUnit then
					sim:warpUnit( self.cameraUnit )
					sim:despawnUnit( self.cameraUnit )
					self.cameraUnit = nil
					if evType == simdefs.TRG_UNIT_WARP and self.targetUnit:isValid() then
						self:spawnCamera( sim, evData.unit )
						return
					end
					self.targetUnit = nil
					self.huddesc = string.format(STRINGS.PROGEXTEND.PROGRAMS.OVERVIEW.HUD_DESC, STRINGS.PROGEXTEND.PROGRAMS.OVERVIEW.WARNING)
				end
			end
		end,

		canUseAbility = function( self, sim, abilityOwner, targetUnit )
			if targetUnit then
				if (not targetUnit:getTraits().isGuard) and (not targetUnit:getTraits().safeUnit) then 				
					return false
				end

				if targetUnit:getTraits().isGuard and (not sim:canPlayerSeeUnit( sim:getPC(), targetUnit )) then
					return false
				end

				if targetUnit:isGhost() then
					return false
				end

				if targetUnit == self.targetUnit then
					return false
				end
			end

			local player = sim:getCurrentPlayer()
			if player == nil or player ~= abilityOwner then
				return false
			end

			if self.cooldown > 0 then 
				return false, STRINGS.UI.REASON.EQUIPPED_ON_COOLDOWN
			end

			if player:getCpus() < self:getCpuCost() then 
				return false, STRINGS.UI.REASON.NOT_ENOUGH_PWR
			end

			if sim:getMainframeLockout() then 
				return false, STRINGS.UI.REASON.INCOGNITA_LOCKED_DOWN
			end 

			return true	
		end,

		executeAbility = function( self, sim, targetUnit )
			self:spawnCamera( sim, targetUnit )

            		self:useCPUs( sim )
			self:setCooldown( sim )
		end,
	},

	W93_power_surge = util.extend( DEFAULT_ABILITY ) 
	{
		name = STRINGS.PROGEXTEND.PROGRAMS.POWERSURGE.NAME,
		desc = STRINGS.PROGEXTEND.PROGRAMS.POWERSURGE.DESC,
		shortdesc = STRINGS.PROGEXTEND.PROGRAMS.POWERSURGE.SHORT_DESC,
		huddesc = STRINGS.PROGEXTEND.PROGRAMS.POWERSURGE.HUD_DESC,
		icon = "gui/icons/programs_icons/icon-program_power_surge.png",
		icon_100 = "gui/icons/programs_icons/store_icons/StorePrograms_power_surge.png",
		cpu_cost = 0,
		credit_cost = 0,
		value = 500,
        	passive = true,	
		PROGRAM_NO_BREAKER_LIST = 10,

		onSpawnAbility = function( self, sim, player  )	
			sim:addTrigger( simdefs.TRG_ICE_BROKEN, self )
		end,

    		onDespawnAbility = function( self, sim, player )	
			sim:removeTrigger( simdefs.TRG_ICE_BROKEN, self )
    		end,

		canUseAbility = function( self, sim )
			return false 	
		end,

		onTrigger = function( self, sim, evType, evData )
			if evType == simdefs.TRG_ICE_BROKEN and evData["unit"]:getTraits().mainframe_ice <= 0 then
				sim:getCurrentPlayer():addCPUs( 1, sim )
				sim:dispatchEvent( simdefs.EV_PLAY_SOUND, cdefs.SOUND_HUD_MAINFRAME_PROGRAM_AUTO_RUN )
				sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.PROGRAMS.POWERSURGE.WARNING, color=cdefs.COLOR_PLAYER_WARNING, sound = "SpySociety/Actions/mainframe_gainCPU",icon=self.icon } )
			end
		end,
	},

	W93_power_uplink = util.extend( DEFAULT_ABILITY )
	{

		name = STRINGS.PROGEXTEND.PROGRAMS.PWRUPLINK.NAME,
		desc = STRINGS.PROGEXTEND.PROGRAMS.PWRUPLINK.DESC,
		huddesc = STRINGS.PROGEXTEND.PROGRAMS.PWRUPLINK.HUD_DESC,
		shortdesc = STRINGS.PROGEXTEND.PROGRAMS.PWRUPLINK.SHORT_DESC,
		tipdesc = STRINGS.PROGEXTEND.PROGRAMS.PWRUPLINK.TIP_DESC,

		icon = "gui/icons/programs_icons/icon-program_power_uplink.png",
		icon_100 = "gui/icons/programs_icons/store_icons/StorePrograms_power_uplink.png",
		cpu_cost = 2,
	        cooldown = 0,        
        	maxCooldown = 5, 
        	value = 600,
		equip_program = true, 
		equipped = false, 
		uplink_hosts = {},

		PROGRAM_NO_BREAKER_LIST = 5,

		onSpawnAbility = function( self, sim )
			DEFAULT_ABILITY.onSpawnAbility( self, sim )
			sim:addTrigger( simdefs.TRG_UNIT_EMP, self )
			sim:addTrigger( simdefs.TRG_ICE_BROKEN, self )
		end, 

    		onDespawnAbility = function( self, sim, player )
    			DEFAULT_ABILITY.onDespawnAbility( self, sim )
			sim:removeTrigger( simdefs.TRG_UNIT_EMP, self )
			sim:removeTrigger( simdefs.TRG_ICE_BROKEN, self )
    		end,

		onTrigger = function( self, sim, evType, evData )
			DEFAULT_ABILITY.onTrigger( self, sim, evType, evData )
			if evType == simdefs.TRG_START_TURN and evData:isPC() then
            			local hosts = util.tdupe(self.uplink_hosts)
				local uplinkCount = 0
            			for i, hostID in ipairs(hosts) do
                			local hostUnit = sim:getUnit( hostID )
					if hostUnit and hostUnit:getTraits().uplink and (hostUnit:getTraits().mainframe_ice <= 0 or hostUnit:getTraits().mainframe_booting) then
						hostUnit:getTraits().uplink = nil
					end
                			if hostUnit and hostUnit:getTraits().uplink and hostUnit:getTraits().mainframe_ice > 0 then
						uplinkCount = uplinkCount+1
					end
            			end
				if uplinkCount > 0 then
					sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.PROGRAMS.PWRUPLINK.WARNING,uplinkCount), color=cdefs.COLOR_PLAYER_WARNING, sound = "SpySociety/Actions/mainframe_gainCPU",icon=self.icon } )
					evData:addCPUs( uplinkCount )
				end
			end
			if evType == simdefs.TRG_UNIT_EMP or evType == simdefs.TRG_ICE_BROKEN then
            			local hosts = util.tdupe(self.uplink_hosts)
            			for i, hostID in ipairs(hosts) do
                			local hostUnit = sim:getUnit( hostID )
					if hostUnit and hostUnit:getTraits().uplink and (hostUnit:getTraits().mainframe_ice <= 0 or hostUnit:getTraits().mainframe_booting) then
						hostUnit:getTraits().uplink = nil
					end
            			end
			end
		end,


		canUseAbility = function( self, sim, abilityOwner, targetUnit )
            		local hosts = util.tdupe(self.uplink_hosts)
			local uplinkCount = 0
            		for i, hostID in ipairs(hosts) do
                		local hostUnit = sim:getUnit( hostID )
				if hostUnit and hostUnit:getTraits().uplink then
					uplinkCount = uplinkCount + 1
				end
            		end
			if uplinkCount > 3 then
				return false, "MAXIMUM NUMBER OF UPLINKS REACHED"
			end

			if targetUnit and targetUnit:getTraits().uplink then
				return false, "ALREADY HAS POWER UPLINK"
			end

			return DEFAULT_ABILITY.canUseAbility( self, sim, abilityOwner, targetUnit )
		end,

		executeAbility = function( self, sim, targetUnit )
        		if not targetUnit:getTraits().uplink then
				sim:dispatchEvent( simdefs.EV_PLAY_SOUND, simdefs.SOUND_HOST_PARASITE.path )
            			self:useCPUs( sim )
				self:setCooldown( sim )
				targetUnit:getTraits().uplink = true 
				sim:dispatchEvent( simdefs.EV_PLAY_SOUND, "SpySociety/Actions/mainframe_parasite_installed")
				table.insert(self.uplink_hosts,targetUnit:getID())
        		end
		end,
	},

	W93_rally = util.extend( DEFAULT_ABILITY ) 
	{
		name = STRINGS.PROGEXTEND.PROGRAMS.RALLY.NAME,
		desc = STRINGS.PROGEXTEND.PROGRAMS.RALLY.DESC,
		shortdesc = STRINGS.PROGEXTEND.PROGRAMS.RALLY.SHORT_DESC,
		huddesc = STRINGS.PROGEXTEND.PROGRAMS.RALLY.HUD_DESC,
		tipdesc = STRINGS.PROGEXTEND.PROGRAMS.RALLY.TIP_DESC,
		icon = "gui/icons/programs_icons/icon-program_rally.png",
		icon_100 = "gui/icons/programs_icons/store_icons/StorePrograms_rally.png",
		break_firewalls = 2,
		cpu_cost = 2,
	        cooldown = 0,        
        	maxCooldown = 1, 
		value = 750,
		equip_program = true, 
		equipped = false, 	
		PROGRAM_LIST = 20,

		onSpawnAbility = function( self, sim, player  )
			DEFAULT_ABILITY.onSpawnAbility( self, sim )
			sim:addTrigger( simdefs.TRG_UNIT_KO, self )
			sim:addTrigger( simdefs.TRG_UNIT_KILLED, self )
		end,

    		onDespawnAbility = function( self, sim, player )
    			DEFAULT_ABILITY.onDespawnAbility( self, sim )	
			sim:removeTrigger( simdefs.TRG_UNIT_KO, self )
			sim:removeTrigger( simdefs.TRG_UNIT_KILLED, self )
    		end,

		onTrigger = function( self, sim, evType, evData )
			DEFAULT_ABILITY.onTrigger( self, sim, evType, evData )
			if (evType == simdefs.TRG_UNIT_KO or evType == simdefs.TRG_UNIT_KILLED) and evData["unit"]:getTraits().isGuard and self.cooldown > 0 then
				self.cooldown = 0
				sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.PROGRAMS.RALLY.WARNING, color=cdefs.COLOR_PLAYER_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off",icon=self.icon } )
			end
		end,
	},

	W93_reflect = util.extend( DEFAULT_ABILITY )
	{
		name = STRINGS.PROGEXTEND.PROGRAMS.REFLECT.NAME,
		desc = STRINGS.PROGEXTEND.PROGRAMS.REFLECT.DESC,
		huddesc = STRINGS.PROGEXTEND.PROGRAMS.REFLECT.HUD_DESC,
		shortdesc = STRINGS.PROGEXTEND.PROGRAMS.REFLECT.SHORT_DESC,

		icon = "gui/icons/programs_icons/icon-program_reflect.png",
		icon_100 = "gui/icons/programs_icons/store_icons/StorePrograms_reflect.png",
		cpu_cost = 8,
        	cooldown = 5,        
        	maxCooldown = 5, 
		value = 1000,
		daemonReversalAdd = 10,
		modeToggle = 2,	
		PROGRAM_NO_BREAKER_LIST = 20,

		onSpawnAbility = function( self, sim, player  )
			DEFAULT_ABILITY.onSpawnAbility( self, sim )	
			self.modeToggle = 0
			sim:addTrigger( simdefs.TRG_DAEMON_REVERSE, self )
			sim:addTrigger( simdefs.TRG_DAEMON_INSTALL, self )
			sim:addTrigger( simdefs.TRG_ICE_BROKEN, self )
		end,

    		onDespawnAbility = function( self, sim, player )
    			DEFAULT_ABILITY.onDespawnAbility( self, sim )	
			self.modeToggle = 0
			sim:removeTrigger( simdefs.TRG_DAEMON_REVERSE, self )
			sim:removeTrigger( simdefs.TRG_DAEMON_INSTALL, self )
			sim:removeTrigger( simdefs.TRG_ICE_BROKEN, self )

    		end,

		onTrigger = function( self, sim, evType, evData )
			local player = sim:getCurrentPlayer()
			DEFAULT_ABILITY.onTrigger( self, sim, evType, evData )
			if evType == simdefs.TRG_DAEMON_REVERSE and self.modeToggle == 1 and self.cooldown <= 0 and sim:getPC():getCpus() >= self:getCpuCost() then
				sim:getPC():addCPUs( -self:getCpuCost(), sim )
				self:setCooldown( sim )
				self.modeToggle = 2
				self.daemonReversalAdd = 0
				sim:getPC():getTraits().reverseAll = nil
				self.icon = "gui/icons/programs_icons/icon-program_reflect.png"
				self.huddesc = STRINGS.PROGEXTEND.PROGRAMS.REFLECT.HUD_DESC3
				self.shortdesc = STRINGS.PROGEXTEND.PROGRAMS.REFLECT.SHORT_DESC3
			end
			if evType == simdefs.TRG_START_TURN and self.modeToggle == 2 and self.cooldown <= 0 then
				self.modeToggle = 0
				self.daemonReversalAdd = 10
				sim:getPC():getTraits().reverseAll = nil
				self.huddesc = STRINGS.PROGEXTEND.PROGRAMS.REFLECT.HUD_DESC
				self.shortdesc = STRINGS.PROGEXTEND.PROGRAMS.REFLECT.SHORT_DESC
			end
			if (evType == simdefs.TRG_DAEMON_INSTALL or simdefs.TRG_DAEMON_REVERSE or simdefs.TRG_ICE_BROKEN or evType == simdefs.TRG_START_TURN) and self.modeToggle == 1 and self.cooldown <= 0 and sim:getPC():getCpus() < self:getCpuCost() then
				self.modeToggle = 0
				self.daemonReversalAdd = 10
				sim:getPC():getTraits().reverseAll = nil
				self.huddesc = STRINGS.PROGEXTEND.PROGRAMS.REFLECT.HUD_DESC
				self.shortdesc = STRINGS.PROGEXTEND.PROGRAMS.REFLECT.SHORT_DESC
			end
		end,

		executeAbility = function( self, sim )
			local player = sim:getCurrentPlayer()

			if self.modeToggle == 0 and sim:getPC():getCpus() >= self:getCpuCost() then
				self.modeToggle = 1
				self.daemonReversalAdd = 0
				sim:getPC():getTraits().reverseAll = true
				self.huddesc = STRINGS.PROGEXTEND.PROGRAMS.REFLECT.HUD_DESC2
				self.shortdesc = STRINGS.PROGEXTEND.PROGRAMS.REFLECT.SHORT_DESC2
			elseif self.modeToggle == 1 then
				self.modeToggle = 0
				self.daemonReversalAdd = 10
				sim:getPC():getTraits().reverseAll = nil
				self.huddesc = STRINGS.PROGEXTEND.PROGRAMS.REFLECT.HUD_DESC
				self.shortdesc = STRINGS.PROGEXTEND.PROGRAMS.REFLECT.SHORT_DESC
			end
		end,
	},

	W93_search = util.extend( DEFAULT_ABILITY )
	{

		name = STRINGS.PROGEXTEND.PROGRAMS.SEARCH.NAME,
		desc = STRINGS.PROGEXTEND.PROGRAMS.SEARCH.DESC,
		huddesc = STRINGS.PROGEXTEND.PROGRAMS.SEARCH.HUD_DESC,
		shortdesc = STRINGS.PROGEXTEND.PROGRAMS.SEARCH.SHORT_DESC,

		icon = "gui/icons/programs_icons/icon-program_search.png",
		icon_100 = "gui/icons/programs_icons/store_icons/StorePrograms_search.png",
		cpu_cost = 1,
		credit_cost = 0,
		cooldown = 0,
		maxCooldown = 4,		
		value = 150,
		locatedNoDatabases = false,

		PROGRAM_NO_BREAKER_LIST = 10,

		canUseAbility = function( self, sim, abilityOwner )
			local player = sim:getCurrentPlayer()
			if player ~= abilityOwner or player == nil then
				return false
			end

			if self.locatedNoDatabases then 
				return false, STRINGS.PROGEXTEND.PROGRAMS.SEARCH.WARNING
			end

			return DEFAULT_ABILITY.canUseAbility( self, sim, abilityOwner )
		end,

		executeAbility = function( self, sim, unit, userUnit, targetCell )
			local player = sim:getCurrentPlayer()
			local availableDatabases = {}

			for _, unit in pairs( sim:getAllUnits() ) do 
				if unit:getTraits().revealDaemons or unit:getTraits().revealUnits or unit:getTraits().showOutline then 
					if unit:getPlayerOwner() ~= player and not player:hasSeen(unit) then 
						table.insert( availableDatabases, unit )
					end
				end
			end

			if #availableDatabases > 0 then
				local database = availableDatabases[ sim:nextRand( 1, #availableDatabases ) ]	            
				sim:getPC():glimpseUnit(sim, database:getID() )
    				sim:dispatchEvent( simdefs.EV_CAM_PAN, { database:getLocation() } )	
				sim:dispatchEvent( simdefs.EV_PLAY_SOUND, "SpySociety/Actions/mainframe_object_camera" )
				sim:dispatchEvent( simdefs.EV_UNIT_MAINFRAME_UPDATE, {units={database:getID()},reveal = true} )
            			self:useCPUs( sim )
            			self:setCooldown( sim )
			else 
				sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.PROGRAMS.SEARCH.WARNING, color=cdefs.COLOR_PLAYER_WARNING, sound = "SpySociety/Actions/mainframe_wisp_activate",icon=self.icon } )
				self.locatedNoDatabases = true
			end
		end,
	},

	W93_sonar = util.extend( DEFAULT_ABILITY )
	{
		name = STRINGS.PROGEXTEND.PROGRAMS.SONAR.NAME,
		desc = STRINGS.PROGEXTEND.PROGRAMS.SONAR.DESC,
		huddesc = STRINGS.PROGEXTEND.PROGRAMS.SONAR.HUD_DESC,
		shortdesc = STRINGS.PROGEXTEND.PROGRAMS.SONAR.SHORT_DESC,
		tipdesc = STRINGS.PROGEXTEND.PROGRAMS.SONAR.TIP_DESC,

		icon = "gui/icons/programs_icons/icon-program_sonar.png",
		icon_100 = "gui/icons/programs_icons/store_icons/StorePrograms_sonar.png",
		cpu_cost = 1,
		cooldown = 0,
		maxCooldown = 4,
		value = 175,
		range = 5,

		PROGRAM_NO_BREAKER_LIST = 20,	

		acquireTargets = function( self, targets, game, sim, unit )
            		local targetHandler = targets.simpleAreaTarget( game, self.range, sim )
            		targetHandler:setHiliteColor( { 0.33, 0.33, 0.33, 0.33 } )
            		return targetHandler
		end, 

		executeAbility = function( self, sim, unit, userUnit, targetCell )
			local player = sim:getCurrentPlayer()
            		local currentProgram = player:getEquippedProgram()

    			player:equipProgram( sim, self:getID() )

			local cellx, celly = unpack(targetCell)
            		local cells = simquery.rasterCircle( sim, cellx, celly, self.range )

			local units = sim:getAllUnits()
			for i, x, y in util.xypairs( cells ) do
                		local cell = sim:getCell( x, y )
				if cell then
					player:glimpseCell( sim, cell )
					for j, unit in pairs(units) do
						local tx,ty = unit:getLocation()
						if tx == x and ty == y then
							player:glimpseUnit( sim, unit:getID() )
						end
					end
				end
			end 
            		sim:dispatchEvent( simdefs.EV_PLAY_SOUND, "SpySociety/Actions/mainframe_datablast_use" )
           		sim:dispatchEvent( simdefs.EV_OVERLOAD_VIZ, {x = cellx, y = celly, units = nil, range = self.range } )
           		sim:dispatchEvent( simdefs.EV_SCRIPT_EXIT_MAINFRAME )
            		self:useCPUs( sim )
			self:setCooldown( sim )
		end,
	},
}

local ai_programs =
{
	W93_hushpuppy_PWR = util.extend( DEFAULT_ABILITY )
	{

		name = STRINGS.PROGEXTEND.PROGRAMS.HUSHPUPPY_PWR.NAME,
		desc = STRINGS.PROGEXTEND.PROGRAMS.HUSHPUPPY_PWR.DESC,
		huddesc = STRINGS.PROGEXTEND.PROGRAMS.HUSHPUPPY_PWR.HUD_DESC,
		shortdesc = STRINGS.PROGEXTEND.PROGRAMS.HUSHPUPPY_PWR.SHORT_DESC,

		icon = "gui/icons/programs_icons/icon-program_hushpuppy.png",
		icon_100 = "gui/icons/programs_icons/store_icons/StorePrograms_hushpuppy.png",
		cpu_cost = 2,
		cooldown = 0,
		maxCooldown = 5,		
		value = 400,

		PROGRAM_NO_BREAKER_LIST = 20,

		canUseAbility = function( self, sim, abilityOwner )
			if not sim:getNPC():hasMainframeAbility( "W93_AI_assembly" ) then
				return false, STRINGS.PROGEXTEND.UI.REASON_NO_AI
			end

			if sim:getNPC():getTraits().suppressedPWR > 0 then
				return false, STRINGS.PROGEXTEND.UI.REASON_ALREADY_SUPPRESSED
			end

			return DEFAULT_ABILITY.canUseAbility( self, sim, abilityOwner )
		end,

		executeAbility = function( self, sim, unit, userUnit, targetCell )
            		self:useCPUs( sim )
            		self:setCooldown( sim )

			sim:getNPC():getTraits().suppressedPWR = sim:getNPC():getTraits().suppressedPWR + 3
			sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.PROGRAMS.HUSHPUPPY_PWR.WARNING, color=cdefs.COLOR_PLAYER_WARNING, sound = "SpySociety/Actions/mainframe_wisp_activate",icon=self.icon } )
		end,
	},

	W93_hushpuppy_PRO = util.extend( DEFAULT_ABILITY )
	{

		name = STRINGS.PROGEXTEND.PROGRAMS.HUSHPUPPY_PRO.NAME,
		desc = STRINGS.PROGEXTEND.PROGRAMS.HUSHPUPPY_PRO.DESC,
		huddesc = STRINGS.PROGEXTEND.PROGRAMS.HUSHPUPPY_PRO.HUD_DESC,
		shortdesc = STRINGS.PROGEXTEND.PROGRAMS.HUSHPUPPY_PRO.SHORT_DESC,

		icon = "gui/icons/programs_icons/icon-program_hushpuppy.png",
		icon_100 = "gui/icons/programs_icons/store_icons/StorePrograms_hushpuppy.png",
		cpu_cost = 2,
		cooldown = 0,
		maxCooldown = 5,		
		value = 400,

		PROGRAM_NO_BREAKER_LIST = 20,

		canUseAbility = function( self, sim, abilityOwner )
			if not sim:getNPC():hasMainframeAbility( "W93_AI_assembly" ) then
				return false, STRINGS.PROGEXTEND.UI.REASON_NO_AI
			end

			if sim:getNPC():getTraits().suppressedPro > 0 then
				return false, STRINGS.PROGEXTEND.UI.REASON_ALREADY_SUPPRESSED
			end

			return DEFAULT_ABILITY.canUseAbility( self, sim, abilityOwner )
		end,

		executeAbility = function( self, sim, unit, userUnit, targetCell )
            		self:useCPUs( sim )
            		self:setCooldown( sim )

			sim:getNPC():getTraits().suppressedPro = sim:getNPC():getTraits().suppressedPro + 3
			sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.PROGRAMS.HUSHPUPPY_PRO.WARNING, color=cdefs.COLOR_PLAYER_WARNING, sound = "SpySociety/Actions/mainframe_wisp_activate",icon=self.icon } )
		end,
	},

	W93_hushpuppy_REA = util.extend( DEFAULT_ABILITY )
	{

		name = STRINGS.PROGEXTEND.PROGRAMS.HUSHPUPPY_REA.NAME,
		desc = STRINGS.PROGEXTEND.PROGRAMS.HUSHPUPPY_REA.DESC,
		huddesc = STRINGS.PROGEXTEND.PROGRAMS.HUSHPUPPY_REA.HUD_DESC,
		shortdesc = STRINGS.PROGEXTEND.PROGRAMS.HUSHPUPPY_REA.SHORT_DESC,

		icon = "gui/icons/programs_icons/icon-program_hushpuppy.png",
		icon_100 = "gui/icons/programs_icons/store_icons/StorePrograms_hushpuppy.png",
		cpu_cost = 2,
		cooldown = 0,
		maxCooldown = 5,		
		value = 400,

		PROGRAM_NO_BREAKER_LIST = 20,

		canUseAbility = function( self, sim, abilityOwner )
			if not sim:getNPC():hasMainframeAbility( "W93_AI_assembly" ) then
				return false, STRINGS.PROGEXTEND.UI.REASON_NO_AI
			end

			if sim:getNPC():getTraits().suppressedRea > 0 then
				return false, STRINGS.PROGEXTEND.UI.REASON_ALREADY_SUPPRESSED
			end

			return DEFAULT_ABILITY.canUseAbility( self, sim, abilityOwner )
		end,

		executeAbility = function( self, sim, unit, userUnit, targetCell )
            		self:useCPUs( sim )
            		self:setCooldown( sim )

			sim:getNPC():getTraits().suppressedRea = sim:getNPC():getTraits().suppressedRea + 3
			sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.PROGRAMS.HUSHPUPPY_REA.WARNING, color=cdefs.COLOR_PLAYER_WARNING, sound = "SpySociety/Actions/mainframe_wisp_activate",icon=self.icon } )
		end,
	},

	W93_leech = util.extend( DEFAULT_ABILITY )
	{

		name = STRINGS.PROGEXTEND.PROGRAMS.LEECH.NAME,
		desc = STRINGS.PROGEXTEND.PROGRAMS.LEECH.DESC,
		huddesc = STRINGS.PROGEXTEND.PROGRAMS.LEECH.HUD_DESC,
		shortdesc = STRINGS.PROGEXTEND.PROGRAMS.LEECH.SHORT_DESC,

		icon = "gui/icons/programs_icons/icon-program_leech.png",
		icon_100 = "gui/icons/programs_icons/store_icons/StorePrograms_leech.png",
		cpu_cost = 0,
		cooldown = 0,
		maxCooldown = 5,		
		value = 350,

		PROGRAM_NO_BREAKER_LIST = 20,

		canUseAbility = function( self, sim, abilityOwner )
			if not sim:getNPC():hasMainframeAbility( "W93_AI_assembly" ) then
				return false, STRINGS.PROGEXTEND.UI.REASON_NO_AI
			end

			return DEFAULT_ABILITY.canUseAbility( self, sim, abilityOwner )
		end,

		executeAbility = function( self, sim, unit, userUnit, targetCell )
			local pwr = math.min(4, sim:getNPC():getCpus())

            		self:useCPUs( sim )
            		self:setCooldown( sim )

			sim:getPC():addCPUs( pwr )
			sim:getNPC():addCPUs( -pwr )
			sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.PROGRAMS.LEECH.WARNING, pwr), color=cdefs.COLOR_PLAYER_WARNING, sound = "SpySociety/Actions/mainframe_wisp_activate",icon=self.icon } )
		end,
	},
}

return 
{
	mainframe_abilities = mainframe_abilities,
	ai_programs = ai_programs,
}
