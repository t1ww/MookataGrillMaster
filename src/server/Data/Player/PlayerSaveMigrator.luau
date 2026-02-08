--!strict
-- src/server/Data/Player/PlayerSaveMigrator.luau

local Types = require(script.Parent.Parent.DataTypes)

local Migrator = {}
local CURRENT = 1

function Migrator.Migrate(data: Types.PlayerSave): Types.PlayerSave
	if data.Version == nil then
		data.Version = 1
	end

	while data.Version < CURRENT do
		-- future migrations go here
		data.Version += 1
	end

	return data
end

return Migrator
