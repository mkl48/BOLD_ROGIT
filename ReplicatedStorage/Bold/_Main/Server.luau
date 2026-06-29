local _Main = script.Parent

local _Utility = _Main.Parent._Utility
local _Classes = _Main.Parent._Classes
local _Packages = _Main.Parent._Packages

local Substance = require(_Packages.Substance)

local Network = require(_Main.Network)

local Server = {}

-- Called when a message is received from a client
-- Override Server.OnMessage to handle incoming messages with custom logic
Server.OnMessage = nil

function Server.Start()
	-- Subscribe to the send channel to receive messages from clients
	Substance.Subscribe(Network.SEND_CHANNEL, function(payload, player)
		local message = payload.Message
		if not message then return end

		-- Attach author info from the sending player
		if player then
			if message.metadata then
				message.metadata.author_id = player.UserId
				message.metadata.author_name = player.Name
			end
		end

		-- If a custom handler is set, call it
		if Server.OnMessage then
			local result = Server.OnMessage(message, player)
			-- If the handler returns false, drop the message
			if result == false then return end
		end

		-- Route the message based on recipient_id
		if message.metadata and message.metadata.recipient_id then
			-- Targeted message: deliver only to the specified player
			local targetPlayer = game:GetService("Players"):GetPlayerByUserId(message.metadata.recipient_id)
			if targetPlayer then
				Substance.Post(Network.DELIVER_CHANNEL, { Message = message }, targetPlayer)
			end
		else
			-- Broadcast message: deliver to all players
			Substance.Broadcast(Network.DELIVER_CHANNEL, { Message = message })
		end
	end)
end

-- Send a message from the server to all clients
function Server.Broadcast(message)
	Substance.Broadcast(Network.DELIVER_CHANNEL, { Message = message })
end

-- Send a message from the server to a specific client
function Server.Send(message, targetPlayer)
	Substance.Post(Network.DELIVER_CHANNEL, { Message = message }, targetPlayer)
end

return Server
