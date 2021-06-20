--C:\Daten\Nextcloud\Coden\Factorio\RefMods\LogisticTrainNetwork_1.16.0\script\stop-events.lua
local myGlobal = require("__nco-LongWarehouses__/lib/nco_data")
local poleIcon = "__nco-LongWarehouses__/graphics/icons/addon-power-pole.png"
local signalPole = {
	type = "electric-pole",
	name = "warehouse-signal-pole",
	supply_area_distance = 0.1,
	collision_box = {{-0.01, -0.01}, {0.01, 0.01}},
	collision_mask = {"colliding-with-tiles-only"},
	selection_box = {{-0.5,-0.5},{0.5,0.5}},
	selection_priority = 150,
	connection_points = {
		{
			shadow = {
				copper = { 1.6-0.1, 0.1 },
				green = { 1.6-0.1, 0.1-0.3 },
				red = { 1.6-0.25, 0.1-0.2	}
			},
			wire = {
				copper = { 0+0.07, -1.2-0.2 },
				green = {	0+0.1, -1.2-0.4 },
				red = {	0-0.15, -1.2-0.3 }
			}
		},
	},
	corpse = "small-electric-pole-remnants",
	drawing_box = { {-0.5,-1.5},{0.5,0.5} },
	dying_explosion = "big-electric-pole-explosion",
	flags = { --https://wiki.factorio.com/Types/EntityPrototypeFlags
		"placeable-neutral",
		"not-deconstructable",
		"player-creation",
		"not-on-map",
		"hidden",
		"hide-alt-info",
		"placeable-off-grid"
	},
	icon = poleIcon,
	icon_size = myGlobal.imageInfo[poleIcon].width,
	icon_mipmaps = 1,
	max_health = 1000,
	destructible = false,
	mineable = false,
	maximum_wire_distance = 15,
	draw_copper_wires = false,
	pictures = {
		layers = {
			{
				direction_count = 1,
				filename = "__nco-LongWarehouses__/graphics/entity/hr/addon-power-pole.png",
				width = myGlobal.imageInfo["__nco-LongWarehouses__/graphics/entity/hr/addon-power-pole.png"].width,
				height = myGlobal.imageInfo["__nco-LongWarehouses__/graphics/entity/hr/addon-power-pole.png"].height,
				shift = { 0, -0.85 },
				scale = 0.5,
			}
		}
	}
}

signalPole.radius_visualisation_picture = util.table.deepcopy(data.raw["electric-pole"]["small-electric-pole"].radius_visualisation_picture)
signalPole.resistances = util.table.deepcopy(data.raw["electric-pole"]["small-electric-pole"].resistances)
signalPole.vehicle_impact_sound = util.table.deepcopy(data.raw["electric-pole"]["small-electric-pole"].vehicle_impact_sound)
signalPole.water_reflection = util.table.deepcopy(data.raw["electric-pole"]["small-electric-pole"].water_reflection)
signalPole.damaged_trigger_effect = util.table.deepcopy(data.raw["electric-pole"]["small-electric-pole"].damaged_trigger_effect)
data:extend({signalPole})

local signalPoleItm = {
	type = "item",
	flags={
		"hidden"
	},
	name = "warehouse-signal-pole",
	icon = poleIcon,
	icon_size = myGlobal.imageInfo[poleIcon].width,
	subgroup = "cust-warehouse",
	order = "a[" .. "warehouse-signal-pole" .. "]",
	place_result = "warehouse-signal-pole",
	stack_size = 1,
}
data:extend({signalPoleItm})