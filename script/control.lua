local myGlobal = require("__nco-LongWarehouses__/lib/nco_data")
local lib_warehouse = require("__nco-LongWarehouses__/lib/lib_warehouse")
local data_util = require("__nco-LongWarehouses__/lib/data_util")
local ghost_util = require("__nco-LongWarehouses__/script/ghost_util")
local myControl = {}
-------------------------------------------------------------------------------------
ghost_util.init(nil,nil,nil)
-------------------------------------------------------------------------------------
-- All the things to control the things
-------------------------------------------------------------------------------------
function myControl.validate_warehouses()
	game.print({"custom-strings.info-validate-warehouses"}, {r = 0.75, g = 0.5, b = 0.25, a = 0} )
	log({"custom-strings.info-validate-warehouses"})
	myControl.validate_warehouse_member("warehouse-signal-pole")
	for _, whBase in pairs(myGlobal["RegisteredWarehouses"]) do
		myControl.validate_warehouse_member(whBase.."-proxy")
		myControl.validate_warehouse_member(whBase.."-h")
		myControl.validate_warehouse_member(whBase.."-v")
	end
end
-------------------------------------------------------------------------------------
function myControl.validate_warehouse_member(subEntityName)
	for _, surface in pairs(game.surfaces) do
		if not surface or not surface.valid then
			break
		end
		for _, force in pairs(game.forces) do
			if not force or not force.valid then
				break
			end
			local searchResult
			searchResult = surface.find_entities_filtered({force = force, name = subEntityName})
			for _, ent in pairs(searchResult) do
				myControl.validate_warehouse(ent.position,ent.force,ent.surface,false)
			end
			searchResult = surface.find_entities_filtered({force = force, ghost_name = subEntityName})
			for _, ent in pairs(searchResult) do
				myControl.validate_warehouse(ent.position,ent.force,ent.surface,false)
			end
		end
	end
end
-------------------------------------------------------------------------------------
function myControl.validate_warehouse(position,force,surface,deconstructing)
	local wh = {
		entity = nil,
		whType = nil,
		entityType = nil,
		last_user = nil
	}
	local pole = {
		entity = nil,
		entityType = nil
	}
	local searchResult
	searchResult = surface.find_entities_filtered({force = force, position = position, radius = 0.001})
	for _, entity in pairs(searchResult) do
		local baseType, entityName = lib_warehouse.checkEntity(entity)
		if data_util.has_value({"horizontal","vertical", "proxy"}, entityName) then
			wh.entity = entity
			wh.entityType = baseType
			wh.whType = entityName
		end
		if entityName == "pole" then
			pole.entity = entity
			pole.entityType = baseType
		end
	end
	if not wh.entity and pole.entity then
		-- "warehouse-signal-pole" needs to be part of a composite-warehouse-entity-group
		game.print({"custom-strings.warning-orphaned-connector"}, {r = 0.75, g = 0.5, b = 0.25, a = 0} )
		log({"custom-strings.warning-orphaned-connector"})
		pole.entity.destroy()
		return
	end
	if deconstructing and pole.entity then
		-- we are deconstructing, the warehouse is handled by game logic, we just need to take care of the custom stuff
		pole.entity.destroy()
		return
	end
	--Ensure all parts of the composite entity exist
	if wh.entity then
		wh.last_user = wh.entity.last_user
	end
	-- every warehouse needs a pole
	if wh.entityType == 'entity' and not pole.entity then
		pole.entity = surface.create_entity{
			name="warehouse-signal-pole",
			position = wh.entity.position,
			force = wh.entity.force,
			player = wh.entity.last_user,
		}
		pole.entityType = 'entity'
	end
	if wh.entityType == 'entity-ghost' and not pole.entity then
		-- it looks neater if warehouse ghosts also have a pole ghost
		pole.entity = surface.create_entity{
			name="entity-ghost",
			inner_name = "warehouse-signal-pole",
			position = wh.entity.position,
			force = wh.entity.force,
			player = wh.entity.last_user,
		}
		pole.entityType = 'entity-ghost'
	end

	if wh.entityType == 'entity' and pole.entityType == 'entity-ghost' then
		-- ghost state of warehouse and pole is synchronized, the pole is never built, but rather script-revived when the warehouse is constructed
		pole.entity.revive()
		searchResult = surface.find_entities_filtered({force = force, position = position, name = "warehouse-signal-pole", radius = 0.001})
		for _, entity in pairs(searchResult) do
			pole.entity = entity
			pole.entityType = "entity"
		end
	end
	log(wh.entityType)
	log(wh.whType)
	if wh.entityType == 'entity-ghost' and data_util.has_value({"horizontal","vertical"}, wh.whType) then
		-- a wh ghost is always a proxy and never a direction typed wh (this only happens with strg-z, which also breakes pole connections, but there is no fix)
		game.print({"custom-strings.warning-undo"}, {r = 0.75, g = 0.5, b = 0.25, a = 0} )
		log({"custom-strings.warning-undo"})
		local newEntityName = string.gsub(wh.entity.ghost_name , "%-[hv]$", "-proxy")
		local direction
		if wh.whType == "vertical" then
			direction = defines.direction.west
		else
			direction = defines.direction.north
		end
		wh.entity.destroy()
		surface.create_entity{
			name="entity-ghost",
			inner_name = newEntityName,
			position = position,
			force = force,
			player = wh.last_user,
			direction = direction
		}
	end
	if pole.entityType == 'entity' then
		-- the pole is invulnerable
		pole.entity.destructible = false
	end
	if pole.entityType == 'entity' and wh.entityType == 'entity' then
		-- the pole is always connected to it's wh
		pole.entity.connect_neighbour({wire = defines.wire_type.red,target_entity = wh.entity})
		pole.entity.connect_neighbour({wire = defines.wire_type.green,target_entity = wh.entity})
	end
end
-------------------------------------------------------------------------------------
-- On Built Item Replace to allow non square warehouses
-------------------------------------------------------------------------------------
function myControl.on_built(event)
	local built_entity = event.created_entity or event.entity
	if not built_entity then
		return
	end
	local position = built_entity.position
	local force = built_entity.force
	local surface = built_entity.surface
	local baseType, entityName = lib_warehouse.checkEntity(built_entity)
	log(baseType .. "::" .. (entityName or ""))
	if baseType == "entity-ghost" and entityName == "proxy" then
		-- manage ghost related pseudo events
		ghost_util.register_ghost(built_entity)
	elseif baseType == "entity" and entityName == "proxy" then
		--it is probable we have been built from a Ghost --> unregister this Ghost from watchlist
		ghost_util.unregister_ghost({
			surface = {name = built_entity.surface.name},
			force = {name = built_entity.force.name},
			ghost_name = built_entity.name,
			position = built_entity.position
		})
	end
	-- do all the things
	if baseType == "entity" and entityName == "proxy" then
		myControl.on_built_proxy(built_entity,event.tags)
	end
	-- finalize all the other things
	if data_util.has_value({"horizontal","vertical", "proxy", "pole"}, entityName) then
		myControl.validate_warehouse(position,force,surface)
	end
end
-------------------------------------------------------------------------------------
-- On WhProxy Build
-------------------------------------------------------------------------------------
function myControl.on_built_proxy(proxy,tags)
	--log("on_built_proxy")
	local proxyData = {
		surface = proxy.surface,
		position = proxy.position,
		force = proxy.force,
		last_user = proxy.last_user,
		direction = proxy.direction % 4
	}
	if proxyData.direction == defines.direction.east or proxyData.direction == defines.direction.west then
		proxyData.structure_name = proxy.name:gsub("-proxy", "-v")
	else
		proxyData.structure_name = proxy.name:gsub("-proxy", "-h")
	end
	-- replace structure
	proxy.destroy()
	--=========================================================================
	proxyData.surface.create_entity{
		name = proxyData.structure_name,
		position = proxyData.position,
		force = proxyData.force,
		player = proxyData.last_user
	}
	--set inventory configuration from blueprint tags
	searchResult = proxyData.surface.find_entities_filtered({force = proxyData.force, name = proxyData.structure_name, position = proxyData.position, radius = 0.001})
	--log(#searchResult)
	for _, wh in pairs(searchResult) do
		--log("configuring "..wh.name)
		local whPrototype = game.entity_prototypes[wh.name]
		--locked slots
		if tags and tags.bar then
			--log("configuring locked slots")
			wh.get_inventory(defines.inventory.chest).set_bar(tags.bar)
		end
		-- requests/buffer-requests
		if (tags and tags.request_slots)then
			if (whPrototype.type == "logistic-container" and data_util.has_value({"requester","buffer"},whPrototype.logistic_mode))then
				--log("configuring request slots")
				for _, request_slot in pairs(data_util.csv_split(tags.request_slots,";")) do
					local slotInfo = data_util.csv_split(request_slot,":")
					wh.set_request_slot({name=slotInfo[2], count=tonumber(slotInfo[3])}, slotInfo[1])
				end
			else
				game.print({"custom-strings.warning-type-changed"}, {r = 0.75, g = 0.5, b = 0.25, a = 0} )
			end
		end
		-- logistic filter
		if (tags and tags.storage_filter) then
			if (whPrototype.type == "logistic-container" and whPrototype.logistic_mode == "storage")then
				--log("configuring storage filter")
				local slotInfo = data_util.csv_split(tags.storage_filter,":")
				wh.storage_filter  = game.item_prototypes[slotInfo[2]]
			else
				game.print({"custom-strings.warning-type-changed"}, {r = 0.75, g = 0.5, b = 0.25, a = 0} )
			end
		end
	end
	-- remainder of composite entity is built in validation called by on_built
end

-------------------------------------------------------------------------------------
-- On Entity Removed
-------------------------------------------------------------------------------------
function myControl.on_entity_removed(event)
	local entity = event.entity
	if not entity or not entity.valid then
		return
	end
	local _, entityName = lib_warehouse.checkEntity(entity)
	if data_util.has_value({"horizontal","vertical", "proxy"}, entityName) then
		myControl.validate_warehouse(entity.position,entity.force,entity.surface,true)
	end
end
-------------------------------------------------------------------------------------
-- On Entity Died
-------------------------------------------------------------------------------------
function myControl.on_entity_died(event)
	local entity = event.entity
	if not entity or not entity.valid then
		return
	end
	local _, whType = lib_warehouse.checkEntity(entity)
	if whType then
		local newEntityName = string.gsub(entity.name , "%-[hv]$", "-proxy")
		local direction
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
-- On GUI opened
-------------------------------------------------------------------------------------
function myControl.on_gui_opened(event)
	local entity = event.entity
	if not entity or not entity.valid or entity.name ~= 'warehouse-signal-pole' or not event.player_index then
		return
	end
	game.get_player(event.player_index).opened = nil
end
-------------------------------------------------------------------------------------
-- On Entity Ghost Removed
-------------------------------------------------------------------------------------
function myControl.on_ghost_removed(data)
	myControl.validate_warehouse(data.position,data.force,data.surface,false)
end
ghost_util.register_callback(myControl.on_ghost_removed)

-------------------------------------------------------------------------------------
-- Register Commands
-------------------------------------------------------------------------------------
commands.add_command("wh_check", nil, function(_)
	myControl.validate_warehouses()
	game.print({"custom-strings.info-called-wh_check"}, {r = 0.75, g = 0.5, b = 0.25, a = 0} )
		log({"custom-strings.info-called-wh_check"})
end)
-------------------------------------------------------------------------------------
-- Register Hooks
-------------------------------------------------------------------------------------
local es = defines.events
script.on_event({es.on_gui_opened}, myControl.on_gui_opened)
script.on_event({es.on_player_joined_game}, myControl.validate_warehouses)
script.on_event({es.on_built_entity, es.on_robot_built_entity, es.script_raised_built, es.script_raised_revive}, myControl.on_built)
script.on_event({es.on_robot_mined_entity, es.on_player_mined_entity}, myControl.on_entity_removed)
script.on_event({es.on_entity_died}, myControl.on_entity_died)
