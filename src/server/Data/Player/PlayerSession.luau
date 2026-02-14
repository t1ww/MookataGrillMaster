--!strict
-- src\server\Data\Player\PlayerSession.luau
local Types = require(script.Parent.Parent.DataTypes)

local Session = {}
local sessions: { [number]: Types.PlayerSave } = {}

function Session.Attach(userId: number, data: Types.PlayerSave)
	sessions[userId] = data
end

function Session.Get(userId: number): Types.PlayerSave?
	return sessions[userId]
end

function Session.Detach(userId: number)
	sessions[userId] = nil
end

function Session.All(): { [number]: Types.PlayerSave }
	return sessions
end

return Session
