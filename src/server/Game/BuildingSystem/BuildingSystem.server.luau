-- src/server/Game/BuildingSystem/BuildingSystem.server.luau
--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage"):WaitForChild("FromRojo")

local Grid = require(
	ReplicatedStorage:WaitForChild("Shared")
		:WaitForChild("Game")
		:WaitForChild("BuildingSystem")
		:WaitForChild("BuildingGrid")
)
local BuildingPlacement = require(script.Parent:WaitForChild("BuildingPlacement"))

local remotes = ReplicatedStorage:FindFirstChild("BuildingRemotes")
if not remotes then
	remotes = Instance.new("Folder")
	remotes.Name = "BuildingRemotes"
	remotes.Parent = ReplicatedStorage
end

local placeEv = remotes:FindFirstChild("PlaceBuilding")
if not placeEv then
	placeEv = Instance.new("RemoteEvent")
	placeEv.Name = "PlaceBuilding"
	placeEv.Parent = remotes
end

local pointEv = remotes:FindFirstChild("PointingCellUpdate")
if not pointEv then
	pointEv = Instance.new("RemoteEvent")
	pointEv.Name = "PointingCellUpdate"
	pointEv.Parent = remotes
end

-- track player pointing index
pointEv.OnServerEvent:Connect(function(player, cell: Vector2)
	player:SetAttribute("PointingCellX", cell.X)
	player:SetAttribute("PointingCellY", cell.Y)
end)

placeEv.OnServerEvent:Connect(function(player, key: string, _worldPos: Vector3)
	local size = require(ReplicatedStorage.Data.Items.Furniture)[key].Size
	local cell = Vector2.new(player:GetAttribute("PointingCellX"), player:GetAttribute("PointingCellY"))

	if not Grid.canOccupy(cell, size) then
		warn(player.Name, "cannot place", key, "space occupied")
		return
	end

	Grid.occupy(cell, size)
	BuildingPlacement.Place(player, key, Grid.cellToWorld(cell))
end)

local configEv = Instance.new("RemoteEvent")
configEv.Name = "InitGrid"
configEv.Parent = remotes

Players.PlayerAdded:Connect(function(player)
	local plotOrigin = Vector3.new(0, 0, 0) -- replace with real plot system
	Grid.setPlotOrigin(plotOrigin)

	configEv:FireClient(player, {
		tileSize = Grid.tileSize,
		areaSize = Grid.areaSize,
		origin = plotOrigin,
	})
end)
