require "Widget"
require "Hierarchy"

Window = {}
Window.__index = Window

function Window.new(x,y, width,height)
    local self = Widget.new(x, y, width, height)
    self.borderSize = Settings.windowBorderSize
    self.borderColor = Settings.windowBorderColor
    self.backgroundColor = Settings.windowBackgroundColor

    self.hierarchy = Hierarchy.new()
    setmetatable(self, Window)
    return self 
end

function Window:close()
    self.closed = true
end

function Window:update(dt)
    self.hierarchy:updateWidgets(dt)
end

function Window:addWidget(widget)
    widget.x = widget.x + self.x
    widget.y = widget.y + self.y
    self.hierarchy:addWidget(widget)
end

function Window:draw()
    -- Draw border
    love.graphics.setColor( unpack(self.borderColor) )
    love.graphics.rectangle("fill", self.x, self.y,
                                    self.width, self.height)

    -- Draw background
    love.graphics.setColor( unpack(self.backgroundColor) )
    love.graphics.rectangle("fill", self.x + self.borderSize, self.y + self.borderSize,
                                    self.width - 2 * self.borderSize, self.height - 2 * self.borderSize)

    love.graphics.setColor(255,255,255)
    self.hierarchy:drawWidgets()
end
