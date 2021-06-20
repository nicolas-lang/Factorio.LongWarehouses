local ghost_util = {}
ghost_util.check_limit = 20
ghost_util.ghosts = {}
ghost_util.ghostcount = 0
--=============================================================================
-------------------------------------------------------------------------------
--	public
-------------------------------------------------------------------------------
function ghost_util.init(lib_event,check_interval,check_limit)
	--ghost_util.lib_event = lib_event
	if check_interval == nil then 
		check_interval = 20
	end
	if check_limit ~= nil then 
		ghost_util.check_limit = check_limit
	end
	script.on_nth_tick(120,ghost_util.check_ghosts)
	--lib_event.add_nth_tick(check_interval, ghost_util.check_ghosts)
end
function ghost_util.unregister_ghost(entity)
	log("ghost_util.unregister_ghost")
	--ghost nauvis:player:cust-warehouse-normal-013-proxy:222:93 became invalid
	--{surface = {name = entity.surface.name},force = {name = entity.force.name}, ghost_name = entity.name, position = entity.position}
	key = string.format("%s:%s:%s:%d:%d",entity.surface.name,entity.force.name, entity.ghost_name, entity.position.x, entity.position.y)
	if ghost_util.ghosts[key] then
		log("unregistered ghost" .. key)
		ghost_util.ghosts[key] = nil
		ghost_util.ghostcount = ghost_util.ghostcount - 1
	end
end

function ghost_util.register_ghost(entity)
	log("ghost_util.register_ghost")
	key = string.format("%s:%s:%s:%d:%d",entity.surface.name,entity.force.name, entity.ghost_name, entity.position.x, entity.position.y)
	ghost_util.ghosts[key] = {entity = entity, position = entity.position, ghost_name = entity.ghost_name, surface = entity.surface, force = entity.force, key = key}
	ghost_util.ghostcount = ghost_util.ghostcount + 1
end

function ghost_util.register_callback(callback_func)
	log("ghost_util.register_callback")
	if callback_func == nil then error("callback function must not be null") end 
	if type(callback_func) ~= "function" then error("Handler should be callable.") end 
	ghost_util.callback_func = callback_func
end
-------------------------------------------------------------------------------
--	pseudo private
-------------------------------------------------------------------------------
function ghost_util.callback_func(entity)
	log("ghost_util.callback_func")
end

function ghost_util.check_ghosts()
	if ghost_util.ghostcount == 0 then
		return
	end
	log("ghost_util.check_ghosts")
	for key, ghost in pairs(ghost_util.ghosts) do
		if not ghost.entity.valid then
			log("ghost " .. key .. " became invalid")
			ghost_util.ghosts[key].entity = nil
			ghost_util.callback_func(ghost_util.ghosts[key])
			ghost_util.ghosts[key] = nil
			ghost_util.ghostcount = ghost_util.ghostcount -1
		end
	end
end
--=============================================================================
return ghost_util