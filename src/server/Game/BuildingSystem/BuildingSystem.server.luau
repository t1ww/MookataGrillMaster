-- src/server/Game/BuildingSystem/BuildingSystem.server.luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local BuildingPlacement = require(script.Parent.BuildingPlacement)
local BuildingGrid = require(script.Parent.BuildingGrid)

-- ensure Workspace.Buildings exists
if not workspace:FindFirstChild("Buildings") then
	local f = Instance.new("Folder")
	f.Name = "Buildings"
	f.Parent = workspace
end

-- RemoteEvent container
local remotes = ReplicatedStorage:FindFirstChild("BuildingRemotes")
if not remotes then
	remotes = Instance.new("Folder")
	remotes.Name = "BuildingRemotes"
	remotes.Parent = ReplicatedStorage
end

local configEv = remotes:FindFirstChild("InitGrid")
if not configEv then
	configEv = Instance.new("RemoteEvent")
	configEv.Name = "InitGrid"
	configEv.Parent = remotes
end

local placeEv = remotes:FindFirstChild("PlaceBuilding")
if not placeEv then
	placeEv = Instance.new("RemoteEvent")
	placeEv.Name = "PlaceBuilding"
	placeEv.Parent = remotes
end

placeEv.OnServerEvent:Connect(function(player, key: string, worldPos: Vector3)
	print("SERVER RECEIVED:", player.Name, key, worldPos)

	local ok, err = BuildingPlacement.Place(player, key, worldPos)
	if not ok then
		warn("BuildingPlacement failed for", player.Name, key, err)
	end
end)

Players.PlayerAdded:Connect(function(player)
	local plotOrigin = Vector3.new(0, 0, 0) -- replace with real plot system
	BuildingGrid.setPlotOrigin(plotOrigin)

	configEv:FireClient(player, {
		tileSize = BuildingGrid.tileSize,
		areaSize = BuildingGrid.areaSize,
		origin = plotOrigin,
	})
end)
