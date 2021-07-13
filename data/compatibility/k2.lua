local data_util = require("__nco-LongWarehouses__/lib/data_util")

if mods["Krastorio2"] then
	if settings.startup["kr-containers"].value then
		local whTech = data.raw["technology"]["nco-LongWarehouses"]
		table.insert(whTech.prerequisites,"kr-containers")
		whTech.unit.ingredients = data_util.getResearchUnitIngredients("kr-containers")
		whTech.unit.count = data_util.getResearchUnitCount("kr-containers")*2
		--
		local whTechLogistic1 = data.raw["technology"]["nco-LongWarehousesLogistics1"]
		table.insert(whTechLogistic1.prerequisites,"kr-logistic-containers-1")
		whTechLogistic1.unit.ingredients = data_util.getResearchUnitIngredients("kr-logistic-containers-1")
		whTechLogistic1.unit.count = data_util.getResearchUnitCount("kr-logistic-containers-1")*2
		--
		local whTechLogistic2 = data.raw["technology"]["nco-LongWarehousesLogistics2"]
		table.insert(whTechLogistic2.prerequisites,"kr-logistic-containers-2")
		whTechLogistic2.unit.ingredients = data_util.getResearchUnitIngredients("kr-logistic-containers-2")
		whTechLogistic2.unit.count = data_util.getResearchUnitCount("kr-logistic-containers-2")*2
	end
end