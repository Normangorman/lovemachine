require "UI.Widgets.Widget"
require "UI.Widgets.Text"

Button = {}
Button.__index = Button
setmetatable(Button, Widget)

function Button.new(x,y, width, height, settings)

    local self = Widget.new(x,y, width, height)

    if settings then
        if settings.image then
            self.image = settings.image
            self.width = self.image:getWidth()
            self.height = self.image:getHeight()

            if settings.mouseoverImage then
                self.mouseoverImage = settings.mouseoverImage
            end
        end
        if settings.text then
            local text_y = (self.y + self.height) / 2 - 0.5 * love.graphics.getFont():getHeight()
            self.textWidget = Text.new(settings.text, self.x, text_y, self.width, "center")
        end
        if settings.callback then self.callback = settings.callback end
    end

    self.backgroundColor = Settings.buttonBackgroundColor
    self.mouseoverBackgroundColor = Settings.buttonMouseoverBackgroundColor
    self.borderColor = Settings.buttonBorderColor
    self.isMouseover = false

    setmetatable(self, Button)
    return self 
end

function Button:update(dt)
    self.isMouseover = false
    if self.textWidget then
        local text_y = self.y + 0.5*self.height - 0.5 * love.graphics.getFont():getHeight()
        self.textWidget:setPosition(self.x, text_y)
    end
end

function Button:draw()
    if self.image then
        if self.isMouseover and self.mouseoverImage then
            love.graphics.draw(self.mouseoverImage, self.x, self.y)
        else
            love.graphics.draw(self.image, self.x, self.y)
        end
    else
        if self.isMouseover then
            love.graphics.setColor( unpack(self.mouseoverBackgroundColor) )
        else
            love.graphics.setColor( unpack(self.backgroundColor) )
        end
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
        
        love.graphics.setColor( unpack(self.borderColor) )
        love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    end

    if self.textWidget then
        -- Draw text centerized by default.
        self.textWidget:draw()
    end
end

function Button:mouseover(mx,my)
    self.isMouseover = true
end

function Button:mousepressed(mx,my,button)
    if button == "l" and self.callback then
        print("Calling button callback.")
        self.callback()
    end
end
