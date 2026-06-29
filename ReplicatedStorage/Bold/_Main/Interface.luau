local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local _Main    = script.Parent
local _Utility = _Main.Parent._Utility
local _Pat     = _Main.Parent._Patterns

local Events = require(_Utility.Events)
local Types  = require(_Main.Parent.Types)

local Interface = {}

-- Default theme
local DEFAULTS: Types.Theme = {
	background        = Color3.fromRGB(30,  31,  34),
	header            = Color3.fromRGB(20,  21,  24),
	message_bg        = Color3.fromRGB(43,  45,  49),
	text              = Color3.fromRGB(220, 221, 222),
	subtext           = Color3.fromRGB(148, 155, 164),
	accent            = Color3.fromRGB(88,  101, 242),
	mention_bg        = Color3.fromRGB(66,  80,  160),
	mention_text      = Color3.fromRGB(180, 195, 255),
	code_bg           = Color3.fromRGB(28,  30,  33),
	code_text         = Color3.fromRGB(186, 230, 126),
	system_text       = Color3.fromRGB(148, 155, 164),
	announcement_bg   = Color3.fromRGB(60,  50,  20),
	announcement_text = Color3.fromRGB(255, 220, 100),
	whisper_bg        = Color3.fromRGB(30,  25,  40),
	whisper_text      = Color3.fromRGB(200, 160, 255),
	team_bg           = Color3.fromRGB(20,  40,  30),
	team_text         = Color3.fromRGB(100, 220, 130),
	pinned_indicator  = Color3.fromRGB(255, 200, 50),
	font              = Enum.Font.Gotham,
	corner_radius     = 8,
}

-- Per-kind overrides -- bg/text color keys into the theme
local KIND_OVERRIDES: { [string]: { bg: string, text: string } } = {
	system       = { bg = "message_bg",       text = "system_text"       },
	announcement = { bg = "announcement_bg",   text = "announcement_text"  },
	whisper      = { bg = "whisper_bg",        text = "whisper_text"       },
	team         = { bg = "team_bg",           text = "team_text"          },
	chat         = { bg = "message_bg",        text = "text"               },
}

Interface.Config = {
	theme         = DEFAULTS,
	window_size   = UDim2.fromOffset(420, 560),
	window_pos    = UDim2.new(1, -20, 1, -20),
	window_anchor = Vector2.new(1, 1),
	header_height = 40,
	max_messages  = 100,
	visible       = true,
	show_header   = true,
	channel_name  = "Messages",
	animate_in    = true,
}

-- Override renderers per kind -- (message, theme) -> Frame
Interface.Renderers = {} :: { [string]: (any, any) -> Frame }

local _gui: ScreenGui?
local _window: Frame?
local _container: ScrollingFrame?
local _header: Frame?

local function tk(key: string): any
	local v = Interface.Config.theme[key]
	return if v ~= nil then v else DEFAULTS[key]
end

local function rgb(c: Color3): string
	return string.format("rgb(%d,%d,%d)", math.floor(c.R * 255), math.floor(c.G * 255), math.floor(c.B * 255))
end

local function corner(parent: Instance, r: number?): UICorner
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or tk("corner_radius"))
	c.Parent = parent
	return c
end

local function pad(parent: Instance, all: number?, h: number?, v: number?): UIPadding
	local p = Instance.new("UIPadding")
	local hv = UDim.new(0, h or all or 0)
	local vv = UDim.new(0, v or all or 0)
	p.PaddingLeft   = hv
	p.PaddingRight  = hv
	p.PaddingTop    = vv
	p.PaddingBottom = vv
	p.Parent = parent
	return p
end

local function listLayout(parent: Instance, dir: Enum.FillDirection?, gap: number?, sort: Enum.SortOrder?): UIListLayout
	local l = Instance.new("UIListLayout")
	l.FillDirection = dir or Enum.FillDirection.Vertical
	l.SortOrder     = sort or Enum.SortOrder.LayoutOrder
	l.Padding       = UDim.new(0, gap or 0)
	l.Parent        = parent
	return l
end

local function label(props: {
	parent: Instance,
	text: string,
	size: UDim2,
	color: Color3?,
	font: Enum.Font?,
	ts: number?,
	wrap: boolean?,
	ax: Enum.TextXAlignment?,
	lo: number?,
	autoY: boolean?,
	rich: boolean?,
	}): TextLabel
	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Text              = props.text
	lbl.Font              = props.font or tk("font")
	lbl.TextSize          = props.ts or 14
	lbl.TextColor3        = props.color or tk("text")
	lbl.TextWrapped       = props.wrap ~= false
	lbl.TextXAlignment    = props.ax or Enum.TextXAlignment.Left
	lbl.RichText          = props.rich or false
	if props.lo then lbl.LayoutOrder = props.lo end
	if props.autoY then
		lbl.Size          = UDim2.new(props.size.X.Scale, props.size.X.Offset, 0, 0)
		lbl.AutomaticSize = Enum.AutomaticSize.Y
	else
		lbl.Size          = props.size
	end
	lbl.Parent = props.parent
	return lbl
end

local function buildGui()
	if _gui then return end
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

	_gui = Instance.new("ScreenGui")
	_gui.Name           = "BoldUI"
	_gui.ResetOnSpawn   = false
	_gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	_gui.Enabled        = Interface.Config.visible
	_gui.Parent         = playerGui

	_window = Instance.new("Frame")
	_window.Name            = "Window"
	_window.Size            = Interface.Config.window_size
	_window.Position        = Interface.Config.window_pos
	_window.AnchorPoint     = Interface.Config.window_anchor
	_window.BackgroundColor3 = tk("background")
	_window.BorderSizePixel = 0
	_window.Parent          = _gui
	corner(_window, 10)
	listLayout(_window, nil, 0)

	if Interface.Config.show_header then
		_header = Instance.new("Frame")
		_header.Name             = "Header"
		_header.Size             = UDim2.new(1, 0, 0, Interface.Config.header_height)
		_header.BackgroundColor3 = tk("header")
		_header.BorderSizePixel  = 0
		_header.LayoutOrder      = 0
		_header.ClipsDescendants = true
		_header.Parent           = _window
		corner(_header, 10)
		pad(_header, nil, 12, 0)

		label({
			parent = _header,
			text   = "#  " .. Interface.Config.channel_name,
			size   = UDim2.new(1, 0, 1, 0),
			color  = tk("text"),
			ts     = 15,
		})
	end

	local containerH = if Interface.Config.show_header
		then UDim2.new(1, 0, 1, -Interface.Config.header_height)
		else UDim2.new(1, 0, 1, 0)

	_container = Instance.new("ScrollingFrame")
	_container.Name                = "Messages"
	_container.Size                = containerH
	_container.BackgroundColor3    = tk("background")
	_container.BorderSizePixel     = 0
	_container.ScrollBarThickness  = 3
	_container.ScrollBarImageColor3 = tk("subtext")
	_container.CanvasSize          = UDim2.new(0, 0, 0, 0)
	_container.AutomaticCanvasSize = Enum.AutomaticSize.Y
	_container.LayoutOrder         = 1
	_container.Parent              = _window

	listLayout(_container, nil, 4)
	pad(_container, nil, 8, 6)

	_container:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		Events.UIScrolled:Fire(_container.CanvasPosition.Y)
	end)
end

-- Builds the rich-text string from a parsed element array
local function elementsToRich(elements: { any }): string
	local parts: { string } = {}

	for _, elem in elements do
		if elem.type == "text" then
			local c = elem.content
				:gsub("&", "&amp;")
				:gsub("<", "&lt;")
				:gsub(">", "&gt;")

			local fmt = elem.formatting
			if fmt then
				if fmt.bold          then c = "<b>" .. c .. "</b>" end
				if fmt.italic        then c = "<i>" .. c .. "</i>" end
				if fmt.underline     then c = "<u>" .. c .. "</u>" end
				if fmt.strikethrough then c = "<s>" .. c .. "</s>" end
				if fmt.color         then
					c = '<font color="' .. rgb(fmt.color) .. '">' .. c .. "</font>"
				end
			end
			table.insert(parts, c)

		elseif elem.type == "emoji_unicode" then
			table.insert(parts, elem.content)

		elseif elem.type == "emoji_custom" then
			-- Custom emoji can't be inlined -- rendered separately after the label
			table.insert(parts, "[:" .. (elem.data and elem.data.emoji_name or "?") .. ":]")

		elseif elem.type == "mention" then
			local name = (elem.data and elem.data.mention_name) or elem.content:sub(2)
			table.insert(parts, string.format(
				'<font color="%s"><b>@%s</b></font>',
				rgb(tk("mention_text")), name
				))

		elseif elem.type == "code" then
			local c = elem.content
				:gsub("&", "&amp;")
				:gsub("<", "&lt;")
				:gsub(">", "&gt;")
			table.insert(parts, string.format(
				'<font color="%s" face="RobotoMono">%s</font>',
				rgb(tk("code_text")), c
				))
		end
	end

	return table.concat(parts)
end

local function buildContentRow(elements: { any }, rawFallback: string?, textColor: Color3, parent: Instance, lo: number)
	local richStr = ""
	local mentionData: { any } = {}

	if elements and #elements > 0 then
		richStr = elementsToRich(elements)
		for _, e in elements do
			if e.type == "mention" and e.data then
				table.insert(mentionData, e.data)
			end
		end
	elseif rawFallback and rawFallback ~= "" then
		richStr = rawFallback
	end

	if richStr == "" then return end

	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Size                   = UDim2.new(1, 0, 0, 0)
	lbl.AutomaticSize          = Enum.AutomaticSize.Y
	lbl.Font                   = tk("font")
	lbl.TextSize               = 14
	lbl.TextColor3             = textColor
	lbl.TextWrapped            = true
	lbl.TextXAlignment         = Enum.TextXAlignment.Left
	lbl.RichText               = true
	lbl.Text                   = richStr
	lbl.LayoutOrder            = lo
	lbl.Parent                 = parent

	-- Overlay button to capture mention clicks
	if #mentionData > 0 then
		local btn = Instance.new("TextButton")
		btn.Size                 = UDim2.new(1, 0, 1, 0)
		btn.BackgroundTransparency = 1
		btn.Text                 = ""
		btn.ZIndex               = lbl.ZIndex + 1
		btn.Parent               = lbl
		btn.MouseButton1Click:Connect(function()
			for _, m in mentionData do
				Events.MentionClicked:Fire(m.mention_id or 0, m.mention_name or "", nil)
			end
		end)
	end
end

local function buildEmbed(embed: any, parent: Instance, lo: number): Frame?
	if not embed or not embed.type then return nil end

	local Parser

	local outer = Instance.new("Frame")
	outer.Name             = "Embed_" .. embed.type
	outer.AutomaticSize    = Enum.AutomaticSize.Y
	outer.Size             = UDim2.new(1, 0, 0, 0)
	outer.BackgroundColor3 = tk("header")
	outer.BorderSizePixel  = 0
	outer.LayoutOrder      = lo
	corner(outer, 6)

	local stripe = Instance.new("Frame")
	stripe.Size             = UDim2.new(0, 3, 1, 0)
	stripe.BackgroundColor3 = embed.color or tk("accent")
	stripe.BorderSizePixel  = 0
	stripe.Parent           = outer
	corner(stripe, 2)

	local inner = Instance.new("Frame")
	inner.AutomaticSize    = Enum.AutomaticSize.Y
	inner.Size             = UDim2.new(1, -12, 0, 0)
	inner.Position         = UDim2.fromOffset(12, 0)
	inner.BackgroundTransparency = 1
	inner.Parent           = outer
	listLayout(inner, nil, 4)
	pad(inner, nil, 6, 8)

	local iLo = 0

	if embed.type == "Image" then
		local img = Instance.new("ImageLabel")
		img.Size              = UDim2.new(1, 0, 0, 140)
		img.BackgroundColor3  = Color3.new(0, 0, 0)
		img.BackgroundTransparency = 0.4
		img.Image             = embed.image_id or ""
		img.ScaleType         = Enum.ScaleType.Fit
		img.LayoutOrder       = iLo; iLo += 1
		img.Parent            = inner
		corner(img, 4)

		if embed.caption and embed.caption ~= "" then
			label({ parent = inner, text = embed.caption, size = UDim2.new(1,0,0,0),
				color = tk("subtext"), ts = 12, lo = iLo, autoY = true })
			iLo += 1
		end

	elseif embed.type == "Gif" then
		local vf = Instance.new("VideoFrame")
		vf.Size             = UDim2.new(1, 0, 0, 140)
		vf.BackgroundColor3 = Color3.new(0, 0, 0)
		vf.Video            = embed.video_id or ""
		vf.Looped           = embed.loop ~= false
		vf.LayoutOrder      = iLo; iLo += 1
		vf.Parent           = inner
		corner(vf, 4)
		if embed.autoplay ~= false then
			vf:Play()
		end

	elseif embed.type == "Sticker" then
		if not Parser then
			Parser = require(_Pat.Parser)
		end
		local asset = Parser.GetStickerAsset(embed.sticker_id or "")
		local sz    = embed.size or 80

		local img = Instance.new("ImageLabel")
		img.Size              = UDim2.fromOffset(sz, sz)
		img.BackgroundTransparency = 1
		img.Image             = asset or ""
		img.ScaleType         = Enum.ScaleType.Fit
		img.LayoutOrder       = iLo; iLo += 1
		img.Parent            = inner

	elseif embed.type == "RichText" then
		if embed.title and embed.title ~= "" then
			label({ parent = inner, text = embed.title, size = UDim2.new(1,0,0,0),
				color = tk("text"), ts = 15, lo = iLo, autoY = true })
			iLo += 1
		end
		if embed.description and embed.description ~= "" then
			label({ parent = inner, text = embed.description, size = UDim2.new(1,0,0,0),
				color = tk("subtext"), ts = 13, lo = iLo, autoY = true })
			iLo += 1
		end
		if embed.thumbnail and embed.thumbnail ~= "" then
			local thumb = Instance.new("ImageLabel")
			thumb.Size                 = UDim2.fromOffset(40, 40)
			thumb.BackgroundTransparency = 1
			thumb.Image                = embed.thumbnail
			thumb.ScaleType            = Enum.ScaleType.Crop
			thumb.LayoutOrder          = iLo; iLo += 1
			thumb.Parent               = inner
			corner(thumb, 20)
		end
		if embed.fields then
			for _, field in embed.fields do
				local fFrame = Instance.new("Frame")
				fFrame.AutomaticSize    = Enum.AutomaticSize.Y
				fFrame.Size             = UDim2.new(1, 0, 0, 0)
				fFrame.BackgroundTransparency = 1
				fFrame.LayoutOrder      = iLo; iLo += 1
				fFrame.Parent           = inner
				listLayout(fFrame, nil, 2)

				label({ parent = fFrame, text = field.name, size = UDim2.new(1,0,0,0),
					color = tk("text"), ts = 13, lo = 0, autoY = true })
				label({ parent = fFrame, text = field.value, size = UDim2.new(1,0,0,0),
					color = tk("subtext"), ts = 13, lo = 1, autoY = true })
			end
		end

	elseif embed.type == "Action" then
		if embed.title and embed.title ~= "" then
			label({ parent = inner, text = embed.title, size = UDim2.new(1,0,0,0),
				color = tk("text"), ts = 14, lo = iLo, autoY = true })
			iLo += 1
		end
		local btnColor = embed.style == "danger"  and Color3.fromRGB(220, 60, 60)
			or embed.style == "ghost"  and Color3.fromRGB(80, 85, 95)
			or tk("accent")

		local btn = Instance.new("TextButton")
		btn.Size             = UDim2.fromOffset(140, 32)
		btn.BackgroundColor3 = btnColor
		btn.BorderSizePixel  = 0
		btn.Text             = embed.button_text or "Action"
		btn.Font             = tk("font")
		btn.TextSize         = 14
		btn.TextColor3       = Color3.new(1, 1, 1)
		btn.LayoutOrder      = iLo
		btn.Parent           = inner
		corner(btn, 6)
		btn.MouseButton1Click:Connect(function()
			Events.EmbedActionFired:Fire(embed.action_id, nil)
		end)
	end

	outer.Parent = parent
	return outer
end

local function buildCard(message: any): Frame
	local kind  = message.kind or "chat"
	local over  = KIND_OVERRIDES[kind] or KIND_OVERRIDES.chat

	-- Custom renderer override
	if Interface.Renderers[kind] then
		return Interface.Renderers[kind](message, Interface.Config.theme)
	end

	local bgColor   = tk(over.bg)
	local txtColor  = tk(over.text)

	local card = Instance.new("Frame")
	card.Name             = "Card"
	card.AutomaticSize    = Enum.AutomaticSize.Y
	card.Size             = UDim2.new(1, 0, 0, 0)
	card.BackgroundColor3 = bgColor
	card.BorderSizePixel  = 0
	corner(card)
	pad(card, nil, 10, 8)
	listLayout(card, nil, 4)

	local lo = 0

	-- Pinned bar
	if message.pinned then
		local bar = Instance.new("Frame")
		bar.Size             = UDim2.new(1, 0, 0, 2)
		bar.BackgroundColor3 = tk("pinned_indicator")
		bar.BorderSizePixel  = 0
		bar.LayoutOrder      = lo; lo += 1
		bar.Parent           = card
	end

	-- Header row: author name + timestamp
	local meta = message.metadata
	if meta then
		local row = Instance.new("Frame")
		row.Size                 = UDim2.new(1, 0, 0, 20)
		row.BackgroundTransparency = 1
		row.LayoutOrder          = lo; lo += 1
		row.Parent               = card

		local authorName = meta.author_name or meta.source or "System"

		label({ parent = row, text = authorName, size = UDim2.new(1, -60, 1, 0),
			color = tk("accent"), ts = 14 })

		if meta.timestamp and meta.timestamp > 0 then
			local t = Instance.new("TextLabel")
			t.BackgroundTransparency = 1
			t.Size                   = UDim2.fromOffset(60, 20)
			t.Position               = UDim2.new(1, -60, 0, 0)
			t.Text                   = os.date("%H:%M", meta.timestamp)
			t.Font                   = tk("font")
			t.TextSize               = 11
			t.TextColor3             = tk("subtext")
			t.TextXAlignment         = Enum.TextXAlignment.Right
			t.Parent                 = row
		end
	end

	-- Tags row
	if message.tags and #message.tags > 0 then
		local row = Instance.new("Frame")
		row.AutomaticSize    = Enum.AutomaticSize.XY
		row.Size             = UDim2.fromOffset(0, 0)
		row.BackgroundTransparency = 1
		row.LayoutOrder      = lo; lo += 1
		row.Parent           = card
		listLayout(row, Enum.FillDirection.Horizontal, 4)

		for _, tag in message.tags do
			local pill = Instance.new("Frame")
			pill.AutomaticSize    = Enum.AutomaticSize.X
			pill.Size             = UDim2.fromOffset(0, 18)
			pill.BackgroundColor3 = tk("header")
			pill.BorderSizePixel  = 0
			pill.Parent           = row
			corner(pill, 4)
			pad(pill, nil, 6, 0)

			local t = Instance.new("TextLabel")
			t.BackgroundTransparency = 1
			t.AutomaticSize          = Enum.AutomaticSize.X
			t.Size                   = UDim2.fromOffset(0, 18)
			t.Text                   = tag
			t.Font                   = tk("font")
			t.TextSize               = 11
			t.TextColor3             = tk("subtext")
			t.Parent                 = pill
		end
	end

	-- Content
	local content = message.content
	if content then
		buildContentRow(content.elements, content.raw_text, txtColor, card, lo)
		lo += 1

		if content.embeds then
			for _, embed in content.embeds do
				local ef = buildEmbed(embed, card, lo)
				if ef then lo += 1 end
			end
		end
	end

	-- Click overlay
	local clickBtn = Instance.new("TextButton")
	clickBtn.Size                 = UDim2.new(1, 0, 1, 0)
	clickBtn.BackgroundTransparency = 1
	clickBtn.Text                 = ""
	clickBtn.ZIndex               = card.ZIndex + 5
	clickBtn.Parent               = card
	clickBtn.MouseButton1Click:Connect(function()
		Events.CardClicked:Fire(message, card)
	end)

	return card
end

local function scrollToBottom()
	task.defer(function()
		if _container then
			_container.CanvasPosition = Vector2.new(0, math.huge)
		end
	end)
end

local function trimMessages()
	if not _container then return end
	local frames: { Frame } = {}
	for _, c in _container:GetChildren() do
		if c:IsA("Frame") then table.insert(frames, c) end
	end
	local excess = #frames - Interface.Config.max_messages
	if excess <= 0 then return end
	for i = 1, excess do
		frames[i]:Destroy()
	end
end

-- Public API

function Interface.Build()
	buildGui()
end

function Interface.Render(message: any)
	if not _container then buildGui() end

	local ok, result = pcall(buildCard, message)
	if not ok then
		warn("[Bold.Interface] Card build failed:", result)
		return
	end

	local card: Frame = result

	if Interface.Config.animate_in then
		card.BackgroundTransparency = 1
		card.Parent = _container
		TweenService:Create(card, TweenInfo.new(0.12, Enum.EasingStyle.Quad), {
			BackgroundTransparency = 0,
		}):Play()
	else
		card.Parent = _container
	end

	trimMessages()
	scrollToBottom()
	Events.MessageRendered:Fire(message, card)
end

function Interface.SetTheme(theme: Types.Theme)
	for k, v in theme do
		Interface.Config.theme[k] = v
	end
	Events.ThemeChanged:Fire(Interface.Config.theme)
end

function Interface.SetChannelName(name: string)
	Interface.Config.channel_name = name
	Events.ChannelChanged:Fire(name, Interface.Config.channel_name)
	if _header then
		local lbl = _header:FindFirstChildOfClass("TextLabel")
		if lbl then lbl.Text = "#  " .. name end
	end
end

function Interface.Toggle(visible: boolean?)
	if not _gui then return end
	local next = if visible ~= nil then visible else not _gui.Enabled
	_gui.Enabled = next
	Events.UIToggled:Fire(next)
end

function Interface.Clear()
	if not _container then return end
	for _, c in _container:GetChildren() do
		if c:IsA("Frame") then c:Destroy() end
	end
end

-- Register a custom card renderer for a message kind
function Interface.RegisterRenderer(kind: string, fn: (any, any) -> Frame)
	Interface.Renderers[kind] = fn
end

-- Register a kind color override at runtime
function Interface.SetKindOverride(kind: string, bg: string, text: string)
	KIND_OVERRIDES[kind] = { bg = bg, text = text }
end

return Interface