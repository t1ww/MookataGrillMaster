-- StarterPlayer/StarterPlayerScripts/SprintInput (LocalScript)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
player:SetAttribute("IsSprinting", false)

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.LeftShift then
		player:SetAttribute("IsSprinting", true)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		player:SetAttribute("IsSprinting", false)
	end
end)
