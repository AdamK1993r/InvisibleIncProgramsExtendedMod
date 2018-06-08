local array = include( "modules/array" )
local util = include( "modules/util" )
local tooltip_breakice = include( "hud/tooltip_breakice" )
local mathutil = include( "modules/mathutil" )
local hud = include( "hud/hud" )
local cdefs = include( "client_defs" )
local serverdefs = include( "modules/serverdefs" )
local aiplayer = include( "sim/aiplayer" )
local pcplayer = include( "sim/pcplayer" )
local simability = include( "sim/simability" )
local simdefs = include( "sim/simdefs" )
local simquery = include( "sim/simquery" )
local simunit = include( "sim/simunit" )
local store = include( "sim/units/store" )
local worldgen = include( "sim/worldgen" )
local mainframe = include( "sim/mainframe" )
local mainframe_panel = include( "hud/mainframe_panel" )
local shop_panel = include( "hud/shop_panel" )
local mission_util = include( "sim/missions/mission_util" )
local modalDialog = include( "states/state-modal-dialog" )

	local null_tooltip = class()

	function null_tooltip:init( hud, str, str2 )
		self._hud = hud
		self._str = str
		self._str2 = str2  
	end

	function null_tooltip:setPosition( wx, wy )
		self._panel:setPosition( self._hud._screen:wndToUI( wx, wy ))
	end

	function null_tooltip:getScreen()
		return self._hud._screen
	end

	function null_tooltip:activate( screen )
		local combat_panel = include( "hud/combat_panel" )
		local COLOR_GREY = util.color(180/255,180/255,180/255,150/255)

		self._panel = combat_panel( self._hud, self._hud._screen )
		self._panel:refreshPanelFromStr( self._str, self._str2, COLOR_GREY )
	end

	function null_tooltip:deactivate()
		self._panel:setVisible( false )
	end

	function updateAgentAbilityAI( remove, agentdefs )
		if remove then
			for i, agentDef in pairs(agentdefs) do
				local j = array.find(agentDef.abilities, "W93_combatAI_scan")
				if j then
					table.remove(agentDef.abilities, j)
				end
				j = array.find(agentDef.abilities, "W93_combatAI_delay")
				if j then
					table.remove(agentDef.abilities, j)
				end
				j = array.find(agentDef.abilities, "W93_combatAI_pwr")
				if j then
					table.remove(agentDef.abilities, j)
				end
				j = array.find(agentDef.abilities, "W93_combatAI_disable")
				if j then
					table.remove(agentDef.abilities, j)
				end
			end
		else
			for i, agentDef in pairs(agentdefs) do
				if not array.find(agentDef.abilities, "W93_combatAI_scan") then
					table.insert(agentDef.abilities, "W93_combatAI_scan")
				end
				if not array.find(agentDef.abilities, "W93_combatAI_delay") then
					table.insert(agentDef.abilities, "W93_combatAI_delay")
				end
				if not array.find(agentDef.abilities, "W93_combatAI_pwr") then
					table.insert(agentDef.abilities, "W93_combatAI_pwr")
				end
				if not array.find(agentDef.abilities, "W93_combatAI_disable") then
					table.insert(agentDef.abilities, "W93_combatAI_disable")
				end
			end
		end
	end

	function set_colors()
		cdefs.TRACKER_COLOURS =
		{
			util.color.fromBytes( 250, 253, 105 ),
			util.color.fromBytes( 250, 253, 105 ),
			util.color.fromBytes( 251, 203, 98 ),
			util.color.fromBytes( 225, 152, 45 ),
			util.color.fromBytes( 246, 90, 21 ),
			util.color.fromBytes( 205, 24, 10 ),
			util.color.fromBytes( 205, 24, 10 ),
			util.color.fromBytes( 180, 15, 5 ),
			util.color.fromBytes( 180, 15, 5 ),
		}

		cdefs.COLOR_AI_WARNING = { r=255/255,g=216/255,b=0/255,a=255/255 }
	end

	function setProgramGfx()
		simdefs.SCREEN_CUSTOMS = util.extend(simdefs.SCREEN_CUSTOMS)
		{
			["hud-inworld.lua"] =
			{
				skins =
				{
					[1] =
					{ children = {
					[7] =
					{
                        			name = [[flailTarget]],
						isVisible = true,
						noInput = true,
						anchor = 1,
						rotation = 0,
						x = -18,
						xpx = true,
						y = 59,
						ypx = true,
						w = 61,
						wpx = true,
						h = 61,
						hpx = true,
						sx = 1,
						sy = 1,
						ctor = [[anim]],
						animfile = [[gui/flailAnim]],
						symbol = [[box2]],
						anim = [[idle]],
						color =
						{
							1,
							1,
							1,
							1,
						}
					},
					[8] =
					{
                        			name = [[crossfeedTarget]],
						isVisible = true,
						noInput = true,
						anchor = 1,
						rotation = 0,
						x = -18,
						xpx = true,
						y = 59,
						ypx = true,
						w = 61,
						wpx = true,
						h = 61,
						hpx = true,
						sx = 1,
						sy = 1,
						ctor = [[anim]],
						animfile = [[gui/crossfeedAnim2]],
						symbol = [[box2]],
						anim = [[idle]],
						color =
						{
							1,
							1,
							1,
							1,
						}
					},
					[9] =
					{
                        			name = [[crossfeedSource]],
						isVisible = true,
						noInput = true,
						anchor = 1,
						rotation = 0,
						x = -18,
						xpx = true,
						y = 59,
						ypx = true,
						w = 61,
						wpx = true,
						h = 61,
						hpx = true,
						sx = 1,
						sy = 0.75,
						ctor = [[anim]],
						animfile = [[gui/crossfeedAnim1]],
						symbol = [[box2]],
						anim = [[idle]],
						color =
						{
							1,
							1,
							1,
							1,
						}
					},
					[10] =
					{
                        			name = [[pwrUplink]],
						isVisible = true,
						noInput = true,
						anchor = 1,
						rotation = 0,
						x = -18,
						xpx = true,
						y = 59,
						ypx = true,
						w = 61,
						wpx = true,
						h = 61,
						hpx = true,
						sx = 1,
						sy = 1,
						ctor = [[anim]],
						animfile = [[gui/pwrUplinkAnim]],
						symbol = [[box2]],
						anim = [[idle]],
						color =
						{
							1,
							1,
							1,
							1,
						}
					}

					}}
				}
			}
		}
	end

	function setAlarmGfx()
		simdefs.SCREEN_CUSTOMS = util.extend(simdefs.SCREEN_CUSTOMS)
		{
			["hud.lua"] =
			{
				widgets =
				{
					[15] =
					{
						children = 
						{
							[1] =
							{
                						animfile = [[gui/hud_danger_wheel_four]],
							},
							[5] =
							{
                						sx = 0.4,
                						sy = 0.4,
							}
						}
					}
				}
			},
			["modal-alarm-first.lua"] =
			{
				widgets =
				{
					[2] =
					{
						children = 
						{
							[8] =
							{
                						animfile = [[gui/hud_danger_wheel_four]],
							}
						}
					}
				}
			}
		}
	end

	function resetAlarmGfx()
		simdefs.SCREEN_CUSTOMS = util.extend(simdefs.SCREEN_CUSTOMS)
		{
			["hud.lua"] =
			{
				widgets =
				{
					[15] =
					{
						children = 
						{
							[1] =
							{
                						animfile = [[gui/hud_danger_wheel_five]],
							},
							[5] =
							{
                						sx = 1.05,
                						sy = 1.05,
							}
						}
					}
				}
			},
			["modal-alarm-first.lua"] =
			{
				widgets =
				{
					[2] =
					{
						children = 
						{
							[8] =
							{
                						animfile = [[gui/hud_danger_wheel_five]],
							}
						}
					}
				}
			}
		}
	end

	function simquery.getMoveSoundRange( unit, cell )
		local range = 0
		if not unit:getTraits().sneaking then  
			range = unit:getTraits().dashSoundRange
		else
			range = simdefs.SOUND_RANGE_0
		end
		if unit:getPlayerOwner():getTraits().shackleDaemon and not unit:getTraits().isDrone then
			range = math.max(range, simdefs.SOUND_RANGE_1)
		end
		return range + (cell.noiseRadius or 0)	
	end

	function aiplayer:addMainframeAbility(sim, abilityID, hostUnit, reversalOdds )
		local monst3rReverseOdds = reversalOdds or 10

		if self:isNPC() then 
			for _, ability in ipairs( sim:getPC():getAbilities() ) do 
				if ability.daemonReversalAdd and monst3rReverseOdds > 0 then 
					monst3rReverseOdds = monst3rReverseOdds + ability.daemonReversalAdd
				end 
			end 
		end

		local count = 0
		for _, ability in ipairs( self._mainframeAbilities ) do
			if ability:getID() == abilityID then
				count = count + 1
			end
		end

		local ability = simability.create( abilityID )


		if ability and count < (ability.max_count or math.huge) then
			local monst3rReverse = nil 
			if self:isNPC() and sim:nextRand( 1, 100 ) < monst3rReverseOdds then 
				monst3rReverse = true 
			elseif findMainframeAbility("W93_reflect") and findMainframeAbility("W93_reflect"):getCpuCost() <= sim:getPC():getCpus() and sim:getPC():getTraits().reverseAll then
				monst3rReverse = true
			end

			if monst3rReverse and (not sim:isVersion("0.17.5") or not ability.noDaemonReversal )  then  
				local newAbilityID = serverdefs.REVERSE_DAEMONS[ sim:nextRand( 1, #serverdefs.REVERSE_DAEMONS ) ] 
				ability = simability.create( newAbilityID )
				sim:triggerEvent( simdefs.TRG_DAEMON_REVERSE )
			end 
		
			table.insert( self._mainframeAbilities, ability )
			ability:spawnAbility( self._sim, self, hostUnit )

			if self:isNPC() then			
				sim:dispatchEvent( simdefs.EV_MAINFRAME_INSTALL_PROGRAM, {idx = #self._mainframeAbilities, ability=ability} )	
				sim:triggerEvent( simdefs.TRG_DAEMON_INSTALL )		
			end		
		end
	end

	function mainframe_panel.panel:refreshBreakIceButton( widget, unit )
		local sim = self._hud._game.simCore
		local program = self:getCurrentProgram()
		local canUse, reason =  false, STRINGS.UI.REASON.NO_EQUIPPED_PROGRAM
	
		if program then
			canUse, reason = mainframe.canBreakIce( sim, unit, program )
		end

		if self._hud._game:isReplaying() then
			canUse, reason = false, nil
		end
    
		local tooltipWidget = widget.binder.btn
		local daemonTooltip = nil
		widget:setAlias( "BreakIce"..unit:getID() )
		if not widget.iceBreak then
			widget.binder.btn:setText(unit:getTraits().mainframe_ice)
		end
		widget.binder.btn:setDisabled( not canUse )
		if not canUse then		
			widget.binder.anim:getProp():setRenderFilter( cdefs.RENDER_FILTERS["desat"] )
		else
			widget.binder.anim:getProp():setRenderFilter( cdefs.RENDER_FILTERS["normal"] )
		end

		if unit:getTraits().parasite then
			widget.binder.anim:setAnim( "idle_bugged" )
		else
			widget.binder.anim:setAnim( "idle" )
		end

		if unit:getTraits().flail_target then
			widget.binder.flailTarget:setVisible(true)
		else
			widget.binder.flailTarget:setVisible(false)
		end

		if unit:getTraits().crossfeed_source then
			widget.binder.crossfeedSource:setVisible(true)
		else
			widget.binder.crossfeedSource:setVisible(false)
		end

		if unit:getTraits().crossfeed_target then
			widget.binder.crossfeedTarget:setVisible(true)
		else
			widget.binder.crossfeedTarget:setVisible(false)
		end

		if unit:getTraits().uplink then
			widget.binder.pwrUplink:setVisible(true)
		else
			widget.binder.pwrUplink:setVisible(false)
		end

		local programWidget = widget.binder.program

		if sim:getHideDaemons() and not unit:getTraits().daemon_sniffed then
			programWidget:setVisible( true )
			programWidget.binder.daemonUnknown:setVisible(false)
			programWidget.binder.daemonKnown:setVisible(false)
			programWidget.binder.daemonHidden:setVisible(true)
		elseif unit:getTraits().mainframe_program ~= nil then
			programWidget:setVisible( true )

			local npc_abilities = include( "sim/abilities/npc_abilities" )
			local ability = npc_abilities[ unit:getTraits().mainframe_program ]
			if unit:getTraits().daemon_sniffed then 
				programWidget.binder.daemonUnknown:setVisible(false)
				programWidget.binder.daemonKnown:setVisible(true)
				if unit:getTraits().daemon_sniffed_revealed == nil then
					unit:getTraits().daemon_sniffed_revealed = true
					programWidget.binder.daemonKnown.binder.txt:spoolText(ability.name, 12)			
				else
					programWidget.binder.daemonKnown.binder.txt:setText(ability.name)			
				end
           			daemonTooltip = programWidget.binder.daemonKnown.binder.bg
        		else
				programWidget.binder.daemonKnown:setVisible(false)
    				programWidget.binder.daemonUnknown:setVisible(true)
			end	
        		programWidget.binder.daemonHidden:setVisible(false)
    		else
        		programWidget:setVisible( false )
		end

    		if not canUse or program == nil or program.acquireTargets then
        		widget.binder.btn.onClick = nil
        		tooltipWidget:setTooltip( nil )
   		else
	    		widget.binder.btn.onClick = function( widget, ie )
                		if unit:isValid() and mainframe.canBreakIce( sim, unit, program ) then
				MOAIFmodDesigner.playSound( cdefs.SOUND_HUD_MAINFRAME_CONFIRM_ACTION )
				self._hud._game:doAction( "mainframeAction", {action = "breakIce", unitID = unit:getID() } )
				end
			end
		end
		if reason == "nulldrone" then
			tooltipWidget:setTooltip( function()
				local str = STRINGS.UI.REASON.SECURED
				local str2 = STRINGS.UI.REASON.SECURED_2
					return null_tooltip( self._hud, str, str2 )
			end )
			widget.binder.btn:setText("-")
		else  
			tooltipWidget:setTooltip( function()
				local breakIceTooltip = include( "hud/tooltip_breakice" )
				return breakIceTooltip( self, widget, unit, reason )
			end )
	    
        		if daemonTooltip then 
        			daemonTooltip:setTooltip( function() 
        				local breakIceTooltip = include( "hud/tooltip_breakice_nolines" )
            				return breakIceTooltip( self, widget, unit, reason )
        			end )
        		end 
		end   
	end

	function tooltip_breakice:init( mainframePanel, iceWidget, unit, reason )
		util.tooltip.init( self, mainframePanel._hud._screen )
		self._iceWidget = iceWidget
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
		section:addLine( "<ttheader>"..util.sformat( STRINGS.UI.TOOLTIPS.MAINFRAME_HACK_UNIT, unit:getName() ).."</>" )
		if unit:getTraits().mainframe_ice then
			section:addAbility( string.format(STRINGS.UI.TOOLTIPS.FIREWALLS, unit:getTraits().mainframe_ice), STRINGS.UI.TOOLTIPS.FIREWALLS_DESC,  "gui/icons/action_icons/Action_icon_Small/icon-action_lock_small.png" )
		end
		if equippedProgram then
			section:addAbility( string.format(STRINGS.UI.TOOLTIPS.CURRENTLY_EQUIPPED, equippedProgram:getDef().name), util.sformat(equippedProgram:getDef().tipdesc, equippedProgram:getCpuCost()),  "gui/icons/arrow_small.png" )
		end 

		if unit:getTraits().parasite then 
			if unit:getTraits().parasiteV2 then
				section:addLine( STRINGS.UI.TOOLTIPS.MAINFRAME_PARASITE_V2 )
			else
				section:addLine( STRINGS.UI.TOOLTIPS.MAINFRAME_PARASITE )
			end
		end

		if unit:getTraits().uplink then
			section:addLine( STRINGS.PROGEXTEND.UI.TARGET_PWRUPLINK )
		end
		if unit:getTraits().crossfeed_source then
			section:addLine( STRINGS.PROGEXTEND.UI.TARGET_CROSSFEED_S )
		end
		if unit:getTraits().crossfeed_target then
			section:addLine( STRINGS.PROGEXTEND.UI.TARGET_CROSSFEED_T )
		end
		if unit:getTraits().flail_target then
			section:addLine( STRINGS.PROGEXTEND.UI.TARGET_FLAIL )
		end

		local sim = mainframePanel._hud._game.simCore
		if sim:getHideDaemons() and not unit:getTraits().daemon_sniffed then
			section:addRequirement( STRINGS.UI.TOOLTIPS.MAINFRAME_MASKED )
		else	
			if unit:getTraits().mainframe_program then
				section:addRequirement( STRINGS.UI.TOOLTIPS.MAINFRAME_DAEMON)
				local npc_abilities = include( "sim/abilities/npc_abilities" )
				local ability = npc_abilities[ unit:getTraits().mainframe_program ]
				if unit:getTraits().daemon_sniffed then 
					section:addAbility( ability.name, ability.desc, ability.icon )
				else
					section:addAbility( STRINGS.UI.TOOLTIPS.MAINFRAME_HIDDEN_DAEMON, "?????????", "gui/items/item_quest.png" )
				end
			end
		end

		if reason then
			section:addRequirement( reason )
		end
	end

	function simunit:processEMP( bootTime, noEmpFX, ignoreMagRei )
		local empResisted = false
		local doEMPeffect = false

		if self:getTraits().mainframe_status == "off" then
			if self:getTraits().mainframe_booting then
        			self:getTraits().mainframe_booting = bootTime -- Restart boot timer.
    			end
		elseif self:getTraits().mainframe_status ~= nil and self:getTraits().mainframe_status ~= "off" then
			local EMP_FIREWALL_BREAK_STRENGTH = 2
			if self:getTraits().magnetic_reinforcement and self:getTraits().mainframe_ice > 2 and not ignoreMagRei then
				empResisted = true
				local x1,y1 = self:getLocation()
				local sim = self._sim 
				mainframe.breakIce( sim, self, EMP_FIREWALL_BREAK_STRENGTH )
				self._sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, {txt=STRINGS.UI.TOOLTIPS.MAGNETIC_REINFOREMENTS,x=x1,y=y1,color={r=255/255,g=255/255,b=255/255,a=1}} )
			else
				self:getTraits().mainframe_status_old = self:getTraits().mainframe_status
	        		if self.deactivate then
			    		self:deactivate( self._sim )
				end

				if self:getTraits().firewallShield then
					self:getTraits().shields = 0			
				end	
				self:getTraits().mainframe_status = "off"
				self:getTraits().mainframe_booting = bootTime
	       			if self:getTraits().switched then
					self:getTraits().switched  = nil 
					self:setSwitchStage(self._sim,"off")
				end	
				if self:getTraits().progress then
					self:setSwitchStage(self._sim,"off")
				end			
				if self:getTraits().hacker then
					local hacker = self._sim:getUnit(self:getTraits().hacker)	
					hacker:getTraits().data_hacking = nil
					hacker:getSounds().spot = nil
					self._sim:dispatchEvent( simdefs.EV_UNIT_TINKER_END, { unit = hacker } ) 	
					self._sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = hacker })
					self:getTraits().hacker = nil 
				end			

				doEMPeffect = true
	    		end
		elseif not empResisted and self:getTraits().heartMonitor == "enabled" then
			doEMPeffect = true
		end
		if doEMPeffect then
			if not noEmpFX then
	   			local x0,y0 = self:getLocation()
				self._sim:dispatchEvent( simdefs.EV_PLAY_SOUND, {sound="SpySociety/HitResponse/hitby_distrupter_flesh", x=x0,y=y0} )
				self._sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = self, fx = "emp" } )			
	    		end		
	    		self._sim:triggerEvent( simdefs.TRG_UNIT_EMP, self )
		end

		if not empResisted and self:getTraits().heartMonitor=="enabled" then
			local x1,y1 = self:getLocation()

			if self:getTraits().improved_heart_monitor then
				self._sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, {txt=STRINGS.UI.FLY_TXT.IMPROVED_HEART_MONITOR,x=x1,y=y1,color={r=1,g=1,b=41/255,a=1}} ) 
			else
				self:getTraits().heartMonitor="disabled"
				self._sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, {txt=STRINGS.UI.FLY_TXT.MONITOR_DISABLED,x=x1,y=y1,color={r=255/255,g=255/255,b=255/255,a=1}} )			
			end
		end

		self._sim:getPC():glimpseUnit( self._sim, self:getID() )
	end

	function reset_servers()
		local serverroom_1 = include( "sim/prefabs/shared/serverroom_1" )
		local serverroom_2 = include( "sim/prefabs/shared/serverroom_2" )
		local serverroom_3 = include( "sim/prefabs/shared/serverroom_3" )

		serverroom_1.units =
		{
    			{
        			maxCount = 5,
        			spawnChance = 1,
        			{
            				{
                				x = 4,
                				y = 1,
                				template = [[console_core]],
                				unitData =
                				{
							facing = 0,
						},
            				},
            				1,
        			},
        			{
            				{
                				x = 3,
                				y = 3,
                				template = [[console]],
                				unitData =
                				{
                    				facing = 0,
                				},
            				},
            				1,
        			},
        			{
					{
                				x = 5,
                				y = 3,
                				template = [[console]],
                				unitData =
                				{
                    				facing = 4,
                				},
            				},
            				1,
        			},
        			{
            				{
                				x = 5,
                				y = 5,
                				template = [[server_terminal]],
                				unitData =
                				{
                    					facing = 4,
                    					tags =
                    					{
                        					"serverFarm",
                    					},
                				},
            				},
            				1,
				},
			},
		}

		serverroom_2.units =
		{
    			{
        			maxCount = 5,
        			spawnChance = 1,
        			{
            				{
                				x = 9,
                				y = 6,
                				template = [[console_core]],
                				unitData =
                				{
                    					facing = 0,
                				},
            				},
            				1,
        			},
        			{
            				{
                				x = 7,
                				y = 6,
                				template = [[console]],
                				unitData =
                				{
                    					facing = 0,
                				},
            				},
            				1,
        			},
        			{
            				{
                				x = 5,
                				y = 6,
                				template = [[console]],
                				unitData =
                				{
                    					facing = 4,
                				},
            				},
            				1,
        			},
        			{
            				{
               					x = 6,
                				y = 3,
                				template = [[server_terminal]],
                				unitData =
                				{
                    					facing = 2,
                    					tags =
                    					{
                        					"serverFarm",
                    					},
                				},
            				},
            				1,
        			},
    			},
		}

		serverroom_3.units =
		{
    			{
        			maxCount = 5,
        			spawnChance = 1,
        			{
            				{
                				x = 6,
                				y = 8,
                				template = [[console_core]],
                				unitData =
                				{
                    					facing = 0,
                				},
            				},
            				1,
        			},
        			{
            				{
                				x = 1,
                				y = 8,
                				template = [[console]],
                				unitData =
                				{
                    					facing = 0,
                				},
            				},
            				1,
        			},
        			{
            				{
                				x = 11,
                				y = 8,
                				template = [[console]],
                				unitData =
                				{
                    					facing = 4,
                				},
            				},
            				1,
        			},
        			{
            				{
                				x = 6,
                				y = 1,
                				template = [[server_terminal]],
                				unitData =
                				{
                    					facing = 2,
                    					tags =
                    					{
                        					"serverFarm",
                    					},
                				},
            				},
            				1,
        			},
    			},
		}
	end

	function set_servers()
		local serverroom_1 = include( "sim/prefabs/shared/serverroom_1" )
		local serverroom_2 = include( "sim/prefabs/shared/serverroom_2" )
		local serverroom_3 = include( "sim/prefabs/shared/serverroom_3" )

		serverroom_1.units =
		{
    			{
        			maxCount = 5,
        			spawnChance = 1,
        			{
            				{
                				x = 3,
                				y = 5,
                				template = [[extra_server_terminal]],
                				unitData =
                				{
							facing = 0,
						},
            				},
            				1,
        			},
        			{
            				{
                				x = 4,
                				y = 1,
                				template = [[console_core]],
                				unitData =
                				{
							facing = 0,
						},
            				},
            				1,
        			},
        			{
            				{
                				x = 3,
                				y = 3,
                				template = [[console]],
                				unitData =
                				{
                    				facing = 0,
                				},
            				},
            				1,
        			},
        			{
					{
                				x = 5,
                				y = 3,
                				template = [[console]],
                				unitData =
                				{
                    				facing = 4,
                				},
            				},
            				1,
        			},
        			{
            				{
                				x = 5,
                				y = 5,
                				template = [[server_terminal]],
                				unitData =
                				{
                    					facing = 4,
                    					tags =
                    					{
                        					"serverFarm",
                    					},
                				},
            				},
            				1,
				},
			},
		}

		serverroom_2.units =
		{
    			{
        			maxCount = 5,
        			spawnChance = 1,
        			{
					{
                				x = 6,
                				y = 9,
                				template = [[extra_server_terminal]],
                				unitData =
                				{
							facing = 6,
                				},
            				},
            				1,
        			},
        			{
            				{
                				x = 9,
                				y = 6,
                				template = [[console_core]],
                				unitData =
                				{
                    					facing = 0,
                				},
            				},
            				1,
        			},
        			{
            				{
                				x = 7,
                				y = 6,
                				template = [[console]],
                				unitData =
                				{
                    					facing = 0,
                				},
            				},
            				1,
        			},
        			{
            				{
                				x = 5,
                				y = 6,
                				template = [[console]],
                				unitData =
                				{
                    					facing = 4,
                				},
            				},
            				1,
        			},
        			{
            				{
               					x = 6,
                				y = 3,
                				template = [[server_terminal]],
                				unitData =
                				{
                    					facing = 2,
                    					tags =
                    					{
                        					"serverFarm",
                    					},
                				},
            				},
            				1,
        			},
    			},
		}

		serverroom_3.units =
		{
    			{
        			maxCount = 5,
        			spawnChance = 1,
        			{
            				{
                				x = 6,
                				y = 3,
                				template = [[extra_server_terminal]],
                				unitData =
                				{
                    					facing = 6,
                				},
            				},
            				1,
        			},
        			{
            				{
                				x = 6,
                				y = 8,
                				template = [[console_core]],
                				unitData =
                				{
                    					facing = 0,
                				},
            				},
            				1,
        			},
        			{
            				{
                				x = 1,
                				y = 8,
                				template = [[console]],
                				unitData =
                				{
                    					facing = 0,
                				},
            				},
            				1,
        			},
        			{
            				{
                				x = 11,
                				y = 8,
                				template = [[console]],
                				unitData =
                				{
                    					facing = 4,
                				},
            				},
            				1,
        			},
        			{
            				{
                				x = 6,
                				y = 1,
                				template = [[server_terminal]],
                				unitData =
                				{
                    					facing = 2,
                    					tags =
                    					{
                        					"serverFarm",
                    					},
                				},
            				},
            				1,
        			},
    			},
		}
	end

	function update_base_programs()
		local simdefs = include( "sim/simdefs" )
		local mainframe_common = include("sim/abilities/mainframe_common")
		local mainframe_abilities_base = include("sim/abilities/mainframe_abilities")
		local npc_abilities = include("sim/abilities/npc_abilities")
		local DEFAULT_ABILITY = mainframe_common.DEFAULT_ABILITY
		local createDaemon = mainframe_common.createDaemon
		local createReverseDaemon = mainframe_common.createReverseDaemon
		local createCountermeasureInterest = mainframe_common.createCountermeasureInterest

	mainframe_abilities_base.remoteprocessor = util.extend( DEFAULT_ABILITY ) 
	{
		name = STRINGS.PROGEXTEND.PROGRAMS.POWER_DRIP.NAME,
		desc = STRINGS.PROGEXTEND.PROGRAMS.POWER_DRIP.DESC,
		shortdesc = STRINGS.PROGEXTEND.PROGRAMS.POWER_DRIP.SHORT_DESC,
		huddesc = STRINGS.PROGEXTEND.PROGRAMS.POWER_DRIP.HUD_DESC,
		icon = "gui/icons/programs_icons/icon-program-powerdrip.png",
		icon_100 = "gui/icons/programs_icons/store_icons/StorePrograms_drip.png", 
		value = 500,

		passive = true,
		
		executeAbility = function( self, sim )
			local player = sim:getCurrentPlayer()		
			if not player:isNPC() then
				local PWR = 1
				sim:dispatchEvent( simdefs.EV_PLAY_SOUND, cdefs.SOUND_HUD_MAINFRAME_PROGRAM_AUTO_RUN )
				if sim:getTrackerStage( math.min( simdefs.TRACKER_MAXCOUNT, sim:getTracker() )) == 0 then
					PWR = 2
				end
				sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=string.format(STRINGS.PROGEXTEND.PROGRAMS.POWER_DRIP.WARNING,PWR), color=cdefs.COLOR_PLAYER_WARNING, sound = "SpySociety/Actions/mainframe_gainCPU",icon=self.icon } )
				player:addCPUs( PWR )
			end
		end,

		canUseAbility = function( self, sim )
			return false 	
		end,

		onSpawnAbility = function( self, sim )
			DEFAULT_ABILITY.onSpawnAbility( self, sim )	
		end,


		onTrigger = function( self, sim, evType, evData )
			DEFAULT_ABILITY.onTrigger( self, sim, evType, evData )

			if evType == simdefs.TRG_START_TURN then
				self:executeAbility(sim)	
			end
		end,
	}

	mainframe_abilities_base.fusion_17_10 = util.extend( mainframe_abilities_base.fusion_17_10 )
	{
        	value = 500,
	}

	mainframe_abilities_base.seed = util.extend( mainframe_abilities_base.seed )
	{
        	value = 550,
	}

	mainframe_abilities_base.pwr_manager = util.extend( DEFAULT_ABILITY )
	{
		name = STRINGS.PROGRAMS.PWR_MANAGER.NAME,
		desc = STRINGS.PROGEXTEND.PROGRAMS.PWR_MANAGER.DESC,
		huddesc = STRINGS.PROGEXTEND.PROGRAMS.PWR_MANAGER.HUD_DESC,
		shortdesc = STRINGS.PROGEXTEND.PROGRAMS.PWR_MANAGER.SHORT_DESC,
		tipdesc = STRINGS.PROGRAMS.PWR_MANAGER.TIP_DESC,
 		passive = true,
		icon = "gui/icons/programs_icons/Program0019.png",
		icon_100 = "gui/icons/programs_icons/store_icons/StorePrograms_0019.png",
		value = 300,

		canUseAbility = function( self, sim )
			return false 	
		end,

		onSpawnAbility = function( self, sim, player )
			DEFAULT_ABILITY.onSpawnAbility( self, sim )	
            		if not player:getTraits().extraStartingPWR then
            			player:getTraits().extraStartingPWR = 0
            		end
			if not player:getTraits().PWRmaxBouns then
				player:getTraits().PWRmaxBouns = 0
			end
            		player:getTraits().extraStartingPWR = player:getTraits().extraStartingPWR + 4
			player:getTraits().PWRmaxBouns = player:getTraits().PWRmaxBouns + 5
		end,

    		onDespawnAbility = function( self, sim, player )
    			DEFAULT_ABILITY.onDespawnAbility( self, sim )	
			player:getTraits().PWRmaxBouns = player:getTraits().PWRmaxBouns - 5
    		end,
	}

	mainframe_abilities_base.pwr_manager_2 = util.extend( DEFAULT_ABILITY )
	{
		name = STRINGS.PROGRAMS.PWR_MANAGER_2.NAME,
		desc = STRINGS.PROGEXTEND.PROGRAMS.PWR_MANAGER_2.DESC,
		huddesc = STRINGS.PROGEXTEND.PROGRAMS.PWR_MANAGER_2.HUD_DESC,
		shortdesc = STRINGS.PROGEXTEND.PROGRAMS.PWR_MANAGER_2.SHORT_DESC,
		tipdesc = STRINGS.PROGRAMS.PWR_MANAGER_2.TIP_DESC,
 		passive = true,
		icon = "gui/icons/programs_icons/Program0019.png",
		icon_100 = "gui/icons/programs_icons/store_icons/StorePrograms_0019.png",
        	value = 450,

		canUseAbility = function( self, sim )
			return false 	
		end,

		onSpawnAbility = function( self, sim, player )
			DEFAULT_ABILITY.onSpawnAbility( self, sim )	
            		if not player:getTraits().extraStartingPWR then
            			player:getTraits().extraStartingPWR = 0
            		end
			if not player:getTraits().PWRmaxBouns then
				player:getTraits().PWRmaxBouns = 0
			end
            		player:getTraits().extraStartingPWR = player:getTraits().extraStartingPWR + 6
			player:getTraits().PWRmaxBouns = player:getTraits().PWRmaxBouns + 10
		end,

    		onDespawnAbility = function( self, sim, player )
    			DEFAULT_ABILITY.onDespawnAbility( self, sim )	
			player:getTraits().PWRmaxBouns = player:getTraits().PWRmaxBouns - 10
    		end,
	}

	mainframe_abilities_base.sniffer = util.extend( mainframe_abilities_base.sniffer )
	{
        	value = 100,
		maxCooldown = 1
	}

	mainframe_abilities_base.rogue = util.extend( mainframe_abilities_base.rogue )
	{
        	value = 150,
		cpu_cost = 1
	}

	mainframe_abilities_base.root = util.extend( DEFAULT_ABILITY )
	{
		name = STRINGS.PROGRAMS.ROOT.NAME,
		desc = STRINGS.PROGEXTEND.PROGRAMS.ROOT.DESC,
		shortdesc = STRINGS.PROGEXTEND.PROGRAMS.ROOT.SHORT_DESC,
		huddesc = STRINGS.PROGEXTEND.PROGRAMS.ROOT.HUD_DESC,
		icon = "gui/icons/programs_icons/icon-program_Root.png",
		icon_100 = "gui/icons/programs_icons/store_icons/StorePrograms_Root.png",
		value = 600,
		pwrMod = 1,

		passive = true,
		
		onTrigger = function( self, sim, evType, evData )
			if evType == simdefs.TRG_START_TURN and evData:isPC() then
				evData:addCPUs( 2 )
				sim:dispatchEvent( simdefs.EV_PLAY_SOUND, cdefs.SOUND_HUD_MAINFRAME_PROGRAM_AUTO_RUN )
				sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGEXTEND.PROGRAMS.ROOT.WARNING, color=cdefs.COLOR_PLAYER_WARNING, sound = "SpySociety/Actions/mainframe_PWRreverse_off",icon=self.icon } )
			end 
			DEFAULT_ABILITY.onTrigger( self, sim, evType, evData )
		end,

		canUseAbility = function( self, sim )
			return false 	
		end,

		onSpawnAbility = function( self, sim )
			DEFAULT_ABILITY.onSpawnAbility( self, sim )		
		end,

    		onDespawnAbility = function( self, sim, player )
    			DEFAULT_ABILITY.onDespawnAbility( self, sim )
    		end,
	}

	mainframe_abilities_base.faust = util.extend( DEFAULT_ABILITY )
	{
		name = STRINGS.PROGEXTEND.PROGRAMS.FAUST.NAME,
		desc = STRINGS.PROGEXTEND.PROGRAMS.FAUST.DESC,
		huddesc = STRINGS.PROGEXTEND.PROGRAMS.FAUST.HUD_DESC,
		shortdesc = STRINGS.PROGEXTEND.PROGRAMS.FAUST.SHORT_DESC,
		tipdesc = STRINGS.PROGEXTEND.PROGRAMS.FAUST.TIP_DESC,
		lockedText = STRINGS.UI.TEAM_SELECT.UNLOCK_CENTRAL_MONSTER,

		icon = "gui/icons/programs_icons/icon-program-faust.png",
		icon_100 = "gui/icons/programs_icons/store_icons/StorePrograms_faust.png",
		value = 500,
		passive = true,
		
		executeAbility = function( self, sim )
			local player = sim:getCurrentPlayer()			
			sim:dispatchEvent( simdefs.EV_PLAY_SOUND, cdefs.SOUND_HUD_MAINFRAME_PROGRAM_AUTO_RUN )
			sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.PROGRAMS.FAUST.WARNING, color=cdefs.COLOR_PLAYER_WARNING, sound = "SpySociety/Actions/mainframe_gainCPU",icon=self.icon } )
			player:addCPUs( 2 )
		end,

		canUseAbility = function( self, sim )
			return false 	
		end,

		onTrigger = function( self, sim, evType, evData )
			DEFAULT_ABILITY.onTrigger( self, sim, evType, evData )
			if evType == simdefs.TRG_START_TURN and evData:isPC() then
				self:executeAbility(sim)
				if evData:getCpus() % 5 == 0 and sim:getTracker() > 1 then
					local programList = nil
					local daemon = nil
					if sim:isVersion("0.17.5") then
						programList = sim:getIcePrograms()
						daemon = programList:getChoice( sim:nextRand( 1, programList:getTotalWeight() ))
					else
						programList = serverdefs.PROGRAM_LIST
						daemon = programList[sim:nextRand(1, #programList)]			
					end	

					sim:getNPC():addMainframeAbility( sim, daemon )
				end 	
			end
		end,
	}

	mainframe_abilities_base.fool = util.extend( DEFAULT_ABILITY )
	{
		name = STRINGS.PROGRAMS.FOOL.NAME,
		desc = STRINGS.PROGRAMS.FOOL.DESC,
		huddesc = STRINGS.PROGRAMS.FOOL.HUD_DESC,
		shortdesc = STRINGS.PROGRAMS.FOOL.SHORT_DESC,
		tipdesc = STRINGS.PROGRAMS.FOOL.TIP_DESC,

		icon = "gui/icons/programs_icons/icon-program_Jester.png",
		icon_100 = "gui/icons/programs_icons/store_icons/StorePrograms_Jester.png",
		cooldown = 0,
		maxCooldown = 1,
		cpu_cost = 0,
		equip_program = true, 
		equipped = false, 
		value = 100,
		
		onSpawnAbility = function( self, sim, player  )
			DEFAULT_ABILITY.onSpawnAbility( self, sim )	
			player:getTraits().daemonDurationModd = (player:getTraits().daemonDurationModd or 0) + 1
		end,

    		onDespawnAbility = function( self, sim, player )
    			DEFAULT_ABILITY.onDespawnAbility( self, sim )	
           		player:getTraits().daemonDurationModd = (player:getTraits().daemonDurationModd or 0) - 1
    		end,

		executeAbility = function( self, sim, targetUnit )
			DEFAULT_ABILITY.executeAbility(self, sim, targetUnit)			
			targetUnit:processEMP( 1, false, true )

			local programList = nil
			local daemon = nil
			if sim:isVersion("0.17.5") then
				programList = sim:getIcePrograms()
				daemon = programList:getChoice( sim:nextRand( 1, programList:getTotalWeight() ))
			else
				programList = serverdefs.PROGRAM_LIST
				daemon = programList[sim:nextRand(1, #programList)]			
			end	

			sim:getNPC():addMainframeAbility( sim, daemon )			
		end,			
	}

	npc_abilities.energize = util.extend( createReverseDaemon( STRINGS.PROGEXTEND.REVERSE_DAEMONS.FORTUNE ) )
	{
		icon = "gui/icons/daemon_icons/Program0021.png",

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

			for i, unit in pairs(sim:getAllUnits()) do
				if unit:getTraits().safeUnit and unit:getPlayerOwner() ~= sim:getPC() and not unit:getTraits().open and unit:getTraits().mainframe_ice then
					if unit:getTraits().credits then
						unit:getTraits().credits = math.floor(unit:getTraits().credits * 1.5)
					end
				end
			end
			sim:dispatchEvent( simdefs.EV_SHOW_REVERSE_DAEMON, { name = self.name, icon=self.icon, txt = util.sformat(self.activedesc, self.duration ) } )
			sim:addTrigger( simdefs.TRG_END_TURN, self )	
		end,

		onDespawnAbility = function( self, sim )		
			sim:removeTrigger( simdefs.TRG_END_TURN, self )	
			for i, unit in pairs(sim:getAllUnits()) do
				if unit:getTraits().safeUnit and unit:getPlayerOwner() ~= sim:getPC() and not unit:getTraits().open and unit:getTraits().mainframe_ice then					
					if unit:getTraits().credits then
						unit:getTraits().credits = math.floor(unit:getTraits().credits / 1.5)
					end				
				end
			end	
		end,
	
		executeTimedAbility = function( self, sim )
			sim:getNPC():removeAbility(sim, self )
		end,	
	}

	npc_abilities.alertPulse = util.extend( createDaemon( STRINGS.PROGEXTEND.DAEMONS.PULSEV2 ) )
	{
		icon = "gui/icons/daemon_icons/icon-daemon_pulse.png",
		standardDaemon = false,
		reverseDaemon = false,
		premanent = true,

	     	ENDLESS_DAEMONS = true,
	     	PROGRAM_LIST = false,
	     	OMNI_PROGRAM_LIST_EASY = false,
	     	OMNI_PROGRAM_LIST = false,
	     	REVERSE_DAEMONS = false,

		onSpawnAbility = function( self, sim, player )
			local pcplayer = sim:getPC()
			self.items = {}

			sim:dispatchEvent( simdefs.EV_SHOW_DAEMON, { name = self.name, icon=self.icon, txt = self.activedesc, } )	

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
		end,

		onDespawnAbility = function( self, sim, unit )
			for _, item in ipairs(self.items) do
				if item:getTraits().cooldownMax then 
					item:getTraits().cooldownMax = item:getTraits().cooldownMax - 3
				end 
			end
		end,	
	}

	npc_abilities.alertModulate = util.extend( createDaemon( STRINGS.PROGEXTEND.DAEMONS.MODULATEV2 ) )
	{
		icon = "gui/icons/daemon_icons/Daemons00013.png",
		standardDaemon = false,
		reverseDaemon = false,
		premanent = true,

	     	ENDLESS_DAEMONS = true,
	     	PROGRAM_LIST = false,
	     	OMNI_PROGRAM_LIST_EASY = false,
	     	OMNI_PROGRAM_LIST = false,
	     	REVERSE_DAEMONS = false,

		onSpawnAbility = function( self, sim, player )
			sim:dispatchEvent( simdefs.EV_SHOW_DAEMON, { name = self.name, icon=self.icon, txt = self.activedesc, } )
			if not sim:getPC():getTraits().program_cost_modifier then
				sim:getPC():getTraits().program_cost_modifier = 0
			end
            		sim:getPC():getTraits().program_cost_modifier = sim:getPC():getTraits().program_cost_modifier + 2
			sim:addTrigger( simdefs.TRG_END_TURN, self )	
		end,

		onDespawnAbility = function( self, sim )
            		sim:getPC():getTraits().program_cost_modifier = sim:getPC():getTraits().program_cost_modifier - 2
			sim:removeTrigger( simdefs.TRG_END_TURN, self )	
		end,	
	}

	npc_abilities.siphon = util.extend( createDaemon( STRINGS.DAEMONS.SIPHON ) )
	{
		icon = "gui/icons/daemon_icons/Daemons0005.png",

		onSpawnAbility = function( self, sim, player )
			self._cpu = sim:nextRand(2, 5)
			sim:dispatchEvent( simdefs.EV_SHOW_DAEMON, { name = self.name, icon=self.icon, txt = util.sformat(self.activedesc, self._cpu ), } )	

			sim:getCurrentPlayer():addCPUs( -self._cpu )
			sim:getNPC():addCPUs( self._cpu )
			player:removeAbility(sim, self )
		end,

		onDespawnAbility = function( self, sim, unit )
		end,
	}

	npc_abilities.fortify = util.extend( createDaemon( STRINGS.DAEMONS.RUBIKS ) )
	{
		icon = "gui/icons/daemon_icons/Daemons0001.png",

		onSpawnAbility = function( self, sim, player )
			sim:dispatchEvent( simdefs.EV_SHOW_DAEMON, { showMainframe=true, name = self.name, icon=self.icon, txt = self.activedesc, } )	
            		sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 0.5 * cdefs.SECONDS )
			for _, unit in pairs( sim:getAllUnits() ) do
				if unit:getTraits().mainframe_ice and unit:getTraits().mainframe_ice > 0 and unit:getPlayerOwner() ~= sim:getPC() then
					unit:increaseIce(sim,1)
				end
			end
			player:removeAbility(sim, self )
		end,

		onDespawnAbility = function( self, sim, unit )
		end,
	}

	end

	function set_shops()
		store.STORE_ITEM.storeType.server["progAmount"] = 6
		store.STORE_ITEM.storeType["extraserver"] =
		{
			itemAmount = 0, 
			progAmount = 4, 				
			weaponAmount = 0, 
			augmentAmount = 0, 				
			noBreakers = true
		}
	end

	function set_rarity()

		for i=1,33,1 do
			store.STORE_ITEM.progList:removeChoice(1)
		end
		for i=1,7,1 do
			store.STORE_ITEM.progList_17_5:removeChoice(1)
		end
		for i=1,24,1 do
			store.STORE_ITEM.noBreakerProgList:removeChoice(1)
		end
		for i=1,5,1 do
			store.STORE_ITEM.noBreakerProgList_17_5:removeChoice(1)
		end

		store.STORE_ITEM.progList:addChoice( "lockpick_1", 20 )
		store.STORE_ITEM.progList:addChoice( "lockpick_2", 20 )
		store.STORE_ITEM.progList:addChoice( "dagger", 20 )
		store.STORE_ITEM.progList:addChoice( "dagger_2", 20 )
		store.STORE_ITEM.progList:addChoice( "parasite", 20 )
		store.STORE_ITEM.progList:addChoice( "parasite_2", 20 )
		store.STORE_ITEM.progList:addChoice( "rapier", 20 )
		store.STORE_ITEM.progList:addChoice( "dataBlast", 20 )
		store.STORE_ITEM.progList:addChoice( "wrench_2", 10 )
		store.STORE_ITEM.progList:addChoice( "wrench_3", 10 )
		store.STORE_ITEM.progList:addChoice( "wrench_4", 10 )
		store.STORE_ITEM.progList:addChoice( "wrench_5", 10 )
		store.STORE_ITEM.progList:addChoice( "hammer", 10 )
		store.STORE_ITEM.progList:addChoice( "brimstone", 10 )
		store.STORE_ITEM.progList_17_5:addChoice( "mercenary", 10 )
		store.STORE_ITEM.progList_17_5:addChoice( "flare", 5 )
		store.STORE_ITEM.progList_17_5:addChoice( "feast", 5 )

		store.STORE_ITEM.noBreakerProgList:addChoice( "hunter", 20 )
		store.STORE_ITEM.noBreakerProgList:addChoice( "mainframePing", 20 )
		store.STORE_ITEM.noBreakerProgList:addChoice( "esp", 20 )
		store.STORE_ITEM.noBreakerProgList:addChoice( "taurus", 20 )
		store.STORE_ITEM.noBreakerProgList:addChoice( "remoteprocessor", 10 )
		store.STORE_ITEM.noBreakerProgList:addChoice( "emergency_drip", 10 )
		store.STORE_ITEM.noBreakerProgList:addChoice( "fusion_17_10", 10 )
		store.STORE_ITEM.noBreakerProgList:addChoice( "seed", 10 )
		store.STORE_ITEM.noBreakerProgList:addChoice( "sniffer", 10 )
		store.STORE_ITEM.noBreakerProgList:addChoice( "oracle", 10 )
		store.STORE_ITEM.noBreakerProgList:addChoice( "pwr_manager", 10 )
		store.STORE_ITEM.noBreakerProgList:addChoice( "faust", 5 )
		store.STORE_ITEM.noBreakerProgList:addChoice( "wildfire", 5 )
		store.STORE_ITEM.noBreakerProgList:addChoice( "wings", 5 )
		store.STORE_ITEM.noBreakerProgList:addChoice( "shade", 5 )
		store.STORE_ITEM.noBreakerProgList:addChoice( "leash", 5 )
		store.STORE_ITEM.noBreakerProgList:addChoice( "pwr_manager_2", 5 )
		store.STORE_ITEM.noBreakerProgList_17_5:addChoice( "lightning", 20 )
		store.STORE_ITEM.noBreakerProgList_17_5:addChoice( "dynamo", 10 )
		store.STORE_ITEM.noBreakerProgList_17_5:addChoice( "overdrive", 10 )
		store.STORE_ITEM.noBreakerProgList_17_5:addChoice( "charge", 10 )
		store.STORE_ITEM.noBreakerProgList_17_5:addChoice( "root", 10 )
		store.STORE_ITEM.noBreakerProgList_17_5:addChoice( "rogue", 10 )
		store.STORE_ITEM.noBreakerProgList_17_5:addChoice( "halt", 5 )
		store.STORE_ITEM.noBreakerProgList_17_5:addChoice( "fool", 5 )
	end

	function set_rarity_dlc()
		local dlc = include( "dlc1/mainframe_abilities")
		store.STORE_ITEM.progList:addChoice( "golem_17_10", 20 )
		store.STORE_ITEM.noBreakerProgList:addChoice( "bless", 20 )
		store.STORE_ITEM.noBreakerProgList:addChoice( "burst", 10 )
		store.STORE_ITEM.noBreakerProgList:addChoice( "cycle", 10 )
		store.STORE_ITEM.noBreakerProgList:addChoice( "aces", 5 )
	end

	function pcplayer:lockdownMainframeAbility( num )
		local abilitiesTotal = #self:getAbilities()

		if num > abilitiesTotal then return end

		if (#self:getLockedAbilities()) > 0 then 
			for _, abilityNum in ipairs(self._lockedMainframeAbilities) do 
				if abilityNum ~= num then
					table.insert(self._lockedMainframeAbilities, num)
				end
			end 
		else 
			table.insert(self._lockedMainframeAbilities, num) 
		end 
	end 

	function aiplayer:onStartTurn( sim )
		local units = util.tdupe( self._units )
		for i,unit in ipairs( units ) do
			if unit:isValid() then
				unit:onStartTurn( sim )
			end
		end

		if sim:getTags().clearPWREachTurn then			
			self:addCPUs( -self:getCpus( ), sim )
		end

		if sim:getTurnCount() <= 1 then
			local counter_ai = sim:getParams().difficultyOptions.W93_AI or -1
			if ((counter_ai == 0 and (sim:getParams().world == "omni" or sim:getParams().world == "omni2")) or ( counter_ai <= sim:getParams().difficulty and counter_ai > 0 )) then
				sim:getNPC():addMainframeAbility( sim, "W93_AI_assembly", nil, 0 )
			end
		end
	end

	function aiplayer:findMainframeAbility(abilityID)
		local mainframe_abilities = include( "sim/abilities/mainframe_abilities" )
		local npc_abilities = include( "sim/abilities/npc_abilities" )
		local testAbility = mainframe_abilities[abilityID]
		if not testAbility then
			testAbility = npc_abilities[abilityID]
		end
		return testAbility
	end

	function mainframe.canBreakIce( sim, targetUnit, equippedProgram )
		local player = sim:getCurrentPlayer()
    		if player == nil then
        		return false
    		end

    		if sim:getMainframeLockout() then
        		return false, STRINGS.UI.REASON.INCOGNITA_LOCKED_DOWN
    		end

    		if (targetUnit:getTraits().mainframe_ice or 0) <= 0 then
        		return false
    		end

    		if targetUnit:getTraits().isDrone and targetUnit:isKO() then
        		return false
    		end

		if targetUnit:getTraits().mainframe_status == "off" then
        		if not (targetUnit:getTraits().mainframe_camera and targetUnit:getTraits().mainframe_booting) then
            			return false
        		end
		end

		if targetUnit:getTraits().iceImmune then
			return false, STRINGS.PROGEXTEND.UI.JAMMED
		end

		if equippedProgram == nil then
			equippedProgram = player:getEquippedProgram()
		end

		if equippedProgram == nil then 
			return false, STRINGS.UI.REASON.NO_PROGRAM
		end 

		if sim:getCurrentPlayer() == nil or equippedProgram:getCpuCost() > player:getCpus() then
			return false, STRINGS.UI.REASON.NOT_ENOUGH_PWR
		end

		local ok, result = equippedProgram:canUseAbility( sim, player, targetUnit )
		if not ok then
			return result	
		end

		if equippedProgram.sniffer then 
			if not sim:getHideDaemons() and not targetUnit:getTraits().mainframe_program then 
				return false, STRINGS.UI.REASON.NO_DAEMON
			elseif targetUnit:getTraits().daemon_sniffed then 
				return false, STRINGS.UI.REASON.DAEMON_REVEALED
			end
		end

		if equippedProgram.daemon_killer then 
			if not sim:getHideDaemons() and not targetUnit:getTraits().mainframe_program then 
				return false, STRINGS.UI.REASON.NO_DAEMON
			end
		end

		if equippedProgram.wrench then 
			if targetUnit:getTraits().mainframe_ice ~= equippedProgram.break_firewalls then 
				return false, util.sformat( STRINGS.UI.REASON.WRONG_WRENCH, equippedProgram.break_firewalls )
			end 
		end

		local x0, y0 = targetUnit:getLocation()
		for unitID, unit in pairs( sim:getAllUnits() ) do
			local range = unit:getTraits().mainframe_suppress_range
			if range and unit:getPlayerOwner() ~= sim:getPC() and not unit:isKO() and unit:getLocation() and unit ~= targetUnit then
				local distSqr = mathutil.distSqr2d( x0, y0, unit:getLocation() )
				if distSqr <= range * range then
					return false, "nulldrone"
				end
			end
		end

		return true
	end

	local function calculateDiscount( unit, tag, buyback )
		local discount = 1.00
		local penalty = unit:getSim():getPC():getTraits().shopPenalty or 0
		discount = discount + penalty
		local shopperUnit = unit
		if tag == "shop" then
			for _, child in pairs( shopperUnit:getChildren() ) do
				if child:getTraits().shopDiscount then 
					discount = discount - child:getTraits().shopDiscount
				end 
			end  
		end 
		if buyback then
			discount = 0.50
		end
		return discount
	end 

	local function onClickBuyItem( panel, item, itemType )
		local sim = panel._hud._game.simCore	
		local player = panel._unit
		if not panel._unit._isPlayer then	
		 	player = panel._unit:getPlayerOwner()
		end
		if player ~= sim:getCurrentPlayer() then
			modalDialog.show( STRINGS.UI.TOOLTIP_CANT_PURCHASE )
			return
		end

		if item:getTraits().mainframe_program then
			local maxPrograms = simdefs.MAX_PROGRAMS  + (sim:getParams().agency.extraPrograms or 0)
			if #player:getAbilities() >= maxPrograms then
				modalDialog.show( STRINGS.UI.TOOLTIP_PROGRAMS_FULL )
				return
			end		
			if player:hasMainframeAbility( item:getTraits().mainframe_program ) then
				modalDialog.show( STRINGS.UI.TOOLTIP_ALREADY_OWN )
				return
			end
		elseif panel._unit:getInventoryCount() >= 8 then  
			modalDialog.show( STRINGS.UI.TOOLTIP_INVENTORY_FULL )
			return
		end

		local credits = player:getCredits()
		if credits < (item:getUnitData().value * panel._discount) then 
			modalDialog.show( STRINGS.UI.TOOLTIP_NOT_ENOUGH_CREDIT )
			return
		end

		local itemIndex = nil 

		if panel._buyback then 
			if itemType == "item" then 
				itemIndex = array.find( panel._shopUnit.buyback.items, item )
			elseif itemType == "weapon" then 
				itemIndex = array.find( panel._shopUnit.buyback.weapons, item )
			elseif itemType == "augment" then 
				itemIndex = array.find( panel._shopUnit.buyback.augments, item )
			end
		else 
			if itemType == "item" then 
				itemIndex = array.find( panel._shopUnit.items, item )
			elseif itemType == "weapon" then 
				itemIndex = array.find( panel._shopUnit.weapons, item )
			elseif itemType == "augment" then 
				itemIndex = array.find( panel._shopUnit.augments, item )
			end
		end 

		MOAIFmodDesigner.playSound(cdefs.SOUND_HUD_BUY)

		panel._hud._game:doAction( "buyItem", panel._unit:getID(), panel._shopUnit:getID(), itemIndex, panel._discount, itemType, panel._buyback )
		panel.last_action = panel._buyback and "buyback" or "buy"
		panel:refresh()
	end

	local function onClickBuyBack( panel )
		panel._buyback = not panel._buyback
		if panel._buyback then 
			panel._discount = 0.50 
			panel._screen.binder.shop_bg.binder.buybackBtn:setText( STRINGS.UI.SHOP_NANOFAB )
		else
			if panel._unit then 
				panel._discount = calculateDiscount(panel._unit, panel._tag, panel._buyback)
			else 
				panel._discount = 1.00
			end
			panel._screen.binder.shop_bg.binder.buybackBtn:setText( STRINGS.UI.SHOP_BUYBACK )
		end 

		if panel._shopUnit then 
			if #panel._shopUnit.buyback.items == 0  and #panel._shopUnit.buyback.weapons == 0 and #panel._shopUnit.buyback.augments == 0 then  
				if not panel._buyback then 
					panel._screen.binder.shop_bg.binder.buybackBtn:setVisible( false )
				end 
			end 
		end 

		panel.last_action = "buyback"
		panel:refresh()
	end

	local function onClickSellItem( panel, item )
		local modalDialog = include( "states/state-modal-dialog" )
		local result = modalDialog.showYesNo( util.sformat(STRINGS.UI.SHOP_SELL_AREYOUSURE, item:getName(), item:getUnitData().value * 0.5 ), STRINGS.UI.SHOP_SELL_AREYOUSURE_TITLE, nil, STRINGS.UI.SHOP_SELL_CONFIRM, nil, true )
		if result == modalDialog.OK then
			local itemIndex = array.find( panel._unit:getChildren(), item )
			MOAIFmodDesigner.playSound(cdefs.SOUND_HUD_SELL)
			panel._hud._game:doAction( "sellItem", panel._unit:getID(), panel._shopUnit:getID(), itemIndex )
			local buybackBtn = panel._screen.binder.shop_bg.binder.buybackBtn
			buybackBtn:setVisible( true )
			buybackBtn.onClick = util.makeDelegate( nil, onClickBuyBack, panel )
			panel.last_action = "sell"
			panel:refresh()
		end 
	end

	local function onClickClose( panel )
		panel:destroy()
	end

	function shop_panel.shop:init( hud, shopperUnit, shopUnit )
		local items_panel = include( "hud/items_panel" )
		items_panel.base.init( self, hud, shopperUnit, shopUnit:getTraits().storeType )

		self._tag = "shop"
		self._shopUnit = shopUnit
		self._unit = shopperUnit
		self._discount = calculateDiscount( shopperUnit, "shop", nil )

    		local panelBinder = self._screen.binder
		panelBinder.sell.binder.titleLbl:setText(STRINGS.UI.SHOP_SELL)
		panelBinder.headerTxt:spoolText(STRINGS.UI.SHOP_PRINTER)
    		panelBinder.shop_bg.binder.closeBtn.onClick = util.makeDelegate( nil, onClickClose, self )
		panelBinder.shop_bg:setVisible(true)
    		panelBinder.shop:setVisible(true)
		panelBinder.inventory_bg:setVisible(false)
		panelBinder.inventory:setVisible(false)
	end

	function shop_panel.shop:refresh()
    		local panelBinder = self._screen.binder
		self._discount = calculateDiscount(self._unit, "shop", self._buyback)

		local itemCount = 0
		for i, widget in panelBinder.items.binder:forEach( "item" ) do
			if self:refreshItem( widget, i, "item" ) then
				itemCount = itemCount + 1
			end
		end

		for i, widget in panelBinder.weapons.binder:forEach( "item" ) do 
			if self:refreshItem( widget, i, "weapon" ) then
				itemCount = itemCount + 1
			end
		end

		for i, widget in panelBinder.augments.binder:forEach( "item" ) do 
			if self:refreshItem( widget, i, "augment" ) then
				itemCount = itemCount + 1
        		end
		end
 
		local items = {}
		for i,childUnit in ipairs(self._unit:getChildren()) do
			if not childUnit:getTraits().augment or not childUnit:getTraits().installed then
				table.insert(items,childUnit)
			end
		end
		for i, widget in panelBinder.sell.binder:forEach( "item" ) do
			self:refreshUserItem( self._unit, items[i], widget, i )
		end

    		self:refreshCredits()

		if (itemCount == 0 and not self._buyback) or not self._unit:canAct() then
			onClickClose( self )
		end
	end

	function shop_panel.shop:refreshItem( widget, i, itemType )
		local guiex = include( "guiex" )
		local item = nil 
		if self._buyback then 
			if itemType == "item" then 
				item = self._shopUnit.buyback.items[i]
			elseif itemType == "weapon" then 
				item = self._shopUnit.buyback.weapons[i]
			elseif itemType == "augment" then 
				item = self._shopUnit.buyback.augments[i]
			end
		else 
			if itemType == "item" then 
				item = self._shopUnit.items[i]
			elseif itemType == "weapon" then 
				item = self._shopUnit.weapons[i]
			elseif itemType == "augment" then 
				item = self._shopUnit.augments[i]
			end
		end 

		if item == nil then
			widget:setVisible( false )
			return false
		else
        		guiex.updateButtonFromItem( self._screen, nil, widget, item, self._unit )
			widget.binder.itemName:setText( util.toupper(item:getName()) )
			widget.binder.cost:setText( util.sformat( STRINGS.FORMATS.CREDITS, math.ceil(item:getUnitData().value * self._discount ) ))
			widget.binder.btn.onClick = util.makeDelegate( nil, onClickBuyItem, self, item, itemType )
       			widget.binder.btn.onDragStart = util.makeDelegate( self, "onDragFromBottom", item:getUnitData().profile_icon, widget.binder.btn.onClick )
			return true
		end
	end

	function shop_panel.shop:refreshUserItem( unit, item, widget, i )
		local items_panel = include( "hud/items_panel" )
		if items_panel.base.refreshUserItem( self, unit, item, widget, i ) then
			widget.binder.cost:setVisible(true)
			if item:getUnitData().value then 
				widget.binder.cost:setText( util.sformat( STRINGS.FORMATS.PLUS_CREDS, math.ceil(item:getUnitData().value * 0.5) ))
				widget.binder.btn.onClick = util.makeDelegate( nil, onClickSellItem, self, item )
            			widget.binder.btn.onDragStart = util.makeDelegate( self, "onDragSell", item:getUnitData().profile_icon, widget.binder.btn.onClick )
			else
				widget.binder.cost:setText( "" )--STRINGS.UI.SHOP_CANNOT_SELL
				widget.binder.btn:setDisabled( true )
			end
        		return true
    		end
	end

	function mission_util.makeAgentConnection( script, sim )
		local SCRIPTS = include('client/story_scripts')
    		script:waitFor( mission_util.UI_INITIALIZED )
    		script:queue( { type = "hideInterface" })

    		sim:dispatchEvent( simdefs.EV_TELEPORT, { units = sim:getPC():getAgents(), warpOut = false } )		

		local isEndless = sim:getParams().difficultyOptions.maxHours == math.huge

    		local settingsFile = savefiles.getSettings( "settings" )
		if sim:getParams().missionCount == 0 and not isEndless then   
        		script:queue( 1*cdefs.SECONDS )
        		script:queue( { script = SCRIPTS.INGAME.CENTRAL_FIRST_LEVEL, type="modalConversation" } ) 
	    		script:queue( { type = "showInterface" })
	    		script:queue( 0.5*cdefs.SECONDS )
	    		script:queue( { type = "showMissionObjectives" })
    		else
        		script:queue( 1.5*cdefs.SECONDS )
        		script:queue( { type = "showInterface" })
        		script:queue( 0.5*cdefs.SECONDS )
        		script:queue( { type = "showMissionObjectives" })
			script:addHook( mission_util.doAgentBanter )		
		end
		if sim:getParams().difficultyOptions.W93_endless_daemons and sim:getParams().campaignHours then
			if sim:getParams().difficultyOptions.W93_endless_daemons < math.floor(sim:getParams().campaignHours/24) and sim:getParams().maxHours == math.huge then
				local daemon = serverdefs.ENDLESS_DAEMONS[ sim:nextRand(1, #serverdefs.ENDLESS_DAEMONS) ]  
				sim:getNPC():addMainframeAbility(sim, daemon, sim:getNPC(), 0 )
			end
		elseif sim:getParams().endlessAlert then
			local daemon = serverdefs.ENDLESS_DAEMONS[ sim:nextRand(1, #serverdefs.ENDLESS_DAEMONS) ]  
			sim:getNPC():addMainframeAbility(sim, daemon, sim:getNPC(), 0 )
		end
	end
		