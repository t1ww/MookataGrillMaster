-- src\server\Data\Player\InventoryService.luau
--!strict
local _Players = game:GetService("Players")
local _playerDataService = game.ServerScriptService.Server.Data.Player
local Session = require(_playerDataService.PlayerSession)
local Scheduler = require(_playerDataService.SaveScheduler)

local _storageData = game:GetService("ReplicatedStorage"):WaitForChild("FromRojo"):WaitForChild("Data")
local _dataItems = _storageData:WaitForChild("Items")
local Ingredients = require(_dataItems:WaitForChild("Ingredients"))
local Equipment = require(_dataItems:WaitForChild("Equipment"))
local Furniture = require(_dataItems:WaitForChild("Furniture"))

local InventoryService = {}

-- category must be exactly one of these strings:
local CONFIGS = {
	Ingredients = Ingredients,
	Equipment = Equipment,
	Furniture = Furniture,
}

-- player: Player, category: "Ingredients"|"Equipment"|"Furniture", key: string
-- returns true or false + error message
function InventoryService.Buy(player: Player, category: string, key: string): (boolean, string?)
	local userId = player.UserId
	local save = Session.Get(userId)
	if not save then
		return false, "No session"
	end

	local config = CONFIGS[category]
	if not config then
		return false, "Unknown category"
	end

	local item = config[key]
	if not item then
		return false, "Unknown item key"
	end

	if save.Currency.Money < item.Price then
		return false, "Not enough money"
	end

	-- deduct currency
	save.Currency.Money -= item.Price

	-- add to the flat Inventory table:
	local current = save.Inventory[key]
	if typeof(current) == "number" then
		save.Inventory[key] = current + 1
	else
		-- either boolean (for singular ownership) or nil
		save.Inventory[key] = typeof(current) == "boolean" and current or 1
	end

	-- schedule a save
	Scheduler.MarkDirty(userId)

	return true
end

return InventoryService
