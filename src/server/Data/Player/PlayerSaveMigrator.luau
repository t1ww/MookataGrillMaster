-- src\server\PlayerDataService\PlayerSaveMigrator.luau
local Migrator = {}
local CURRENT = 1

function Migrator.Migrate(data)
    if not data.Version then
        data.Version = 1
    end

    while data.Version < CURRENT do
        -- future migrations go here
        data.Version += 1
    end

    return data
end

return Migrator
