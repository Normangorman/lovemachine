require "UI.Settings"
require "UI.Widgets.Widget"
require "UI.Widgets.Workspace"
require "UI.Widgets.ControllerState"

ControllerWorkspace = {}
ControllerWorkspace.__index = ControllerWorkspace
setmetatable(ControllerWorkspace, Workspace)

function ControllerWorkspace.new(x, y)
    local width = love.window.getWidth() - x
    local height = love.window.getHeight() - y

    local self = Workspace.new(x,y,width,height)

    local animationState = ControllerState.new(100,100)
    self.hierarchy:addWidget(animationState)

    setmetatable(self, ControllerWorkspace)
    return self
end
