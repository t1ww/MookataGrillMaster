-- src\server\Data\Player\PlayerDataStore.luau
local Types = require(script.Parent.Parent.DataTypes)

local DSS = game:GetService("DataStoreService")
local Store = DSS:GetDataStore("PlayerSave_V1")

local Defaults = require(script.Parent.PlayerSaveDefaults)
local Migrator = require(script.Parent.PlayerSaveMigrator)

local PlayerDataStore = {}

function PlayerDataStore.Load(userId: number): Types.PlayerSave
	local key = "player_" .. userId
	local data: unknown

	local success = pcall(function()
		data = Store:GetAsync(key)
	end)

	if not success or type(data) ~= "table" then
		return Defaults.New()
	end

	return Migrator.Migrate(data :: Types.PlayerSave)
end

function PlayerDataStore.Save(userId: number, data: Types.PlayerSave)
	local key = "player_" .. userId

	pcall(function()
		Store:UpdateAsync(key, function()
			return data
		end)
	end)
end

return PlayerDataStore
