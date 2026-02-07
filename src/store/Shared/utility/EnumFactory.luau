-- src/shared/Shared/utility/EnumFactory.lua
local function createEnum(names)
	local enum = {}
	local reverse = {}

	for i, name in ipairs(names) do
		enum[name] = i
		reverse[i] = name
	end

	return table.freeze({
		Enum = table.freeze(enum),
		FromValue = table.freeze(reverse),
	})
end

return createEnum
