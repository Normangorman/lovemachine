require "UI.Widgets.Widget"
require "UI.Settings"

Checkbox = {}
Checkbox.__index = Checkbox
setmetatable(Checkbox, Widget)

function Checkbox.new(checked, x, y, inputCallback)
    local width = Settings.checkboxDefaultSize
    local height = Settings.checkboxDefaultSize
    local self = Widget.new(x,y,width,height)

    self.checked = checked or false
    self.callback = inputCallback or function() end

    self.backgroundColor = Settings.checkboxBackgroundColor
    self.borderColor = Settings.checkboxBorderColor
    self.checkColor = Settings.checkboxCheckColor

    setmetatable(self, Checkbox)
    return self
end

function Checkbox:draw()
    love.graphics.setColor( unpack(self.backgroundColor) )
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.setColor(255,255,255)

    love.graphics.setColor( unpack(self.borderColor) )
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    love.graphics.setColor(255,255,255)

    if self.checked then
        local oldWidth = love.graphics.getLineWidth()
        love.graphics.setLineWidth(1)
        love.graphics.setLineStyle("smooth")
        love.graphics.setColor( unpack(self.checkColor) )
        love.graphics.line(self.x + oldWidth*2, self.y + oldWidth*2,
                           self.x + self.width - oldWidth*2, self.y + self.height - oldWidth*2)
        love.graphics.line(self.x + self.width - oldWidth*2, self.y + oldWidth*2,
                           self.x + oldWidth*2, self.y + self.height - oldWidth*2)
        love.graphics.setColor(255,255,255)
        love.graphics.setLineWidth(oldWidth)
    end
end

function Checkbox:mousepressed()
    self.checked = not self.checked
    self.callback(self.checked)
end

function Checkbox:isChecked()
    return self.checked
end
