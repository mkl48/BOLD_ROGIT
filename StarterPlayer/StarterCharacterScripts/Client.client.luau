local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Bold = require(ReplicatedStorage.Bold)

Bold.Start()

Bold.Message({
	content = {
		embeds = {
			Bold.Image("rbxassetid://95743251635238"),
			Bold.Image("rbxassetid://95743251635238"),
			Bold.Image("rbxassetid://95743251635238"),
			Bold.Image("rbxassetid://95743251635238"),
			Bold.Action("test", {
				action_id = "test",
				style = "danger",
				button_text = "CLICK ME TO DELETE"
			})
		}
	}
})