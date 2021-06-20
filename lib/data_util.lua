local data_util = {}
-------------------------------------------------------------------------------------
function data_util.has_value (tab, val)
	if val == nil then
		return false
	end
	if not tab then
		return false
	end
	for index, value in ipairs(tab) do
		if value == val then
			return true
		end
	end
	return false
end
-------------------------------------------------------------------------------------
function data_util.getResearchUnitIngredients(technology_name)
	local technology = data_util.getTechnologyFromName(technology_name)
	if technology and next(technology) ~= nil then
		if technology.unit then
			if technology.unit.ingredients then
				return technology.unit.ingredients
			end
		end	
	end
	return {}
end
-------------------------------------------------------------------------------------
function data_util.getTechnologyFromName(technology_name)
	for name, technology in pairs(data.raw.technology) do
		if name == technology_name then
			return technology
		end
	end
	return nil
end
-------------------------------------------------------------------------------------

function data_util.getResearchUnitCount(technology_name)
	local technology = data_util.getTechnologyFromName(technology_name)
	if technology and next(technology) ~= nil then
		if technology.unit then
			if technology.unit.count then
				return technology.unit.count
			end
		end	
	end
	return 1
end
-------------------------------------------------------------------------------------
function data_util.reload_tech_unlock(technology_name)
	log("reload_tech_unlock")
	for _, force in pairs(game.forces) do
		if force.technologies[technology_name].researched then
			for _, effect in pairs(force.technologies[technology_name].effects) do
				log(serpent.block( effect, {comment = false, numformat = '%1.8g', compact = true } ))
				if effect.type == "unlock-recipe" then
					force.recipes[effect.recipe].enabled = true
					log(effect.recipe .. " enabled")
				end
			end
		end
	end
end
-------------------------------------------------------------------------------------
return data_util