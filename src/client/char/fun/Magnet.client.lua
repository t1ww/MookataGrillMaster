-- StarterPlayer/StarterCharacterScripts/Magnet.client.lua

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local part = workspace
	:WaitForChild("Sample instances")
	:WaitForChild("thai boat grill pan")

part.Anchored = true
part.CanCollide = false

RunService.Heartbeat:Connect(function()
	part.CFrame = part.CFrame:Lerp(hrp.CFrame, 0.25)
end)
