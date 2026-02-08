--!strict
-- src\server\Data\Player\SaveScheduler.luau
local Factory = require(script.Parent.Parent.SaveSchedulerFactory)

local Session = require(script.Parent.PlayerSession)
local Store = require(script.Parent.PlayerDataStore)

return Factory.create({
	get = Session.Get,
	getAll = Session.All,
	save = Store.Save,
	cooldown = 30,
	autosaveInterval = 60,
})
