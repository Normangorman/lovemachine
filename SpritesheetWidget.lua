-- SpritesheetWidget is the object used to interact with a spritesheet in the GUI.
-- It is not designed for user instantiation or inclusion in any output.
require "Widget"
require "Settings"

SpritesheetWidget = {}
SpritesheetWidget.__index = SpritesheetWidget

function SpritesheetWidget.new(data, x, y)
    self = Widget.new(x,y, data.image:getDimensions())
    self.data = data -- a SpritesheetData table
    self.frameSelectedColor = Settings.spritesheetFrameSelectedColor
    self.frameNumberColor = Settings.spritesheetFrameNumberColor
    self.gridLineColor = Settings.spritesheetGridLineColor

    self.selectedFrames = {}

    setmetatable(self, SpritesheetWidget)
    return self
end

function SpritesheetWidget:draw()
    love.graphics.setColor(255,255,255)
    love.graphics.draw(self.data.image, self.x, self.y)
    self:drawGrid()

    -- Draw borders around selected frames and number them.
    for i, frameCoords in ipairs(self.selectedFrames) do
        local frame_x = self.x + (frameCoords.x - 1) * self.data.frameWidth
        local frame_y = self.y + (frameCoords.y - 1) * self.data.frameHeight

        -- Border:
        local r,g,b = unpack(self.frameSelectedColor)
        love.graphics.setColor(r,g,b,255)
        love.graphics.rectangle("line", frame_x, frame_y, self.data.frameWidth, self.data.frameHeight) 

        -- Transparent inner fill:
        love.graphics.setColor(r,g,b,50)
        love.graphics.rectangle("fill", frame_x, frame_y, self.data.frameWidth, self.data.frameHeight) 

        -- Number:
        love.graphics.setColor(unpack(self.frameNumberColor))
        local offset = 5
        love.graphics.print(i, frame_x + offset, frame_y + offset)
    end

    love.graphics.setColor(255,255,255)
end

function SpritesheetWidget:drawGrid()
    love.graphics.setColor(unpack(self.gridLineColor)) 

    -- Vertical lines:
    for x=self.x, self.x + self.data.imageWidth, self.data.frameWidth do
        love.graphics.line(x, self.y, x, self.y + self.data.imageHeight)
    end
    
    -- Horizontal lines:
    for y=self.y, self.y + self.data.imageHeight, self.data.frameHeight do
        love.graphics.line(self.x, y, self.x + self.data.imageWidth, y)
    end
end

function SpritesheetWidget:mousepressed(mouse_x, mouse_y)
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
                self:toggleFrameSelected(i, frame_y)
            end
        elseif lastFrameSelected.y < frame_y then
            for i=lastFrameSelected.y + 1, frame_y do
                self:toggleFrameSelected(frame_x, i)
            end
        end

    else
        self:toggleFrameSelected(frame_x, frame_y)
    end
end

function SpritesheetWidget:toggleFrameSelected(frame_x, frame_y)
    if frame_x < 1 or frame_y < 1 or
       frame_x > self.data.numCols or frame_y > self.data.numRows then
       print("SpritesheetWidget:toggleFrameSelected - WARNING tried to toggle a frame outside of the range of the spritesheet.")
       return
    end

    local frameAlreadySelected = false
    local frameIndex = 0
    for i, frameCoords in ipairs(self.selectedFrames) do
        if frameCoords.x == frame_x and frameCoords.y == frame_y then
            frameAlreadySelected = true
            frameIndex = i
        end
    end

    if frameAlreadySelected then
        print("unselected frame "..frame_y..", "..frame_x)
        table.remove(self.selectedFrames, frameIndex)
    else
        print("Selected frame "..frame_y..", "..frame_x)
        table.insert(self.selectedFrames, {x=frame_x, y=frame_y})
    end
end
