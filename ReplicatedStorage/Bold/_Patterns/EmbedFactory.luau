-- Bold/_Patterns/EmbedFactory.luau
local EmbedFactory = {}

-- This maps the "Type" in your metadata to the folder in _Assets
local AssetMap = {
	Gif = require(game.ReplicatedStorage.Bold._Assets._Embeds._Gifs),
	Sticker = require(game.ReplicatedStorage.Bold._Assets._Embeds._Stickers),
	Default = require(game.ReplicatedStorage.Bold._Assets._Embeds._Default)
}

function EmbedFactory:Build(metadata: {Type: string, Data: any}): GuiObject
	local renderer = AssetMap[metadata.Type] or AssetMap.Default

	-- The renderer returns a fresh UI frame from your _Assets templates
	return renderer:Create(metadata.Data)
end

return EmbedFactory