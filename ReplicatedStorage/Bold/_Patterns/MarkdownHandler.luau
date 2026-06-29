-- Bold/_Patterns/MarkdownHandler.luau
local Processor = require(game.ReplicatedStorage.Bold._Patterns.Processor)

Processor:RegisterHandler("EnableMarkdown", function(text: string)
	local formatted = text
	-- Bold: **text** -> <b>text</b>
	formatted = formatted:gsub("%*%*(.-)%*%*", "<b>%1</b>")
	-- Italics: *text* -> <i>text</i>
	formatted = formatted:gsub("%*(.-)%*", "<i>%1</i>")
	return formatted
end)