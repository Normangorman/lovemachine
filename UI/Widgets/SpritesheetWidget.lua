require "UI.Settings"
require "UI.Widgets.Widget"

SpritesheetWidget = {}
SpritesheetWidget.__index = SpritesheetWidget
setmetatable(SpritesheetWidget, Widget)

function SpritesheetWidget.new(panel, imagePath, frameWidth, frameHeight, x, y)
    local spritesheetImage = love.graphics.newImage(imagePath)

    self = Widget.new(x,y, spritesheetImage:getDimensions())
    self.panel = panel -- the SpritesheetPanel
    self.spritesheet = {} 
    self.spritesheet.imagePath = imagePath
    self.spritesheet.image = spritesheetImage
    self.spritesheet.frameWidth = frameWidth
    self.spritesheet.frameHeight = frameHeight
    self.spritesheet.numCols = self.width / frameWidth
    self.spritesheet.numRows = self.height / frameHeight

    self.frameSelectedColor = Settings.spritesheetFrameSelectedColor
    self.frameNumberColor = Settings.spritesheetFrameNumberColor
    self.gridLineColor = Settings.spritesheetGridLineColor
    self.mouseoverFrameColor = Settings.spritesheetMouseoverFrameColor
    self.frameSelectedBorderColor = Settings.spritesheetFrameSelectedBorderColor
    self.frameSelectedFillColor = Settings.spritesheetFrameSelectedFillColor
    self.mouseoverFrame = {x=0, y=0}

    self.selectedFrames = {}
    self.animationSettings = {
        loop = true,
        bounce = false,
        drawOnFinish = true,
        defaultDuration = Settings.defaultAnimationFrameDuration,
        name = "",
    }

    setmetatable(self, SpritesheetWidget)
    return self
end

function SpritesheetWidget:update()
    self.mouseoverFrame = {x=0, y=0}
end

function SpritesheetWidget:draw()
    love.graphics.setColor(255,255,255)
    love.graphics.draw(self.spritesheet.image, self.x, self.y)
    self:drawGrid()

    -- Highlighted the mouseover'd frame if it exists
    if self.mouseoverFrame.x > 0 and self.mouseoverFrame.y > 0 then
        local fx, fy = self:frameCoordsToPosition( self.mouseoverFrame.x, self.mouseoverFrame.y )
        love.graphics.setColor( unpack(self.mouseoverFrameColor) )
        love.graphics.rectangle("fill", fx,fy, self.spritesheet.frameWidth, self.spritesheet.frameHeight)
        love.graphics.setColor(255,255,255)
    end

    -- Draw borders around selected frames and number them.
    for i, frameCoords in ipairs(self.selectedFrames) do
        local fx, fy = self:frameCoordsToPosition( frameCoords.x, frameCoords.y )

        -- Border:
        love.graphics.setColor( unpack(self.frameSelectedBorderColor) )
        love.graphics.rectangle("line", fx, fy, self.spritesheet.frameWidth, self.spritesheet.frameHeight) 

        -- Transparent inner fill:
        love.graphics.setColor( unpack(self.frameSelectedFillColor) )
        love.graphics.rectangle("fill", fx, fy, self.spritesheet.frameWidth, self.spritesheet.frameHeight) 

        -- Number:
        love.graphics.setColor(unpack(self.frameNumberColor))
        local offset = 5
        love.graphics.print(i, fx + offset, fy + offset)
    end

    love.graphics.setColor(255,255,255)
end

function SpritesheetWidget:drawGrid()
    love.graphics.setColor(unpack(self.gridLineColor)) 

    -- Vertical lines:
    for x=self.x, self.x + self.width, self.spritesheet.frameWidth do
        love.graphics.line(x, self.y, x, self.y + self.height)
    end
    
    -- Horizontal lines:
    for y=self.y, self.y + self.height, self.spritesheet.frameHeight do
        love.graphics.line(self.x, y, self.x + self.width, y)
    end
end

function SpritesheetWidget:frameCoordsToPosition(frame_x, frame_y)
    local frame_x = self.x + (frame_x - 1) * self.spritesheet.frameWidth
    local frame_y = self.y + (frame_y - 1) * self.spritesheet.frameHeight
    return frame_x, frame_y
end

function SpritesheetWidget:isFrameSelected(frame_x, frame_y)
    for i, frameCoords in ipairs(self.selectedFrames) do
        if frameCoords.x == frame_x and frameCoords.y == frame_y then
            return true, i
        end
    end

    return false, 0
end

function SpritesheetWidget:toggleFrameSelected(frame_x, frame_y)
    if frame_x < 1 or frame_y < 1 or
       frame_x > self.spritesheet.numCols or frame_y > self.spritesheet.numRows then
       print("SpritesheetWidget:toggleFrameSelected - WARNING tried to toggle a frame outside of the range of the spritesheet.")
       return
    end

    local frameAlreadySelected, frameIndex = self:isFrameSelected(frame_x, frame_y)

    local frameCoords = {x=frame_x, y=frame_y}
    if frameAlreadySelected then
        print("Deselected frame "..frame_y..", "..frame_x)
        table.remove(self.selectedFrames, frameIndex)
        self.panel:removeFrame(frameCoords)
    else
        print("Selected frame "..frame_y..", "..frame_x)
        table.insert(self.selectedFrames, {x=frame_x, y=frame_y})
        self.panel:addFrame(frameCoords)
    end
end

function SpritesheetWidget:mousepressed(mouse_x, mouse_y, button)
    print(string.format("Spritesheet widget clicked at %d, %d", mouse_x, mouse_y))
    -- Assumes the click did fall within the spritesheet's bounding rectangle.
    local frame_x = math.ceil((mouse_x - self.x) / self.spritesheet.frameWidth)
    local frame_y = math.ceil((mouse_y - self.y) / self.spritesheet.frameHeight)
    print(string.format("Frame clicked - x: %d, y %d", frame_x, frame_y))

    -- Allow multiple frames to be selected if shift is held
    if #self.selectedFrames > 0 and (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then
        print("Shift was held")
        local lastFrameSelected = self.selectedFrames[#self.selectedFrames]

        if lastFrameSelected.x < frame_x then
            for i=lastFrameSelected.x + 1, frame_x do
                local frameAlreadySelected = self:isFrameSelected(i, frame_y)
                if not frameAlreadySelected then
                    self:toggleFrameSelected(i, frame_y)
                end
            end
        elseif lastFrameSelected.y < frame_y then
            for i=lastFrameSelected.y + 1, frame_y do
                local frameAlreadySelected = self:isFrameSelected(frame_x, i)
                if not frameAlreadySelected then
                    self:toggleFrameSelected(frame_x, i)
                end
            end
        end
    else
        if button == 'l' then
            self:toggleFrameSelected(frame_x, frame_y)
        elseif button == 'r' then
            -- Right click selects a frame if it is already highlighted, thus it is possible this is called
            -- on a frame that isn't already selected. If this happens, don't do anything.
            for _, f in ipairs(self.selectedFrames) do
                if f.x == frame_x and f.y == frame_y then
                    self.panel:selectFrame(f)
                    break
                end
            end
        end
    end
end

function SpritesheetWidget:mouseover(mx, my)
    local frame_x = math.ceil((mx - self.x) / self.spritesheet.frameWidth)
    local frame_y = math.ceil((my - self.y) / self.spritesheet.frameHeight)

    -- Check if the frame is already selected, if not then highlight it.
    local frameAlreadySelected = self:isFrameSelected(frame_x, frame_y)
    if not frameAlreadySelected then
        self.mouseoverFrame = {x=frame_x, y=frame_y}
    end
end
