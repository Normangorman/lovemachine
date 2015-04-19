require "UI.Widgets.Widget"
require "UI.Settings"

Text = {}
Text.__index = Text
setmetatable(Text, Widget)

function Text.new(text, x, y, width, align, color, font)
    if not font then
        font = love.graphics.getFont()
    end

    local wrapWidth, numLines = font:getWrap(text,width)
    local height = numLines * font:getHeight()

    local self = Widget.new(x,y,width,height)

    self.text = text
    self.font = font
    self.align = align or "left"
    self.color = color or Settings.defaultTextColor 

    setmetatable(self, Text)
    return self
end

function Text:draw()
    local oldFont
    if self.font then 
        oldFont = love.graphics.getFont()
        love.graphics.setFont(self.font)
    end
    love.graphics.setColor( unpack(self.color) )
    love.graphics.printf(self.text, self.x, self.y, self.width, self.align)
    love.graphics.setColor(255,255,255,255)

    if oldFont then
        love.graphics.setFont(oldFont)
    end
end

function Text:setText(newText)
    self.text = newText
    self.height = self.font:getWrap(newText, self.width) * self.font:getLineHeight()
end
