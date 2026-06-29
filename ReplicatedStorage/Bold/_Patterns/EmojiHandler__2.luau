-- Bold/_Patterns/EmojiHandler.luau
local Processor = require(game.ReplicatedStorage.Bold._Patterns.Processor)
local Config = require(game.ReplicatedStorage.Bold._Config)

Processor:RegisterHandler("EnableEmojis", function(text: string)
	return text:gsub(":(%w+):", function(emojiName)
		local emojiId = Config.Assets.EmojiRegistry[emojiName]
		if emojiId then
			-- Replace with RichText image tag
			return `<img src="rbxassetid://{emojiId}" size="1,0,1,0"/>`
		end
		return ":" .. emojiName .. ":" -- Return original if not found
	end)
end)