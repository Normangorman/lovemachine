require "UI.Widgets.Widget"

Button = {}
Button.__index = Button
setmetatable(Button, Widget)

function Button.new(x,y, callback)
    local inactiveImage = love.graphics.newImage(Settings.closeButtonInactiveImagePath)
    local activeImage = love.graphics.newImage(Settings.closeButtonActiveImagePath)

    local self = Widget.new(x,y,inactiveImage:getDimensions())
    self.inactiveImage = inactiveImage
    self.activeImage = activeImage
    self.image = inactiveImage
    self.callback = callback
    setmetatable(self, Button)
    return self 
end

function Button:update(dt)
    self.image = self.inactiveImage
end

function Button:draw()
    love.graphics.draw(self.image, self.x, self.y)
end

function Button:mouseover(mx,my)
    print("Button moused over")
    self.image = self.activeImage
end

function Button:mousepressed(mx,my,button)
    if button == "l" then
        self.callback()
    end
end
