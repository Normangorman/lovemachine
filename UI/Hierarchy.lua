Hierarchy = {}
Hierarchy.__index = Hierarchy

function Hierarchy.new(widget)
    local self = {}
    -- isRoot should only be true for the top level hierarchy.
    if not widget then
        self.isRoot = true
        self._owner = nil
    else
        self.isRoot = false
        self._owner = widget
    end

    self.widgets = {}
    self.widgetCount = 0
    setmetatable(self, Hierarchy)
    return self 
end

function Hierarchy:update(dt)
    --Work from the bottom of the stack upwards.
    for i, widget in ipairs(self.widgets) do
        widget:update(dt)
        if widget._deleted then table.remove(self.widgets, i) end
    end
end

function Hierarchy:draw()
    for _, widget in ipairs(self.widgets) do
        widget:draw()
    end
end

function Hierarchy:mouseover(x,y)
    -- Work from the top of the stack to the bottom. When a widget is collided with, stop.
    for i = #self.widgets, 1, -1 do
        local widget = self.widgets[i]
        if self:checkCollision(x, y, widget) then
            widget:mouseover(x, y)
            return true
        end
    end
    return false
end

function Hierarchy:mousepressed(x,y,button)
    -- Work from the top of the stack to the bottom. When a widget is collided with, stop.
    for i = #self.widgets, 1, -1 do
        local widget = self.widgets[i]
        if self:checkCollision(x, y, widget) then
            widget:mousepressed(x, y, button)
            return true, widget
        end
    end
    return false
end

function Hierarchy:mousereleased(x,y,button)
    -- Trigger mousereleased events for all widgets.
    for _, widget in ipairs(self.widgets) do
        widget:mousereleased(x, y, button) 
    end
end

function Hierarchy:mousefocus(f)
    if f == false then
        -- Trigger mousereleased events for all widgets.
        for _, widget in ipairs(self.widgets) do
            widget:mousereleased(x, y, button) 
        end
    end
end

function Hierarchy:textinput(text)
    for _, widget in ipairs(self.widgets) do
        widget:textinput(text)
    end
end

function Hierarchy:keypressed(key)
    for _, widget in ipairs(self.widgets) do
        widget:keypressed(key)
    end
end

function Hierarchy:keyreleased(key)
    for _, widget in ipairs(self.widgets) do
        widget:keyreleased(key)
    end
end

function Hierarchy:addWidget(widget)
    self.widgetCount = self.widgetCount + 1
    widget._id = self.widgetCount 
    widget._parentHierarchy = self
    table.insert(self.widgets, widget)
end

function Hierarchy:removeWidget(id)
    for i, w in ipairs(self.widgets) do
        if w._id == id then
            table.remove(self.widgets, i)
        end
    end
end

function Hierarchy:getWidgetsWithClass(class)
    local ws = {}
    print("Getting widgets with class: "..class)
    for i, w in ipairs(self.widgets) do
        -- Iterate through the widgets classes to see if the class in question is there.
        for _, c in ipairs(w._classes) do
            if c == class then
                table.insert(ws, w)
                break
            end
        end
    end
    print(string.format("Found %d widgets", #ws))
    return ws
end

function Hierarchy:deleteWidgetsWithClass(class)
    for _, w in ipairs(self:getWidgetsWithClass(class)) do
        w:delete()
    end
end

function Hierarchy:addWidgetToRoot(widget)
    if self.isRoot then
        self:addWidget(widget)
    else
        self._owner._parentHierarchy:addWidgetToRoot(widget)
    end
end

function Hierarchy:clearWidgets()
    self.widgets = {}
    self.widgetCount = 0
end

function Hierarchy:elevateWidget(id)
    print("elevateWidget called with id="..id)
    for i, widget in ipairs(self.widgets) do
        print("Comparing with widget id "..widget._id)
        if widget._id == id then
            print("It's a match")
            -- shift the element to the top of the stack.
            table.remove(self.widgets, i)
            table.insert(self.widgets, widget)
            break
        end
    end
end

function Hierarchy:translate(x,y)
    for _, widget in ipairs(self.widgets) do
        widget:translate(x,y)
    end
end

function Hierarchy:checkCollision(x,y,widget)
    -- Is the point x,y inside the widget's bounding rectangle?
    local left_x, right_x = widget.x, widget.x + widget.width
    local top_y, bottom_y = widget.y, widget.y + widget.height

    if  left_x < x and x < right_x and
        top_y < y and y < bottom_y then
        return true
    else return false end
end
