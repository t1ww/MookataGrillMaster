-- SaveScheduler.luau

local Store = require(script.Parent.PlayerDataStore)
local Session = require(script.Parent.PlayerSession)

local SaveScheduler = {}

local Dirty = {}
local LastSave = {}

local COOLDOWN = 30
local AUTOSAVE_INTERVAL = 60

function SaveScheduler.MarkDirty(userId)
    Dirty[userId] = true
end

function SaveScheduler.RequestSave(userId, bypassCooldown)
    if not Dirty[userId] then return end

    local now = os.time()
    if not bypassCooldown and LastSave[userId] and now - LastSave[userId] < COOLDOWN then
        return
    end

    SaveScheduler.ForceSave(userId)
end

function SaveScheduler.ForceSave(userId)
    local data = Session.Get(userId)
    if not data then return end

    Dirty[userId] = nil
    LastSave[userId] = os.time()

    Store.Save(userId, data)
end

function SaveScheduler.ForceSaveAll()
    for userId in pairs(Session.All()) do
        SaveScheduler.ForceSave(userId)
    end
end

-- autosave loop
task.spawn(function()
    while true do
        task.wait(AUTOSAVE_INTERVAL)
        for userId in pairs(Dirty) do
            SaveScheduler.RequestSave(userId)
        end
    end
end)

return SaveScheduler
