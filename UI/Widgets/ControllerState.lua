require "UI.Widgets.Widget"
require "UI.Widgets.Text"
require "UI.Settings"

ControllerState = {}
ControllerState.__index = ControllerState
setmetatable(ControllerState, Widget)

function ControllerState.new(panel, x,y)
    local self = Widget.new(x,y, Settings.controllerStateWidth, Settings.controllerStateHeight)
    self.panel = panel
    self.name = "State0"
    self.color = Settings.controllerStateColor
    self.beingDragged = false
    self.oldMousePosition = nil

    setmetatable(self, ControllerState)

    self:refreshNameText()

    return self
end

function ControllerState:setAnimation(animation)
    self.animation = animation
end

function ControllerState:setName(name)
    self.name = name
    self:refreshNameText()
end

function ControllerState:refreshNameText()
    local text_y = self.y + self.height / 2 - love.graphics.getFont():getHeight() / 2
    self.nameTextWidget = Text.new(self.name, self.x, text_y, self.width, "center")
end

function ControllerState:update(dt)
    if self.beingDragged then
        local mx, my = love.mouse.getPosition()
        local dx = mx - self.oldMousePosition.x
        local dy = my - self.oldMousePosition.y

        self:translate(dx, dy)
        self.nameTextWidget:translate(dx,dy)
        self.oldMousePosition = {x=mx, y=my}
    end
end

function ControllerState:draw()
    love.graphics.setColor( unpack(self.color) )
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.setColor(255,255,255)
    self.nameTextWidget:draw()
end

function ControllerState:mousepressed(_, _, button)
    if button == 'l' then
        self.panel:setActiveState(self)
        self.beingDragged = true
        self.oldMousePosition = {x = love.mouse.getX(), y = love.mouse.getY()}
    end
end

function ControllerState:mousereleased(mx, my, button)
    if button == 'l' then
        self.beingDragged = false
    end
end
