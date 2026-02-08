-- src\server\test\test.server.luau

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local function banner(title)
	print("")
	print(("="):rep(60))
	print("TEST:", title)
	print(("="):rep(60))
end

-- =========================
-- EnumFactory test
-- =========================
banner("EnumFactory")

local createEnum = require(
	ReplicatedStorage:WaitForChild("FromRojo")
		:WaitForChild("Shared")
		:WaitForChild("utility")
		:WaitForChild("EnumFactory")
)

local E = createEnum({ "Idle", "Running" })

print(E.Enum.Running) --> 2
print(E.FromValue[2]) --> "Running"

-- =========================
-- PlayerDataService test
-- =========================
banner("PlayerDataService basic mutation")

local PlayerDataService = require(
	ServerScriptService:WaitForChild("Server"):WaitForChild("PlayerDataService"):WaitForChild("PlayerDataService")
)

-- get existing player (Studio already spawned one)
local player
while not player do
	player = Players:GetPlayers()[1]
	task.wait()
end

-- wait until PlayerDataService finished attaching session data
while not PlayerDataService.Get(player) do
	task.wait()
end

-- read
local save = PlayerDataService.Get(player)
print("Initial money:", save.Currency.Money)

-- modify
PlayerDataService.Modify(player, function(data)
	data.Currency.Money += 100
end)

print("After grant:", PlayerDataService.Get(player).Currency.Money)

-- force save (safe even in Studio; no-op if datastore disabled)
PlayerDataService.RequestImmediateSave(player)

banner("PlayerDataService test complete")
