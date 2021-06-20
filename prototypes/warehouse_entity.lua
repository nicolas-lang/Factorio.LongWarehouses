log("warehouses-entity")
local myGlobal = require("__nco-LongWarehouses__/lib/nco_data")
local lib_warehouse = require("__nco-LongWarehouses__/lib/lib_warehouse")
-------------------------------------------------------------------------------------
local function makeWarehouseProxy(unitSize,logisticType)
	-------------------------------------------------------------------------------------
	-- Configure Details
	-------------------------------------------------------------------------------------
	local whData = lib_warehouse.getWHData(unitSize,logisticType,1,"proxy")
	local whSizeA = whData.gridSize
	local whSizeB = 2
	log("registering warehouse " .. whData.whName)
	table.insert(myGlobal["RegisteredWarehouses"],{name=whData.whName,whType=whData.whTypeName})
	--===================================================================================
	--Define Recipe data
	--===================================================================================
	local whProxRec = {
		type = "recipe",
		name = whData.whName,
		energy_required = 20,
		enabled = "false",
		ingredients = lib_warehouse.getWHIngredients(unitSize,logisticType,"proxy"),
		result = whData.whName,
		icons = lib_warehouse.getWHIcon(unitSize,logisticType),
		subgroup = "cust-warehouse",
		order = "a"
	}
	-------------------------------------------------------------------------------------
	local whProxItm = {
			type = "item",
			name = whData.whName,
			icons = lib_warehouse.getWHIcon(unitSize,logisticType),
			subgroup = "cust-warehouse",
			order = "a[" .. whData.whName .. "]",
			place_result = whData.whName,
			stack_size = 5,
		}
	local whProxEnt = {
		type = "pump",
		name = whData.whName,
		fast_replaceable_group = whData.whGroupName,
		icons = lib_warehouse.getWHIcon(unitSize,logisticType),
		minable = { mining_time = 0.1, result = whData.whName},
		flags = {"player-creation", "placeable-neutral","hide-alt-info"},
		max_health = 100,
		collision_box = {{-(whSizeA/2-0.01), -(whSizeB/2-0.01)}, {(whSizeA/2-0.01),(whSizeB/2-0.01)}},
		selection_box = {{-(whSizeA/2), -(whSizeB/2)}, {(whSizeA/2), (whSizeB/2)}},
		fluid_box = {pipe_connections = {}},
		energy_usage = "0kW",
		energy_source = {type = "void"},
		pumping_speed = 0,
		animations = {},
		pictures = {picture = {}},
		circuit_wire_connection_points = circuit_connector_definitions["pump"].points,
		circuit_connector_sprites = circuit_connector_definitions["pump"].sprites,
		circuit_wire_max_distance = 0.0001
	}
	-------------------------------------------------------------------------------------
	--===================================================================================
	-- Entity: Sprites
	--===================================================================================
	local mySpriteH = lib_warehouse.buildSpriteLayer("warehouse",logisticType,unitSize,"h")
	local mySpriteV = lib_warehouse.buildSpriteLayer("warehouse",logisticType,unitSize,"v")
	whProxEnt.animations = {north={},south={},west={},east={}}
	whProxEnt.animations.north.layers = util.table.deepcopy(mySpriteH)
	whProxEnt.animations.south.layers = util.table.deepcopy(mySpriteH)
	whProxEnt.animations.west.layers = util.table.deepcopy(mySpriteV)
	whProxEnt.animations.east.layers = util.table.deepcopy(mySpriteV)
	--log("registering item")
	data:extend({whProxItm})
	--log("registering entity")
	data:extend({whProxEnt})
	--log("registering recipe")
	data:extend({whProxRec})
	
end
-------------------------------------------------------------------------------------
local function makeWarehouse(unitSize,logisticType,subType)
	-------------------------------------------------------------------------------------
	-- Configure Details
	-------------------------------------------------------------------------------------
	local whData = lib_warehouse.getWHData(unitSize,logisticType,80,subType)
	local whProxy = lib_warehouse.getWHData(unitSize,logisticType,80,"proxy")
	local whSizeA = whData.gridSize
	local whSizeB = 1.999
	log("registering warehouse " .. whData.whName)
	--table.insert(myGlobal["RegisteredWarehouses"],{name=whData.whName,whType=whData.whTypeName})
	--===================================================================================
	--Define Recipe
	--===================================================================================
	local whRec = {
		type = "recipe",
		hidden = "true",
		enabled = "false",
		hide_from_player_crafting = "true",
		hide_from_stats = "true",
		name = whData.whName,
		energy_required = 20,
		enabled = "false",
		ingredients = {{"coal",1}},
		result = whData.whName,
		icons = lib_warehouse.getWHIcon(unitSize,logisticType),
		subgroup = "cust-warehouse",
		order = "a"
	}
	--===================================================================================
	--Define Item 
	--===================================================================================
	local whItm = {
			type = "item",
			flags={
				"hidden"
			},
			name = whData.whName,
			icons = lib_warehouse.getWHIcon(unitSize,logisticType),
			subgroup = "cust-warehouse",
			order = "a[" .. whData.whName .. "]",
			place_result = whData.whName,
			stack_size = 5,
		}
	--===================================================================================
	--Define Entity
	--===================================================================================
	local whEnt = {
			type = "container",
			name = whData.whName,
			icons = lib_warehouse.getWHIcon(unitSize,logisticType),
			flags = {"placeable-neutral", "player-creation"},
			minable = {mining_time = 5, result = whProxy.whName},
			max_health = whData.whHealth,
			create_ghost_on_death = false,
			corpse = "small-remnants",
			open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.65 },
			close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7 },
			resistances = {
					{type = "fire",	percent = 99},
					{type = "explosion",	percent = 80}
				},
			collision_box = {{-(whSizeA/2-0.01), -(whSizeB/2-0.01)}, {(whSizeA/2-0.01),(whSizeB/2-0.01)}},
			selection_box = {{-(whSizeA/2), -(whSizeB/2)}, {(whSizeA/2), (whSizeB/2)}},
			fast_replaceable_group = whData.whGroupName,
			inventory_size = whData.whInvSize,
			vehicle_impact_sound =	{ filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
			picture = {layers = {}},
			circuit_wire_connection_point = circuit_connector_definitions["chest"].points,
			circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
			circuit_wire_max_distance = 0.001,
			render_layer = "higher-object-under"
		}
	-------------------------------------------------------------------------------------
	-- Entity: logistics ?
	-------------------------------------------------------------------------------------
	if logisticType ~= "normal" then
		whEnt.type = "logistic-container"
		whEnt.logistic_mode = logisticType
		whEnt.opened_duration = logistic_chest_opened_duration
		if logisticType == "requester" or logisticType == "buffer" then
			whEnt.logistic_slots_count = 25 + math.min(math.floor(unitSize*2.5),25)
		elseif logisticType == "storage" then
			whEnt.max_logistic_slots = 1
		end
	end
	-------------------------------------------------------------------------------------
	-- Entity: H/V
	-------------------------------------------------------------------------------------
	if subType == "v" then 
		whEnt.collision_box = {{-(whSizeB/2-0.01), -(whSizeA/2-0.01)}, {(whSizeB/2-0.01),(whSizeA/2-0.01)}}
		whEnt.selection_box = {{-(whSizeB/2), -(whSizeA/2)}, {(whSizeB/2),(whSizeA/2)}}
	end
	--===================================================================================
	-- Entity: Sprites
	--===================================================================================
	whEnt.picture.layers = lib_warehouse.buildSpriteLayer("warehouse",logisticType,unitSize,subType)
	--===================================================================================
	--Register Warehouse
	--===================================================================================
	--log("registering item")
	data:extend({whItm})
	--log("registering entity")
	data:extend({whEnt})
	--log("registering recipe")
	data:extend({whRec})
end -- function makeWarehouse

--===================================================================================
--Call WH Generator
--===================================================================================
myGlobal["whSizes"] = {2,4}
local directions = {"h","v"}
-------------------------------------------------------------------------------------
for k1,v1 in pairs(myGlobal["whSizes"]) do
	makeWarehouseProxy(v1,"normal");
	for k2,v2 in pairs(directions) do
		makeWarehouse(v1,"normal",v2);
	end
end
-------------------------------------------------------------------------------------
local logistictypes = {"requester","storage","passive-provider","active-provider","buffer"}
for k1,v1 in pairs(myGlobal["whSizes"]) do
	for k2,v2 in pairs(logistictypes) do
		makeWarehouseProxy(v1,v2);
		for k3,v3 in pairs(directions) do
			makeWarehouse(v1,v2,v3);
		end
	end
end