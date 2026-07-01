-- Bold
-- _Utility/HardBlockFilter
-- Plinko Labs
--
-- Local case-insensitive blocklist backstop layered on top of Roblox's
-- TextService filter (not a replacement). Detection runs over a *collapsed,
-- normalized* copy of the text -- spacing/punctuation dropped, digit-leet mapped
-- to letters -- while masking is applied back to the original via an index map.
-- That catches "f u c k", "f.u.c.k", "f0ck", "fvck", "f*ck", AND "fck"-style
-- vowel-dropping without relying on TextService. Blocked words are matched as
-- patterns where vowels are optional (consonants stay literal and adjacent),
-- so "fuck" also matches a missing-vowel "fck" without opening up matches on
-- unrelated words. The blocklist MUST still stay narrow: matching has no word
-- boundary, which is only false-positive-safe for words that never
-- legitimately appear inside other words.

local _Utility = script.Parent
local _Packages = _Utility.Parent._Packages
local Proflis = require(_Packages.Proflis)

local AdviseFilter = {}

type Entry = { word: string, pattern: string }

local SEP: { [string]: boolean } = {
	[" "] = true, ["."] = true, ["-"] = true, ["_"] = true,
	["*"] = true, [","] = true, ["'"] = true,
}

-- digit/symbol leet mapped to letters
local LEET: { [string]: string } = {
	["4"] = "a", ["@"] = "a", ["3"] = "e", ["1"] = "i", ["!"] = "i",
	["0"] = "o", ["5"] = "s", ["$"] = "s", ["7"] = "t", ["8"] = "b", ["9"] = "g",
}

local VOWELS: { [string]: boolean } = { a = true, e = true, i = true, o = true, u = true }

local SENTINEL = "\1" -- non-letter boundary a blocked word can never cross

-- Escapes a single char for use inside a Lua pattern.
local function escapeLiteral(c: string): string
	if c:match("%w") then
		return c
	end
	return "%" .. c
end

-- Builds a find-pattern for a word where vowels are optional (catches
-- missing-vowel obfuscation like "fck" for "fuck") and consonants stay
-- literal and adjacent (keeps unrelated words like "flock" from matching).
local function wordToPattern(word: string): string
	local parts = {}
	for i = 1, #word do
		local c = word:sub(i, i)
		if VOWELS[c] then
			table.insert(parts, "[aeiou]?")
		else
			table.insert(parts, escapeLiteral(c))
		end
	end
	return table.concat(parts)
end

local function makeEntry(word: string): Entry
	local lower = word:lower()
	return { word = lower, pattern = wordToPattern(lower) }
end

local _blocked: { Entry } = {}

for k, w in Proflis.Get() do
	table.insert(_blocked, makeEntry(k))
end

-- Words exempted even if a blocked substring is found inside them.
-- Checked against the WHOLE original word enclosing a match, e.g. AddAllowed("classic")
-- would stop a match inside "classic" from being blocked, without removing the
-- underlying blocked word from _blocked.
local _allowed: { [string]: boolean } = {}

-- Build a collapsed normalized string plus a map from normalized position ->
-- original byte index, so a match can be projected back onto the source text.
local function normalize(text: string): (string, { number })
	local chars: { string } = {}
	local map: { number } = {}
	for i = 1, #text do
		local ch = text:sub(i, i)
		local low = ch:lower()
		if low:match("%a") then
			table.insert(chars, low)
			table.insert(map, i)
		elseif LEET[ch] then
			table.insert(chars, LEET[ch])
			table.insert(map, i)
		elseif SEP[ch] then
			-- dropped
		else
			table.insert(chars, SENTINEL)
			table.insert(map, i)
		end
	end
	return table.concat(chars), map
end

-- Expands a byte span in the ORIGINAL text out to the full contiguous
-- word/number run it sits inside (letters, digits, apostrophes), so the
-- allow list can be checked against the whole enclosing word rather than
-- just the matched substring.
local function expandToEnclosingWord(text: string, startByte: number, endByte: number): (number, number)
	local len = #text
	local s, e = startByte, endByte

	local function isWordChar(c: string): boolean
		return c ~= "" and (c:match("%w") ~= nil or c == "'")
	end

	while s > 1 and isWordChar(text:sub(s - 1, s - 1)) do
		s -= 1
	end
	while e < len and isWordChar(text:sub(e + 1, e + 1)) do
		e += 1
	end

	return s, e
end

-- Original [startByte, endByte] spans to mask, plus the matched original
-- substring for each (used by Detect for logging/scoring). Allow-listed
-- enclosing words are skipped.
local function findSpans(text: string): { { start: number, stop: number, match: string } }
	local norm, map = normalize(text)
	local spans: { { start: number, stop: number, match: string } } = {}

	for _, entry in _blocked do
		local from = 1
		while true do
			local s, e = norm:find(entry.pattern, from)
			if not s then break end

			local byteStart, byteEnd = map[s], map[e]

			local skip = false
			if next(_allowed) ~= nil then
				local ws, we = expandToEnclosingWord(text, byteStart, byteEnd)
				local enclosing = text:sub(ws, we):lower()
				if _allowed[enclosing] then
					skip = true
				end
			end

			if not skip then
				table.insert(spans, { start = byteStart, stop = byteEnd, match = text:sub(byteStart, byteEnd) })
			end

			from = (e >= s) and (e + 1) or (s + 1) -- guard against zero-length matches
		end
	end

	return spans
end

-- ============================================================
-- Existing API -- unchanged signatures, still drop-in for your framework
-- ============================================================

function AdviseFilter.Replace(text: string): string
	if text == "" then return text end
	local spans = findSpans(text)
	if #spans == 0 then return text end
	local masked = table.create(#text)
	for i = 1, #text do
		masked[i] = text:sub(i, i)
	end
	for _, span in spans do
		for i = span.start, span.stop do
			masked[i] = "*"
		end
	end
	return table.concat(masked)
end

function AdviseFilter.ContainsBlockedWord(text: string): boolean
	if text == "" then return false end
	return #findSpans(text) > 0
end

-- Extend the blocklist at runtime (surfaced as Bold.AddBlockedWords).
function AdviseFilter.Add(words: { string } | string)
	if type(words) == "string" then
		table.insert(_blocked, makeEntry(words :: string))
		return
	end
	for _, w in words :: { string } do
		table.insert(_blocked, makeEntry(w))
	end
end

-- Remove a word from the blocklist at runtime.
function AdviseFilter.Remove(word: string)
	local lower = word:lower()
	for i, entry in _blocked do
		if entry.word == lower then
			table.remove(_blocked, i)
			break
		end
	end
end

-- ============================================================
-- Allow list (Scunthorpe-style exceptions)
-- ============================================================

function AdviseFilter.AddAllowed(words: { string } | string)
	if type(words) == "string" then
		_allowed[(words :: string):lower()] = true
		return
	end
	for _, w in words :: { string } do
		_allowed[w:lower()] = true
	end
end

function AdviseFilter.RemoveAllowed(word: string)
	_allowed[word:lower()] = nil
end

function AdviseFilter.IsAllowed(word: string): boolean
	return _allowed[word:lower()] == true
end

-- ============================================================
-- Match reporting (for logging, scoring, or feeding your
-- active-typing warning system a reason string instead of just true/false)
-- ============================================================

-- Returns the list of matched original substrings, e.g. { "f*ck", "fck", "fvck" }
function AdviseFilter.Detect(text: string): { string }
	local spans = findSpans(text)
	local matches = table.create(#spans)
	for _, span in spans do
		table.insert(matches, span.match)
	end
	return matches
end

-- Convenience for scoring/thresholds in your warning system, e.g.
-- escalate a warning only after N hits.
function AdviseFilter.Count(text: string): number
	return #findSpans(text)
end

return AdviseFilter