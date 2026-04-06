-- src\store\Data\Items\Furniture.luau
-- Keeping these in ReplicatedStorage / Cloud / BuildingTemplates
-- - Example: ReplicatedStorage/Cloud/BuildingTemplates/BasicBoatGrillPan for the BasicBoatGrillPan in the data.
-- By the table, placing chairs <= prefer amount will +satisfy, max will -satisfy
local Furniture = {
	-- Pans
	BasicBoatGrillPan = { Price = 75, Size = Vector2.new(1, 1) },
	SteelBoatGrillPan = { Price = 120, Size = Vector2.new(1, 1) },

	-- Tables
	WoodenTable1x1 = { Price = 50, Size = Vector2.new(1, 1) }, -- Prefer 2 chair, max 4 chair
	WoodenTable2x1 = { Price = 100, Size = Vector2.new(2, 1) }, -- Prefer 4 chair, max 6 chair

	-- Chair
	WoodenStool = { Price = 50, Size = Vector2.new(1, 1) },
}

return Furniture
