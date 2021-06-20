if active_mods["Krastorio2"] and false then
	log("K2 compatibility not yet implemented")
--[[
	table.insert(whTechLogistic1.prerequisites, "kr-logistic-containers-1")

	table.insert(whTechLogistic2.prerequisites, "kr-logistic-containers-2")
	whTechLogistic2.unit.ingredients = myGlobal.getResearchUnitIngredients("kr-logistic-containers-2")
	whTechLogistic2.unit.count = myGlobal.getResearchUnitCount("kr-logistic-containers-2")*2

	table.insert(whTechFluid.prerequisites, "kr-containers")
	table.insert(whTechFluid.prerequisites, "kr-steel-fluid-handling")
	whTechFluid.unit.ingredients = myGlobal.getResearchUnitIngredients("kr-steel-fluid-handling")
	whTechFluid.unit.count = myGlobal.getResearchUnitCount("kr-steel-fluid-handling")*2
]]--
end