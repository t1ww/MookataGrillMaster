-- StarterPlayer/StarterCharacterScripts/Magnet.client.lua

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local part = workspace
	:WaitForChild("Sample instances")
	:WaitForChild("thai boat grill pan")

part.Anchored = false
part.CanCollide = false

RunService.Heartbeat:Connect(function()
	-- lerp POSITION ONLY
	part.Position = part.Position:Lerp(hrp.Position, 0.25)
end)
