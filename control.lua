local myGlobal = require("__nco-LongWarehouses__/lib/nco_data")
local lib_warehouse = require("__nco-LongWarehouses__/lib/lib_warehouse")
local data_util = require("__nco-LongWarehouses__/lib/data_util")
local ghost_util = require("__nco-LongWarehouses__/lib/ghost_util")
local myControl = {}
-------------------------------------------------------------------------------------
ghost_util.init(nil,nil,nil)
-------------------------------------------------------------------------------------
local function debugMsg(msg)
	if game then
		game.players[1].print(msg)
		if game.players[2] then
			game.players[2].print(msg)
		end
	end
	log(msg)
end
-------------------------------------------------------------------------------------
--Enable Recipes if tech researched ( usefull if an update added new WH types)
-------------------------------------------------------------------------------------
function myControl.script_on_configuration_changed()
	data_util.reload_tech_unlock("nco-LongWarehouses")
	data_util.reload_tech_unlock("nco-LongWarehousesLogistics1")
	data_util.reload_tech_unlock("nco-LongWarehousesLogistics2")
end
-------------------------------------------------------------------------------------
-- All the things to control the things
-------------------------------------------------------------------------------------
function myControl.validate_warehouses()
	debugMsg("myControl.validate_warehouses")
	myControl.validate_warehouse_member("warehouse-signal-pole")
	for _, whBase in pairs(myGlobal["RegisteredWarehouses"]) do
		myControl.validate_warehouse_member(whBase.."-proxy")
		myControl.validate_warehouse_member(whBase.."-h")
		myControl.validate_warehouse_member(whBase.."-v")
	end
end
-------------------------------------------------------------------------------------
function myControl.validate_warehouse_member(subEntityName)
	debugMsg("validating " .. subEntityName)
	for _, surface in pairs(game.surfaces) do
		if not surface or not surface.valid then
			debugMsg("invalid surface")
			break
		end
		local searchResult
		searchResult = surface.find_entities_filtered({force = force, name = subEntityName})
		debugMsg("found " .. tostring(#searchResult) .. " entities")
		for _, ent in pairs(searchResult) do
			myControl.validate_warehouse(ent.position,ent.force,ent.surface,false)
		end
		searchResult = surface.find_entities_filtered({force = force, ghost_name = subEntityName})
		debugMsg("found " .. tostring(#searchResult) .. " entity-ghosts")
		for _, ent in pairs(searchResult) do
			myControl.validate_warehouse(ent.position,ent.force,ent.surface,false)
		end
	end
end
-------------------------------------------------------------------------------------
function myControl.validate_warehouse(position,force,surface,deconstructing)
	debugMsg("validating warehouse composite entity")
	local last_user
	local searchResult
	local whEntityType
	local whType
	local poleEntity
	local poleEntityType
	searchResult = surface.find_entities_filtered({force = force, position = position, radius = 0.001})
	for _,ent in pairs(searchResult) do
		local _baseType
		local _entityName
		_baseType, _entityName = lib_warehouse.checkEntity(ent)
		if data_util.has_value({"horizontal","vertical", "proxy"}, _entityName) then
			debugMsg("found ".. _entityName .." " .. _baseType)
			whEntity = ent
			whEntityType = _baseType
			whType = _entityName
		end
		if _entityName == "pole" then
			debugMsg("found existing warehouse connector " .. _baseType)
			poleEntity = ent
			poleEntityType = _baseType
		end
	end
	-- "warehouse-signal-pole" always is part of a composite entity with a warehouse
	if not whType and poleEntityType then
		debugMsg("removed orphaned warehouse connector")
		poleEntity.destroy()
		return
	end
	-- we are deconstructing...
	if deconstructing and poleEntityType then
		debugMsg("removed warehouse connector")
		poleEntity.destroy()
		return
	end
	
	-- every warehouse needs a pole
	if whEntityType == 'entity' and not poleEntity then
		debugMsg("created new warehouse connector")
		poleEntity = surface.create_entity{
			name="warehouse-signal-pole",
			position = whEntity.position,
			force = whEntity.force,
			player = whEntity.last_user,
		}
		poleEntityType = 'entity'
	end
	-- it looks neater if warehouse ghosts also have a pole ghost
	if whEntityType == 'entity-ghost' and not poleEntity then
		debugMsg("created new warehouse connector ghost")
		poleEntity = surface.create_entity{
			name="entity-ghost",
			inner_name = "warehouse-signal-pole",
			position = whEntity.position,
			force = whEntity.force,
			player = whEntity.last_user,
		}
		poleEntityType = 'entity-ghost'
	end
	
	-- ghost state of warehouse and pole is synchronized, the pole is never manually built, but rather scripted
	if whEntityType == 'entity' and poleEntityType == 'entity-ghost' then
		debugMsg("revived warehouse connector ghost")
		_, poleEntity = poleEntity.revive()
		poleEntityType = "entity"
	end
	
	-- a wh ghost is always a proxy and never a direction typed wh (this only happens with strg-z, which also breakes pole connections, but there is no fix)
	if whEntityType == 'entity-ghost' and data_util.has_value({"horizontal","vertical"}, whType) then
		debugMsg("warning, using undo will break wire connections of the warehouse connector")
		local newEntityName = string.gsub(whEntity.ghost_name , "%-[hv]$", "-proxy")
		local direction
		debugMsg("replacing ghost for " .. whEntity.ghost_name  .. " with " .. newEntityName)
		if whType == "vertical" then
			direction = defines.direction.west
		else
			direction = defines.direction.north
		end
		whEntity.destroy()
		surface.create_entity{
			name="entity-ghost",
			inner_name = newEntityName,
			position = position,
			force = force,
			player = last_user,
			direction = direction
		}
	end
	-- the pole is invulnerable
	if poleEntityType == 'entity' then
		poleEntity.destructible = false
	end
	-- the pole is always connected to it's wh
	if poleEntityType == 'entity' and whEntityType == 'entity' then
		debugMsg("connecting wires")
		poleEntity.connect_neighbour({wire = defines.wire_type.red,target_entity = whEntity})
		poleEntity.connect_neighbour({wire = defines.wire_type.green,target_entity = whEntity})
	end
end
-------------------------------------------------------------------------------------
-- On Built Item Replace to allow non square warehouses
-------------------------------------------------------------------------------------
function myControl.on_built(event)
	local built_entity = event.created_entity or event.entity
	if not built_entity then
		debugMsg("on_built - entity not defined")
		return
	end
	debugMsg("on_built " .. built_entity.name)
	local baseType
	local entityName
	local position = built_entity.position
	local force = built_entity.force
	local surface = built_entity.surface
	-- ensure we are building something relevant
	baseType, entityName = lib_warehouse.checkEntity(built_entity)
	debugMsg(baseType .. "::" .. (entityName or ""))
	-- manage ghost related pseudo events
	if baseType == "entity-ghost" and entityName == "proxy" then
		debugMsg("watching new proxy ghost")
		ghost_util.register_ghost(built_entity)
	elseif baseType == "entity" and entityName == "proxy" then
		--it is probably we have been built from a Ghost --> unregister this Ghost from watchlist
		debugMsg("unregistering possible proxy ghost from watchlist")
		ghost_util.unregister_ghost({
			surface = {name = built_entity.surface.name},
			force = {name = built_entity.force.name},
			ghost_name = built_entity.name,
			position = built_entity.position
		})
	end
	-- do all the things
	if baseType == "entity" and entityName == "proxy" then
		myControl.on_built_proxy(built_entity)
	end
	-- finalize all the other things
	if data_util.has_value({"horizontal","vertical", "proxy", "pole"}, entityName) then
		myControl.validate_warehouse(position,force,surface)
	end
end
-------------------------------------------------------------------------------------
-- On WhProxy Build
-------------------------------------------------------------------------------------
function myControl.on_built_proxy(proxy)
	debugMsg("on_built_proxy")
	local surface = proxy.surface
	local position = proxy.position
	local force = proxy.force
	local last_user = proxy.last_user
	local direction = proxy.direction % 4
	local structure_name
	if direction == defines.direction.east or direction == defines.direction.west then
		structure_name = proxy.name:gsub("-proxy", "-v")
	else
		structure_name = proxy.name:gsub("-proxy", "-h")
	end
	-- replace structure
	debugMsg("kill proxy ".. proxy.name)
	proxy.destroy()
	--=========================================================================
	debugMsg("created new " .. structure_name)
	surface.create_entity{
		name = structure_name,
		position = position,
		force = force,
		player = last_user
	}
	-- remainer of composite entity if built in validation called by on_built
end

-------------------------------------------------------------------------------------
-- On Entity Removed
-------------------------------------------------------------------------------------
function myControl.on_entity_removed(event)
	debugMsg("OnEntityRemoved")
	local entity = event.entity
	if not entity or not entity.valid then 
		debugMsg("OnEntityRemoved - entity not defined")
		return
	end
	debugMsg(entity.name or entity.ghost_name)
	baseType, entityName = lib_warehouse.checkEntity(entity)
	debugMsg((baseType or "") .. "::" .. (entityName or ""))
	if data_util.has_value({"horizontal","vertical", "proxy"}, entityName) then
		myControl.validate_warehouse(entity.position,entity.force,entity.surface,true)
	end
end
-------------------------------------------------------------------------------------
-- On Entity Died
-------------------------------------------------------------------------------------
function myControl.on_entity_died(event)
	debugMsg("OnEntityDied")
	local entity = event.entity
	if not entity or not entity.valid then 
		debugMsg("OnEntityDied - entity not defined")
		return
	end
	
	local entity = event.entity
	_ , whType = lib_warehouse.checkEntity(entity)
	if whType then
		local newEntityName = string.gsub(entity.name , "%-[hv]$", "-proxy")
		local direction
		debugMsg("creating ghost for died " .. entity.name  .. " as " .. newEntityName)
		if whType == "vertical" then
			direction = defines.direction.west
		else
			direction = defines.direction.north
		end
		entity.surface.create_entity{
			name="entity-ghost",
			inner_name = newEntityName,
			position = entity.position,
			force = entity.force,
			player = entity.last_user,
			direction = direction
		}
	end
	myControl.validate_warehouse(entity.position,entity.force,entity.surface,false)
end
-------------------------------------------------------------------------------------
-- On Entity Ghost Removed
-------------------------------------------------------------------------------------
function myControl.on_ghost_removed(data)
	debugMsg("entity-ghost became invalid at ".. data.key)
	myControl.validate_warehouse(data.position,data.force,data.surface,false)
end
ghost_util.register_callback(myControl.on_ghost_removed)
-------------------------------------------------------------------------------------
-- On Blueprint Item Replace to Reset Item to Item-Proxy
-------------------------------------------------------------------------------------
function myControl.on_blueprint(event)
	debugMsg("on_blueprint")
	local player = game.players[event.player_index]
	local bp = player.blueprint_to_setup
	if not bp or not bp.valid_for_read then
		bp = player.cursor_stack
	end
	if not bp or not bp.valid_for_read then
		return
	end
	local entities = bp.get_blueprint_entities()
	if not entities then
		return
	end
	for _, e in ipairs(entities) do
		local whType = lib_warehouse.checkEntityName(e.name)
		if data_util.has_value({"horizontal","vertical", "proxy"}, whType)  then
			if whType == "horizontal" then
				e.name =  e.name:gsub("-h", "-proxy")
			elseif whType == "vertical" then
				e.name =  e.name:gsub("-v", "-proxy")
				e.direction = defines.direction.west
			end
		end
	end
	bp.set_blueprint_entities(entities)
end
-------------------------------------------------------------------------------------
-- Register Commands
-------------------------------------------------------------------------------------
commands.add_command("wh_check", nil, function(command)
	myControl.validate_warehouses()
end)
-------------------------------------------------------------------------------------
-- Register Hooks
-------------------------------------------------------------------------------------
local es = defines.events
script.on_configuration_changed( myControl.script_on_configuration_changed )
script.on_event({es.on_player_joined_game}, myControl.validate_warehouses)
script.on_event({es.on_built_entity, es.on_robot_built_entity, es.script_raised_built, es.script_raised_revive}, myControl.on_built)
script.on_event(es.on_player_setup_blueprint, myControl.on_blueprint)
script.on_event({es.on_robot_mined_entity, es.on_player_mined_entity}, myControl.on_entity_removed)
script.on_event({es.on_entity_died}, myControl.on_entity_died)
