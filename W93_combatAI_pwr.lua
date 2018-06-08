local array = include( "modules/array" )
local util = include( "modules/util" )
local cdefs = include( "client_defs" )
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local inventory = include("sim/inventory")
local abilityutil = include( "sim/abilities/abilityutil" )
local speechdefs = include("sim/speechdefs")
local mathutil = include( "modules/mathutil" )

local W93_combatAI_pwr =
{
	name = STRINGS.PROGEXTEND.UI.AI_PWR,
        proxy = true,

	onTooltip = function( self, hud, sim, abilityOwner, abilityUser, targetUnitID )
		local tooltip = util.tooltip( hud._screen )
		local section = tooltip:addSection()
		local canUse, reason = abilityUser:canUseAbility( sim, self, abilityOwner, targetUnitID )		
	        section:addLine( STRINGS.PROGEXTEND.UI.AI_COMBAT )
		section:addAbility( STRINGS.PROGEXTEND.UI.AI_PWR, string.format(STRINGS.PROGEXTEND.UI.AI_PWR_DESC, math.max((abilityOwner:getSkillLevel( "hacking" )-3)*2,0)), self.profile_icon )
		section:addAbility( STRINGS.PROGEXTEND.UI.AI_SKILL, STRINGS.PROGEXTEND.UI.AI_SKILL_PWR, "gui/icons/skills_icons/skills_icon_small/icon-item_analyze_small.png" )
		if reason then
			section:addRequirement( reason )
		end
		return tooltip
	end,

	getName = function( self, sim, abilityOwner, abilityUser, targetUnitID )
		return string.format( STRINGS.PROGEXTEND.UI.AI_COMBAT)
	end,
		
	profile_icon = "gui/icons/action_icons/Action_icon_Small/icon-action_chargeweapon_small.png",

        getProfileIcon = function( self, sim, abilityOwner )
		return self.profile_icon
        end,

	isTarget = function( self, abilityOwner, unit, targetUnit )
		if not targetUnit:getTraits().mainframe_console then
			return false
		end

		if targetUnit:getTraits().mainframe_status ~= "active" then
			return false
		end

		return true
	end,

	acquireTargets = function( self, targets, game, sim, abilityOwner, unit )
		local x0, y0 = unit:getLocation()
		local units = {}
		for _, targetUnit in pairs(sim:getAllUnits()) do
			local x1, y1 = targetUnit:getLocation()
			if x1 and self:isTarget( abilityOwner, unit, targetUnit ) and sim:getNPC():findMainframeAbility("W93_AI_assembly") and sim:getNPC():hasMainframeAbility("W93_AI_assembly") then
				local range = mathutil.dist2d( x0, y0, x1, y1 )
				if range <= 1 and simquery.isConnected( sim, sim:getCell( x0, y0 ), sim:getCell( x1, y1 ) ) then
					table.insert( units, targetUnit )
				end
			end
		end

		return targets.unitTarget( game, units, self, abilityOwner, unit )
	end,

	canUseAbility = function( self, sim, abilityOwner, unit, targetUnitID )
		if abilityOwner ~= unit and abilityOwner:getUnitOwner() ~= unit then
			return false
		end

		if (abilityOwner:getSkillLevel( "hacking" ) or 0) < 3 then
			return false, string.format( STRINGS.UI.TOOLTIP_REQUIRES_SKILL_LVL, "HACKING", 3 )
		end

		local targetUnit = sim:getUnit( targetUnitID )
		if targetUnit then
			assert( self:isTarget( abilityOwner, unit, targetUnit ))
			if targetUnit:getTraits().mainframe_console_lock > 0 then
				return false, STRINGS.UI.REASON.CONSOLE_LOCKED
			end
			if not targetUnit:getTraits().hijacked then
				return false, STRINGS.PROGEXTEND.UI.REASON_NOT_HIJACKED
			end

			local dir = targetUnit:getFacing()
			local x0, y0 = targetUnit:getLocation()
			local x1, y1 = simquery.getDeltaFromDirection(dir)
			local consoleFront = sim:getCell( x0 + x1, y0 + y1 )

			if consoleFront ~= sim:getCell(abilityOwner:getLocation()) then
				return false, STRINGS.PROGEXTEND.UI.REASON_DIRECTION
			end
		end
		return abilityutil.checkRequirements( abilityOwner, unit )
	end,

	executeAbility = function( self, sim, abilityOwner, unit, targetUnitID )
		sim:emitSpeech( unit, speechdefs.EVENT_HIJACK )
		local targetUnit = sim:getUnit( targetUnitID )
		local x1, y1 = targetUnit:getLocation()
    		local x0,y0 = unit:getLocation()
		local facing = simquery.getDirectionFromDelta( x1 - x0, y1 - y0 )
		sim:dispatchEvent( simdefs.EV_UNIT_USECOMP, { unitID = unit:getID(), targetID = targetUnit:getID(), facing = facing, sound = "SpySociety/Actions/monst3r_jackin" , soundFrame = 16, useTinker=true } )
            	sim:triggerEvent(simdefs.TRG_UNIT_HIJACKED, { unit = targetUnit, sourceUnit = unit, action = "pwr" } )
		sim:getNPC():addCPUs( -5 )
		sim:getPC():addCPUs( math.max( (abilityOwner:getSkillLevel( "hacking" ) -3)*2,0), sim, x1, y1 )
		sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60*0.65)
		targetUnit:processEMP( 4 )
		sim:processReactions( abilityOwner )
		sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = targetUnit } )
	end
}

return W93_combatAI_pwr