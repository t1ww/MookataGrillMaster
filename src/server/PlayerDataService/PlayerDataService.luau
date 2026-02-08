-- ServerScriptService/PlayerDataService/PlayerDataService.luau

local Players = game:GetService("Players")

local Session   = require(script.Parent.PlayerSession)
local Scheduler = require(script.Parent.SaveScheduler)
local Store     = require(script.Parent.PlayerDataStore)

local PlayerDataService = {}

function PlayerDataService.Get(player)
	if not player then return nil end
	return Session.Get(player.UserId)
end


function PlayerDataService.Modify(player, callback)
    local save = Session.Get(player.UserId)
    if not save then return end

    callback(save)
    Scheduler.MarkDirty(player.UserId)
end

function PlayerDataService.RequestImmediateSave(player)
    Scheduler.RequestSave(player.UserId, true)
end

-- lifecycle
Players.PlayerAdded:Connect(function(player)
    local data = Store.Load(player.UserId)
    Session.Attach(player.UserId, data)
end)

Players.PlayerRemoving:Connect(function(player)
    Scheduler.ForceSave(player.UserId)
    Session.Detach(player.UserId)
end)

game:BindToClose(function()
    Scheduler.ForceSaveAll()
end)

return PlayerDataService
