--!strict
-- src/server/Data/SaveSchedulerFactory.luau
local Factory = {}

export type Scheduler = {
	MarkDirty: (number) -> (),
	RequestSave: (number, boolean?) -> (),
	ForceSave: (number) -> (),
	ForceSaveAll: () -> (),
}

export type Config<T> = {
	get: (number) -> T?,
	getAll: () -> { [number]: T },
	save: (number, T) -> (),
	cooldown: number,
	autosaveInterval: number,
}

function Factory.create<T>(config: Config<T>): Scheduler
	local Dirty: { [number]: boolean } = {}
	local LastSave: { [number]: number } = {}

	local function forceSave(id: number)
		local data = config.get(id)
		if not data then
			return
		end

		Dirty[id] = nil
		LastSave[id] = os.time()
		config.save(id, data)
	end

	-- autosave loop
	task.spawn(function()
		while true do
			task.wait(config.autosaveInterval)
			for id in pairs(Dirty) do
				local last = LastSave[id]
				if not last or os.time() - last >= config.cooldown then
					forceSave(id)
				end
			end
		end
	end)

	return {
		MarkDirty = function(id: number)
			Dirty[id] = true
		end,

		RequestSave = function(id: number, bypassCooldown: boolean?)
			if not Dirty[id] then
				return
			end
			if not bypassCooldown and LastSave[id] and os.time() - LastSave[id] < config.cooldown then
				return
			end
			forceSave(id)
		end,

		ForceSave = forceSave,

		ForceSaveAll = function()
			local all = config.getAll() :: { [number]: unknown }
			for id in pairs(all) do
				forceSave(id)
			end
		end,
	}
end

return Factory
