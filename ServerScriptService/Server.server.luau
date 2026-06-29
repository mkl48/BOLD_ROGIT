local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Bold = require(ReplicatedStorage.Bold)

Bold.Start()


task.wait(3)

while task.wait() do
	local message = "Hello world! " .. math.random(1, 100)
	Bold.Message({
		content = {
			raw_text = message,
			
			embeds = {
				Bold.Embed({
					type = "Image",
					image_id = "rbxassetid://95743251635238"
				})
			}
		},
		metadata = {
			author_id = game:GetService("Players").Kr3ativeKrayon.UserId,
			author_name = "Kr3ativeKrayon"
		}
	})
end
