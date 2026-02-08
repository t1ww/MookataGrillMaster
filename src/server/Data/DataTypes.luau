--!strict
-- src\server\Data\DataTypes.luau

export type CurrencySave = {
	Money: number,
}

export type ProgressionSave = {
	PigFarmingUnlocked: boolean,
	AnalyticsUnlocked: boolean,
	UnlockedRecipes: {[string]: boolean},
}

export type PanInstance = {
	InstanceId: string,
	PanTierId: string,
	Durability: number?,
}

export type StoveInstance = {
	InstanceId: string,
	StoveId: string,
	FuelRemaining: number?,
}

export type EquipmentInventory = {
	Pans: {[string]: PanInstance},
	Stoves: {[string]: StoveInstance},
}

export type FurnitureInstance = {
	InstanceId: string,
	FurnitureId: string,
}

export type FurnitureInventory = {
	Tables: {[string]: FurnitureInstance},
	Decorations: {[string]: FurnitureInstance},
}

export type InventorySave = {
	Ingredients: {[string]: number},
	Equipment: EquipmentInventory,
	Furniture: FurnitureInventory,
}

export type PigSave = {
	InstanceId: string,
	PigTemplateId: string,
	AgeStage: number,

	CurrentTextures: {
		Tenderness: number,
		Crispiness: number,
		Meatyness: number,
	},

	AppliedFeeds: {string},
}

export type NPCSave = {
	NpcId: string,

	FlavorPreferences: {
		Spicy: number,
		Salty: number,
		Sweet: number,
		Sour: number,
		Tangy: number,
		Bitter: number,
	},

	TexturePreferences: {
		Tenderness: number,
		Crispiness: number,
		Meatyness: number,
	},
}

export type AnalyticsSave = {
	DiscoveredFlavorSamples: number,
	KnownFlavorRanges: {
		Spicy: NumberRange?,
		Salty: NumberRange?,
		Sweet: NumberRange?,
		Sour: NumberRange?,
		Tangy: NumberRange?,
		Bitter: NumberRange?,
	},
}

export type PlayerSave = {
	Version: number,

	Currency: CurrencySave,
	Progression: ProgressionSave,
	Inventory: InventorySave,

	Pigs: {[string]: PigSave},
	DiscoveredNPCs: {[string]: NPCSave},

	Analytics: AnalyticsSave,
}
