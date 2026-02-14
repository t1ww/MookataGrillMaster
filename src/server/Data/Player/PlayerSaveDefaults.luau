--!strict
-- src\server\Data\Player\PlayerSaveDefaults.luau
local Types = require(script.Parent.Parent.DataTypes)

local Defaults = {}
local VERSION = 1

function Defaults.New(): Types.PlayerSave
	return {
		Version = VERSION,

		Currency = {
			Money = 5000,
		},

		Progression = {
			PigFarmingUnlocked = false,
			AnalyticsUnlocked = false,
			UnlockedRecipes = {},
		},

		-- flatten Inventory into one table:
		Inventory = {}, -- { [itemKey:string]: number | boolean }

		Pigs = {},
		DiscoveredNPCs = {},

		Analytics = {
			DiscoveredFlavorSamples = 0,
			KnownFlavorRanges = {},
		},
	}
end

return Defaults
