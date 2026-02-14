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
local currentKey: string? = "BasicPan"

-- toggleable build mode -- default
local buildModeEnabled = false 
local gridSpawned = false

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
			clearGrid()
		end
	end
end)

RunService.RenderStepped:Connect(function()
	-- only clear ghost tiles, grid lines remain
	Ghost.clearTiles()
	if not buildModeEnabled or not currentKey or not mouse.Hit then
		return
	end

	local size = FurnitureData[currentKey].Size
	local cell = Grid.getPointingCell(mouse.Hit.Position, size)
	pointEv:FireServer(cell)

	for dx = 0, size.X - 1 do
		for dy = 0, size.Y - 1 do
			Ghost.spawnTile(cell + Vector2.new(dx, dy), false)
		end
	end
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
	end
end)
