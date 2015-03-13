require "Widget"
require "Hierarchy"
require "Settings"
require "Animation"
require "AnimationPlayer"
require "Window"

Workspace = {}
Workspace.__index = Workspace

function Workspace.new(x,y,width,height)
    local self = Widget.new(x,y,width,height)

    self.canvas = love.graphics.newCanvas(width, height)
    self.hierarchy = Hierarchy.new()

    self.maxWidth = 2000
    self.maxHeight = 2000
    self.backgroundColor = Settings.workspaceBackgroundColor
    self.gridLineColor = Settings.workspaceGridLineColor

    self.cameraPosition = {x = 0, y = 0}
    self.beingDragged = false
    self.oldMousePosition = {x = 0, y = 0}

    -- Startup widgets:
    local hero_image = love.graphics.newImage("assets/hero_60x92.png")
    local heroSpritesheetData = SpritesheetData.new(hero_image, 60, 92)
    local heroSpritesheetWidget = SpritesheetWidget.new(heroSpritesheetData, 100, 100)
    self.hierarchy:addWidget(heroSpritesheetWidget)

    local animation_frames = {}
    for i=1,10 do
        table.insert(animation_frames, {x=i, y=1})
    end
    local heroAnimation = Animation.new(heroSpritesheetData, animation_frames, {bounce = true, delay=0.1})

    local animationPlayerWindow = Window.new(100,400, 300, 300)

    self.hierarchy:addWidget(animationPlayerWindow)

    local heroAnimationPlayer = AnimationPlayer.new(heroAnimation, 0,0)
    heroAnimationPlayer:play()
    animationPlayerWindow:addWidget(heroAnimationPlayer)

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

    self.hierarchy:updateWidgets(dt)
end

function Workspace:mousePositionToLocal(mx, my)
    local local_x = mx + self.cameraPosition.x
    local local_y = my + self.cameraPosition.y
    return local_x, local_y
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

        self.hierarchy:drawWidgets()
    end)

    love.graphics.origin()
    love.graphics.draw(self.canvas, self.x, self.y)
    love.graphics.print(string.format("camera x: %d\n camera y: %d", self.cameraPosition.x, self.cameraPosition.y), 10, 10)
end

function Workspace:mousepressed(mouse_x, mouse_y, button)
    print(string.format("Workspace was mousepressed at %d, %d with %s", mouse_x, mouse_y, button))

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

function Workspace:mousereleased(mouse_x, mouse_y, button)
    if mouse_x and mouse_y then
        local mx, my = self:mousePositionToLocal( mouse_x, mouse_y )
        print(string.format("Workspace was mousereleased at %d, %d with %s", mx, my, button))
        self.beingDragged = false
        self.hierarchy:mousereleased(mx, my, button)
    end
end
