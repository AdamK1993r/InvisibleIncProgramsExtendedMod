local simdefs = include( "sim/simdefs" )
local simquery = include( "sim/simquery" )
local cdefs = include( "client_defs" )
local array = include( "modules/array" )
local util = include( "modules/util" )
local serverdefs = include( "modules/serverdefs" )
local mathutil = include( "modules/mathutil" )
local simfactory = include( "sim/simfactory" )
local alarm_states = include( "sim/alarm_states" )
--------------------------------------------------------------------------
-- Base class alarm handler

local alarm_handler = alarm_states.alarm_handler
local buildAlarmSpeech =  alarm_states.buildAlarmSpeech
local alarm_level_tips = 
{
	activateCameras = STRINGS.PROGEXTEND.UI.ALARM_NEXT_OWL,
	W93_speed = STRINGS.PROGEXTEND.UI.ALARM_NEXT_SPEED,
	W93_owl_speed = STRINGS.PROGEXTEND.UI.ALARM_NEXT_OWL_SPEED,
	W93_ko_armor = STRINGS.PROGEXTEND.UI.ALARM_NEXT_GUARDBUFFS,
	W93_reboot = STRINGS.PROGEXTEND.UI.ALARM_NEXT_REBOOT,
	W93_lockdown = STRINGS.PROGEXTEND.UI.ALARM_NEXT_LOCKDOWN,
}
--------------------------------------------------------------------------
-- Alarm functions

--Alarm Level 4 Normal
local activateCameras = class( alarm_handler )

function activateCameras:init( sim, stage )
	alarm_handler.init( self, sim, stage )
	local numCameras = simdefs.TRACKER_CAMERAS[stage]

	sim:forEachUnit(
	    function( cameraUnit ) 
		    if cameraUnit:getTraits().mainframe_camera and numCameras > 0 then 
                	numCameras = numCameras - 1
			cameraUnit:deactivate( sim )
			cameraUnit:getTraits().mainframe_status = "off" -- Because we don't want them hackable.
		    end 
	    end ) 
end

function activateCameras:executeAlarm( sim, stage )

	sim:dispatchEvent( simdefs.EV_SHOW_ALARM,
        { txt = string.format( STRINGS.UI.ALARM_LEVEL_NUM, stage ),
          txt2 = string.format( util.sformat(STRINGS.PROGEXTEND.UI.ALARM_OWL,stage) ),
          stage = stage,
          speech = buildAlarmSpeech(math.min(stage,6), "CAMERAS"),
        } ) 
	sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 30 )

	if stage == 4 then
		sim:getNPC():addMainframeAbility( sim, "W93_owlV2", nil, 0 )
	end

	for _, cameraUnit in pairs( sim:getAllUnits() ) do
		if cameraUnit:getTraits().mainframe_camera and cameraUnit:getTraits().mainframe_status =="off" and
		not cameraUnit:getTraits().mainframe_booting and not cameraUnit:getTraits().dead then
			cameraUnit:getTraits().mainframe_status_old = "active"
			cameraUnit:getTraits().mainframe_booting = 1
			sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = cameraUnit } )
		end
	end
end


--Alarm Level 4 DLC
local W93_owl_speed = class( alarm_handler )

function W93_owl_speed:executeAlarm( sim, stage )

	sim:dispatchEvent( simdefs.EV_SHOW_ALARM,
        { txt = string.format( STRINGS.UI.ALARM_LEVEL_NUM, stage ),
          txt2 = string.format( STRINGS.PROGEXTEND.UI.ALARM_OWL_SPEED ),
          stage = stage,
          speech =  buildAlarmSpeech(math.min(stage,6)),
        } ) 
	sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 30 )
	sim:getNPC():addMainframeAbility( sim, "W93_owlV2", nil, 0 )
	sim:getNPC():addMainframeAbility( sim, "W93_alertV2", nil, 0 )
end

-- Alarm Level 5
local spawnEnforcers = class( alarm_handler )

function spawnEnforcers:executeAlarm( sim, stage )
	local npcPlayer = sim:getNPC()
	local spawnCount = 1

	if stage >= 6 then
		spawnCount = 2
	end
	sim:addEnforcerWavesSpawned( spawnCount )
  
	sim:dispatchEvent( simdefs.EV_SHOW_ALARM,
	{ txt = string.format( STRINGS.UI.ALARM_LEVEL_NUM, stage ),
	  txt2 = util.sformat( STRINGS.UI.ALARM_ENFORCERS, spawnCount, math.min(sim:getEnforcerWavesSpawned(),2) ),
	  stage = stage,
	  speech = buildAlarmSpeech(math.min(stage,6), "ENFORCERS"),
	} )	

	if sim._params.difficulty < 3 then
		for i=1,spawnCount do 
			npcPlayer:doTrackerSpawn(sim, 1, simdefs.TRACKER_SPAWN_UNIT_ENFORCER )
		end  
	else
		for i=1,spawnCount do 
			npcPlayer:doTrackerSpawn(sim, 1, simdefs.TRACKER_SPAWN_UNIT_ENFORCER_2 )
		end  
	end

	if sim:getEnforcerWavesSpawned() < 3 then
		for _, unit in ipairs(npcPlayer:getUnits() ) do
			if unit:getBrain() and not unit:getTraits().enforcer then
				if not unit:isAlerted() then
					unit:setAlerted(true)
					npcPlayer:joinEnforcerHuntSituation(unit)
				else
					npcPlayer:joinEnforcerHuntSituation(unit, unit:getBrain():getInterest() )
  				end
			end
		end
	end
	npcPlayer:huntAgents( math.min(sim:getEnforcerWavesSpawned(),2) )
end

--Alarm Level 6 Normal
local W93_speed = class( alarm_handler )

function W93_speed:executeAlarm( sim, stage )
	local npcPlayer = sim:getNPC()
	local spawnCount = 1

	if stage >= 6 then
		spawnCount = 2
	end
	sim:addEnforcerWavesSpawned( spawnCount )

	sim:dispatchEvent( simdefs.EV_SHOW_ALARM,
        { txt = string.format( STRINGS.UI.ALARM_LEVEL_NUM, stage ),
          txt2 = string.format( STRINGS.PROGEXTEND.UI.ALARM_SPEED ),
          stage = stage,
          speech =  buildAlarmSpeech(math.min(stage,6),"ENFORCERS"),
        } ) 
	sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 30 )

	if sim._params.difficulty < 3 then
		for i=1,spawnCount do 
			npcPlayer:doTrackerSpawn(sim, 1, simdefs.TRACKER_SPAWN_UNIT_ENFORCER )
		end  
	else
		for i=1,spawnCount do 
			npcPlayer:doTrackerSpawn(sim, 1, simdefs.TRACKER_SPAWN_UNIT_ENFORCER_2 )
		end  
	end

	if sim:getEnforcerWavesSpawned() < 3 then
		for _, unit in ipairs(npcPlayer:getUnits() ) do
			if unit:getBrain() and not unit:getTraits().enforcer then
				if not unit:isAlerted() then
					unit:setAlerted(true)
					npcPlayer:joinEnforcerHuntSituation(unit)
				else
					npcPlayer:joinEnforcerHuntSituation(unit, unit:getBrain():getInterest() )
  				end
			end
		end
	end
	npcPlayer:huntAgents( math.min(sim:getEnforcerWavesSpawned(),2) )

	sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 30 )

	sim:getNPC():addMainframeAbility( sim, "W93_alertV2", nil, 0 )
end

--Alarm Level 6 DLC
local W93_ko_armor = class( alarm_handler )

function W93_ko_armor:executeAlarm( sim, stage )
	local npcPlayer = sim:getNPC()
	local spawnCount = 1

	if stage >= 6 then
		spawnCount = 2
	end
	sim:addEnforcerWavesSpawned( spawnCount )


	sim:dispatchEvent( simdefs.EV_SHOW_ALARM,
        { txt = string.format( STRINGS.UI.ALARM_LEVEL_NUM, stage ),
          txt2 = string.format( STRINGS.PROGEXTEND.UI.ALARM_GUARDBUFF ),
          stage = stage,
          speech =  buildAlarmSpeech(math.min(stage,6),"GUARD_BUFF_KO"),
        } ) 
	sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 30 )

	for i,unit in ipairs(npcPlayer:getUnits()) do
		if unit:isKO() then
			unit:tickKO( sim )
		end   
	end

	sim:getNPC():addMainframeAbility( sim, "shockAlarm", nil, 0 )
	sim:getNPC():addMainframeAbility( sim, "chitonAlarm", nil, 0 )

	if sim._params.difficulty < 3 then
		for i=1,spawnCount do 
			npcPlayer:doTrackerSpawn(sim, 1, simdefs.TRACKER_SPAWN_UNIT_ENFORCER )
		end  
	else
		for i=1,spawnCount do 
			npcPlayer:doTrackerSpawn(sim, 1, simdefs.TRACKER_SPAWN_UNIT_ENFORCER_2 )
		end  
	end

	if sim:getEnforcerWavesSpawned() < 3 then
		for _, unit in ipairs(npcPlayer:getUnits() ) do
			if unit:getBrain() and not unit:getTraits().enforcer then
				if not unit:isAlerted() then
					unit:setAlerted(true)
					npcPlayer:joinEnforcerHuntSituation(unit)
				else
					npcPlayer:joinEnforcerHuntSituation(unit, unit:getBrain():getInterest() )
  				end
			end
		end
	end
	npcPlayer:huntAgents( math.min(sim:getEnforcerWavesSpawned(),2) )
end

-- Alarm Level 7
local W93_reboot = class ( alarm_handler )

function W93_reboot:executeAlarm( sim, stage )
	local reebots = 30
	if sim._params.difficulty < 3 then
		reebots = 15
	end

	sim:dispatchEvent( simdefs.EV_SHOW_ALARM,
	{ txt = string.format( STRINGS.UI.ALARM_LEVEL_NUM, stage ),
	  txt2 = string.format( STRINGS.PROGEXTEND.UI.ALARM_REBOOT, reebots ),
	  stage = stage,
	  speech = buildAlarmSpeech(math.min(stage,6)),
	} )

	sim:triggerEvent(simdefs.TRG_RECAPTURE_DEVICES, { reboots = reebots } )
end

-- Alarm Level 8
local W93_lockdown = class( alarm_handler )

function W93_lockdown:executeAlarm( sim, stage )
	local npcPlayer = sim:getNPC()
	local spawnCount = 1

	if stage >= 6 then
		spawnCount = 2
	end
	sim:addEnforcerWavesSpawned( spawnCount )
  
	sim:dispatchEvent( simdefs.EV_SHOW_ALARM,
	{ txt = string.format( STRINGS.UI.ALARM_LEVEL_NUM, stage ),
	  txt2 = util.sformat( STRINGS.PROGEXTEND.UI.ALARM_LOCKDOWN, spawnCount, math.min(sim:getEnforcerWavesSpawned(),2) ),
	  stage = stage,
	  speech = buildAlarmSpeech(math.min(stage,6),"ENFORCERS"),
	} )	

	if sim._params.difficulty < 3 then
		for i=1,spawnCount do 
			npcPlayer:doTrackerSpawn(sim, 1, simdefs.TRACKER_SPAWN_UNIT_ENFORCER )
		end  
	else
		for i=1,spawnCount do 
			npcPlayer:doTrackerSpawn(sim, 1, simdefs.TRACKER_SPAWN_UNIT_ENFORCER_2 )
		end  
	end

	if sim:getEnforcerWavesSpawned() < 3 then
		for _, unit in ipairs(npcPlayer:getUnits() ) do
			if unit:getBrain() and not unit:getTraits().enforcer then
				if not unit:isAlerted() then
					unit:setAlerted(true)
					npcPlayer:joinEnforcerHuntSituation(unit)
				else
					npcPlayer:joinEnforcerHuntSituation(unit, unit:getBrain():getInterest() )
  				end
			end
		end
	end
	npcPlayer:huntAgents( math.min(sim:getEnforcerWavesSpawned(),2) )
	sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 30 )
	sim:getNPC():addMainframeAbility( sim, "W93_lockdownV2", nil, 0 )
end

return
{
	alarm_level_tips = alarm_level_tips,
	cameras = activateCameras,
	W93_speed = W93_speed,
	W93_owl_speed = W93_owl_speed,
	W93_ko_armor = W93_ko_armor,
	enforcers = spawnEnforcers,
	W93_reboot = W93_reboot,
	W93_lockdown = W93_lockdown,
}
