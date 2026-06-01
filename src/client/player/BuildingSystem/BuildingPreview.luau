-- src\client\player/Game/BuildingSystem/BuildingPreview.luau
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Grid = require(ReplicatedStorage.FromRojo.Shared.Game.BuildingSystem.BuildingGrid)

local BuildingPreview = {}
-- active ghost tiles (per-frame)
BuildingPreview.tiles = {}
-- persistent grid lines (guide)
BuildingPreview.gridLines = {}
-- part pool for recycling
BuildingPreview.partPool = {}
-- colors for ghost tiles
BuildingPreview.ghostColors = {}
-- current ghost model
BuildingPreview.ghostModel = nil

local LINE_THICKNESS = 0.15

-- folder to keep ghost parts organized
local folder = workspace:FindFirstChild("BuildingGhosts")
if not folder then
	folder = Instance.new("Folder")
	folder.Name = "BuildingGhosts"
	folder.Parent = workspace
end

-- get a part from pool or create new
local function getPart(): Part
	local p = table.remove(BuildingPreview.partPool)
	if p then
		p.Parent = folder
		return p
	end
	-- Create new part
	local newPart = Instance.new("Part")
	newPart.Anchored = true
	newPart.CanCollide = false
	newPart.CanTouch = false
	newPart.CanQuery = false
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
function BuildingPreview.spawnTile(cell: Vector2)
	if not Grid.isInside(cell) then
		return
	end
	local worldPos = Grid.cellToWorld(cell)

	-- determine color from latest server update
	local key = ("%d,%d"):format(cell.X, cell.Y)
	local occupied = BuildingPreview.ghostColors[key] or false -- <- use BuildingPreview.ghostColors
	local color = occupied and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
	local opacity = 0.5

	local part = spawnPart(CFrame.new(worldPos), Vector3.new(Grid.tileSize, 0.5, Grid.tileSize), color, opacity)
	table.insert(BuildingPreview.tiles, part)
end

-- spawn grid line (persistent)
function BuildingPreview.spawnGridLine(cell: Vector2, centerCell: Vector2)
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
		table.insert(BuildingPreview.gridLines, part)
	end
end

-- spawn ghost model
function BuildingPreview.spawnGhostModel(key: string, cell: Vector2, occupied: boolean)
	if BuildingPreview.ghostModel then
		BuildingPreview.ghostModel:Destroy()
	end

	local TEMPLATES = ReplicatedStorage:WaitForChild("Cloud"):WaitForChild("BuildingTemplates")
	local template = TEMPLATES:FindFirstChild(key)
	if not template then
		return
	end
	local model = template:Clone()

	local color = occupied and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)

	-- make it ghost
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = true
			part.CanCollide = false
			part.Transparency = 0.5
			part.Color = color
		end
	end

	-- position
	local FurnitureData = require(ReplicatedStorage.FromRojo.Data.Items.Furniture)
	local size = FurnitureData[key].Size
	local centerCell = cell + Vector2.new((size.X - 1) / 2, (size.Y - 1) / 2)
	local pos = Grid.cellToWorld(centerCell)

	if model.PrimaryPart then
		model:SetPrimaryPartCFrame(CFrame.new(pos + Vector3.new(0, model.PrimaryPart.Size.Y / 2, 0)))
	else
		model:PivotTo(CFrame.new(pos))
	end

	model.Parent = folder
	BuildingPreview.ghostModel = model
end

-- clear ghost tiles only (per-frame)
function BuildingPreview.clearTiles()
	for _, p in ipairs(BuildingPreview.tiles) do
		p.Parent = nil
		table.insert(BuildingPreview.partPool, p)
	end
	BuildingPreview.tiles = {}
end

-- clear grid lines (when toggling off)
function BuildingPreview.clearGrid()
	for _, p in ipairs(BuildingPreview.gridLines) do
		p.Parent = nil
		table.insert(BuildingPreview.partPool, p)
	end
	BuildingPreview.gridLines = {}
end

-- clear ghost model
function BuildingPreview.clearGhostModel()
	if BuildingPreview.ghostModel then
		BuildingPreview.ghostModel:Destroy()
		BuildingPreview.ghostModel = nil
	end
end

return BuildingPreview
