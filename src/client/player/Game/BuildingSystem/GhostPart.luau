-- src\client\player\Game\BuildingSystem\GhostPart.luau
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Grid = require(ReplicatedStorage.FromRojo.Shared.Game.BuildingSystem.BuildingGrid)

local Ghost = {}
Ghost.parts = {}

local LINE_THICKNESS = 0.15

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

-- spawn a single tile ghost (highlight)
function Ghost.spawnTile(cell: Vector2, occupied: boolean)
	if not Grid.isInside(cell) then
		return
	end

	local worldPos = Grid.cellToWorld(cell)
	local color = occupied and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)

	Ghost.spawnPart(CFrame.new(worldPos), Vector3.new(Grid.tileSize, 0.5, Grid.tileSize), color, 0.5)
end

-- spawn grid lines
function Ghost.spawnGridLine(cell: Vector2, centerCell: Vector2)
	if not Grid.isInside(cell) then
		return
	end

	local worldPos = Grid.cellToWorld(cell)

	local dx = cell.X - centerCell.X
	local dy = cell.Y - centerCell.Y
	local distance = Vector2.new(dx, dy).Magnitude

	local halfArea = math.floor(Grid.areaSize / 2)
	local alpha = math.clamp(distance / halfArea, 0, 1)
	local transparency = 0.2 + alpha * 0.5

	local halfTile = Grid.tileSize / 2
	local lt = LINE_THICKNESS

	local edges = {
		{
			CFrame = CFrame.new(worldPos.X, worldPos.Y, worldPos.Z - halfTile + lt / 2),
			Size = Vector3.new(Grid.tileSize, 0.2, lt),
		},
		{
			CFrame = CFrame.new(worldPos.X, worldPos.Y, worldPos.Z + halfTile - lt / 2),
			Size = Vector3.new(Grid.tileSize, 0.2, lt),
		},
		{
			CFrame = CFrame.new(worldPos.X - halfTile + lt / 2, worldPos.Y, worldPos.Z),
			Size = Vector3.new(lt, 0.2, Grid.tileSize),
		},
		{
			CFrame = CFrame.new(worldPos.X + halfTile - lt / 2, worldPos.Y, worldPos.Z),
			Size = Vector3.new(lt, 0.2, Grid.tileSize),
		},
	}

	for _, e in ipairs(edges) do
		Ghost.spawnPart(e.CFrame, e.Size, Color3.fromRGB(0, 255, 0), transparency)
	end
end

return Ghost
