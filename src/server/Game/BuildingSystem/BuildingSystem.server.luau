-- src/server/Game/BuildingSystem/BuildingSystem.server.luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BuildingPlacement = require(script.Parent.BuildingPlacement)

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
