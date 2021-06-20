log("warehouses-tech")
local myGlobal = require("__nco-LongWarehouses__/lib/nco_data")
local data_util = require("__nco-LongWarehouses__/lib/data_util")
--===================================================================================
--Register Tech
--===================================================================================
--log(serpent.block( myGlobal.imageInfo, {comment = false, numformat = '%1.8g', compact = true } ))
local techIcon = "__nco-LongWarehouses__/graphics/icons/tech-warehouses.png"
--log(myGlobal.imageInfo[techIcon])
local whTech = {
		type = "technology",
		name = "nco-LongWarehouses",
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
whTechLogistic1.prerequisites = { "logistic-robotics", "nco-LongWarehouses"}
whTechLogistic1.icon = "__nco-LongWarehouses__/graphics/icons/tech-warehouses-logistics.png"

whTechLogistic1.unit.ingredients = data_util.getResearchUnitIngredients("logistic-robotics")
whTechLogistic1.unit.count = data_util.getResearchUnitCount("logistic-robotics")*2
-------------------------------------------------------------------------------------
whTechLogistic2.name = "nco-LongWarehousesLogistics2"
whTechLogistic2.prerequisites = {"logistic-system", "nco-LongWarehousesLogistics1"}
whTechLogistic2.icon = "__nco-LongWarehouses__/graphics/icons/tech-warehouses-logistics.png"
whTechLogistic2.unit.ingredients = data_util.getResearchUnitIngredients("logistic-system")
whTechLogistic2.unit.count = data_util.getResearchUnitCount("logistic-system")*2
-------------------------------------------------------------------------------------
for k,v in pairs(myGlobal.RegisteredWarehouses) do
	log(v.name)
	if v.whType == "normal" then
		table.insert(whTech.effects,{type = "unlock-recipe",recipe = v.name})
	elseif v.whType == "storage" or v.whType == "passive-provider" then
		table.insert(whTechLogistic1.effects,{type = "unlock-recipe",recipe = v.name})
	else 
		table.insert(whTechLogistic2.effects,{type = "unlock-recipe",recipe = v.name})
	end
end
data:extend({whTech})
data:extend({whTechLogistic1})
data:extend({whTechLogistic2})
