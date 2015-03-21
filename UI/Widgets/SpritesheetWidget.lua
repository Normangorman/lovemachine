require "UI.Settings"
require "UI.Widgets.Widget"

SpritesheetWidget = {}
SpritesheetWidget.__index = SpritesheetWidget
setmetatable(SpritesheetWidget, Widget)

function SpritesheetWidget.new(panel, data, x, y)
    self = Widget.new(x,y, data.image:getDimensions())
    self.data = data -- a SpritesheetData table
    self.panel = panel -- the SpritesheetPanel

    self.frameSelectedColor = Settings.spritesheetFrameSelectedColor
    self.frameNumberColor = Settings.spritesheetFrameNumberColor
    self.gridLineColor = Settings.spritesheetGridLineColor
    self.mouseoverFrameColor = Settings.spritesheetMouseoverFrameColor
    self.frameSelectedBorderColor = Settings.spritesheetFrameSelectedBorderColor
    self.frameSelectedFillColor = Settings.spritesheetFrameSelectedFillColor

    self.selectedFrames = {}
    self.mouseoverFrame = {x=0, y=0}

    setmetatable(self, SpritesheetWidget)
    return self
end

function SpritesheetWidget:update()
    self.mouseoverFrame = {x=0, y=0}
end

function SpritesheetWidget:draw()
    love.graphics.setColor(255,255,255)
    love.graphics.draw(self.data.image, self.x, self.y)
    self:drawGrid()

    -- Highlighted the mouseover'd frame if it exists
    if self.mouseoverFrame.x > 0 and self.mouseoverFrame.y > 0 then
        local fx, fy = self:frameCoordsToPosition( self.mouseoverFrame.x, self.mouseoverFrame.y )
        love.graphics.setColor( unpack(self.mouseoverFrameColor) )
        love.graphics.rectangle("fill", fx,fy, self.data.frameWidth, self.data.frameHeight)
        love.graphics.setColor(255,255,255)
    end

    -- Draw borders around selected frames and number them.
    for i, frameCoords in ipairs(self.selectedFrames) do
        local fx, fy = self:frameCoordsToPosition( frameCoords.x, frameCoords.y )

        -- Border:
        love.graphics.setColor( unpack(self.frameSelectedBorderColor) )
        love.graphics.rectangle("line", fx, fy, self.data.frameWidth, self.data.frameHeight) 

        -- Transparent inner fill:
        love.graphics.setColor( unpack(self.frameSelectedFillColor) )
        love.graphics.rectangle("fill", fx, fy, self.data.frameWidth, self.data.frameHeight) 

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
    for x=self.x, self.x + self.width, self.data.frameWidth do
        love.graphics.line(x, self.y, x, self.y + self.height)
    end
    
    -- Horizontal lines:
    for y=self.y, self.y + self.height, self.data.frameHeight do
        love.graphics.line(self.x, y, self.x + self.width, y)
    end
end

function SpritesheetWidget:frameCoordsToPosition(frame_x, frame_y)
    local frame_x = self.x + (frame_x - 1) * self.data.frameWidth
    local frame_y = self.y + (frame_y - 1) * self.data.frameHeight
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
       frame_x > self.data.numCols or frame_y > self.data.numRows then
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
    local frame_x = math.ceil((mouse_x - self.x) / self.data.frameWidth)
    local frame_y = math.ceil((mouse_y - self.y) / self.data.frameHeight)
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
            self.panel:selectFrame{x=frame_x, y=frame_y}
        end
    end
end

function SpritesheetWidget:mouseover(mx, my)
    local frame_x = math.ceil((mx - self.x) / self.data.frameWidth)
    local frame_y = math.ceil((my - self.y) / self.data.frameHeight)

    -- Check if the frame is already selected, if not then highlight it.
    local frameAlreadySelected = self:isFrameSelected(frame_x, frame_y)
    if not frameAlreadySelected then
        self.mouseoverFrame = {x=frame_x, y=frame_y}
    end
end
