local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local _Source = "https://raw.githubusercontent.com/mkl48/BOLD/refs/heads/main/scripts/proflis.json"
local _Event = script.Repl_List

local Proflis = {}
Proflis._ls = {}

function Proflis.Start()
	if RunService:IsClient() then return end
	
	local Fetch = HttpService:GetAsync(_Source)
	
	if not Fetch then
		error("Failed to fetch Proflis.json")
		return
	end
	
	local Decoded = HttpService:JSONDecode(Fetch)
	
	if not Decoded then
		error("Failed to decode Proflis")
		return
	end
	
	Proflis._ls = Decoded
	
	_Event.OnServerInvoke = function()
		return Proflis._ls
	end
end

function Proflis.Get()
	if RunService:IsClient() then
		return _Event:InvokeServer()
	end
	return Proflis._ls
end

return Proflis