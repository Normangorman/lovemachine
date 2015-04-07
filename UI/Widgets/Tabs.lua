require "UI.Hierarchy"
require "UI.Settings"
require "UI.Widgets.Widget"

-- Tab is a private class. To make some tabs create a Tabs object with Tabs.new then call Tabs:createTab.
local Tab = {}
Tab.__index = Tab
setmetatable(Tab, Widget)

function Tab.new(tabName, x,y, height)
    local horizontalTextPadding = Settings.tabsHorizontalTextPadding 
    local verticalTextPadding = Settings.tabsVerticalTextPadding 
    local cornerWidth = Settings.tabsCornerWidth
    local width = love.graphics.getFont():getWidth(tabName) + horizontalTextPadding * 2 + cornerWidth * 2

    local self = Widget.new(x,y,width,height)
    self.name = tabName

    self.horizontalTextPadding = horizontalTextPadding
    self.verticalTextPadding = verticalTextPadding
    self.cornerWidth = cornerWidth

    self.activeColor = Settings.tabsActiveTabColor
    self.mouseoverColor = Settings.tabsMouseoverTabColor
    self.inactiveColor = Settings.tabsInactiveTabColor
    
    self.active = false
    self.hierarchy = Hierarchy.new()

    setmetatable(self, Tab)
    return self
end

function Tab:update(dt)
    self.isMouseover = false
    if self.active then
        self.hierarchy:update(dt)
    end
end

function Tab:draw()
    if self.active then
        love.graphics.setColor( unpack(self.activeColor) )
    elseif self.isMouseover then
        love.graphics.setColor( unpack(self.mouseoverColor) )
    else
        love.graphics.setColor( unpack(self.inactiveColor) )
    end

    -- The vertices of a tab look like this:
    --
    --   2*********3 
    --  *   Text    *
    -- 1*************4
    --
    
    local vertices = {
        self.x, self.y + self.height,
        self.x + self.cornerWidth, self.y,
        self.x + self.width - self.cornerWidth, self.y,
        self.x + self.width, self.y + self.height
    }
                    
    love.graphics.polygon("fill", vertices)
    love.graphics.setColor(255,255,255)

    love.graphics.print(
        self.name,
        self.x + self.cornerWidth + self.horizontalTextPadding,
        self.y + self.verticalTextPadding
    )

    if self.active then
        self.hierarchy:draw()
    end
end

function Tab:mouseover(mx, my)
    self.isMouseover = true
    self.hierarchy:mouseover(mx, my)
end

function Tab:mousepressed(mx, my, button)
    print "Tab was mousepressed."
    self.hierarchy:mousepressed(mx, my, button)
end

function Tab:mousereleased(mx, my, button)
    print "Tab was mousereleased."
    self.hierarchy:mousereleased(mx, my, button)
end

function Tab:keypressed(key)
    self.hierarchy:keypressed(key)
end

function Tab:keyreleased(key)
    self.hierarchy:keyreleased(key)
end

function Tab:textinput(text)
    self.hierarchy:textinput(text)
end

function Tab:addWidget(w)
    self.hierarchy:addWidget(w)
end

Tabs = {}
Tabs.__index = Tabs
setmetatable(Tabs, Widget)

function Tabs.new(x,y,width,height)
    local self = Widget.new(x,y,width,height)

    self.tabs = {}
    -- This hierarchy only contains the tabs themselves.
    -- Each tab has its own hierarchy containing all the widgets in the actual scene.
    self.hierarchy = Hierarchy.new()
    self.activeTab = nil

    self.tabHeight = Settings.tabsTabHeight
    self.tabSpacing = Settings.tabsTabSpacing

    self.innerX = x
    self.innerY = y + self.tabHeight  

    setmetatable(self, Tabs)
    return self
end

function Tabs:update(dt)
    self.hierarchy:update(dt)
end

function Tabs:draw()
    self.hierarchy:draw()

    love.graphics.setLineWidth(1)
    local y = self.y + self.tabHeight - 1
    love.graphics.setColor( unpack(Settings.tabsActiveTabColor) )
    love.graphics.line(self.x, y, self.x + self.width, y)
    love.graphics.setColor(255,255,255,255)
    love.graphics.setLineWidth(1)
end

function Tabs:mouseover(mx, my)
    if not self.hierarchy:mouseover(mx, my) then
        if self.activeTab then
            self.activeTab:mouseover(mx, my)
        end
    end
end

function Tabs:mousepressed(mx, my, button)
    local wasTabClicked, clickedTab = self.hierarchy:mousepressed(mx,my,button)

    if wasTabClicked then
        self:setActiveTab(clickedTab)
    else
        self.activeTab:mousepressed(mx,my,button)
    end
end

function Tabs:mousereleased(mx, my, button)
    print "Tabs was mousereleased"
    if self.activeTab then
        self.activeTab:mousereleased(mx, my, button)
    end
end

function Tabs:keypressed(key)
    if self.activeTab then
        self.activeTab:keypressed(key)
    end
end

function Tabs:keyreleased(key)
    if self.activeTab then 
        self.activeTab:keyreleased(key)
    end
end

function Tabs:textinput(text)
    if self.activeTab then
        self.activeTab:textinput(text)
    end
end

function Tabs:setActiveTab(tab)
    if self.activeTab then
        self.activeTab.active = false
    end

    self.activeTab = tab
    tab.active = true
    self.hierarchy:elevateWidget(tab._id)
end

function Tabs:createTab(tabName)
    print("Creating tab:", tabName)
    local tabCount = 0
    for _ in pairs(self.tabs) do tabCount = tabCount + 1 end

    if tabCount == 0 then
        print "Number of tabs was 0"
        local tabX = self.x
        local tab = Tab.new(tabName, tabX, self.y, self.tabHeight)
        self.tabs[tabName] = tab 
        self.hierarchy:addWidget(tab)
        self:setActiveTab(tab)
    else
        -- Get the x position and the width of the farthest tab, then add the new tab to the right of it.
        print "Number of tabs not 0"
        local farthest_tab_x = 0
        local farthest_tab_width = 0 
        for name, tab in pairs(self.tabs) do
            if tab.x >= farthest_tab_x then
                farthest_tab_x = tab.x
                farthest_tab_width = tab.width
            end
        end

        print("Farthest tab x:", farthest_tab_x)
        print("Farthest tab width:", farthest_tab_width)

        local tabX = farthest_tab_x + farthest_tab_width + self.tabSpacing
        local tab = Tab.new(tabName, tabX, self.y, self.tabHeight)
        self.tabs[tabName] = tab 
        self.hierarchy:addWidget(tab)
    end
end

function Tabs:addWidget(tabName, widget)
    if not self.tabs[tabName] then
        print(string.format("ERROR: Tabs:addWidget - tabName '%s' does not exist.", tabName))
        return
    end

    self.tabs[tabName]:addWidget(widget)
end
