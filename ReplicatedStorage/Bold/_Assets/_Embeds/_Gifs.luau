local Gifs = {}

function Gifs:Create(data: {Url: string}): VideoFrame
	local frame = Instance.new("VideoFrame")
	frame.Video = data.Url
	frame.Size = UDim2.new(0, 200, 0, 200) -- Or fetch from Config
	frame.Looped = true
	frame.Playing = true
	return frame
end

return Gifs