----------------------------------------------------------------
-- Copyright (c) 2012 Klei Entertainment Inc.
-- All Rights Reserved.
-- SPY SOCIETY.
----------------------------------------------------------------
local metadefs = include( "sim/metadefs" )

-----------------------------------------------------------------

local DLC_INSTALL_REWARD_1 = 
{ 
    unlockType = metadefs.PROGRAM_UNLOCK,
    unlocks = {{ name = 'W93_power_uplink' }, { name = 'W93_fission' }, { name = 'W93_breach' }, { name = 'W93_flail' }}
}

return 
{
	DLC_INSTALL_REWARDS = DLC_INSTALL_REWARD_1,
}