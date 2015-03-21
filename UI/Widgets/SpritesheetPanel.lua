require "Animation.Animation"
require "UI.Widgets.AnimationPlayer"
require "UI.Widgets.Panel"
require "UI.Widgets.Text"
require "UI.Widgets.TextInput"
require "UI.Widgets.Widget"

SpritesheetPanel = {}
SpritesheetPanel.__index = SpritesheetPanel
setmetatable(SpritesheetPanel, Panel)

function SpritesheetPanel.new()
    local self = Panel.new(love.window.getWidth() * 0.8, 0,
                           love.window.getWidth() * 0.2, love.window.getHeight())

    self.spritesheetWidget = nil
    self.selectedFrame = {x=0, y=0}
    
    -- The SpritesheetWidget only stores the x and y position of selected frames. This will store the actual 
    -- frame objects which will be used to create the animation.
    -- The objects have properties like duration etc.
    self.selectedFrames = {}

    setmetatable(self, SpritesheetPanel)

    local maxWidth = self.width - 2 * self.padding
    self.titleText = Text.new("No spritesheet selected.", 0, 0, maxWidth)
    self:addWidget(self.titleText)

    return self
end

function SpritesheetPanel:update(dt)
    self.hierarchy:update(dt)
end

function SpritesheetPanel:setSpritesheetWidget(w)
    -- Don't change if the widget is the same as the one that's already set.
    -- check this just by comparing the image paths of the two widget's SpritesheetData objects.
    if not self.spritesheetWidget or w.data.imagePath ~= self.spritesheetWidget.data.imagePath then
        print("SpritesheetPanel:setSpritesheetWidget - spritesheetWidget was set")

        self.spritesheetWidget = w
        self.spritesheetNumSelectedFrames = #w.selectedFrames

        if self.animationPreview then -- delete the old one from the hierarchy
            self.animationPreview:delete()
        end

        self:populateSpritesheetWidgets()
    end
end

function SpritesheetPanel:addWidget(w)
    w.x = w.x + self.x + self.padding
    w.y = w.y + self.y + self.padding
    self.hierarchy:addWidget(w)
end

function SpritesheetPanel:populateSpritesheetWidgets()
    self.hierarchy:clearWidgets()

    local maxWidth = self.width - 2 * self.padding
    local w = self.spritesheetWidget
    local titleText = Text.new("Spritesheet selected: ".. w.data.imagePath, 0, 0, maxWidth)
    self:addWidget(titleText)

    self:addWidget(Text.new("Frame width:", 0, 40, maxWidth))
    local spritesheetFrameWidthInput = TextInput.new(0, 55, maxWidth, function(text)
        self:changeFrameWidth(text)
    end) 
    spritesheetFrameWidthInput:setText(self.spritesheetWidget.data.frameWidth)
    self:addWidget(spritesheetFrameWidthInput)

    self:addWidget(Text.new("Frame height:", 0, 80, maxWidth))
    local spritesheetFrameHeightInput = TextInput.new(0, 95, maxWidth, function(text)
        self:changeFrameHeight(text)
    end)
    spritesheetFrameHeightInput:setText(self.spritesheetWidget.data.frameHeight)
    self:addWidget(spritesheetFrameHeightInput)
end

function SpritesheetPanel:populateSelectedFrameWidgets()
    -- Delete the old widgets if there are any.
    self.hierarchy:deleteWidgetsWithClass("selected_frame")

    local maxWidth = self.width - 2 * self.padding
    local ypos = 135
    local titleText = string.format("Frame selected: {%d, %d}", self.selectedFrame.x, self.selectedFrame.y)
    self.selectedFrameTitle = Text.new(titleText, 0, ypos, maxWidth)
    self.selectedFrameTitle:addClasses{"selected_frame"}
    self:addWidget(self.selectedFrameTitle)
    ypos = ypos + love.graphics.getFont():getHeight() + 5

    local animation = Animation.new(self.spritesheetWidget.data, {self.selectedFrame})
    self.selectedFrameImage = AnimationPlayer.new(animation, 0, ypos)
    self.selectedFrameImage:addClasses{"selected_frame"}
    self.selectedFrameImage:play()
    self:addWidget(self.selectedFrameImage)
    ypos = ypos + animation.height + 5

    local frameDurationLabel = Text.new("Duration (seconds):", 0, ypos, maxWidth)
    frameDurationLabel:addClasses{"selected_frame"}
    self:addWidget(frameDurationLabel)
    ypos = ypos + love.graphics.getFont():getHeight() + 2

    local frameDurationInput = TextInput.new(0, ypos, maxWidth, function(text)
        self:changeFrameDuration(text)
    end)
    frameDurationInput:addClasses{"selected_frame"}
    self:addWidget(frameDurationInput)
    ypos = ypos + love.graphics.getFont():getHeight() + 5


    local frameCallbackLabel = Text.new("Owner callback:", 0, ypos, maxWidth)
    frameCallbackLabel:addClasses{"selected_frame"}
    self:addWidget(frameCallbackLabel)
    ypos = ypos + love.graphics.getFont():getHeight() + 2

    local frameCallbackInput = TextInput.new(0, ypos, maxWidth, function(text)
        self:changeFrameCallback(text)
    end)
    frameCallbackInput:addClasses{"selected_frame"}
    self:addWidget(frameCallbackInput)
    ypos = ypos + love.graphics.getFont():getHeight() + 5
end

function SpritesheetPanel:changeFrameWidth(text)
    print("SpritesheetPanel:changeFrameWidth was called with text="..text)
    local num = tonumber(text)
    if num then
        self.spritesheetWidget.data.frameWidth = num
    else
        print("Couldn't parse text as num")
    end
end

function SpritesheetPanel:changeFrameHeight(text)
    local num = tonumber(text)
    if num then
        self.spritesheetWidget.data.frameHeight = num
    end
end

function SpritesheetPanel:addFrame(frameCoords)
    print(string.format("SpritesheetPanel:addFrame - x: %d, y: %d", frameCoords.x, frameCoords.y))

    table.insert(self.selectedFrames, frameCoords)
    self:selectFrame(frameCoords)
end

function SpritesheetPanel:selectFrame(frameCoords)
    -- Right click selects a frame if it is already highlighted, thus it is possible this is called
    -- on a frame that isn't already selected. If this happens, don't do anything.
    local isFrameAdded = false
    for _, f in ipairs(self.selectedFrames) do
        if f.x == frameCoords.x and f.y == frameCoords.y then
            isFrameAdded = true
            break
        end
    end

    if isFrameAdded then
        self.selectedFrame = frameCoords
        self:populateSelectedFrameWidgets()
    end
end

function SpritesheetPanel:removeFrame(frameCoords)
    print(string.format("SpritesheetPanel:frameDeselected - x: %d, y: %d", frameCoords.x, frameCoords.y))
    for i, f in ipairs(self.selectedFrames) do
        if f.x == self.selectedFrame.x and f.y == self.selectedFrame.y then
            table.remove(self.selectedFrames, i)
        end
    end

    if frameCoords.x == self.selectedFrame.x and frameCoords.y == self.selectedFrame.y then
        print("Selected frame was deselected, deleting the widgets...")
        self.hierarchy:deleteWidgetsWithClass("selected_frame")
        self.selectedFrame = {x=0, y=0}
    end
end

function SpritesheetPanel:changeFrameDuration(text)
    local num = tonumber(text)
    if num then
        for _, f in ipairs(self.selectedFrames) do
            if f.x == self.selectedFrame.x and f.y == self.selectedFrame.y then
                f.duration = num
            end
        end
    end
end

function SpritesheetPanel:changeFrameCallback(text)
    self.selectedFrame.ownerCallback = text
end
