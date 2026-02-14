-- src\client\player\Game\BuildingSystem\BuildingSystem.client.luau
--!strict

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()

-- match server's tile size
local TILE_SIZE = 4

-- remote to tell server to place
local remotes = ReplicatedStorage:WaitForChild("BuildingRemotes")
local placeEv = remotes:WaitForChild("PlaceBuilding")

-- must match server's config
local _storageData = game:GetService("ReplicatedStorage"):WaitForChild("FromRojo"):WaitForChild("Data")
local FurnitureData = require(_storageData:WaitForChild("Items"):WaitForChild("Furniture"))

-- the currently selected building key (hook this up to your hotbar)
local currentKey: string? = nil
currentKey = "BasicPan" -- test

-- all ghost parts
local ghostParts: { BasePart } = {}

-- world → cell
local function worldToCell(pos: Vector3): Vector2
	local half = TILE_SIZE / 2
	local x = math.floor((pos.X + half) / TILE_SIZE)
	local y = math.floor((pos.Z + half) / TILE_SIZE)
	return Vector2.new(x, y)
end

-- cell → world (center)
local function cellToWorld(cell: Vector2): Vector3
	return Vector3.new(cell.X * TILE_SIZE, 0.2, cell.Y * TILE_SIZE)
end

-- rebuild the ghost every frame
local function updateGhost()
	-- clear old
	for _, p in ipairs(ghostParts) do
		p:Destroy()
	end
	ghostParts = {}

	if not currentKey then
		return
	end
	local size = FurnitureData[currentKey]
	if not size then
		return
	end

	local baseCell = worldToCell(mouse.Hit.Position)
	local color = Color3.fromRGB(0, 255, 0)

	for dx = 0, size.X - 1 do
		for dy = 0, size.Y - 1 do
			local cell = baseCell + Vector2.new(dx, dy)
			local worldPos = cellToWorld(cell)

			local part = Instance.new("Part")
			part.Size = Vector3.new(TILE_SIZE, 0.2, TILE_SIZE)
			part.Anchored = true
			part.CanCollide = false
			part.Material = Enum.Material.Neon
			part.Transparency = 0.5
			part.CFrame = CFrame.new(worldPos)
			part.Parent = workspace
			table.insert(ghostParts, part)

			-- simple occupancy check via Region3
			local half = TILE_SIZE / 2
			local p1 = worldPos - Vector3.new(half, 1, half)
			local p2 = worldPos + Vector3.new(half, 1, half)
			local region = Region3.new(p1, p2)
			region = region:ExpandToGrid(TILE_SIZE) -- make it valid
			local parts = workspace:FindPartsInRegion3WithIgnoreList(region, ghostParts, 10)
			if #parts > 0 then
				color = Color3.fromRGB(255, 0, 0)
			end

			part.Color = color
		end
	end
end

-- run every frame
RunService.RenderStepped:Connect(updateGhost)

-- Example input-handling:
-- TODO: listen to your inventory hotbar selection and set currentKey accordingly
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then
		return
	end

	-- example: press '1','2','3' to pick an item
	if input.KeyCode == Enum.KeyCode.One then
		currentKey = "WoodenTable1x1"
	elseif input.KeyCode == Enum.KeyCode.Two then
		currentKey = "WoodenTable2x1"
	elseif input.KeyCode == Enum.KeyCode.Three then
		currentKey = "WoodenChair"
	end

	-- place on left-click
	if input.UserInputType == Enum.UserInputType.MouseButton1 and currentKey then
		placeEv:FireServer(currentKey, mouse.Hit.Position)
		currentKey = nil
	end
end)
