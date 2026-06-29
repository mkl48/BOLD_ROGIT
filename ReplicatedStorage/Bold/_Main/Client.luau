-- Bold/_Main/Client.luau
local Client = {}

-- Load core components
local Config = require(game.ReplicatedStorage.Bold._Config)
local Hooks = require(game.ReplicatedStorage.Bold._Patterns.Hooks)
local Processor = require(game.ReplicatedStorage.Bold._Patterns.Processor)

function Client:Init()
	-- 1. Setup the initial pipeline
	-- Ensure all handlers are loaded so they register themselves to the Processor
	require(game.ReplicatedStorage.Bold._Patterns.MarkdownHandler)
	require(game.ReplicatedStorage.Bold._Patterns.MentionHandler)

	-- 2. Hook into the message flow
	Hooks:On("MessageReceived", function(rawData)
		-- Process through all enabled patterns
		local formattedText = Processor:Process(rawData.Text)

		-- Fire an event that the UI can listen to
		Hooks:Fire("UI_CreateMessage", {
			Sender = rawData.Sender,
			Text = formattedText,
			Metadata = rawData.Metadata -- Contains embeds/gifs/stickers
		})
	end)
end

return Client