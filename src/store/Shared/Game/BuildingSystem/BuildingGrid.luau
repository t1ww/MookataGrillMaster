-- src\store\Shared\Game\BuildingSystem\BuildingGrid.luau
--!strict
local RunService = game:GetService("RunService")

local Grid = {}

Grid.tileSize = 4
Grid.areaSize = 50
Grid.plotOrigin = Vector3.new(0, 0, 0)

-- Bounds helpers
local function getHalfSize(): number
	return math.floor(Grid.areaSize / 2)
end

function Grid.isInside(cell: Vector2): boolean
	local half = getHalfSize()
	return math.abs(cell.X) <= half and math.abs(cell.Y) <= half
end

function Grid.worldToCell(pos: Vector3): Vector2
	local relative = pos - Grid.plotOrigin
	local halfTile = Grid.tileSize / 2
	local x = math.floor((relative.X + halfTile) / Grid.tileSize)
	local y = math.floor((relative.Z + halfTile) / Grid.tileSize)
	return Vector2.new(x, y)
end

function Grid.cellToWorld(cell: Vector2): Vector3
	local x = cell.X * Grid.tileSize
	local z = cell.Y * Grid.tileSize
	return Grid.plotOrigin + Vector3.new(x, 0, z)
end

-- Centralized pointing index
function Grid.getPointingCell(worldPos: Vector3, size: Vector2): Vector2
	local relative = worldPos - Grid.plotOrigin
	local x = math.floor(relative.X / Grid.tileSize + 0.5)
	local y = math.floor(relative.Z / Grid.tileSize + 0.5)
	local cell = Vector2.new(x, y)
	local half = math.floor(Grid.areaSize / 2)
	return Vector2.new(math.clamp(cell.X, -half, half - size.X + 1), math.clamp(cell.Y, -half, half - size.Y + 1))
end

-- Occupancy server-only
local occupancy: { [string]: boolean } = {}

if RunService:IsServer() then
	function Grid.canOccupy(cell: Vector2, size: Vector2): boolean
		for dx = 0, size.X - 1 do
			for dy = 0, size.Y - 1 do
				local checkCell = Vector2.new(cell.X + dx, cell.Y + dy)
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
else
	Grid.canOccupy = function()
		return true
	end
	Grid.occupy = function() end
end

function Grid.clear(cell: Vector2, size: Vector2)
	if RunService:IsServer() then
		for dx = 0, size.X - 1 do
			for dy = 0, size.Y - 1 do
				local key = ("%d,%d"):format(cell.X + dx, cell.Y + dy)
				occupancy[key] = nil
			end
		end
	end
end

function Grid.setPlotOrigin(origin: Vector3)
	Grid.plotOrigin = origin
end

return Grid
