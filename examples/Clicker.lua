local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Fusion)
local Component = require(ReplicatedStorage.FusionComponent)

local ClickerComponent = Component()

function ClickerComponent:init()
	self.clicks = Fusion.Value(0)
end

function ClickerComponent:render()
	return {
		Fusion.New "TextButton" {
			Text = "Click me!",
			TextColor3 = Color3.new(0,0,0),
			AnchorPoint = Vector2.one / 2,
			Size = UDim2.fromOffset(200,50),
			Position = UDim2.fromScale(.4,.5),
			[Fusion.OnEvent("Activated")] = function()
				self.clicks:set(self.clicks:get() + 1)
			end,
		},
		Fusion.New "TextLabel" {
			Text = self.clicks,
			AnchorPoint = Vector2.one / 2,
			Size = UDim2.fromOffset(200,50),
			Position = UDim2.fromScale(.6,.5)
		}
	}
end

return ClickerComponent.new