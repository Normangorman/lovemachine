require "UI.Settings"
require "UI.Widgets.Button"
require "UI.Widgets.Widget"
require "UI.Widgets.Window"

AlertWindow = {}
AlertWindow.__index = AlertWindow
setmetatable(AlertWindow, Window)

function AlertWindow.new(message)
    local width, height = 200, 80 
    local x = 0.5 * love.window.getWidth() - 0.5 * width
    local y = 0.5 * love.window.getHeight() - 0.5 * height

    local self = Window.new(x,y,width,height, {
        hasTitle = false
    })

    local font = love.graphics.getFont()
    local horizontalTextPadding = 20
    local verticalTextPadding = 10
    local _, lines = font:getWrap(message, width - horizontalTextPadding * 2)
    self.height = self.height + font:getHeight() * lines

    local innerWidth, innerHeight = self:getInnerWidth(), self:getInnerHeight()
    self:addWidget(Text.new(message, horizontalTextPadding, verticalTextPadding, innerWidth - horizontalTextPadding * 2, "center"))

    local buttonWidth = 150
    local buttonHeight = 30
    local closeButton = Button.new(
        0.5 * self.width - 0.5 * buttonWidth - self.borderSize,
        self.height - buttonHeight - 30,
        buttonWidth,
        buttonHeight,
        {
            callback = function() self:close() end,
            text = "Ok"
        }
    )
    self:addWidget(closeButton)
        
    setmetatable(self, AlertWindow)
    return self
end
