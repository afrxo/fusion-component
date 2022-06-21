-- FusionComponent
-- afrxo, 21.06.22

export type Component<Props> = {
    props: Props,
    new: (props: Props) -> Fragment<Props>,
    init: ((Component<Props>, props: Props) -> ())?,
    render: ((Component<Props>) -> ())?,
    didInit: ((Component<Props>) -> ())?,
    didRender: ((Component<Props>) -> ())?,
    didDestroy: ((Component<Props>) -> ())?,
    willDestroy: ((Component<Props>) -> ())?
}

export type Fragment<Props> = {
    mount: (Fragment<Props>, parent: Instance) -> (),
    element: Instance,
    destroy: (Fragment<Props>) -> ()
}

local ComponentSymbol = newproxy()

local function reconcileProps(props)
    local reconciled = {}
    for key, value in pairs(props) do
        if (getmetatable(value) == ComponentSymbol) then
            reconciled[key] = value.element
        elseif (type(value) == "table") and (getmetatable(value) == nil) then
            reconciled[key] = reconcileProps(value)
        else
            reconciled[key] = value
        end
    end
    return reconciled
end

local function createComponentFactory(Component, BaseClass)
    return function (props)
        local Fragment = setmetatable({}, {__index = Component, __metatable = ComponentSymbol})

        props = props or {}
        props = reconcileProps(props)

        if (Fragment.init) then
            Fragment:init(props)
        end

        Fragment.props = props

        if (Fragment.didInit) then
            Fragment:didInit()
        end

        if (not Fragment.render) then
            error("Component.new() - render function not implemented")
        end

        local Tree = Fragment:render()

        if (getmetatable(Tree) == ComponentSymbol) then
            Tree = Tree.element
        end

        if (type(Tree) == "table") then
            local canvasGroup = Instance.new("CanvasGroup")
            canvasGroup.BackgroundTransparency = 1
            canvasGroup.Size = UDim2.fromScale(1,1)
            for _, instance in ipairs(Tree) do
                instance.Parent = canvasGroup
            end
            Tree = canvasGroup
        end

        if (not (typeof(Tree) == "Instance")) then
            error("Component.new() - render function did not return an Instance, collection of Instances or a Component")
        end

        Fragment.element = Tree

        if (Fragment.didRender) then
            Fragment:didRender()
        end

        Fragment._destroying = Tree.Destroying:Connect(function()
            if (Fragment.willDestroy) then
                Fragment:willDestroy()
            end

            if (type(BaseClass) == "table") and (BaseClass.willDestroy) then
                BaseClass.willDestroy(Fragment)
            end

            Fragment._destroying:Disconnect()

            task.defer(function()
                if (Fragment.didDestroy) then
                    Fragment:didDestroy()
                end
                if (type(BaseClass) == "table") and (BaseClass.didDestroy) then
                    BaseClass.didDestroy(Fragment)
                end
            end)
        end)

        return Fragment
    end
end

return function <Props>(BaseClass: table?): Component<Props>
    local Component = setmetatable({}, {})
    Component.prototype = { new = createComponentFactory(Component, BaseClass) }

    if type(BaseClass) == "table" then
        getmetatable(Component).__index = BaseClass
    end

    function Component.new(props: Props)
        return Component.prototype.new(props)
    end

    --> Initializes the BaseClass
    function Component:super(props)
        if type(BaseClass) == "table" then
            self:__super(reconcileProps(props or {}))
        end
    end

    --> On Component creation
    function Component:init(props) end
    --> After Component initialization
    function Component:didInit() end
    --> Render Fusion UI
    function Component:render() end
    --> After Fusion UI is rendered
    function Component:didRender() end
    --> Before Fusion UI is destroyed
    function Component:willDestroy() end
    --> After Fusion UI is destroyed
    function Component:didDestroy() end

    --> Parents the Fusion UI to the instance
    function Component:mount(parent)
        if (not self.element) then
            error("Component:mount() - component has not been rendered")
        end
        if (typeof(self.element) == "Instance") then
            self.element.Parent = parent
        elseif (typeof(self.element) == "table") then
            for _, instance in ipairs(self.element) do
                if (typeof(instance) == "Instance") then
                    instance.Parent = parent
                end
            end
        end
    end

    --> Destroys the Fusion UI & deinitializes the Component
    function Component:destroy()
        if (not self.element) then
            error("Component:destroy() - component has not been rendered")
        end
        self.element:Destroy()
    end

    return Component
end