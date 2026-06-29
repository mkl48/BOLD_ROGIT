local HttpService = game:GetService("HttpService")

local ID = {}

function ID.Generate()
	return HttpService:GenerateGUID(false)
end

return ID