log("warehouses-tech")
local myGlobal = require("__nco-LongWarehouses__/lib/nco_data")
local data_util = require("__nco-LongWarehouses__/lib/data_util")
--===================================================================================
--Register Tech
--===================================================================================
local techIcon = "__nco-LongWarehouses__/graphics/icons/tech-warehouses.png"
local whTech = {
		type = "technology",
		name = "nco-LongWarehouses",
		localised_name = {"technology-name.nco-longWarehouses"},
		localised_description = {"technology-description.nco-longWarehouses"},
		icon = techIcon,
		icon_size = myGlobal.imageInfo[techIcon].width,
		prerequisites = {
			"automated-rail-transportation"
		},
		effects = {},
		unit = {
			count = 150,
			ingredients = {
				{"automation-science-pack", 1},
				{"logistic-science-pack", 2},
			},
			time = 30
		},
		order = "c-a"
	}
-------------------------------------------------------------------------------------
local whTechLogistic1 = util.table.deepcopy(whTech)
local whTechLogistic2 = util.table.deepcopy(whTech)
-------------------------------------------------------------------------------------
whTech.unit.ingredients = data_util.getResearchUnitIngredients("automated-rail-transportation")
whTech.unit.count = data_util.getResearchUnitCount("automated-rail-transportation")*2
-------------------------------------------------------------------------------------
whTechLogistic1.name = "nco-LongWarehousesLogistics1"
whTechLogistic1.localised_name = {"technology-name.nco-longWarehousesLogistics1"}
whTechLogistic1.localised_description = {"technology-description.nco-longWarehousesLogistics1"}
whTechLogistic1.prerequisites = { "logistic-robotics", "nco-LongWarehouses"}
whTechLogistic1.icon = "__nco-LongWarehouses__/graphics/icons/tech-warehouses-logistics.png"
whTechLogistic1.unit.ingredients = data_util.getResearchUnitIngredients("logistic-robotics")
whTechLogistic1.unit.count = data_util.getResearchUnitCount("logistic-robotics")*2
-------------------------------------------------------------------------------------
whTechLogistic2.name = "nco-LongWarehousesLogistics2"
whTechLogistic2.localised_name = {"technology-name.nco-longWarehousesLogistics2"}
whTechLogistic2.localised_description = {"technology-description.nco-longWarehousesLogistics2"}
whTechLogistic2.prerequisites = {"logistic-system", "nco-LongWarehousesLogistics1"}
whTechLogistic2.icon = "__nco-LongWarehouses__/graphics/icons/tech-warehouses-logistics2.png"
whTechLogistic2.unit.ingredients = data_util.getResearchUnitIngredients("logistic-system")
whTechLogistic2.unit.count = data_util.getResearchUnitCount("logistic-system")*2
-------------------------------------------------------------------------------------
for k,v in pairs(myGlobal.RegisteredWarehouses) do
	--log(v.name)
	if v.whType == "normal" then
		table.insert(whTech.effects,{type = "unlock-recipe",recipe = v.name})
	elseif v.whType == "storage" or v.whType == "passive-provider" then
		table.insert(whTechLogistic1.effects,{type = "unlock-recipe",recipe = v.name})
	else
		table.insert(whTechLogistic2.effects,{type = "unlock-recipe",recipe = v.name})
	end
end
data:extend({whTech})
if settings.startup["wh-enable-logistic"].value then
	data:extend({whTechLogistic1})
end
if settings.startup["wh-enable-advanced-logistic"].value then
	data:extend({whTechLogistic2})
end
