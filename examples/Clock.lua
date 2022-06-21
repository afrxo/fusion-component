local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Fusion)
local Component = require(ReplicatedStorage.FusionComponent)

local ClockComponent = Component()

function ClockComponent:init()
	self.time = Fusion.Value(0)
end

function ClockComponent:render()
	return Fusion.New "TextLabel" {
		Text = self.time,
		AnchorPoint = Vector2.one / 2,
		Size = UDim2.fromOffset(200,50),
		Position = UDim2.fromScale(.5,.5),
	}
end

function ClockComponent:didRender()
	task.defer(function()
		while task.wait(1) do
			self.time:set(self.time:get() + 1)
		end
	end)
end

return ClockComponent.new