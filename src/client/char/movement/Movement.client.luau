-- StarterPlayer/StarterCharacterScripts/Movement (LocalScript)

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")

local NORMAL_SPEED = 32
local SPRINT_SPEED = 64

local function updateSpeed()
	humanoid.WalkSpeed = player:GetAttribute("IsSprinting")
		and SPRINT_SPEED
		or NORMAL_SPEED
end

updateSpeed()

player:GetAttributeChangedSignal("IsSprinting"):Connect(updateSpeed)

