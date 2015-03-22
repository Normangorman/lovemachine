require "Animation.Animation"
require "UI.Widgets.AnimationPlayer"
require "UI.Widgets.Checkbox"
require "UI.Widgets.Panel"
require "UI.Widgets.Text"
require "UI.Widgets.TextInput"
require "UI.Widgets.Widget"

SpritesheetPanel = {}
SpritesheetPanel.__index = SpritesheetPanel
setmetatable(SpritesheetPanel, Panel)

function SpritesheetPanel.new()
    local self = Panel.new(love.window.getWidth() * 0.75, 0,
                           love.window.getWidth() * 0.25, love.window.getHeight())

    self.spritesheetWidget = nil
    self.selectedFrame = {x=0, y=0}
    
    setmetatable(self, SpritesheetPanel)

    self.titleText = Text.new("No spritesheet selected.", 0, 0, self:getMaxWidth())
    self:addWidget(self.titleText)

    return self
end

function SpritesheetPanel:update(dt)
    self.hierarchy:update(dt)
end

function SpritesheetPanel:setSpritesheetWidget(newWidget)
    -- Don't change if the widget is the same as the one that's already set.
    -- check this just by comparing the image paths of the two widget's SpritesheetData objects.
    if not self.spritesheetWidget or newWidget.data.imagePath ~= self.spritesheetWidget.data.imagePath  then
        print("SpritesheetPanel:setSpritesheetWidget - spritesheetWidget was set.")

        self.spritesheetWidget = newWidget 
        self.selectedFrame = {x=0, y=0}

        self:populateSpritesheetWidgets()
        if #newWidget.selectedFrames > 0 then
            self:populateAnimationPreviewWidgets()
        end
    end
end

function SpritesheetPanel:addWidget(w)
    w.x = w.x + self.x + self.padding
    w.y = w.y + self.y + self.padding
    self.hierarchy:addWidget(w)
end

function SpritesheetPanel:populateSpritesheetWidgets()
    self.hierarchy:clearWidgets()

    local maxWidth = self:getMaxWidth()
    local w = self.spritesheetWidget

    -- Title:
    local titleText = Text.new("Spritesheet selected: ".. w.data.imagePath, 0, 0, maxWidth)
    self:addWidget(titleText)

    -- Frame width
    self:addWidget(Text.new("Frame width:", 0, 40, maxWidth))
    local spritesheetFrameWidthInput = TextInput.new(0, 55, maxWidth, function(text)
        self:changeFrameWidth(text)
    end) 
    spritesheetFrameWidthInput:setText(self.spritesheetWidget.data.frameWidth)
    self:addWidget(spritesheetFrameWidthInput)

    -- Frame height
    self:addWidget(Text.new("Frame height:", 0, 80, maxWidth))
    local spritesheetFrameHeightInput = TextInput.new(0, 95, maxWidth, function(text)
        self:changeFrameHeight(text)
    end)
    spritesheetFrameHeightInput:setText(self.spritesheetWidget.data.frameHeight)
    self:addWidget(spritesheetFrameHeightInput)
end

function SpritesheetPanel:populateAnimationPreviewWidgets()
    -- Delete the old widgets if there are any.
    self.hierarchy:deleteWidgetsWithClass("animation_preview")

    local ypos = 135
    local maxWidth = self:getMaxWidth()

    -- Title
    local title = Text.new("Animation preview:", 0, ypos, maxWidth)
    title:addClasses{"animation_preview"}
    self:addWidget(title)
    ypos = ypos + love.graphics.getFont():getHeight() + 2
    
    -- Animation player
    local animation = Animation.new(self.spritesheetWidget.data, self.spritesheetWidget.selectedFrames, self.animationSettings)
    local animationPlayer = AnimationPlayer.new(animation, 0, ypos)
    animationPlayer:addClasses{"animation_preview", "animation_preview_player"}
    animationPlayer:play()
    self:addWidget(animationPlayer)
    ypos = ypos + animationPlayer.height + 5

    -- Loop label 
    local loopLabel = Text.new("Loop?", 0, ypos, maxWidth)
    loopLabel:addClasses{"animation_preview"}
    self:addWidget(loopLabel)

    -- Loop checkbox
    local loopCheckbox = Checkbox.new(true, 60, ypos, function(checkboxState)
        self:changeAnimationSettingLoop(checkboxState)
    end)
    loopCheckbox:addClasses{"animation_preview"}
    self:addWidget(loopCheckbox)
    ypos = ypos + love.graphics.getFont():getHeight() + 2

    -- Bounce label
    local bounceLabel = Text.new("Bounce?", 0, ypos, maxWidth)
    bounceLabel:addClasses{"animation_preview"}
    self:addWidget(bounceLabel)
    
    -- Bounce checkbox
    local bounceCheckbox = Checkbox.new(false, 60, ypos, function(checkboxState)
        self:changeAnimationSettingBounce(checkboxState)
    end)
    bounceCheckbox:addClasses{"animation_preview"}
    self:addWidget(bounceCheckbox)
    ypos = ypos + love.graphics.getFont():getHeight() + 2
end

function SpritesheetPanel:refreshAnimationPreview()
    print("\nRefreshing animation preview")
    local playerList = self.hierarchy:getWidgetsWithClass("animation_preview_player")

    if #playerList == 0 then return end

    local player = playerList[1]

    local newAnimation = Animation.new(self.spritesheetWidget.data, self.spritesheetWidget.selectedFrames, self.spritesheetWidget.animationSettings)
    player:changeAnimation(newAnimation)

    print("Animation settings:")
    for k, v in pairs(self.spritesheetWidget.animationSettings) do
        print(k,v)
    end
end

function SpritesheetPanel:populateSelectedFrameWidgets()
    -- Delete the old widgets if there are any.
    self.hierarchy:deleteWidgetsWithClass("selected_frame")

    local maxWidth = self:getMaxWidth()
    local ypos = 300

    -- Title
    local titleText = string.format("Frame selected: {%d, %d}", self.selectedFrame.x, self.selectedFrame.y)
    self.selectedFrameTitle = Text.new(titleText, 0, ypos, maxWidth)
    self.selectedFrameTitle:addClasses{"selected_frame"}
    self:addWidget(self.selectedFrameTitle)
    ypos = ypos + love.graphics.getFont():getHeight() + 5

    -- Frame image
    local animation = Animation.new(self.spritesheetWidget.data, {self.selectedFrame})
    self.selectedFrameImage = AnimationPlayer.new(animation, 0, ypos)
    self.selectedFrameImage:addClasses{"selected_frame"}
    self.selectedFrameImage:play()
    self:addWidget(self.selectedFrameImage)
    ypos = ypos + animation.height + 5

    -- Frame duration label
    local frameDurationLabel = Text.new("Duration (seconds):", 0, ypos, maxWidth)
    frameDurationLabel:addClasses{"selected_frame"}
    self:addWidget(frameDurationLabel)
    ypos = ypos + love.graphics.getFont():getHeight() + 2

    -- Frame duration input
    local frameDurationInput = TextInput.new(0, ypos, maxWidth, function(text)
        self:changeFrameDuration(text)
    end)
    frameDurationInput:addClasses{"selected_frame"}
    if self.selectedFrame.duration then
        frameDurationInput:setText(self.selectedFrame.duration)
    end
    self:addWidget(frameDurationInput)
    ypos = ypos + love.graphics.getFont():getHeight() + 5

    -- Frame callback label
    local frameCallbackLabel = Text.new("Owner callback:", 0, ypos, maxWidth)
    frameCallbackLabel:addClasses{"selected_frame"}
    self:addWidget(frameCallbackLabel)
    ypos = ypos + love.graphics.getFont():getHeight() + 2

    -- Frame callback input
    local frameCallbackInput = TextInput.new(0, ypos, maxWidth, function(text)
        self:changeFrameCallback(text)
    end)
    frameCallbackInput:addClasses{"selected_frame"}
    if self.selectedFrame.ownerCallback then
        frameCallbackInput:setText(self.selectedFrame.ownerCallback)
    end
    self:addWidget(frameCallbackInput)
    ypos = ypos + love.graphics.getFont():getHeight() + 5
end


function SpritesheetPanel:addFrame(frameCoords)
    print(string.format("SpritesheetPanel:addFrame - x: %d, y: %d", frameCoords.x, frameCoords.y))

    self:selectFrame(frameCoords)

    -- If this is the first frame, then create all the animation preview widgets.
    -- If not, then just change the frames of the animation that's playing.
    if #self.spritesheetWidget.selectedFrames == 1 then
        self:populateAnimationPreviewWidgets()
    else
        self:refreshAnimationPreview()
    end

    print("Selected frames:")
    for _, frame in ipairs(self.spritesheetWidget.selectedFrames) do
        for k, v in pairs(frame) do
            print(k, v)
        end
    end
end

function SpritesheetPanel:selectFrame(frame)
    self.selectedFrame = frame
    self:populateSelectedFrameWidgets()
end

function SpritesheetPanel:removeFrame(frameCoords)
    print(string.format("SpritesheetPanel:removeFrame - x: %d, y: %d", frameCoords.x, frameCoords.y))

    if frameCoords.x == self.selectedFrame.x and frameCoords.y == self.selectedFrame.y then
        print("Selected frame was deselected, deleting the widgets...")
        self.hierarchy:deleteWidgetsWithClass("selected_frame")
        self.selectedFrame = {x=0, y=0}
    end

    -- If no frames remain, remove the animation preview widgets.
    if #self.spritesheetWidget.selectedFrames == 0 then
        self.hierarchy:deleteWidgetsWithClass("animation_preview")
    else
        self:refreshAnimationPreview()
    end
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

function SpritesheetPanel:changeFrameDuration(text)
    local num = tonumber(text)
    if num then
        for _, f in ipairs(self.spritesheetWidget.selectedFrames) do
            if f.x == self.selectedFrame.x and f.y == self.selectedFrame.y then
                f.duration = num
            end
        end
    end
end

function SpritesheetPanel:changeFrameCallback(text)
    self.selectedFrame.ownerCallback = text
end

function SpritesheetPanel:changeAnimationSettingLoop(checkboxState)
    self.spritesheetWidget.animationSettings.loop = checkboxState
    self:refreshAnimationPreview()
end

function SpritesheetPanel:changeAnimationSettingBounce(checkboxState)
    self.spritesheetWidget.animationSettings.bounce = checkboxState
    self:refreshAnimationPreview()
end
