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

local ghostEv = remotes:FindFirstChild("UpdateGhostColor")
if not ghostEv then
	ghostEv = Instance.new("RemoteEvent")
	ghostEv.Name = "UpdateGhostColor"
	ghostEv.Parent = remotes
end

-- track player pointing index and notify occupancy
pointEv.OnServerEvent:Connect(function(player, cell: Vector2, size: Vector2, requestId: number?)
	player:SetAttribute("PointingCellX", cell.X)
	player:SetAttribute("PointingCellY", cell.Y)

	-- check occupancy for the cell with given size
	local occupied = not Grid.canOccupy(cell, size)
	print("Pointing at cell", cell, "size", size, "occupied", occupied)

	-- send occupancy info to this client
	ghostEv:FireClient(player, cell, occupied, requestId or 0)
end)

placeEv.OnServerEvent:Connect(function(player, key: string, cell: Vector2)
	local size = require(ReplicatedStorage.Data.Items.Furniture)[key].Size
	print("Placing", key, "at cell", cell, "size", size)
	local canOccupy = Grid.canOccupy(cell, size)
	print("canOccupy result:", canOccupy)

	if not canOccupy then
		warn(player.Name, "cannot place", key, "space occupied")
		return
	end

	Grid.occupy(cell, size)
	print("Placed", key, "at cell", cell, "size", size)
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
