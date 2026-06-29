local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")

local IS_SERVER = RunService:IsServer()

local Filter = {}

local _cache: { [string]: string } = {}
local CACHE_LIMIT = 500

local function cacheKey(text: string, userId: number): string
	return tostring(userId) .. "|" .. text
end

local function evict()
	local count = 1
	
	for k in pairs(_cache) do
		count += 1
	end
	
	if count > CACHE_LIMIT then
		table.clear(_cache)
	end
end

-- Broadcast-safe filter -- applies to all viewers
-- Must be called server-side
function Filter.Broadcast(text: string, fromPlayer: Player?): string
	if not IS_SERVER then return text end

	local uid = fromPlayer and fromPlayer.UserId or 0
	local key = cacheKey(text, uid)

	if _cache[key] then return _cache[key] end

	local ok, result = pcall(function()
		local res = TextService:FilterStringAsync(text, uid)
		return res:GetNonChatStringForBroadcastAsync()
	end)

	local out = ok and result or text
	evict()
	_cache[key] = out
	return out
end

-- Chat filter -- result is appropriate for a specific viewer
function Filter.ForPlayer(text: string, fromPlayer: Player, toPlayer: Player): string
	if not IS_SERVER then return text end

	local ok, result = pcall(function()
		local res = TextService:FilterStringAsync(text, fromPlayer.UserId)
		return res:GetChatForUserAsync(toPlayer.UserId)
	end)

	return ok and result or text
end

return Filter