-- src/server/Game/BuildingSystem/BuildingGrid.luau
--!strict

local Grid = {}
Grid.tileSize = 4 -- studs per grid cell

-- occupancy map: { ["x,y"] = true }
local occupancy: { [string]: boolean } = {}

-- world Position → grid cell (Vector2)
function Grid.worldToCell(pos: Vector3): Vector2
	local half = Grid.tileSize / 2
	local x = math.floor((pos.X + half) / Grid.tileSize)
	local y = math.floor((pos.Z + half) / Grid.tileSize)
	return Vector2.new(x, y)
end

-- grid cell → world Position (center of cell)
function Grid.cellToWorld(cell: Vector2): Vector3
	local x = cell.X * Grid.tileSize
	local z = cell.Y * Grid.tileSize
	return Vector3.new(x, 0, z)
end

-- return true if all cells in the area are free
function Grid.canOccupy(cell: Vector2, size: Vector2): boolean
	for dx = 0, size.X - 1 do
		for dy = 0, size.Y - 1 do
			local key = ("%d,%d"):format(cell.X + dx, cell.Y + dy)
			if occupancy[key] then
				return false
			end
		end
	end
	return true
end

-- mark region as occupied
function Grid.occupy(cell: Vector2, size: Vector2)
	for dx = 0, size.X - 1 do
		for dy = 0, size.Y - 1 do
			local key = ("%d,%d"):format(cell.X + dx, cell.Y + dy)
			occupancy[key] = true
		end
	end
end

-- optional: free up a region
function Grid.clear(cell: Vector2, size: Vector2)
	for dx = 0, size.X - 1 do
		for dy = 0, size.Y - 1 do
			local key = ("%d,%d"):format(cell.X + dx, cell.Y + dy)
			occupancy[key] = nil
		end
	end
end

return Grid
