local lib_warehouse = require("__nco-LongWarehouses__/lib/lib_warehouse")
local data_util = require("__nco-LongWarehouses__/lib/data_util")
-------------------------------------------------------------------------------------
-- On Blueprint Item Replace to Reset Item to Item-Proxy
-------------------------------------------------------------------------------------
local function on_blueprint(event)
	--log("on_blueprint")
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
		if data_util.has_value({"horizontal","vertical"}, whType) then
			--log("save inventory filters, requests for h/v. A proxy copied from a ghost should have inherited the tags")
			local searchResult = player.surface.find_entities_filtered({force = e.force, name = e.name, position = e.position, radius = 0.001})
			--log(#searchResult)
			for _, ent in pairs(searchResult) do
				local inventory = ent.get_inventory(defines.inventory.chest)
				local request_slots = ""
				local filter_slot = ""
				for slotIndex = 1,ent.request_slot_count,1 do
					local slot = ent.get_request_slot(slotIndex)
					if slot then
						request_slots = ((request_slots == "" and request_slots) or (request_slots..";"))..tostring(slotIndex)..":"..slot.name..":"..tostring(slot.count)
					end
				end
				if ent.filter_slot_count and ent.filter_slot_count > 0 and ent.storage_filter then
					filter_slot = ent.storage_filter.type..":"..ent.storage_filter.name
				end
				e.tags = {
					request_slots = (request_slots ~= "" and request_slots or nil),
					storage_filter = (filter_slot ~= "" and filter_slot or nil),
					bar = (inventory.get_bar() <= #inventory and inventory.get_bar() or nil),
				}
				--log("set blueprint entity tags for "..ent.name.." to:"..serpent.block(e.tags, {comment = false, numformat = '%1.8g', compact = true } ))
			end
			--log("change to proxy")
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
local es = defines.events
script.on_event(es.on_player_setup_blueprint, on_blueprint)