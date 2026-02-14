-- src/server/Game/BuildingSystem/BuildingPlacement.luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Grid = require(ReplicatedStorage.FromRojo.Shared.Game.BuildingSystem.BuildingGrid)
local TEMPLATES = ReplicatedStorage:WaitForChild("Cloud"):WaitForChild("BuildingTemplates")

-- Using size info from Furniture data:
local _storageData = ReplicatedStorage:WaitForChild("FromRojo"):WaitForChild("Data")
local FurnitureData = require(_storageData:WaitForChild("Items"):WaitForChild("Furniture"))

local BuildingPlacement = {}

-- Create Buildings folder
local BuildingsFolder = Instance.new("Folder")
BuildingsFolder.Name = "Buildings"
BuildingsFolder.Parent = workspace

function BuildingPlacement.Place(player, key: string, worldPos: Vector3): (boolean, string?)
	local itemData = FurnitureData[key]
	if not itemData then
		return false, ("Unknown building key %q"):format(key)
	end

	local size = itemData.Size
	local cell = Grid.worldToCell(worldPos)

	-- clone & position
	local template = TEMPLATES:WaitForChild(key)
	local model = template:Clone()

	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = true
		end
	end

	local centerCell = cell + Vector2.new((size.X - 1) / 2, (size.Y - 1) / 2)
	local pos = Grid.cellToWorld(centerCell)
	if model.PrimaryPart then
		model:SetPrimaryPartCFrame(CFrame.new(pos + Vector3.new(0, model.PrimaryPart.Size.Y / 2, 0)))
	else
		for _, part in ipairs(model:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CFrame = CFrame.new(pos + Vector3.new(0, part.Size.Y / 2, 0))
			end
		end
	end

	model.Parent = BuildingsFolder
	return true, nil
end

return BuildingPlacement
