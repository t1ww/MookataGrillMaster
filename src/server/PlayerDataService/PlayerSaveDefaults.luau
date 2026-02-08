-- PlayerSaveDefaults.luau

local Defaults = {}
local VERSION = 1

function Defaults.New()
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
