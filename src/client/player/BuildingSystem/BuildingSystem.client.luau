-- src/client/player/Game/BuildingSystem/BuildingSystem.client.lua
--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage"):WaitForChild("FromRojo")

local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()

local Grid = require(ReplicatedStorage.Shared.Game.BuildingSystem.BuildingGrid)
local BuildingPreview = require(script.Parent:WaitForChild("BuildingPreview"))
local FurnitureData = require(ReplicatedStorage.Data.Items.Furniture)

local remotes = ReplicatedStorage:WaitForChild("BuildingRemotes")
local placeEv = remotes:WaitForChild("PlaceBuilding")
local pointEv = remotes:WaitForChild("PointingCellUpdate")
local ghostEv = remotes:WaitForChild("UpdateGhostColor")
local configEv = remotes:WaitForChild("InitGrid")

-- listen for grid config
configEv.OnClientEvent:Connect(function(config)
	Grid.setPlotOrigin(config.origin)
end)

-- currently selected building
local currentKey: string? = "WoodenTable1x1"

-- toggleable build mode -- default
local buildModeEnabled = false
local gridSpawned = false

-- track last highlighted cell to avoid flicker
local lastCell: Vector2? = nil
local lastPointRequestId = 0

-- grid spawning queue
local pendingGridCells = {}
local pendingGridIndex = 1
local GRID_CELLS_PER_FRAME = 20

local gridClearing = false

local function getPlayerCell(): Vector2
	local character = localPlayer.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")

	if rootPart then
		return Grid.worldToCell(rootPart.Position)
	end

	return Vector2.zero
end

-- spawn all grid lines once
local function spawnGrid()
	if gridSpawned then
		return
	end

	gridSpawned = true
	gridClearing = false

	pendingGridCells = {}
	pendingGridIndex = 1

	local playerCell = getPlayerCell()
	local half = math.floor(Grid.areaSize / 2)

	for dx = -half, half do
		for dy = -half, half do
			local cell = Vector2.new(dx, dy)

			table.insert(pendingGridCells, {
				cell = cell,
				distance = (cell - playerCell).Magnitude,
			})
		end
	end

	table.sort(pendingGridCells, function(a, b)
		return a.distance < b.distance
	end)
end

-- clear all grid lines
local function clearGrid()
	if not gridSpawned then
		return
	end

	gridClearing = true

	pendingGridCells = {}
	pendingGridIndex = 1

	local playerCell = getPlayerCell()
	local half = math.floor(Grid.areaSize / 2)

	for dx = -half, half do
		for dy = -half, half do
			local cell = Vector2.new(dx, dy)

			table.insert(pendingGridCells, {
				cell = cell,
				distance = (cell - playerCell).Magnitude,
			})
		end
	end

	table.sort(pendingGridCells, function(a, b)
		return a.distance > b.distance
	end)
end

-- centralized ghost renderer (single source of truth)
local function renderGhost(cell: Vector2)
	if not currentKey then
		return
	end

	local size = FurnitureData[currentKey].Size
	local occupied = false

	for dx = 0, size.X - 1 do
		for dy = 0, size.Y - 1 do
			local key = ("%d,%d"):format(cell.X + dx, cell.Y + dy)

			if BuildingPreview.ghostColors[key] then
				occupied = true
				break
			end
		end

		if occupied then
			break
		end
	end

	BuildingPreview.clearGhostModel()
	BuildingPreview.spawnGhostModel(currentKey, cell, occupied)
end

-- toggle key
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then
		return
	end

	if input.KeyCode == Enum.KeyCode.One then
		buildModeEnabled = not buildModeEnabled

		if buildModeEnabled then
			spawnGrid()
		else
			lastCell = nil
			BuildingPreview.clearGhostModel()
			clearGrid()
		end
	end
end)

RunService.RenderStepped:Connect(function()
	-- gradually spawn grid lines from player outward
	if buildModeEnabled and gridSpawned and not gridClearing then
		for _ = 1, GRID_CELLS_PER_FRAME do
			local data = pendingGridCells[pendingGridIndex]

			if not data then
				break
			end

			BuildingPreview.spawnGridLine(data.cell, getPlayerCell())

			pendingGridIndex += 1
		end
	end

	-- gradually remove grid lines from furthest inward
	if gridClearing then
		for _ = 1, GRID_CELLS_PER_FRAME do
			local data = pendingGridCells[pendingGridIndex]

			if not data then
				gridClearing = false
				gridSpawned = false
				break
			end
			BuildingPreview.removeGridCell(data.cell)
			pendingGridIndex += 1
		end
	end

	-- only clear ghost tiles, grid lines remain
	if (not buildModeEnabled) or not currentKey or not mouse.Hit then
		lastCell = nil
		BuildingPreview.clearGhostModel()
		return
	end

	local size = FurnitureData[currentKey].Size
	local cell = Grid.getPointingCell(mouse.Hit.Position, size)

	-- only update if cell changed
	if lastCell and lastCell == cell then
		return
	end

	lastCell = cell
	lastPointRequestId += 1

	pointEv:FireServer(cell, size, lastPointRequestId) -- only here

	renderGhost(cell)
end)

-- placement
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then
		return
	end

	if not buildModeEnabled then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 and currentKey then
		placeEv:FireServer(currentKey, lastCell)

		-- force next RenderStepped to recompute
		lastCell = nil
	end
end)

-- listen for server updates
ghostEv.OnClientEvent:Connect(function(cell: Vector2, occupied: boolean, requestId: number?)
	if not requestId or requestId ~= lastPointRequestId then
		return
	end

	local key = ("%d,%d"):format(cell.X, cell.Y)
	BuildingPreview.ghostColors[key] = occupied

	if lastCell and lastCell == cell then
		renderGhost(cell)
	end
end)
