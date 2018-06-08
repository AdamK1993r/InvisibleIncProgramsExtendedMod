local util = include( "modules/util" )
local simdefs = include( "sim/simdefs" )
local simquery = include( "sim/simquery" )
local abilitydefs = include( "sim/abilitydefs" )

local oldJackin = abilitydefs.lookupAbility("jackin")
local oldExecuteAbility = oldJackin.executeAbility

local jackin = util.extend(oldJackin)
{
	onTooltip = function( self, hud, sim, abilityOwner, abilityUser, targetUnitID )
		local tooltip = util.tooltip( hud._screen )
		local section = tooltip:addSection()
		local canUse, reason = abilityUser:canUseAbility( sim, self, abilityOwner, targetUnitID )		
		local targetUnit = sim:getUnit( targetUnitID )
	        section:addLine( targetUnit:getName() )
		if (targetUnit:getTraits().cpus or 0) > 0 then
			if abilityOwner:getTraits().PWR_conversion then 
				section:addAbility( self:getName(sim, abilityOwner, abilityUser, targetUnitID),
				util.sformat(STRINGS.PROGEXTEND.UI.HIJACK_CONSOLE_DESC_CONVERT_TO_CRED, abilityOwner:getName()), "gui/items/icon-action_hack-console.png" )
			else
				section:addAbility( self:getName(sim, abilityOwner, abilityUser, targetUnitID),
				STRINGS.PROGEXTEND.UI.HIJACK_CONSOLE_DESC, "gui/items/icon-action_hack-console.png" )
			end
		end
		if reason then
			section:addRequirement( reason )
		end
		return tooltip
	end,
}
return jackin