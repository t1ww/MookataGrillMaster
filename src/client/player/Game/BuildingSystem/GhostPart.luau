-- src\client\player/Game/BuildingSystem/GhostPart.luau
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Grid = require(ReplicatedStorage.FromRojo.Shared.Game.BuildingSystem.BuildingGrid)

local Ghost = {}
Ghost.tiles = {} -- active ghost tiles (per-frame)
Ghost.gridLines = {} -- persistent grid lines
Ghost.partPool = {} -- recycled parts

local LINE_THICKNESS = 0.15

-- folder to keep ghost parts organized
local folder = workspace:FindFirstChild("GhostParts")
if not folder then
	folder = Instance.new("Folder")
	folder.Name = "GhostParts"
	folder.Parent = workspace
end

-- get a part from pool or create new
local function getPart(): Part
	local p = table.remove(Ghost.partPool)
	if p then
		p.Parent = folder
		return p
	end
	local newPart = Instance.new("Part")
	newPart.Anchored = true
	newPart.CanCollide = false
	newPart.Material = Enum.Material.Neon
	newPart.Parent = folder
	return newPart
end

-- spawn a part
local function spawnPart(cframe: CFrame, size: Vector3, color: Color3, transparency: number): Part
	local part = getPart()
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Transparency = transparency
	return part
end

-- spawn a ghost tile (highlight)
function Ghost.spawnTile(cell: Vector2, occupied: boolean)
	if not Grid.isInside(cell) then
		return
	end
	local worldPos = Grid.cellToWorld(cell)
	local color = occupied and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
	local part = spawnPart(CFrame.new(worldPos), Vector3.new(Grid.tileSize, 0.5, Grid.tileSize), color, 0.5)
	table.insert(Ghost.tiles, part)
end

-- spawn grid line (persistent)
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
		local part = spawnPart(e.CFrame, e.Size, Color3.fromRGB(0, 255, 0), transparency)
		table.insert(Ghost.gridLines, part)
	end
end

-- clear ghost tiles only (per-frame)
function Ghost.clearTiles()
	for _, p in ipairs(Ghost.tiles) do
		p.Parent = nil
		table.insert(Ghost.partPool, p)
	end
	Ghost.tiles = {}
end

-- clear grid lines (when toggling off)
function Ghost.clearGrid()
	for _, p in ipairs(Ghost.gridLines) do
		p.Parent = nil
		table.insert(Ghost.partPool, p)
	end
	Ghost.gridLines = {}
end

return Ghost
