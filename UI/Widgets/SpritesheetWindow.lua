require "UI.Widgets.Window"
require "UI.Widgets.SpritesheetWidget"

SpritesheetWindow = {}
SpritesheetWindow.__index = SpritesheetWindow
setmetatable(SpritesheetWindow, Window)

function SpritesheetWindow.new(panel, imagePath, frameWidth, frameHeight, x, y)
    local widget = SpritesheetWidget.new(panel, imagePath, frameWidth, frameHeight, 0,0)
    local self = Window.newWithWidget(x,y, widget, {title=imagePath})

    self.spritesheetWidget = widget
    self.panel = panel

    setmetatable(self, SpritesheetWindow)
    return self 
end

function SpritesheetWindow:mousepressed(mx, my, button)
    self.panel:setActiveSpritesheet(self.spritesheetWidget)

    Window.mousepressed(self, mx, my, button)
end

function SpritesheetWindow:mousereleased(mx, my, button)
    Window.mousereleased(self, mx, my, button)
end

function SpritesheetWindow:close()
    self._deleted = true
    self.panel:spritesheetClosed(self.spritesheetWidget)
end
