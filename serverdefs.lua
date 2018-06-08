----------------------------------------------------------------
-- Copyright (c) 2012 Klei Entertainment Inc.
-- All Rights Reserved.
-- SPY SOCIETY.
----------------------------------------------------------------
local serverdefs = include( "modules/serverdefs" )


local SELECTABLE_PROGRAMS = 
{
    [1] = -- Power generators
    {
	"W93_power_uplink",
	"W93_fission",
	"W93_nosferatu",   	
    },
    [2] = -- Breakers
    {
    	"W93_breach",
	"W93_flail",
	"W93_rally",	
    },
}

return
{
	SELECTABLE_PROGRAMS = SELECTABLE_PROGRAMS,
}



