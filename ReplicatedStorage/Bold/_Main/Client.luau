local PlayerGui = game.Players.LocalPlayer.PlayerGui
local StarterGui = game:GetService("StarterGui")

local _Main = script.Parent

local _Utility = _Main.Parent._Utility
local _Classes = _Main.Parent._Classes
local _Packages = _Main.Parent._Packages
local _Patterns = _Main.Parent._Patterns

local Substance = require(_Packages.Substance)

local Network = require(_Main.Network)
local Interface = require(_Main.Interface)

local ImageSearch = require(_Patterns.ImageSearch)

local Client = {}

-- Called when a message is received on the client
-- Override Client.OnMessage to handle incoming messages with custom logic
Client.OnMessage = nil

function Client.Start()
	
	--
	
	--local ContentProvider = game:GetService("Contlocal Screen = Instance.new("ScreenGui")
	--Screen.Parent = PlayerGui
	
	--local Frame = Instance.new("Frame")
	--Frame.Parent = Screen
	--Frame.Size = UDim2.new(1, 0, 1, 0)
	
	--local List = Instance.new("ScrollingFrame")
	--List.Parent = Frame
	--List.Size = UDim2.new(1, 0, 1, 0)
	
	--local Layout = Instance.new("UIListLayout")
	--Layout.Parent = List
	--Layout.SortOrder = Enum.SortOrder.LayoutOrder
	--Layout.Wraps = true
	
	--local Result = ImageSearch.InquireTopic("meme")
	--Result:Next()
	--warn(Result:GetCurrent())entProvider")
	
	--local Images = {}
	
	--Result:ForContentsInPage(1, function(asset)
	--	local ID = asset.AssetId
	--	table.insert(Images, "rbxassetid://" .. ID)
	--end)
	
	--ContentProvider:PreloadAsync(Images, function(ID, status)
	--	if status == Enum.AssetFetchStatus.Success then
	--		local Image = Instance.new("ImageLabel")
	--		Image.Parent = List
	--		Image.Size = UDim2.new(1, 0, 0, 100)
	--		Image.Image = "rbxassetid://" .. ID
	--	else
	--		warn("Failed to load asset: " .. ID)
	--	end
	--end)

	-- Use your existing loop, but ensure the string format is correct for UI
	--Result:ForContentsInPage(1, function(asset)
	--	local targetId = asset.AssetId

	--	local Image = Instance.new("ImageLabel")
	--	Image.Name = "Image_" .. targetId
	--	Image.Parent = List
	--	Image.Size = UDim2.fromScale(.1, .1) -- Using Offset Y for the height
	--	Image.BackgroundTransparency = 1

	--	-- THIS is the critical part that replaces PreloadAsync
	--	-- This tells Roblox: "Give me the image data for this Decal ID"
	--	Image.Image = "rbxthumb://type=Asset&id=" .. targetId .. "&w=420&h=420"
	--end)

	Substance.Subscribe(Network.DELIVER_CHANNEL, function(payload)
		local message = payload.Message
		if not message then return end

		if Client.OnMessage then
			local result = Client.OnMessage(message)
			if result == false then return end
		end

		Interface.Render(message)
	end)
	
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
end

-- Send a message from the client to the server
function Client.Send(message)
	Substance.Post(Network.SEND_CHANNEL, { Message = message })
end

return Client
