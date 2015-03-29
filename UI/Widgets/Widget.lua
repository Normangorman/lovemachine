Widget = {}
Widget.__index = Widget

function Widget.new(x,y,width,height, classes)
    local self = {}
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self._classes = classes or {}
    self._id = 0 -- This will be set if the widget is added to a hierarchy.
    self._parentHierarchy = nil 
    self._deleted = false -- deleted widgets will eventually be deleted from the hierarchy.

    return self 
end

function Widget:update(dt) end
function Widget:draw() end
function Widget:keypressed() end
function Widget:keyreleased() end
function Widget:mouseover(x,y) end
function Widget:mousepressed(x,y,button) end
function Widget:mousereleased(x,y,button) end
function Widget:textinput(text) end

function Widget:translate(x,y)
    self.x = self.x + x
    self.y = self.y + y
    return self
end

function Widget:setPosition(x,y)
    self.x = x
    self.y = y
    return self
end

function Widget:setWidth(width)
    self.width = width
    return self
end

function Widget:setHeight(height)
    self.height = height
    return self
end

function Widget:delete()
    self._deleted = true
end

function Widget:addClasses(classes)
    for _, class in ipairs(classes) do
        print("Widget:addClass - class added: "..class)
        table.insert(self._classes, class)
    end
end
