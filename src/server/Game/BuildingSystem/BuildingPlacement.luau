-- src/server/Game/BuildingSystem/BuildingPlacement.luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BuildingGrid = require(script.Parent.BuildingGrid)
local TEMPLATES = ReplicatedStorage:WaitForChild("Cloud"):WaitForChild("BuildingTemplates")

-- Using size info from Furniture data:
local _storageData = game:GetService("ReplicatedStorage"):WaitForChild("FromRojo"):WaitForChild("Data")
local FurnitureData = require(_storageData:WaitForChild("Items"):WaitForChild("Furniture"))

local BuildingPlacement = {}

function BuildingPlacement.Place(player, key: string, worldPos: Vector3): (boolean, string?)
	local itemData = FurnitureData[key]
	if not itemData then
		return false, ("Unknown building key %q"):format(key)
	end

	local size = itemData.Size
	local cell = BuildingGrid.worldToCell(worldPos)

	if not BuildingGrid.canOccupy(cell, size) then
		return false, "Space is occupied"
	end

	BuildingGrid.occupy(cell, size)

	-- clone & position using the key → template in ReplicatedStorage
	local template = TEMPLATES:WaitForChild(key)
	local model = template:Clone()

	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = true
		end
	end

	-- center‐of‐area cell → world pos
	local centerCell = cell + Vector2.new((size.X - 1) / 2, (size.Y - 1) / 2)
	local pos = BuildingGrid.cellToWorld(centerCell)
	if model.PrimaryPart then
		-- offset Y so the bottom of the model sits on the grid
		local yOffset = model.PrimaryPart.Size.Y / 2
		model:SetPrimaryPartCFrame(CFrame.new(pos + Vector3.new(0, yOffset, 0)))
	else
		for _, part in ipairs(model:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CFrame = CFrame.new(pos + Vector3.new(0, part.Size.Y / 2, 0))
			end
		end
	end

	model.Parent = workspace.Buildings
	return true
end

return BuildingPlacement
