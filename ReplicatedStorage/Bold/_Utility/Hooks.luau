local Hooks = {}

local _registry: { [string]: { (any) -> any? } } = {}

local function bucket(name: string): { (any) -> any? }
	if not _registry[name] then
		_registry[name] = {}
	end
	return _registry[name]
end

-- Register a hook -- returns an unregister function
function Hooks.Register(name: string, fn: (any) -> any?): () -> ()
	local list = bucket(name)
	table.insert(list, fn)
	return function()
		local idx = table.find(list, fn)
		if idx then table.remove(list, idx) end
	end
end

-- Run all hooks for name against ctx
-- Returns (passed: boolean, ctx: any)
-- A hook returning false cancels the pipeline -- returning a non-nil value replaces ctx
function Hooks.Run(name: string, ctx: any): (boolean, any)
	local list = _registry[name]
	if not list or #list == 0 then return true, ctx end

	for _, fn in list do
		local ok, result = pcall(fn, ctx)
		if not ok then
			warn("[Bold.Hooks] Error in hook '" .. name .. "':", result)
			continue
		end
		if result == false then
			return false, ctx
		end
		if result ~= nil then
			ctx = result
		end
	end

	return true, ctx
end

function Hooks.Has(name: string): boolean
	local list = _registry[name]
	return list ~= nil and #list > 0
end

function Hooks.Clear(name: string)
	_registry[name] = nil
end

Hooks.BEFORE_SEND    = "BeforeSend"
Hooks.AFTER_SEND     = "AfterSend"
Hooks.BEFORE_DELIVER = "BeforeDeliver"
Hooks.AFTER_DELIVER  = "AfterDeliver"
Hooks.BEFORE_RENDER  = "BeforeRender"
Hooks.AFTER_RENDER   = "AfterRender"
Hooks.BEFORE_PARSE   = "BeforeParse"
Hooks.AFTER_PARSE    = "AfterParse"
Hooks.ON_FILTER      = "OnFilter"

return Hooks