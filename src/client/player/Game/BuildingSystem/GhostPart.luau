-- src\client\player\Game\BuildingSystem\GhostPart.luau
--!strict
local Grid = require(script.Parent:WaitForChild("BuildingGrid"))

local Ghost = {}
Ghost.parts = {}

-- create a single ghost part or edge
function Ghost.spawnPart(cframe: CFrame, size: Vector3, color: Color3, transparency: number)
	local part = Instance.new("Part")
	part.Size = size
	part.CFrame = cframe
	part.Anchored = true
	part.CanCollide = false
	part.Material = Enum.Material.Neon
	part.Transparency = transparency
	part.Color = color
	part.Parent = workspace
	table.insert(Ghost.parts, part)
end

-- clear previous parts
function Ghost.clear()
	for _, p in ipairs(Ghost.parts) do
		p:Destroy()
	end
	Ghost.parts = {}
end

-- spawn a single tile ghost (highlight) with optional occupancy
function Ghost.spawnTile(cell: Vector2, occupied: boolean)
	if not Grid.isInsideAllowedArea(cell) then
		return
	end

	local worldPos = Grid.cellToWorld(cell)
	local color = occupied and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
	Ghost.spawnPart(CFrame.new(worldPos), Vector3.new(Grid.TILE_SIZE, 0.5, Grid.TILE_SIZE), color, 0.5)
end

-- spawn grid lines (fade out with distance from centerCell)
function Ghost.spawnGridLine(cell: Vector2, centerCell: Vector2)
	if not Grid.isInsideAllowedArea(cell) then
		return
	end

	local worldPos = Grid.cellToWorld(cell)
	local dx, dy = cell.X - centerCell.X, cell.Y - centerCell.Y
	local distance = Vector2.new(dx, dy).Magnitude
	local alpha = math.clamp(distance / Grid.GRID_RADIUS, 0, 1)
	local transparency = 0.2 + alpha * 0.5

	local half = Grid.TILE_SIZE / 2
	local lt = Grid.LINE_THICKNESS

	local edges = {
		{
			CFrame = CFrame.new(worldPos.X, worldPos.Y, worldPos.Z - half + lt / 2),
			Size = Vector3.new(Grid.TILE_SIZE, 0.2, lt),
		},
		{
			CFrame = CFrame.new(worldPos.X, worldPos.Y, worldPos.Z + half - lt / 2),
			Size = Vector3.new(Grid.TILE_SIZE, 0.2, lt),
		},
		{
			CFrame = CFrame.new(worldPos.X - half + lt / 2, worldPos.Y, worldPos.Z),
			Size = Vector3.new(lt, 0.2, Grid.TILE_SIZE),
		},
		{
			CFrame = CFrame.new(worldPos.X + half - lt / 2, worldPos.Y, worldPos.Z),
			Size = Vector3.new(lt, 0.2, Grid.TILE_SIZE),
		},
	}

	for _, e in ipairs(edges) do
		Ghost.spawnPart(e.CFrame, e.Size, Color3.fromRGB(0, 255, 0), transparency)
	end
end

return Ghost
