require "Animation.Animation"
require "UI.Hierarchy"
require "UI.Settings"
require "UI.Widgets.AnimationPlayer"
require "UI.Widgets.SpritesheetWindow"
require "UI.Widgets.Widget"
require "UI.Widgets.Window"

Workspace = {}
Workspace.__index = Workspace

function Workspace.new(x,y,width,height)
    local self = Widget.new(x,y,width,height)

    self.canvas = love.graphics.newCanvas(width, height)
    self.staticHierarchy = Hierarchy.new(self) -- for elements like panels etc. that don't belong in the scrollable scene
    self.hierarchy = Hierarchy.new(self)

    self.maxWidth = 2000
    self.maxHeight = 2000
    self.backgroundColor = Settings.workspaceBackgroundColor
    self.gridLineColor = Settings.workspaceGridLineColor

    self.cameraPosition = {x = 0, y = 0}
    self.beingDragged = false
    self.oldMousePosition = {x = 0, y = 0}


    -- Panels:
    local spritesheetPanel = SpritesheetPanel.new()
    self.staticHierarchy:addWidget(spritesheetPanel)

    -- Startup widgets:
    local hero_image_path = "UI/Assets/hero_60x92.png"
    local heroSpritesheetWindow = SpritesheetWindow.new(spritesheetPanel, hero_image_path, 60, 92, 100, 100)
    self.hierarchy:addWidget(heroSpritesheetWindow)

    local wibletSpritesheetWindow = SpritesheetWindow.new(spritesheetPanel, "UI/Assets/wiblet_48x64.png", 48,64, 800,100)
    self.hierarchy:addWidget(wibletSpritesheetWindow)

    local animation_frames = {}
    for i=1,10 do
        table.insert(animation_frames, {x=i, y=1})
    end

    local heroSpritesheetData = SpritesheetData.new(hero_image_path, 60,92)
    local heroAnimation = Animation.new(heroSpritesheetData, animation_frames, {bounce = true, delay=0.1})

    local heroAnimationPlayer = AnimationPlayer.new(heroAnimation, 0,0)
    heroAnimationPlayer:play()
    local animationPlayerWindow = Window.newWithWidget(100, 400, heroAnimationPlayer, {title="Preview"})
    self.hierarchy:addWidget(animationPlayerWindow)


    setmetatable(self, Workspace)
    return self 
end

function Workspace:update(dt)
    if self.beingDragged then
        local mx, my = self:mousePositionToLocal(love.mouse.getPosition())
        local dx = mx - self.oldMousePosition.x
        local dy = my - self.oldMousePosition.y

        self.cameraPosition.x = self.cameraPosition.x - dx
        self.cameraPosition.y = self.cameraPosition.y - dy

        -- Don't let dragging the camera go outside the boundaries of the workspace.
        if self.cameraPosition.x < 0 then self.cameraPosition.x = 0 end
        local right_boundary = self.maxWidth - self.width 
        if self.cameraPosition.x > right_boundary then self.cameraPosition.x = right_boundary end

        if self.cameraPosition.y < 0 then self.cameraPosition.y = 0 end
        local bottom_boundary = self.maxHeight - self.height 
        if self.cameraPosition.y > bottom_boundary then self.cameraPosition.y = bottom_boundary end

        -- mx - dx because after translating the canvas, the new local mouse position is different even if it hasn't moved globally.
        -- thus the delta must be compensated for.
        self.oldMousePosition = {x = mx - dx, y = my - dy}
    end

    self.hierarchy:update(dt)
    self.staticHierarchy:update(dt)
end

function Workspace:draw()
    self.canvas:renderTo(function()
        self.canvas:clear()
        love.graphics.translate(-1*self.cameraPosition.x, -1*self.cameraPosition.y)

        -- draw background:
        love.graphics.setColor( unpack(self.backgroundColor) )
        love.graphics.rectangle('fill', 0, 0, self.maxWidth, self.maxHeight)

        -- draw grid pattern:
        -- vertical lines
        love.graphics.setColor( unpack(self.gridLineColor) )
        for x=1, self.maxWidth, 100 do
            love.graphics.line(x,0, x,self.maxHeight)
        end

        -- horizontal lines
        for y=1, self.maxHeight, 100 do
            love.graphics.line(0,y, self.maxWidth,y)
        end

        self.hierarchy:draw()
    end)

    love.graphics.origin()
    love.graphics.draw(self.canvas, self.x, self.y)
    love.graphics.print(string.format("camera x: %d\ncamera y: %d", self.cameraPosition.x, self.cameraPosition.y), 10, 10)
    love.graphics.print(string.format("mouse x: %d\nmouse y: %d", self:mousePositionToLocal(love.mouse:getPosition())), 150, 10)

    self.staticHierarchy:draw()
end

function Workspace:mousePositionToLocal(mx, my)
    local local_x = mx + self.cameraPosition.x
    local local_y = my + self.cameraPosition.y
    return local_x, local_y
end

function Workspace:mouseover(mx,my)
    if not self.staticHierarchy:mouseover(mx, my) then
        self.hierarchy:mouseover( self:mousePositionToLocal(mx,my) )
    end
end

function Workspace:mousepressed(mouse_x, mouse_y, button)
    print(string.format("Workspace was mousepressed at %d, %d with %s", mouse_x, mouse_y, button))

    local wasSomethingStaticClicked = self.staticHierarchy:mousepressed(mouse_x, mouse_y)
    if not wasSomethingStaticClicked then

        local mx, my = self:mousePositionToLocal( mouse_x, mouse_y )
        local wasSomethingClicked = self.hierarchy:mousepressed(mx, my, button)

        if not wasSomethingClicked then
            -- Drag the canvas
            if button == 'l' then
                self.beingDragged = true
                self.oldMousePosition = {x = mx, y = my}
            end
        end

    end
end

function Workspace:mousereleased(mouse_x, mouse_y, button)
    if mouse_x and mouse_y then
        local mx, my = self:mousePositionToLocal( mouse_x, mouse_y )
        print(string.format("Workspace was mousereleased at %d, %d with %s", mx, my, button))
        self.beingDragged = false
        self.staticHierarchy:mousereleased(mx, my, button)
        self.hierarchy:mousereleased(mx, my, button)
    end
end

function Workspace:textinput(text)
    self.staticHierarchy:textinput(text)
    self.hierarchy:textinput(text)
end

function Workspace:keypressed(key)
    self.staticHierarchy:keypressed(key)
    self.hierarchy:keypressed(key)
end

function Workspace:keyreleased(key)
    self.staticHierarchy:keyreleased(key)
    self.hierarchy:keyreleased(key)
end