local hud = include( "hud/hud" )
local simdefs = include( "sim/simdefs" )
local simquery = include( "sim/simquery" )
local oldCreateHud = hud.createHud

hud.createHud = function( ... )
	local hudObject = oldCreateHud( ... )

    	local oldRefreshHud = hudObject.refreshHud
    	local oldOnSimEvent = hudObject.onSimEvent

	local function refreshTrackerMusic( hud, stage )
		stage = math.max( stage or 0, hud._musicStage or 0 )
		local isClimax = stage >= simdefs.TRACKER_MAXSTAGE or hud._game.simCore:getClimax()

		if not isClimax then
			for i, unit in pairs( hud._game.simCore:getPC():getAgents() ) do
				if simquery.isUnitUnderOverwatch( unit ) then
					isClimax = true
					break
				end
			end
		end

		MOAIFmodDesigner.setMusicProperty("intensity", math.min(stage,6) )
		if isClimax then
			MOAIFmodDesigner.setMusicProperty("kick",1)
    		else
			MOAIFmodDesigner.setMusicProperty("kick",0)
		end

		hud._musicStage = stage
	end

    	function hudObject:refreshHud()
        	oldRefreshHud( self )
        	refreshTrackerMusic( self )
    	end

    	function hudObject:onSimEvent( ev )
        	oldOnSimEvent( self, ev )
        	if ev.eventType == simdefs.EV_ADVANCE_TRACKER or ev.eventType == "used_radio" then
            		refreshTrackerMusic( self )
        	end
    	end

    	return hudObject
end