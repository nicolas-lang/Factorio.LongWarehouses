local lib_warehouse = require("__nco-LongWarehouses__/lib/lib_warehouse")
local data_util = require("__nco-LongWarehouses__/lib/data_util")
-------------------------------------------------------------------------------------
-- On Blueprint Item Replace to Reset Item to Item-Proxy
-------------------------------------------------------------------------------------
local function on_blueprint(event)
	-- debugMsg("on_blueprint")
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
local es = defines.events
script.on_event(es.on_player_setup_blueprint, on_blueprint)