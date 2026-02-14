-- src\client\player\Game\BuildingSystem\BuildingGrid.luau
--!strict
local Grid = {}

Grid.TILE_SIZE = 4
Grid.GRID_RADIUS = 6 -- 13x13 area
Grid.FLOOR_Y = 0
Grid.LINE_THICKNESS = 0.1

-- center of the allowed building area (spawn)
Grid.CENTER_POS = Vector3.new(0, 0, 0)

-- convert world position → grid cell
function Grid.worldToCell(pos: Vector3): Vector2
	local half = Grid.TILE_SIZE / 2
	local x = math.floor((pos.X + half) / Grid.TILE_SIZE)
	local y = math.floor((pos.Z + half) / Grid.TILE_SIZE)
	return Vector2.new(x, y)
end

-- convert cell → world position (center)
function Grid.cellToWorld(cell: Vector2): Vector3
	return Vector3.new(cell.X * Grid.TILE_SIZE, Grid.FLOOR_Y, cell.Y * Grid.TILE_SIZE)
end

-- check if cell is within allowed 25x25 area
function Grid.isInsideAllowedArea(cell: Vector2): boolean
	local centerCell = Grid.worldToCell(Grid.CENTER_POS)
	return math.abs(cell.X - centerCell.X) <= Grid.GRID_RADIUS
	   and math.abs(cell.Y - centerCell.Y) <= Grid.GRID_RADIUS
end

return Grid
