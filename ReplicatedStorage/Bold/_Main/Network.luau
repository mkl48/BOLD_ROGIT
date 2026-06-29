local _Main = script.Parent

local _Utility = _Main.Parent._Utility
local _Classes = _Main.Parent._Classes
local _Packages = _Main.Parent._Packages

local Substance = require(_Packages.Substance)
local Type = Substance.Type

local RunService = game:GetService("RunService")

local Network = {}

local IS_SERVER = RunService:IsServer()

-- Channel names
Network.SEND_CHANNEL = "__Message"       -- client -> server (clients post messages)
Network.DELIVER_CHANNEL = "__Message:Deliver" -- server -> client (server delivers messages)

function Network.Start()
	-- Compose both channels as Event type (RemoteEvent)
	-- Events.Start() already defined the schemas; we just need to set event types
	if IS_SERVER then
		Substance.Define(Network.SEND_CHANNEL, {
			Message = Type.table(),
		}):Compose(Network.SEND_CHANNEL, "Strict")

		Substance.Define(Network.DELIVER_CHANNEL, {
			Message = Type.table(),
		}):Compose(Network.DELIVER_CHANNEL, "Strict")
	else
		Substance.Define(Network.SEND_CHANNEL, {
			Message = Type.table(),
		}):Compose(Network.SEND_CHANNEL, "Strict")

		Substance.Define(Network.DELIVER_CHANNEL, {
			Message = Type.table(),
		}):Compose(Network.DELIVER_CHANNEL, "Strict")
	end
end

return Network