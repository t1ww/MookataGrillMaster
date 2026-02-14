-- src/client/player/Game/BuildingSystem/BuildingSystem.client.lua
--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()

local Grid = require(script.Parent:WaitForChild("BuildingGrid"))
local Ghost = require(script.Parent:WaitForChild("GhostPart"))

local placeEv = ReplicatedStorage:WaitForChild("BuildingRemotes"):WaitForChild("PlaceBuilding")
local FurnitureData = require(ReplicatedStorage.FromRojo.Data.Items.Furniture)

local currentKey: string? = "BasicPan"

RunService.RenderStepped:Connect(function()
	Ghost.clear()
	if not currentKey or not mouse.Hit then
		return
	end

	local baseCell = Grid.worldToCell(mouse.Hit.Position)
	local size = FurnitureData[currentKey].Size

	-- limit tiles in allowed area
	for dx = 0, size.X - 1 do
		for dy = 0, size.Y - 1 do
			local cell = baseCell + Vector2.new(dx, dy)
			Ghost.spawnTile(cell, false) -- occupancy check can be added later
		end
	end

	-- grid lines
	local centerCell = Grid.worldToCell(Grid.CENTER_POS)
	for dx = -Grid.GRID_RADIUS, Grid.GRID_RADIUS do
		for dy = -Grid.GRID_RADIUS, Grid.GRID_RADIUS do
			local cell = centerCell + Vector2.new(dx, dy)
			Ghost.spawnGridLine(cell, centerCell)
		end
	end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 and currentKey then
		placeEv:FireServer(currentKey, mouse.Hit.Position)
	end
end)
