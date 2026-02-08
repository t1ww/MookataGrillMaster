-- src\server\Data\Player\PlayerDataStore.luau
local DSS = game:GetService("DataStoreService")
local Store = DSS:GetDataStore("PlayerSave_V1")

local Defaults = require(script.Parent.PlayerSaveDefaults)
local Migrator = require(script.Parent.PlayerSaveMigrator)

local PlayerDataStore = {}

function PlayerDataStore.Load(userId)
    local key = "player_" .. userId
    local data

    local success = pcall(function()
        data = Store:GetAsync(key)
    end)

    if not success or not data then
        return Defaults.New()
    end

    return Migrator.Migrate(data)
end

function PlayerDataStore.Save(userId, data)
    local key = "player_" .. userId

    pcall(function()
        Store:UpdateAsync(key, function()
            return data
        end)
    end)
end

return PlayerDataStore
