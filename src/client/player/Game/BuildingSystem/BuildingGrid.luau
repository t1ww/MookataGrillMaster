-- src/server/Game/BuildingSystem/BuildingGrid.luau
--!strict

local Grid = {}

Grid.tileSize = 4 -- studs per grid cell
Grid.areaSize = 13 -- 13x13 build area
Grid.plotOrigin = Vector3.new(0, 0, 0)

-- occupancy map: { ["x,y"] = true }
local occupancy: { [string]: boolean } = {}

-- Plot configuration
function Grid.setPlotOrigin(origin: Vector3)
	Grid.plotOrigin = origin
end

-- Bounds helpers
-- Half size computed from areaSize
local function getHalfSize(): number
	return math.floor(Grid.areaSize / 2)
end

function Grid.isInside(cell: Vector2): boolean
	local half = getHalfSize()
	return math.abs(cell.X) <= half and math.abs(cell.Y) <= half
end

-- Conversions
-- world Position → grid cell (Vector2)
function Grid.worldToCell(pos: Vector3): Vector2
	local relative = pos - Grid.plotOrigin
	local halfTile = Grid.tileSize / 2

	local x = math.floor((relative.X + halfTile) / Grid.tileSize)
	local y = math.floor((relative.Z + halfTile) / Grid.tileSize)

	return Vector2.new(x, y)
end

-- grid cell → world Position (center of cell)
function Grid.cellToWorld(cell: Vector2): Vector3
	local x = cell.X * Grid.tileSize
	local z = cell.Y * Grid.tileSize

	return Grid.plotOrigin + Vector3.new(x, 0, z)
end

-- Occupancy
function Grid.canOccupy(cell: Vector2, size: Vector2): boolean
	for dx = 0, size.X - 1 do
		for dy = 0, size.Y - 1 do
			local checkCell = Vector2.new(cell.X + dx, cell.Y + dy)

			-- 🔥 Bounds check added
			if not Grid.isInside(checkCell) then
				return false
			end

			local key = ("%d,%d"):format(checkCell.X, checkCell.Y)
			if occupancy[key] then
				return false
			end
		end
	end

	return true
end

function Grid.occupy(cell: Vector2, size: Vector2)
	for dx = 0, size.X - 1 do
		for dy = 0, size.Y - 1 do
			local key = ("%d,%d"):format(cell.X + dx, cell.Y + dy)
			occupancy[key] = true
		end
	end
end

function Grid.clear(cell: Vector2, size: Vector2)
	for dx = 0, size.X - 1 do
		for dy = 0, size.Y - 1 do
			local key = ("%d,%d"):format(cell.X + dx, cell.Y + dy)
			occupancy[key] = nil
		end
	end
end

return Grid
