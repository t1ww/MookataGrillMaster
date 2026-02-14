-- src\client\player\Game/BuildingSystem/BuildingSystem.client.lua
--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage"):WaitForChild("FromRojo")

local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()

-- Use shared grid
local Grid = require(
	ReplicatedStorage:WaitForChild("Shared")
		:WaitForChild("Game")
		:WaitForChild("BuildingSystem")
		:WaitForChild("BuildingGrid")
)
local Ghost = require(script.Parent:WaitForChild("GhostPart"))
local FurnitureData = require(ReplicatedStorage.Data.Items.Furniture)
local placeEv = ReplicatedStorage:WaitForChild("BuildingRemotes"):WaitForChild("PlaceBuilding")
local pointEv = ReplicatedStorage:WaitForChild("BuildingRemotes"):WaitForChild("PointingCellUpdate")

-- the currently selected building key (hook this up to your hotbar)
local currentKey: string? = nil
currentKey = "BasicPan" -- test

-- toggleable build mode
local buildModeEnabled = true

-- toggle key
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then
		return
	end
	if input.KeyCode == Enum.KeyCode.One then
		buildModeEnabled = not buildModeEnabled
		Ghost.clear()
	end
end)

RunService.RenderStepped:Connect(function()
	Ghost.clear()
	if not buildModeEnabled or not currentKey or not mouse.Hit then
		return
	end

	local size = FurnitureData[currentKey].Size
	local cell = Grid.getPointingCell(mouse.Hit.Position, size)
	pointEv:FireServer(cell) -- sync pointing index to server

	-- spawn ghost tiles
	for dx = 0, size.X - 1 do
		for dy = 0, size.Y - 1 do
			Ghost.spawnTile(cell + Vector2.new(dx, dy), false)
		end
	end

	-- spawn grid lines
	local half = math.floor(Grid.areaSize / 2)
	for dx = -half, half do
		for dy = -half, half do
			Ghost.spawnGridLine(Vector2.new(dx, dy), Vector2.zero)
		end
	end
end)

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
