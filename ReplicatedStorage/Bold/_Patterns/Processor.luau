-- Bold/_Patterns/Processor.luau
local Config = require(game.ReplicatedStorage.Bold._Config)
local Hooks = require(game.ReplicatedStorage.Bold._Patterns.Hooks)

local Processor = {}
Processor.Handlers = {}

-- Register a new handler (e.g., Markdown, Mentions)
function Processor:RegisterHandler(name: string, handler: (string) -> string)
	self.Handlers[name] = handler
end

-- Process the raw message through all enabled handlers
function Processor:Process(rawText: string): string
	local processedText = rawText

	for name, handler in pairs(self.Handlers) do
		-- Check if enabled in Config
		if Config.Features[name] ~= false then
			processedText = handler(processedText)
		end
	end

	return processedText
end

return Processor