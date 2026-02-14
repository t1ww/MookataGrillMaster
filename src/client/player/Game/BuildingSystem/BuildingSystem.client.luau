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

	-- Draw ghost tiles
	for dx = 0, size.X - 1 do
		for dy = 0, size.Y - 1 do
			local cell = baseCell + Vector2.new(dx, dy)
			Ghost.spawnTile(cell, false)
		end
	end

	-- Draw grid lines based on areaSize
	local half = math.floor(Grid.areaSize / 2)

	for dx = -half, half do
		for dy = -half, half do
			local cell = Vector2.new(dx, dy)
			Ghost.spawnGridLine(cell, Vector2.zero)
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
