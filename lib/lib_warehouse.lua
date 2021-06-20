local lib_warehouse = {}
local myGlobal = require("__nco-LongWarehouses__/lib/nco_data")
--=================================================================================--
function lib_warehouse.getWHData(unitSize,whType,sizeScaling,suffix)
	sizeScaling = sizeScaling or 0
	local gridSize = unitSize*6 + math.max(0,unitSize-1)
	local whNameBase = "cust-warehouse"
	local whSizeName = string.format("%03d" , gridSize)
	local whTypeName = whType
	local whGroupName = string.format("%s-%s" , whNameBase , whSizeName)
	local whName = string.format("%s-%s-%s", whNameBase, whTypeName, whSizeName)
	if suffix then
		whName = whName .. "-" .. suffix
	end
	local whInvSize = math.min(unitSize * sizeScaling,540) -- Factorio team member "Earendal" mentions that containers >540 units have a huge ups issue. I dont know why this is, but I take his word for it.
	local whHealth = 500 + unitSize * 250
	return {whNameBase = whNameBase, whSizeName=whSizeName, whTypeName=whTypeName, whGroupName=whGroupName, whName=whName, gridSize=gridSize, whInvSize=whInvSize, whHealth=whHealth}
end
-------------------------------------------------------------------------------------
function lib_warehouse.getWHIcon(unitSize,whType)
	local whIconImage = "__nco-LongWarehouses__/graphics/icons/warehouse-" .. whType .. ".png"
	local whIconImageSize = "__nco-LongWarehouses__/graphics/icons/Numbers/icon_" .. tostring(unitSize) .. ".png"
	local Icons = {
		{
			icon = whIconImage,
			icon_size = myGlobal.imageInfo[whIconImage].width,
		},
		{
			icon = whIconImageSize,
			icon_size = myGlobal.imageInfo[whIconImageSize].width,
		}
	}
	return Icons
end
-------------------------------------------------------------------------------------
function lib_warehouse.getParentSize(unitSize,_)
	local parentSize = -1
	local sizeList = myGlobal.whSizes
	for k,v in pairs(sizeList) do
		if v < unitSize then
			parentSize = v
		else
			return parentSize
		end
	end
	return -1
end
-------------------------------------------------------------------------------------
function lib_warehouse.getWHParent(unitSize,logisticType,subType)
	if logisticType ~= "normal" then
		return lib_warehouse.getWHData(unitSize,"normal",0,subType)
	else
		local parentSize = lib_warehouse.getParentSize(unitSize,logisticType)
		if parentSize>0 then
			return lib_warehouse.getWHData(parentSize,"normal",0,subType)
		end
	end
end
-------------------------------------------------------------------------------------
function lib_warehouse.getWHIngredients(unitSize,logisticType,subType)
	local initialScore = math.pow(2,unitSize)*55
	local resourceScore = initialScore
	local baseIngredients ={
		{name="low-density-structure",	count=20,		limit=600,	val=1000000},
		{name="plastic-bar",			count=20,		limit=400,	val=100000},
		{name="concrete",				count=20,		limit=400,	val=10000},
		{name="small-lamp",				count=5,		limit=40,	val=1000},
		{name="stone-wall",				count=20,		limit=400,	val=100},
		{name="steel-chest",			count=5,		limit=50,	val=10},
		{name="stone-brick",			count=10,		limit=400,	val=1},
	}
	local techIngredients ={
		{name="nuclear-reactor",		count=1,		limit=10,	val=10000000},
		{name="roboport",				count=1,		limit=10,	val=1000000},
		{name="logistic-robot",			count=5,		limit=100,	val=10000},
		{name="processing-unit",		count=10,		limit=400,	val=100},
		{name="advanced-circuit",		count=10,		limit=400,	val=1},
	}
	local ingredients ={}
	local WHparent = lib_warehouse.getWHParent(unitSize,logisticType,subType)
	if WHparent then
		table.insert(ingredients, {WHparent.whName,1})
		resourceScore = resourceScore / 2
	end
	local resourceCount = math.min(5,unitSize)
	local data
	if logisticType == "normal" then
		data = lib_warehouse.getWHIngredients2(resourceScore,baseIngredients,resourceCount)
	else
		data = lib_warehouse.getWHIngredients2(resourceScore,techIngredients,2)
	end
	local additionalIngredients = data.ingredients
	--log("dyn additionalIngredients done")
	for k,v in pairs(additionalIngredients) do
		table.insert(ingredients, v)
	end
	--log("dyn recipe (score:" .. tostring(data.resourceScore) .. "/".. tostring(initialScore) .."):" )
	--log(serpent.block( ingredients, {comment = false, numformat = '%1.8g', compact = true } ))
	return ingredients
end
-------------------------------------------------------------------------------------
function lib_warehouse.getWHIngredients2(resourceScore,resourceTable,maxcount)
	--Konzept Preis
	--WH Wert unitSize*skalar
	--Immer ein WH der nächst kleineren Größe
	--Schleife (max 6 resourcen)
	--	50% restwert berechnen - Teuerste Resource für den Preis verwenden ( gerundet auf 50 )
	--normal
	-- stone brick, iron chest, steel chest, stone wall, small-lamp, concrete, plastic-bar, low-density-structure,
	-- logistics
	-- electronic-circuit, advanced-circuit, Processing unit, express-transport-belt, logistic-robot, roboport
	local ingredients = {}
	local i=0
	for k,res in pairs(resourceTable) do
		--log("checking resource")
		--log(serpent.block( res, {comment = false, numformat = '%1.8g' } ))
		if resourceScore>res.val then
			local cnt  = resourceScore/res.val
			cnt = math.floor(cnt/res.count)*res.count
			cnt = math.min(cnt,res.limit)
			if cnt>0 and i < maxcount then
				i = i + 1
				resourceScore = resourceScore - res.val*cnt
				table.insert(ingredients, {res.name,cnt})
			end
		end
	end
	return {ingredients=ingredients,resourceScore=resourceScore}
end
--=================================================================================--
function lib_warehouse.buildSpriteLayer(baseName,entityType,unitSize,direction)
	local imageFile, imageFileHr, shft
	local entityData = lib_warehouse.getWHData(unitSize,entityType,0,direction)
	local layers = {}
	local bgTint = {r = 0.6, g = 0.6, b = 0.8, a = 0.9}
	if entityType == "requester" then
		bgTint = {r = 0.15, g = 0.6, b = 0.9, a = 0.9}
	elseif entityType == "passive-provider" then
		bgTint = {r = 0.9, g = 0.3, b = 0.3, a = 0.9}
	elseif entityType == "storage" then
		bgTint = {r = 0.65, g = 0.65, b = 0.2, a = 0.9}
	elseif entityType == "active-provider" then
		bgTint = {r = 0.6, g = 0.2, b = 0.7, a = 0.9}
	elseif entityType == "buffer" then
		bgTint = {r = 0.2, g = 0.6, b = 0.2, a = 0.9}
	elseif baseName == "tank" then
		bgTint = {r = 0.1, g = 0.1, b = 0.1, a = 0.8}
	end
	-------------------------------------------------------------------------------------
	--left background
	-------------------------------------------------------------------------------------
	imageFile = "__nco-LongWarehouses__/graphics/entity/" .. baseName .. "-" .. direction .. "-bg-left.png"
	shft = {
		-(32*entityData.gridSize/2) + (32*3/2),
		5
	}
	if direction == "v" then
		shft = {0,shft[1]+2}
	end
	table.insert(layers,{
			filename = imageFile,
			width = myGlobal.imageInfo[imageFile].width,
			height = myGlobal.imageInfo[imageFile].height,
			shift = util.by_pixel(shft[1],shft[2]),
			scale = 0.25,
			tint = util.table.deepcopy(bgTint)
		})
	-------------------------------------------------------------------------------------
	--middle background
	-------------------------------------------------------------------------------------
	imageFile = "__nco-LongWarehouses__/graphics/entity/" .. baseName .. "-" .. direction .. "-bg-mid.png"
	if unitSize > 1 then
		for i=1,math.max(0,unitSize-1) do
			shft = {
				-(32*entityData.gridSize/2) + (32*6.5) + ((i-1)*32*7),
				5
			}
			if direction == "v" then
				shft = {0,shft[1]+2}
			end
			table.insert(layers,{
				filename = imageFile,
				width = myGlobal.imageInfo[imageFile].width,
				height = myGlobal.imageInfo[imageFile].height,
				shift = util.by_pixel(shft[1],shft[2]),
				scale = 0.25,
				tint = util.table.deepcopy(bgTint)
			})
		end
	end
	-------------------------------------------------------------------------------------
	--right background
	-------------------------------------------------------------------------------------
	imageFile = "__nco-LongWarehouses__/graphics/entity/" .. baseName .. "-" .. direction .. "-bg-right.png"
	shft = {
		(32*entityData.gridSize/2) - (32*3/2),
		5
	}
	if direction == "v" then
		shft = {0,shft[1]+2}
	end
	table.insert(layers,{
		filename = imageFile,
		width = myGlobal.imageInfo[imageFile].width,
		height = myGlobal.imageInfo[imageFile].height,
		shift = util.by_pixel(shft[1],shft[2]),
		scale = 0.25,
		tint = util.table.deepcopy(bgTint)
	})
	-------------------------------------------------------------------------------------
	--buildings
	-------------------------------------------------------------------------------------
	imageFile = "__nco-LongWarehouses__/graphics/entity/" .. baseName .. "-" .. direction .. "-building.png"
	imageFileHr = "__nco-LongWarehouses__/graphics/entity/hr/" .. baseName .. "-" .. direction .. "-building.png"
	for i=1,unitSize do
		shft = {
			-(32*entityData.gridSize/2) + (32*6/2 + 5) + ((i-1)*32*7)-5,
			0
		}
		if direction == "v" then
			shft = {0,shft[1]}
		end
		table.insert(layers,{
			filename = imageFile,
			width = myGlobal.imageInfo[imageFile].width,
			height = myGlobal.imageInfo[imageFile].height,
			shift = util.by_pixel(shft[1],shft[2]),
			hr_version = {
				filename = imageFileHr,
				width = myGlobal.imageInfo[imageFileHr].width,
				height = myGlobal.imageInfo[imageFileHr].height,
				shift = util.by_pixel(shft[1],shft[2]),
				scale = 0.25,
			}
		})
	end
	--Power Pole
	table.insert(layers,{
				filename = "__nco-LongWarehouses__/graphics/entity/hr/addon-power-pole.png",
				width = myGlobal.imageInfo["__nco-LongWarehouses__/graphics/entity/hr/addon-power-pole.png"].width,
				height = myGlobal.imageInfo["__nco-LongWarehouses__/graphics/entity/hr/addon-power-pole.png"].height,
				shift = { 0, -0.85 },
				scale = 0.5,
		})
	table.insert(layers,{
				draw_as_shadow = true,
				filename = "__nco-LongWarehouses__/graphics/entity/hr/addon-power-pole-shadow.png",
				width = myGlobal.imageInfo["__nco-LongWarehouses__/graphics/entity/hr/addon-power-pole-shadow.png"].width,
				height = myGlobal.imageInfo["__nco-LongWarehouses__/graphics/entity/hr/addon-power-pole-shadow.png"].height,
				shift = { 0.75, 0 },
				scale = 0.5,
		})
	--log(serpent.block( layers, {comment = false, numformat = '%1.8g', compact = true } ))
	return util.table.deepcopy(layers)
end	
--=================================================================================--
function lib_warehouse.checkEntityName(name)
	log("checking name " .. name)
	if string.find(name, "^cust%-warehouse%-.+%-%d%d%d%-proxy$") then
		return "proxy"
	end
	if string.find(name, "^cust%-warehouse%-.+%-%d%d%d%-h$") then
		return "horizontal"
	end
	if string.find(name, "^cust%-warehouse%-.+%-%d%d%d%-v$") then
		return "vertical"
	end
	if name == "warehouse-signal-pole"then
		return "pole"
	end
	if string.find(name, "^cust%-warehouse%-.+%-%d%d%d%$") then
		return "-"
	end
	return false
end
--=================================================================================--
function lib_warehouse.checkEntity(entity)
	log("checking entity " .. entity.type)
	if entity.type == "entity-ghost" then
		return "entity-ghost", lib_warehouse.checkEntityName(entity.ghost_name)
	else
		return 'entity', lib_warehouse.checkEntityName(entity.name)
	end
end
--=================================================================================--
return lib_warehouse