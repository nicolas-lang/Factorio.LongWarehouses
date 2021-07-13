local data_util = require("__nco-LongWarehouses__/lib/data_util")
if mods["aai-containers"] then
	--
	local whTech = data.raw["technology"]["nco-LongWarehouses"]
	table.insert(whTech.prerequisites,"aai-storehouse-base")
	whTech.unit.ingredients = data_util.getResearchUnitIngredients("aai-storehouse-base")
	whTech.unit.count = data_util.getResearchUnitCount("aai-storehouse-base")*2
	--
	local whTechLogistic1 = data.raw["technology"]["nco-LongWarehousesLogistics1"]
	table.insert(whTechLogistic1.prerequisites,"aai-storehouse-storage")
	whTechLogistic1.unit.ingredients = data_util.getResearchUnitIngredients("aai-storehouse-storage")
	whTechLogistic1.unit.count = data_util.getResearchUnitCount("aai-storehouse-storage")*2
	--
	local whTechLogistic2 = data.raw["technology"]["nco-LongWarehousesLogistics2"]
	table.insert(whTechLogistic2.prerequisites,"aai-storehouse-logistic")
	whTechLogistic2.unit.ingredients = data_util.getResearchUnitIngredients("aai-storehouse-logistic")
	whTechLogistic2.unit.count = data_util.getResearchUnitCount("aai-storehouse-logistic")*2
end