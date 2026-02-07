-- src\server\init\init.server.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local createEnum = require(
	ReplicatedStorage
		:WaitForChild("FromRojo")
		:WaitForChild("Shared")
		:WaitForChild("utility")
		:WaitForChild("EnumFactory")
)

local E = createEnum({ "Idle", "Running" })

print(E.Enum.Running)   --> 2
print(E.FromValue[2])   --> "Running"
