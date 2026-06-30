local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Bold = require(ReplicatedStorage.Bold)

Bold.Start({
	parsing = {
		enabled  = true,
		markdown = true,
		mentions = true,
		emoji    = true,
		filter   = true,   -- Roblox TextService filtering
	},
})


task.wait(3)

while task.wait() do
	--local message = "Hello world! " .. math.random(1, 100)
	--Bold.Message({
	--	content = {
	--		raw_text = message,
			
	--		embeds = {
	--			Bold.Image({
	--				type = "Image",
	--				image_id = "rbxassetid://95743251635238"
	--			})
	--		}
	--	},
	--	metadata = {
	--		author_id = game:GetService("Players").Kr3ativeKrayon.UserId,
	--		author_name = "Kr3ativeKrayon"
	--	}
	--})
end
