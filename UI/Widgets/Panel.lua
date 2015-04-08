require "UI.Hierarchy"
require "UI.Widgets.Widget"

Panel = {}
Panel.__index = Panel
setmetatable(Panel, Widget)

function Panel.new(x,y,width,height)
    local self = Widget.new(x,y,width,height)
    self.hierarchy = Hierarchy.new(self)
    self.backgroundColor = Settings.panelBackgroundColor
    self.padding = Settings.panelPadding
    self.widgetPadding = Settings.panelWidgetPadding

    setmetatable(self, Panel)
    return self
end

function Panel:update(dt)
    self.hierarchy:update(dt)
end

function Panel:draw()
    love.graphics.setColor(unpack(self.backgroundColor))
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.setColor(255,255,255)
    self.hierarchy:draw()
end

function Panel:addWidget(w)
    w:translate(self.x + self.padding, self.y + self.padding)
    self.hierarchy:addWidget(w)
end

function Panel:mouseover(mx, my)
    self.hierarchy:mouseover(mx, my)
end

function Panel:mousepressed(mx, my, button)
    self.hierarchy:mousepressed(mx, my, button)
end

function Panel:mousereleased(mx, my, buton)
    self.hierarchy:mousereleased(mx, my, button)
end

function Panel:textinput(text)
    self.hierarchy:textinput(text)
end

function Panel:keypressed(key)
    self.hierarchy:keypressed(key)
end

function Panel:keyreleased(key)
    self.hierarchy:keyreleased(key)
end

-- The maximum width / height a widget can have.
function Panel:getMaxWidth()
    return self.width - 2 * self.padding
end

function Panel:getMaxHeight()
    return self.height - 2 * self.padding
end
