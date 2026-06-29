local RunService = game:GetService("RunService")

local _Main = script._Main
local _Patterns = script._Patterns
local _Utility = script._Utility
local _Packages = script._Packages

local Substance = require(_Packages.Substance)
local Type = Substance.Type

local Network = require(_Main.Network)
local Events = require(_Utility.Events)
local MessagePattern = require(_Patterns.Message)
local Types = require(script.Types)

local Bold = {}

local IS_SERVER = RunService:IsServer()
local started = false

function Bold.Start(config)
	if started then return end
	started = true

	if config then
		if config.interface then
			for k, v in config.interface do
				Interface.Config[k] = v
			end
		end
	end

	Events.Start()
	Network.Start()

	if IS_SERVER then
		local Server = require(_Main.Server)
		
		Bold.Server = Server
		
		Server.Start()
	else
		local Client = require(_Main.Client)
		local Interface = require(_Main.Interface)
		
		Bold.Client = Client
		Bold.Interface = Interface
		
		Client.Start()
	end
	
	Bold.Substance = Substance
	Bold.Network = Network
end

function Bold.Message(config: Types.MessageClass?): Types.MessageClass
	local message = MessagePattern.Construct(config)
	
	local Server = Bold.Server
	local Client = Bold.Client
	
	if IS_SERVER then
		if message.metadata and message.metadata.recipient_id then
			local targetPlayer = game:GetService("Players"):GetPlayerByUserId(message.metadata.recipient_id)
			if targetPlayer then
				Server.Send(message, targetPlayer)
			end
		else
			Server.Broadcast(message)
		end
	else
		-- Client: send to server for routing
		Client.Send(message)
	end

	return message
end

function Bold.Embed(config: Types.Embed): Types.Embed
	return config
end

return Bold