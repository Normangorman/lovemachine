require "UI.Widgets.Button"
require "UI.Widgets.ControllerState"
require "UI.Widgets.Widget"
require "UI.Widgets.Panel"
require "UI.Settings"

ControllerPanel = {}
ControllerPanel.__index = ControllerPanel
setmetatable(ControllerPanel, Panel)

function ControllerPanel.new(workspace, x,y)
    local width = love.window.getWidth() - x
    local height = love.window.getHeight() - y
    local self = Panel.new(x, y, width, height)

    self.workspace = workspace
    self.activeState = nil
    setmetatable(self, ControllerPanel)

    self:populateBaseWidgets()

    return self
end

function ControllerPanel:setActiveState(state)
    self.activeState = state

    -- Change the title text
    self.titleText:delete()
    self.titleText = Text.new("State selected", 0, 0, self.width)
    self:addWidget(self.titleText)

    -- Remake the active state widgets
    self.hierarchy:deleteWidgetsWithClass("activeState")
    self:populateStateWidgets()
end

function ControllerPanel:populateBaseWidgets()
    local ypos = 0
    local fontHeight = love.graphics.getFont():getHeight()
    local maxWidth = self:getMaxWidth()

    -- Title text
    self.titleText = Text.new("No state selected.", 0, ypos, maxWidth)
    self:addWidget(self.titleText)
    ypos = ypos + fontHeight + 5

    -- New state button
    local newStateButton = Button.new(0, ypos, maxWidth, 40, {
        callback = function() self:addNewState() end,
        text = "Add new state"
    })
    self:addWidget(newStateButton)
end

function ControllerPanel:populateStateWidgets()
    local ypos = 100
    local fontHeight = love.graphics.getFont():getHeight()
    local maxWidth = self:getMaxWidth()

    -- State name
    local stateNameLabel = Text.new("State name:", 0, ypos, maxWidth)
    stateNameLabel:addClasses{"activeState"}
    self:addWidget(stateNameLabel)
    ypos = ypos + fontHeight

    local stateNameInput = TextInput.new(0, ypos, maxWidth, function(text)
        self:changeActiveStateName(text)
    end)
    stateNameInput:addClasses{"activeState"}
    stateNameInput:setText(self.activeState.name)
    self:addWidget(stateNameInput)
    ypos = ypos + 10
end

function ControllerPanel:addNewState()
    print "Adding new state...\n"
    local x = self.workspace.maxWidth / 2 + love.math.random() * 400 - 200
    local y = self.workspace.maxHeight / 2 + love.math.random() * 400 - 200
    local newState = ControllerState.new(self, x, y)
    self.workspace:addState(newState)

    local stateNum = tostring(self.workspace.numStates - 1)
    newState:setName("state"..stateNum)

    self:setActiveState(newState)
end

function ControllerPanel:changeActiveStateName(text)
    if #text > 0 then
        self.activeState:setName(text)
    end
end
