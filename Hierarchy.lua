Hierarchy = {}
Hierarchy.__index = Hierarchy

function Hierarchy.new()
    local self = {}
    self.widgets = {}
    self.widgetCount = 0
    setmetatable(self, Hierarchy)
    return self 
end

function Hierarchy:mousepressed(x,y,button)
    -- Work from the top of the stack to the bottom. When a widget is collided with, stop.
    print(string.format("Hierarchy:mousepressed - Mouse button '%s' pressed at %d, %d", button, x, y))
    for i = #self.widgets, 1, -1 do
        local widget = self.widgets[i]
        if self:checkCollision(x, y, widget) then
            if widget.mousepressed then widget:mousepressed(x, y, button) end
            return true
        end
    end
    return false
end

function Hierarchy:mousereleased(x,y,button)
    print(string.format("Hierarchy:mousereleased - Mouse button '%s' released at %d, %d", button, x, y))

    -- Trigger mousereleased events for all widgets.
    for _, widget in ipairs(self.widgets) do
        if widget.mousereleased then widget:mousereleased(x, y, button) end
    end
end

function Hierarchy:mousefocus(f)
    if f == false then
        -- Trigger mousereleased events for all widgets.
        for _, widget in ipairs(self.widgets) do
            if widget.mousereleased then widget:mousereleased(x, y, button) end
        end
    end
end

function Hierarchy:addWidget(widget)
    self.widgetCount = self.widgetCount + 1
    widget.id = self.widgetCount 
    table.insert(self.widgets, widget)
    print("Hierarchy: added a widget with id number "..self.widgetCount)
end

function Hierarchy:elevateWidget(id)
    for i, widget in ipairs(self.widgets) do
        if widget.id == id then
            -- shift the element to the top of the stack.
            table.remove(self.widgets, i)
            table.insert(widget)
            break
        end
    end
end

function Hierarchy:updateWidgets(dt)
    --Work from the bottom of the stack upwards.
    for _, widget in ipairs(self.widgets) do
        if widget.update then widget:update(dt) end
    end
end

function Hierarchy:drawWidgets()
    for _, widget in ipairs(self.widgets) do
        if widget.draw then widget:draw() end
    end
end

-- Utility function - might belong better elsewhere?
function Hierarchy:checkCollision(x,y,widget)
    -- Is the point x,y inside the widget's bounding rectangle?
    local left_x, right_x = widget.x, widget.x + widget.width
    local top_y, bottom_y = widget.y, widget.y + widget.height

    if  left_x < x and x < right_x and
        top_y < y and y < bottom_y then
        print( string.format("Collision detected with a widget at %d, %d", x,y) )
        return true
    else return false end
end
