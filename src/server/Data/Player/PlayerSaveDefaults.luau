--!strict
-- src\server\Data\Player\PlayerSaveDefaults.luau
local Types = require(script.Parent.Parent.DataTypes)

local Defaults = {}
local VERSION = 1

function Defaults.New(): Types.PlayerSave
	return {
		Version = VERSION,

		Currency = {
			Money = 0,
		},

		Progression = {
			PigFarmingUnlocked = false,
			AnalyticsUnlocked = false,
			UnlockedRecipes = {},
		},

		Inventory = {
			Ingredients = {},
			Equipment = {
				Pans = {},
				Stoves = {},
			},
			Furniture = {
				Tables = {},
				Decorations = {},
			},
		},

		Pigs = {},
		DiscoveredNPCs = {},

		Analytics = {
			DiscoveredFlavorSamples = 0,
			KnownFlavorRanges = {},
		},
	}
end

return Defaults