local myGlobal = require("__nco-LongWarehouses__/lib/nco_data")
local poleIcon = "__nco-LongWarehouses__/graphics/icons/addon-power-pole.png"

local signalPole = {
	type = "programmable-speaker",
	name = "warehouse-signal-pole",
	collision_box = {{-0.01, -0.01}, {0.01, 0.01}},
	collision_mask = {"colliding-with-tiles-only"},
	selection_box = {{-0.65,-0.65},{0.65,0.65}},
	selection_priority = 150,
	energy_source = {
		type = "void",
		usage_priority = "secondary-input",
		render_no_power_icon = false
	},
	energy_usage_per_tick = "1W",
	maximum_polyphony = 0,
	instruments = { },
	circuit_wire_connection_point = {
		shadow = {
			green = {
				 1.9-0.1
				,0.1-0.1
			},
			red = {
				 1.9-0.25
				, 0.1-0
			}
		},
		wire = {
			green = {
				 -0.55
				,-1.8
			},
			red = {
				 0.55
				,-1.8
			}
		}
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
	circuit_wire_max_distance = 15,
	draw_copper_wires = true,
	sprite = {
		layers = {
			{
				direction_count = 1,
				filename = "__nco-LongWarehouses__/graphics/entity/hr/addon-power-pole.png",
				width = myGlobal.imageInfo["__nco-LongWarehouses__/graphics/entity/hr/addon-power-pole.png"].width,
				height = myGlobal.imageInfo["__nco-LongWarehouses__/graphics/entity/hr/addon-power-pole.png"].height,
				shift = util.by_pixel(0,-23),
				scale = 0.5,
			}
		}
	}
}

--signalPole.radius_visualisation_picture = util.table.deepcopy(data.raw["electric-pole"]["small-electric-pole"].radius_visualisation_picture)
signalPole.resistances = util.table.deepcopy(data.raw["electric-pole"]["small-electric-pole"].resistances)
signalPole.vehicle_impact_sound = util.table.deepcopy(data.raw["electric-pole"]["small-electric-pole"].vehicle_impact_sound)
signalPole.operable = false
--signalPole.water_reflection = util.table.deepcopy(data.raw["electric-pole"]["small-electric-pole"].water_reflection)
--signalPole.damaged_trigger_effect = util.table.deepcopy(data.raw["electric-pole"]["small-electric-pole"].damaged_trigger_effect)
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