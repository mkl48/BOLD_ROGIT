local Types = {}

export type TextFormatting = {
	font: Enum.Font?,
	text_size: number?,
	italic: boolean?,
	bold: boolean?,
	underline: boolean?,
	strikethrough: boolean?,
	color: Color3?,
	code: boolean?,
}

export type ElementType = "text" | "mention" | "emoji_unicode" | "emoji_custom" | "code"

export type Element = {
	type: ElementType,
	content: string,
	formatting: TextFormatting?,
	data: {
		mention_name: string?,
		mention_id: number?,
		emoji_name: string?,
		emoji_asset: string?,
	}?,
}

export type BaseEmbed = {
	color: Color3?,
	timestamp: number?,
}

export type ImageEmbed = BaseEmbed & {
	type: "Image",
	image_id: string,
	aspect_ratio: number?,
	caption: string?,
}

export type GifEmbed = BaseEmbed & {
	type: "Gif",
	video_id: string,
	loop: boolean?,
	autoplay: boolean?,
}

export type StickerEmbed = BaseEmbed & {
	type: "Sticker",
	sticker_id: string,
	size: number?,
}

export type RichTextEmbed = BaseEmbed & {
	type: "RichText",
	title: string,
	description: string?,
	thumbnail: string?,
	fields: { { name: string, value: string, inline: boolean? } }?,
}

export type ActionEmbed = BaseEmbed & {
	type: "Action",
	title: string,
	action_id: string,
	button_text: string,
	style: ("primary" | "danger" | "ghost")?,
}

export type Embed = ImageEmbed | GifEmbed | StickerEmbed | RichTextEmbed | ActionEmbed

export type MessageKind = "chat" | "system" | "announcement" | "whisper" | "team" | string

export type MessageMetadata = {
	id: string,
	source: string,
	timestamp: number,
	author_id: number?,
	author_name: string?,
	recipient_id: number?,
	channel: string?,
}

export type MessageClass = {
	metadata: MessageMetadata,
	content: {
		raw_text: string?,
		elements: { Element },
		embeds: { Embed }?,
	},
	kind: MessageKind?,
	tags: { string }?,
	pinned: boolean?,
	filtered: boolean?,
}

export type Theme = {
	background: Color3?,
	header: Color3?,
	message_bg: Color3?,
	text: Color3?,
	subtext: Color3?,
	accent: Color3?,
	mention_bg: Color3?,
	mention_text: Color3?,
	code_bg: Color3?,
	code_text: Color3?,
	system_text: Color3?,
	announcement_bg: Color3?,
	announcement_text: Color3?,
	whisper_bg: Color3?,
	whisper_text: Color3?,
	team_bg: Color3?,
	team_text: Color3?,
	pinned_indicator: Color3?,
	font: Enum.Font?,
	corner_radius: number?,
}

export type BoldConfig = {
	interface: {
		theme: Theme?,
		window_size: UDim2?,
		window_position: UDim2?,
		window_anchor: Vector2?,
		header_height: number?,
		max_messages: number?,
		visible: boolean?,
		show_header: boolean?,
		channel_name: string?,
		animate_in: boolean?,
	}?,
	parsing: {
		enabled: boolean?,
		markdown: boolean?,
		mentions: boolean?,
		emoji: boolean?,
		filter: boolean?,
	}?,
}

export type ImageAsset = {
	Name: string,
	AssetId: number,
	AssetVersionId: number,
	CreatorName: string,
}

return Types