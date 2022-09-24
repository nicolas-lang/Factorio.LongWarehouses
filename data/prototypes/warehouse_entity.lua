--log("warehouses-entity")
local util = require("util")
local myGlobal = require("__nco-LongWarehouses__/lib/nco_data")
local data_util = require("__nco-LongWarehouses__/lib/data_util")
local lib_warehouse = require("__nco-LongWarehouses__/lib/lib_warehouse")
local whSizeScaling = 80
-------------------------------------------------------------------------------------
local function makeWarehouseProxy(unitSize,logisticType)
	-------------------------------------------------------------------------------------
	-- Configure Details
	-------------------------------------------------------------------------------------
	local whData = lib_warehouse.getWHData(unitSize,logisticType,whSizeScaling,"proxy")
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
		order = whData.sortOrder,
		localised_name = {"recipe-name.cust-warehouse",{"custom-strings.cust-warehouse-name-"..logisticType},whData.whSizeNameAdvanced}
	}
	-------------------------------------------------------------------------------------
	local whProxItm = {
			type = "item",
			name = whData.whName,
			icons = lib_warehouse.getWHIcon(unitSize,logisticType),
			subgroup = "cust-warehouse",
			order = whData.sortOrder,
			place_result = whData.whName,
			stack_size = 5,
			localised_name = {"item-name.cust-warehouse",{"custom-strings.cust-warehouse-name-"..logisticType},whData.whSizeNameAdvanced},
			localised_description = {"item-description.cust-warehouse",whData.whSizeNameAdvanced, whData.whInvSize}
		}
	local whProxEnt = {
		--should never be placed for more than 1 tick, unless it is a ghost
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
		circuit_wire_max_distance = 0.0001,
		localised_name = {"item-name.cust-warehouse",{"custom-strings.cust-warehouse-name-"..logisticType},whData.whSizeNameAdvanced},
		localised_description = {"item-description.cust-warehouse",whData.whSizeNameAdvanced, whData.whInvSize}
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
	data:extend({whProxItm})
	data:extend({whProxEnt})
	data:extend({whProxRec})
end
-------------------------------------------------------------------------------------
local function makeWarehouse(unitSize,logisticType,subType)
	-------------------------------------------------------------------------------------
	-- Configure Details
	-------------------------------------------------------------------------------------
	local whData = lib_warehouse.getWHData(unitSize,logisticType,whSizeScaling,subType)
	local whProxy = lib_warehouse.getWHData(unitSize,logisticType,whSizeScaling,"proxy")
	local whSizeA = whData.gridSize
	local whSizeB = 1.999
	--log("registering warehouse " .. whData.whName)
	--===================================================================================
	--Define Recipe
	--===================================================================================
	local whRec = {
		--never used, just required as a dummy
		type = "recipe",
		hidden = "true",
		enabled = "false",
		hide_from_player_crafting = "true",
		hide_from_stats = "true",
		name = whData.whName,
		energy_required = 20,
		ingredients = {{"coal",1}},
		result = whData.whName,
		icons = lib_warehouse.getWHIcon(unitSize,logisticType),
		subgroup = "cust-warehouse",
		order = whData.sortOrder
	}
	--===================================================================================
	--Define Item
	--===================================================================================
	local whItm = {
			--never used, just required as a dummy
			type = "item",
			flags={
				"hidden"
			},
			name = whData.whName,
			icons = lib_warehouse.getWHIcon(unitSize,logisticType),
			subgroup = "cust-warehouse",
			order = whData.sortOrder,
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
			localised_name = {"entity-name.cust-warehouse",{"custom-strings.cust-warehouse-name-"..logisticType},whData.whSizeNameAdvanced},
			localised_description = {"entity-description.cust-warehouse"}
		}
	-------------------------------------------------------------------------------------
	-- Entity: logistics properties
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
	data:extend({whItm})
	data:extend({whEnt})
	data:extend({whRec})
end -- function makeWarehouse

--===================================================================================
-- call WH Generator based on mod settings
--===================================================================================
myGlobal["whSizes"] = {}
for _, size in pairs(data_util.csv_split(settings.startup["wh-sizes"].value, ';')) do
	local sizeValue = tonumber(data_util.trim(size))
	if (
			sizeValue
		and	sizeValue < 32
		and	not data_util.has_value (myGlobal["whSizes"], sizeValue)
	)then
		table.insert(myGlobal["whSizes"],sizeValue)
	else
		log("invalid size: " .. sizeValue)
	end
end
-------------------------------------------------------------------------------------
local directions = {"h","v"}
for _, v1 in pairs(myGlobal["whSizes"]) do
	makeWarehouseProxy(v1,"normal");
	for _, v2 in pairs(directions) do
		makeWarehouse(v1,"normal",v2);
	end
end
-------------------------------------------------------------------------------------
-- Logistic Warehouses
-------------------------------------------------------------------------------------
local logistictypes = {}
if settings.startup["wh-enable-logistic"].value then
	table.insert(logistictypes,"storage")
	table.insert(logistictypes,"passive-provider")
end
if settings.startup["wh-enable-advanced-logistic"].value then
	table.insert(logistictypes,"requester")
	table.insert(logistictypes,"active-provider")
	table.insert(logistictypes,"buffer")
end
for _, v1 in pairs(myGlobal["whSizes"]) do
	for _, v2 in pairs(logistictypes) do
		makeWarehouseProxy(v1,v2);
		for _, v3 in pairs(directions) do
			makeWarehouse(v1,v2,v3);
		end
	end
end