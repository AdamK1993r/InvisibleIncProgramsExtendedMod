----------------------------------------------------------------
-- Copyright (c) 2012 Klei Entertainment Inc.
-- All Rights Reserved.
-- SPY SOCIETY.
----------------------------------------------------------------

local util = include( "modules/util" )
local array = include( "modules/array" )
local unitdefs = include( "sim/unitdefs" )
local simunit = include( "sim/simunit" )
local simdefs = include( "sim/simdefs" )
local simquery = include( "sim/simquery" )
local simfactory = include( "sim/simfactory" )
local inventory = include( "sim/inventory" )
-----------------------------------------------------
-- Grenade item

local W93_translocator_grenade = { ClassType = "W93_translocator_grenade" }

function W93_translocator_grenade:throw( throwingUnit, targetCell )
	local sim = self:getSim()
	local player = throwingUnit:getPlayerOwner()
	local x0, y0 = throwingUnit:getLocation()

    	assert( player )
	self:setPlayerOwner(player)
	
	sim:dispatchEvent( simdefs.EV_UNIT_THROWN, { unit = self, x=targetCell.x, y=targetCell.y } )

	if x0 ~= targetCell.x or y0 ~= targetCell.y then
		sim:warpUnit(self, targetCell)
	end

    	self:getTraits().throwingUnit = throwingUnit:getID()
    	self:getTraits().cooldown = self:getTraits().cooldownMax or 0

    	self:activate( throwingUnit, targetCell )

    	if self:getTraits().keepPathing == false and throwingUnit:getBrain() then
    		throwingUnit:useMP(throwingUnit:getMP(), sim)
    	end

	sim:processReactions()
end

function W93_translocator_grenade:activate( throwingUnit, targetCell )
	assert( not self:getTraits().deployed )
	local sim = self:getSim()

	self:getTraits().deployed = true

	if self:getTraits().guardBeacon and throwingUnit and targetCell and targetCell.impass <= 0 and not sim:getQuery().checkDynamicImpass(sim, targetCell) then
		sim:dispatchEvent( simdefs.EV_UNIT_APPEARED, { unitID = throwingUnit:getID(), noSightingFx=true } )
		sim:dispatchEvent( simdefs.EV_TELEPORT, { units={throwingUnit}, warpOut =true } )
		sim:warpUnit( throwingUnit, targetCell )
		sim:dispatchEvent( simdefs.EV_UNIT_APPEARED, { unitID = throwingUnit:getID(), noSightingFx=true } )
		sim:dispatchEvent( simdefs.EV_TELEPORT, { units={throwingUnit}, warpOut =false } )
		sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = throwingUnit } )
		inventory.pickupItem( sim, throwingUnit, self )
		sim:dispatchEvent( simdefs.EV_UNIT_PICKUP, { unitID = throwingUnit:getID() } )
		sim:processReactions( throwingUnit )
	elseif self:getTraits().guardBeacon and throwingUnit and targetCell and (targetCell.impass > 0 or sim:getQuery().checkDynamicImpass(sim, targetCell)) then
		local x0, y0 = throwingUnit:getLocation()
		local cell = sim:getCell( x0, y0 )
		sim:dispatchEvent( simdefs.EV_TELEPORT, { units={self}, warpOut =true } )
		sim:warpUnit( self, cell )
		sim:dispatchEvent( simdefs.EV_TELEPORT, { units={self}, warpOut =false } )
		inventory.pickupItem( sim, throwingUnit, self )
		sim:dispatchEvent( simdefs.EV_UNIT_PICKUP, { unitID = throwingUnit:getID() } )
	elseif self:getTraits().guardBeacon and not throwingUnit then
		self:deactivate()
 		sim:warpUnit(self, nil)
		sim:despawnUnit( self )
		for i, player in ipairs(sim:getPlayers()) do			
			player:glimpseUnit(sim, unitID)
		end
	end

	if self:getTraits().snareGrenade and self:getTraits().explodes then
		if self:getTraits().explodes <= 0 then
			local cells = self:getExplodeCells()
			sim:dispatchEvent( simdefs.EV_UNIT_ACTIVATE, { unit = self, cells=cells } )
			self:explode()
		else
			local cells = self:getExplodeCells()
			self:getTraits().timer = self:getTraits().explodes
			sim:addTrigger( simdefs.TRG_START_TURN, self )
			sim:addTrigger( simdefs.TRG_UNIT_PICKEDUP, self )
			sim:dispatchEvent( simdefs.EV_UNIT_ACTIVATE, { unit = self, cells=cells } )
        		sim:triggerEvent( simdefs.TRG_UNIT_DEPLOYED, { unit = self })
		end
	end
end

function W93_translocator_grenade:deactivate()
	self:getTraits().deployed = nil
	local sim = self:getSim()

	if self:getTraits().explodes == nil then
		sim:removeTrigger( simdefs.TRG_UNIT_PICKEDUP, self )
	elseif self:getTraits().explodes > 0 then
		sim:removeTrigger( simdefs.TRG_START_TURN, self )
		sim:removeTrigger( simdefs.TRG_UNIT_PICKEDUP, self )
	end

	sim:dispatchEvent( simdefs.EV_UNIT_DEACTIVATE, { unit = self } )
end

function W93_translocator_grenade:onExplode( cells )
	local sim = self:getSim()
	local targetCell = sim:getCell( self:getLocation() )
	if self:getTraits().snareGrenade and targetCell and targetCell.impass <= 0 and not sim:getQuery().checkDynamicImpass(sim, targetCell) then
		local target = nil
		for i, cell in ipairs(cells) do
			for i, cellUnit in ipairs( cell.units ) do
				if cellUnit:getTraits().isAgent and not cellUnit:getTraits().isGuard and targetCell.impass <= 0 and not sim:getQuery().checkDynamicImpass(sim, targetCell) then
					sim:dispatchEvent( simdefs.EV_UNIT_APPEARED, { unitID = cellUnit:getID(), noSightingFx=true } )
					sim:dispatchEvent( simdefs.EV_TELEPORT, { units={cellUnit}, warpOut =true } )
					sim:warpUnit( cellUnit, targetCell )
					sim:dispatchEvent( simdefs.EV_UNIT_APPEARED, { unitID = cellUnit:getID(), noSightingFx=true } )
					sim:dispatchEvent( simdefs.EV_TELEPORT, { units={cellUnit}, warpOut =false } )
					sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = cellUnit } )
					break
				end
			end
		end
	end
end

function W93_translocator_grenade:explode()
	assert( self:getTraits().deployed )

	local sim = self:getSim()
	local x, y = self:getLocation()
	local cells = self:getExplodeCells()
	sim:dispatchEvent(simdefs.EV_GRENADE_EXPLODE, { unit = self, cells = cells } )

	if self.onExplode then
        	self:onExplode(cells)
	end

	self:deactivate()
	local unitID = self:getID()
 	sim:warpUnit(self, nil)
	sim:despawnUnit( self )

	for i,player in ipairs(sim:getPlayers()) do			
		player:glimpseUnit(sim, unitID)
	end
end

function W93_translocator_grenade:getExplodeCells()
	local sim = self:getSim()
	local x0, y0 = self:getLocation()
	local currentCell = sim:getCell( x0, y0 )
	local cells = {currentCell}
	if self:getTraits().range then
		local fillCells = simquery.fillCircle( sim, x0, y0, self:getTraits().range, 0)

		for i, cell in ipairs(fillCells) do
			if cell ~= currentCell then
				local raycastX, raycastY = sim:getLOS():raycast(x0, y0, cell.x, cell.y)
				if raycastX == cell.x and raycastY == cell.y then
					table.insert(cells, cell)
				end
			end
		end
	end
	return cells
end

function W93_translocator_grenade:onWarp( sim, oldcell, cell)
	if not oldcell and cell then
		sim:addTrigger( simdefs.TRG_UNIT_WARP, self )
	elseif not cell and oldcell then
		sim:removeTrigger( simdefs.TRG_UNIT_WARP, self )
	end
end

function W93_translocator_grenade:onTrigger( sim, evType, evData )
	if evType == simdefs.TRG_UNIT_PICKEDUP and evData.item == self then
		self:deactivate()
	elseif evType == simdefs.TRG_UNIT_WARP and evData.unit ~= self then
		local x0,y0 = self:getLocation()

		if evData.to_cell == sim:getCell(self:getLocation()) or evData.from_cell == sim:getCell(self:getLocation()) then
			if evData.unit:getTraits().isAgent then
				sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = self } )
			end
		end
	elseif evType == simdefs.TRG_START_TURN then
		if evData:isNPC() and self:getTraits().timer then
            		self:getTraits().timer = self:getTraits().timer - 1
            		if self:getTraits().timer <= 0 then
                		self:explode()
            		end
		end
	end
end
-----------------------------------------------------
-- Interface functions

local function createGrenade( unitData, sim )
	return simunit.createUnit( unitData, sim, W93_translocator_grenade )
end

simfactory.register( createGrenade )

return
{
	createGrenade = createGrenade,
}


