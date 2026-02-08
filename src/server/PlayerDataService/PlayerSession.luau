-- PlayerSession.luau

local Session = {}
local sessions = {}

function Session.Attach(userId, data)
    sessions[userId] = data
end

function Session.Get(userId)
    return sessions[userId]
end

function Session.Detach(userId)
    sessions[userId] = nil
end

function Session.All()
    return sessions
end

return Session
