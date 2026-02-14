-- src\client\player\Game\BuildingSystem\GridRenderer.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Grid = require(ReplicatedStorage.FromRojo.Shared.Game.BuildingSystem.BuildingGrid)

local Renderer = {}
Renderer.parts = {}

function Renderer.clear()
	for _, part in ipairs(Renderer.parts) do
		part:Destroy()
	end
	Renderer.parts = {}
end

function Renderer.render()
	Renderer.clear()

	local half = math.floor(Grid.areaSize / 2)

	for x = -half, half do
		for y = -half, half do
			local cell = Vector2.new(x, y)
			local worldPos = Grid.cellToWorld(cell)

			local part = Instance.new("Part")
			part.Size = Vector3.new(Grid.tileSize, 0.1, Grid.tileSize)
			part.Anchored = true
			part.CanCollide = false
			part.Transparency = 0.9
			part.Position = worldPos
			part.Parent = workspace

			table.insert(Renderer.parts, part)
		end
	end
end

return Renderer
