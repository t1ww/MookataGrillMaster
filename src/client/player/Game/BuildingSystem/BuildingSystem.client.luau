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

-- spawn all grid lines once
local function spawnGrid()
	if (gridSpawned) then
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
	if (not gridSpawned) then
		return
	end
	gridSpawned = false
	Ghost.clearGrid() -- this now clear only grid lines on toggle off
end

-- centralized ghost renderer (single source of truth)
local function renderGhost(cell: Vector2)
	if (not currentKey) then
		return
	end

	local size = FurnitureData[currentKey].Size
	local occupied = false
	for dx = 0, size.X - 1 do
		for dy = 0, size.Y - 1 do
			local key = ("%d,%d"):format(cell.X + dx, cell.Y + dy)
			if (Ghost.ghostColors[key]) then
				occupied = true
				break
			end
		end
		if (occupied) then
			break
		end
	end

	Ghost.clearGhostModel()
	Ghost.spawnGhostModel(currentKey, cell, occupied)
end

-- toggle key
UserInputService.InputBegan:Connect(function(input, gpe)
	if (gpe) then
		return
	end
	if (input.KeyCode == Enum.KeyCode.One) then
		buildModeEnabled = not buildModeEnabled
		if (buildModeEnabled) then
			spawnGrid()
		else
			lastCell = nil
			Ghost.clearGhostModel()
			clearGrid()
		end
	end
end)

RunService.RenderStepped:Connect(function()
	-- only clear ghost tiles, grid lines remain
	if ((not buildModeEnabled) or (not currentKey) or (not mouse.Hit)) then
		lastCell = nil
		Ghost.clearGhostModel()
		return
	end

	local size = FurnitureData[currentKey].Size
	local cell = Grid.getPointingCell(mouse.Hit.Position, size)

	-- only update if cell changed
	if (lastCell and lastCell == cell) then
		return
	end

	lastCell = cell
	lastPointRequestId += 1
	pointEv:FireServer(cell, size, lastPointRequestId) -- only here

	renderGhost(cell)
end)

-- placement
UserInputService.InputBegan:Connect(function(input, gpe)
	if (gpe) then
		return
	end
	if (not buildModeEnabled) then
		return
	end
	if (input.UserInputType == Enum.UserInputType.MouseButton1 and currentKey) then
		placeEv:FireServer(currentKey, lastCell)
		-- force next RenderStepped to recompute
		lastCell = nil
	end
end)

-- listen for server updates
ghostEv.OnClientEvent:Connect(function(cell: Vector2, occupied: boolean, requestId: number?)
	if (not requestId or requestId ~= lastPointRequestId) then
		return
	end

	local key = ("%d,%d"):format(cell.X, cell.Y)
	Ghost.ghostColors[key] = occupied

	if (lastCell and lastCell == cell) then
		renderGhost(cell)
	end
end)
