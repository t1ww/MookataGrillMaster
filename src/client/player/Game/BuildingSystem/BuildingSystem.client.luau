-- src/client/player/Game/BuildingSystem/BuildingSystem.client.lua
--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage"):WaitForChild("FromRojo")

local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()

local Grid = require(ReplicatedStorage.Shared.Game.BuildingSystem.BuildingGrid)
local Ghost = require(script.Parent:WaitForChild("GhostPart"))
local FurnitureData = require(ReplicatedStorage.Data.Items.Furniture)
local placeEv = ReplicatedStorage.BuildingRemotes.PlaceBuilding
local pointEv = ReplicatedStorage.BuildingRemotes.PointingCellUpdate

-- currently selected building
local currentKey: string? = "WoodenTable1x1"

-- toggleable build mode -- default
local buildModeEnabled = false
local gridSpawned = false

-- track last highlighted cell to avoid flicker
local lastCell: Vector2? = nil

-- spawn all grid lines once
local function spawnGrid()
	if gridSpawned then
		return
	end
	gridSpawned = true
	local half = math.floor(Grid.areaSize / 2)
	for dx = -half, half do
		for dy = -half, half do
			Ghost.spawnGridLine(Vector2.new(dx, dy), Vector2.zero)
		end
	end
end

-- clear all grid lines
local function clearGrid()
	if not gridSpawned then
		return
	end
	gridSpawned = false
	Ghost.clearGrid() -- this now clear only grid lines on toggle off
end

-- centralized ghost renderer (single source of truth)
local function renderGhost(cell: Vector2)
	if not currentKey then
		return
	end

	local size = FurnitureData[currentKey].Size

	Ghost.clearTiles()
	for dx = 0, size.X - 1 do
		for dy = 0, size.Y - 1 do
			Ghost.spawnTile(cell + Vector2.new(dx, dy))
		end
	end
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
			Ghost.clearTiles()
			clearGrid()
		end
	end
end)

RunService.RenderStepped:Connect(function()
	-- only clear ghost tiles, grid lines remain
	if not buildModeEnabled or not currentKey or not mouse.Hit then
		lastCell = nil
		Ghost.clearTiles()
		return
	end

	local size = FurnitureData[currentKey].Size
	local cell = Grid.getPointingCell(mouse.Hit.Position, size)

	-- only update if cell changed
	if lastCell and lastCell == cell then
		return
	end

	lastCell = cell

	pointEv:FireServer(cell) -- only here

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
		placeEv:FireServer(currentKey, mouse.Hit.Position)
		-- force next RenderStepped to recompute
		lastCell = nil
	end
end)

-- ensure the UpdateGhostColor RemoteEvent exists on client
local ghostEv = ReplicatedStorage:WaitForChild("BuildingRemotes"):WaitForChild("UpdateGhostColor")

-- listen for server updates
ghostEv.OnClientEvent:Connect(function(cell: Vector2, occupied: boolean)
	local key = ("%d,%d"):format(cell.X, cell.Y)

	local previous = Ghost.ghostColors[key]
	if previous == nil then
		previous = false
	end

	if previous == occupied then
		return -- no visual change
	end

	Ghost.ghostColors[key] = occupied

	if lastCell and lastCell == cell then
		renderGhost(cell)
	end
end)
