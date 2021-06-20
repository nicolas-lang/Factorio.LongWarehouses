if not data.raw["item-subgroup"]["cust-warehouse"] then
	data:extend({
		{
			type = "item-subgroup",
			name = "cust-warehouse",
			group = "logistics",
			order = "zd",
		},
	})
end