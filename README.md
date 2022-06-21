# FusionComponent


```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Fusion)
local Component = require(ReplicatedStorage.FusionComponent)

local ExampleComponent = Component()

function ExampleComponent:render()
	return Fusion.New "TextLabel" {
		Text = self.props.text,
		AnchorPoint = Vector2.one / 2,
		Size = UDim2.fromOffset(200,50),
		Position = UDim2.fromScale(.5,.5)
	}
end

return ExampleComponent.new
```

```lua
local ExampleComponent = require(script.Parent.ExampleComponent)

ExampleComponent { text = "Hello, world!" }
	:mount(script.Parent)
```