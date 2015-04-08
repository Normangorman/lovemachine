require "UI.Settings"
require "UI.Widgets.Widget"
require "UI.Widgets.Workspace"
require "UI.Widgets.ControllerState"
require "UI.Widgets.ControllerPanel"

ControllerWorkspace = {}
ControllerWorkspace.__index = ControllerWorkspace
setmetatable(ControllerWorkspace, Workspace)

function ControllerWorkspace.new(x, y)
    local width = love.window.getWidth() - x
    local height = love.window.getHeight() - y

    local self = Workspace.new(x,y,width,height)

    -- Startup widgets:
    -- Panel:
    local controllerPanel = ControllerPanel.new(self, x + width * 0.75, y)
    self.staticHierarchy:addWidget(controllerPanel)

    -- Empty state:
    local animationState = ControllerState.new(controllerPanel, 100,100)
    self.hierarchy:addWidget(animationState)
    self.numStates = 1

    setmetatable(self, ControllerWorkspace)
    return self
end

function ControllerWorkspace:addState(newState)
    self.numStates = self.numStates + 1
    self.hierarchy:addWidget(newState)
end
