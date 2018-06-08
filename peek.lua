local util = include( "modules/util" )
local abilitydefs = include( "sim/abilitydefs" )

local oldPeek = abilitydefs.lookupAbility("peek")
local oldCanUseAbility = oldPeek.canUseAbility

local peek = util.extend(oldPeek)
{
	canUseAbility = function( self, sim, unit )
		if unit:getTraits().blindfold_penalty then
			return false, STRINGS.PROGEXTEND.UI.BLINDFOLD_DESC
		end

		return oldCanUseAbility( self, sim, unit )
	end,
}
return peek
