require "Hierarchy"

UIManager = {}
UIManager.__index = UIManager

function UIManager.new()
    local self = {}
    self.hierarchy = Hierarchy.new()
    self.widgetCount = 0
    setmetatable(self, UIManager)
    return self 
end

function UIManager:registerEvents()
    local callbacks = {'keypressed', 'keyreleased', 'mousepressed', 'mousereleased', 'mousefocus', 'gamepadpressed', 'gamepadreleased', 'gamepadaxis', 'textinput'}
    local old_functions = {}
    local empty_function = function() end
    for _, f in ipairs(callbacks) do
        old_functions[f] = love[f] or empty_function
        love[f] = function(...)
            old_functions[f](...)
            self[f](self, ...)
        end
    end
end

function UIManager:addWidget(w)
    self.hierarchy:addWidget(w)
end

function UIManager:updateWidgets(dt)
    self.hierarchy:updateWidgets(dt)
end

function UIManager:drawWidgets()
    self.hierarchy:drawWidgets()
end

function UIManager:keypressed(key)
end

function UIManager:keyreleased(key)
end

function UIManager:mousepressed(x,y,button)
    self.hierarchy:mousepressed(x,y,button)
end

function UIManager:mousereleased(x,y,button)
    self.hierarchy:mousereleased(x,y,button)
end

function UIManager:mousefocus(f)
    self.hierarchy:mousefocus(f)
end

function UIManager:gamepadpressed(joystick, button)
end

function UIManager:gamepadreleased(joystick, button)
end

function UIManager:gamepadaxis(joystick, axis, value)
end

function UIManager:textinput(text)
end
