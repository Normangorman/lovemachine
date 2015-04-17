require "Animation.Animation"
require "UI.Widgets.AlertWindow"
require "UI.Widgets.AnimationPlayer"
require "UI.Widgets.Checkbox"
require "UI.Widgets.Panel"
require "UI.Widgets.SpritesheetWindow"
require "UI.Widgets.Text"
require "UI.Widgets.TextInput"
require "UI.Widgets.Widget"

local Filesystem = require "UI.Filesystem"

SpritesheetPanel = {}
SpritesheetPanel.__index = SpritesheetPanel
setmetatable(SpritesheetPanel, Panel)

function SpritesheetPanel.new(workspace, x, y)
    local width = love.window.getWidth() - x
    local height = love.window.getHeight() - y
    local self = Panel.new(x, y, width, height)

    self.activeSpritesheet = nil
    self.selectedFrame = {x=0, y=0}
    self.workspace = workspace
    
    setmetatable(self, SpritesheetPanel)

    self:populateBaseWidgets()

    return self
end

function SpritesheetPanel:setActiveSpritesheet(newWidget)
    -- Don't change if the widget is the same as the one that's already set.
    -- check this just by comparing the image paths of the two widget's SpritesheetData objects.
    if not self.activeSpritesheet or newWidget.spritesheet.imagePath ~= self.activeSpritesheet.spritesheet.imagePath  then
        print("SpritesheetPanel:setActiveSpritesheet - activeSpritesheet was set.")

        self.activeSpritesheet = newWidget 
        self.selectedFrame = {x=0, y=0}

        self:populateSpritesheetWidgets()
        if #newWidget.selectedFrames > 0 then
            self:populateAnimationPreviewWidgets()
        end
    end
end

function SpritesheetPanel:populateBaseWidgets()
    local maxWidth = self:getMaxWidth()
    local ypos = 0
    local fontHeight = love.graphics.getFont():getHeight()

    self.titleText = Text.new("No spritesheet selected.", 0, ypos, maxWidth)
    self:addWidget(self.titleText)
    self.titleText:addClasses{"base"}
    ypos = ypos + fontHeight + 5

    local spritesheetPathLabel = Text.new("Spritesheet file path:", 0, ypos, maxWidth)
    self:addWidget(spritesheetPathLabel)
    spritesheetPathLabel:addClasses{"base"}
    ypos = ypos + fontHeight + 5

    self.spritesheetPathInput = TextInput.new(0, ypos, maxWidth)
    self:addWidget(self.spritesheetPathInput)
    self.spritesheetPathInput:addClasses{"base"}
    ypos = ypos + self.spritesheetPathInput.height + 5

    local loadSpritesheetButton = Button.new(0, ypos, maxWidth, 20, {
        text = "Load spritesheet",
        callback = function() self:loadSpritesheet(self.spritesheetPathInput:getText()) end
    })
    self:addWidget(loadSpritesheetButton)
    loadSpritesheetButton:addClasses{"base"}
end

function SpritesheetPanel:populateSpritesheetWidgets()
    -- Delete the old widgets if there are any.
    self.hierarchy:deleteWidgetsWithClass("spritesheet")

    local maxWidth = self:getMaxWidth()
    local w = self.activeSpritesheet
    local ypos = 90 

    -- Title: (assumes self.titleText already set)
    self.titleText:setText("Spritesheet selected: ".. w.spritesheet.imagePath)

    -- Frame width
    local frameWidthLabel = Text.new("Frame width:", 0, ypos, maxWidth)
    self:addWidget(frameWidthLabel)
    frameWidthLabel:addClasses{"spritesheet"}
    ypos = ypos + frameWidthLabel.height

    local frameWidthInput = TextInput.new(0, ypos, maxWidth, function(text)
        self:changeFrameWidth(text)
    end) 
    frameWidthInput:setText(self.activeSpritesheet.spritesheet.frameWidth)
    self:addWidget(frameWidthInput)
    frameWidthInput:addClasses{"spritesheet"}
    ypos = ypos + frameWidthInput.height

    -- Frame height
    local frameHeightLabel = Text.new("Frame height:", 0, ypos, maxWidth)
    self:addWidget(frameHeightLabel)
    frameHeightLabel:addClasses{"spritesheet"}
    ypos = ypos + frameHeightLabel.height

    local frameHeightInput = TextInput.new(0, ypos, maxWidth, function(text)
        self:changeFrameHeight(text)
    end)
    frameHeightInput:setText(self.activeSpritesheet.spritesheet.frameHeight)
    self:addWidget(frameHeightInput)
    frameHeightInput:addClasses{"spritesheet"}
end

function SpritesheetPanel:populateAnimationPreviewWidgets()
    self.hierarchy:deleteWidgetsWithClass("animation_preview")

    local ypos = 160
    local maxWidth = self:getMaxWidth()

    -- Title
    local title = Text.new("Animation preview:", 0, ypos, maxWidth)
    title:addClasses{"animation_preview"}
    self:addWidget(title)
    ypos = ypos + title.height + 5
    
    -- Animation player
    local animation = Animation.new(
        self.activeSpritesheet.spritesheet.imagePath,
        self.activeSpritesheet.spritesheet.frameWidth,
        self.activeSpritesheet.spritesheet.frameHeight,
        self.activeSpritesheet.selectedFrames,
        self.activeSpritesheet.animationSettings
    )
    local animationPlayer = AnimationPlayer.new(animation, 0, ypos)
    animationPlayer:addClasses{"animation_preview", "animation_preview_player"}
    animationPlayer:play()
    self:addWidget(animationPlayer)
    ypos = ypos + animationPlayer.height + 5

    -- Name label
    local nameLabel = Text.new("Name:", 0, ypos, maxWidth)
    nameLabel:addClasses{"animation_preview"}
    self:addWidget(nameLabel)

    -- Name input
    local nameInput = TextInput.new(120, ypos, maxWidth - 120, function(text)
        self:changeAnimationSettingName(text)
    end)
    nameInput:addClasses{"animation_preview"}
    local name = self.activeSpritesheet.animationSettings.name 
    if name then
        nameInput:setText(name)
    end
    self:addWidget(nameInput)
    ypos = ypos + nameInput.height + 5

    -- Loop label 
    local loopLabel = Text.new("Loop?", 0, ypos, maxWidth)
    loopLabel:addClasses{"animation_preview"}
    self:addWidget(loopLabel)

    -- Loop checkbox
    local loopSetting = self.activeSpritesheet.animationSettings.loop
    local loopCheckbox = Checkbox.new(loopSetting, 120, ypos, function(checkboxState)
        self:changeAnimationSettingLoop(checkboxState)
    end)
    loopCheckbox:addClasses{"animation_preview"}
    self:addWidget(loopCheckbox)
    ypos = ypos + loopCheckbox.height + 5

    -- Bounce label
    local bounceLabel = Text.new("Bounce?", 0, ypos, maxWidth)
    bounceLabel:addClasses{"animation_preview"}
    self:addWidget(bounceLabel)
    
    -- Bounce checkbox
    local bounceSetting = self.activeSpritesheet.animationSettings.bounce
    local bounceCheckbox = Checkbox.new(bounceSetting, 120, ypos, function(checkboxState)
        self:changeAnimationSettingBounce(checkboxState)
    end)
    bounceCheckbox:addClasses{"animation_preview"}
    self:addWidget(bounceCheckbox)
    ypos = ypos + bounceCheckbox.height + 5

    -- Draw on finish label
    local drawOnFinishLabel = Text.new("Draw on finish?", 0, ypos, maxWidth)
    drawOnFinishLabel:addClasses{"animation_preview"}
    self:addWidget(drawOnFinishLabel)

    -- Draw on finish checkbox
    local drawOnFinishSetting = self.activeSpritesheet.animationSettings.drawOnFinish
    local drawOnFinishCheckbox = Checkbox.new(drawOnFinishSetting, 120, ypos, function(checkboxState)
        self:changeAnimationSettingDrawOnFinish(checkboxState)
    end)
    drawOnFinishCheckbox:addClasses{"animation_preview"}
    self:addWidget(drawOnFinishCheckbox)
    ypos = ypos + drawOnFinishCheckbox.height + 5

    -- Default duration label
    local defaultDurationLabel = Text.new("Default duration?", 0, ypos, maxWidth)
    defaultDurationLabel:addClasses{"animation_preview"}
    self:addWidget(defaultDurationLabel)
    
    -- Default duration input
    local defaultDurationSetting = self.activeSpritesheet.animationSettings.defaultDuration 
    local defaultDurationInput = TextInput.new(120, ypos, 60, function(text)
        self:changeAnimationSettingDefaultDuration(text)
    end)
    defaultDurationInput:addClasses{"animation_preview"}
    if defaultDurationSetting then
        defaultDurationInput:setText( tostring(defaultDurationSetting) )
    end
    self:addWidget(defaultDurationInput)
    ypos = ypos + defaultDurationInput.height + 5

    -- Save animation button
    -- Located at the bottom of the panel, so not in the usual area.
    local saveAnimationButton = Button.new(0, love.window.getHeight() - 80, maxWidth, 50, {
        callback=function() self:saveAnimation() end,
        text = "Save animation"
    })
    saveAnimationButton:addClasses{"animation_preview"}
    self:addWidget(saveAnimationButton)
end

function SpritesheetPanel:refreshAnimationPreview()
    print("\nRefreshing animation preview")
    local playerList = self.hierarchy:getWidgetsWithClass("animation_preview_player")

    if #playerList == 0 then return end

    local player = playerList[1]

    local newAnimation = Animation.new(
        self.activeSpritesheet.spritesheet.imagePath,
        self.activeSpritesheet.spritesheet.frameWidth,
        self.activeSpritesheet.spritesheet.frameHeight,
        self.activeSpritesheet.selectedFrames,
        self.activeSpritesheet.animationSettings
    )
    player:changeAnimation(newAnimation)

    print("Animation settings:")
    for k, v in pairs(self.activeSpritesheet.animationSettings) do
        print(k,v)
    end
end

function SpritesheetPanel:populateSelectedFrameWidgets()
    self.hierarchy:deleteWidgetsWithClass("selected_frame")

    local maxWidth = self:getMaxWidth()
    local ypos = 390

    -- Title
    local titleText = string.format("Frame selected: {%d, %d}", self.selectedFrame.x, self.selectedFrame.y)
    self.selectedFrameTitle = Text.new(titleText, 0, ypos, maxWidth)
    self.selectedFrameTitle:addClasses{"selected_frame"}
    self:addWidget(self.selectedFrameTitle)
    ypos = ypos + love.graphics.getFont():getHeight() + 5

    -- Frame image
    local animation = Animation.new(
        self.activeSpritesheet.spritesheet.imagePath,
        self.activeSpritesheet.spritesheet.frameWidth,
        self.activeSpritesheet.spritesheet.frameHeight,
        {self.selectedFrame}
    )
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

-- Called by spritesheets in the hierarchy when they are closed.
function SpritesheetPanel:spritesheetClosed(spritesheet)
    self.activeSpritesheet = nil
    self.hierarchy:clearWidgets()
    self:populateBaseWidgets()
end


function SpritesheetPanel:addFrame(frameCoords)
    print(string.format("SpritesheetPanel:addFrame - x: %d, y: %d", frameCoords.x, frameCoords.y))

    self:selectFrame(frameCoords)

    -- If this is the first frame, then create all the animation preview widgets.
    -- If not, then just change the frames of the animation that's playing.
    if #self.activeSpritesheet.selectedFrames == 1 then
        self:populateAnimationPreviewWidgets()
    else
        self:refreshAnimationPreview()
    end

    print("Selected frames:")
    for _, frame in ipairs(self.activeSpritesheet.selectedFrames) do
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
    if #self.activeSpritesheet.selectedFrames == 0 then
        self.hierarchy:deleteWidgetsWithClass("animation_preview")
    else
        self:refreshAnimationPreview()
    end
end

function SpritesheetPanel:changeFrameWidth(text)
    print("SpritesheetPanel:changeFrameWidth was called with text="..text)
    local num = tonumber(text)
    if num then
        self.activeSpritesheet.spritesheet.frameWidth = num
    else
        print("Couldn't parse text as num")
    end
end

function SpritesheetPanel:changeFrameHeight(text)
    local num = tonumber(text)
    if num then
        self.activeSpritesheet.spritesheet.frameHeight = num
    end
end

function SpritesheetPanel:changeFrameDuration(text)
    local num = tonumber(text)
    if num then
        for _, f in ipairs(self.activeSpritesheet.selectedFrames) do
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
    self.activeSpritesheet.animationSettings.loop = checkboxState
    self:refreshAnimationPreview()
end

function SpritesheetPanel:changeAnimationSettingBounce(checkboxState)
    self.activeSpritesheet.animationSettings.bounce = checkboxState
    self:refreshAnimationPreview()
end

function SpritesheetPanel:changeAnimationSettingDrawOnFinish(checkboxState)
    self.activeSpritesheet.animationSettings.drawOnFinish = checkboxState
    self:refreshAnimationPreview()
end

function SpritesheetPanel:changeAnimationSettingDefaultDuration(text)
    local num = tonumber(text)
    if num then
        print "Chaning default duration..."
        self.activeSpritesheet.animationSettings.defaultDuration = num
        self:refreshAnimationPreview()
    end
end

function SpritesheetPanel:changeAnimationSettingName(text)
    self.activeSpritesheet.animationSettings.name = text
end

function SpritesheetPanel:saveAnimation()
    print "Saving animation..."

    local sw = self.activeSpritesheet
    local animationTable = {
        imagePath = sw.spritesheet.imagePath,
        frameWidth = sw.spritesheet.frameWidth,
        frameHeight = sw.spritesheet.frameHeight,
        frames = sw.selectedFrames,
        animationSettings = sw.animationSettings
    }

    local saveFolder = Settings.animationSaveFolderName
    if Filesystem.mkdir(saveFolder) then
        print "Animations directory exists."
    else
        print "Animations directory could not be created. Couldn't save animation."
        return
    end

    local animationName
    if animationTable.animationSettings.name and #animationTable.animationSettings.name > 0 then
        animationName = animationTable.animationSettings.name .. ".lua"
    else
        print "WARNING: No animation name given. Randomly generating one..."
        animationName = "animation_" .. os.time() .. ".lua"
    end

    local fileName = saveFolder .. '/' .. animationName

    Filesystem.saveTable(animationTable, fileName)

    local animation = Animation.newFromFile(fileName)
    local successMessage
    if not animation then
        successMessage = "Animation was not saved successfully."
    else
        successMessage = "Animation saved successfully."
    end
    print(successMessage)

    self.hierarchy:addWidgetToRoot(AlertWindow.new(successMessage))
end

function SpritesheetPanel:loadSpritesheet(filePath)
    print("SpritesheetPanel:loadSpritesheet was called with filePath="..filePath)

    -- Check that the file exists and it has an appropriate format.
    local raiseError = function(errorMsg)
        print(errorMsg)
        local alertWindow = AlertWindow.new("ERROR: "..errorMsg)
        self.hierarchy:addWidgetToRoot(alertWindow)
    end

    local fileExists = love.filesystem.exists(filePath)
    if not fileExists then
        raiseError("File does not exist.")
        return
    end

    local fileExtension = string.match(filePath, '%.[a-z]+')
    if fileExtension == nil then
        raiseError("File has an inappropriate name.")
        return
    end

    local appropriateExtension = fileExtension == ".jpg" or fileExtension == ".bmp" or
                                 fileExtension == ".tga" or fileExtension == ".png"
    if not appropriateExtension then
        raiseError("File has an inappropriate format. Acceptable formats are 'jpg', 'bmp', 'tga' or 'png'.")
        return
    end

    local testImage = love.graphics.newImage(filePath)
    if testImage == nil then
        raiseError("Could not load image.")
        return
    end

    local parentWidth, parentHeight = self.workspace.width, self.workspace.height
    local x = parentWidth / 2 + (love.math.random() - 0.5) * (parentWidth / 4)
    local y = parentHeight / 2 + (love.math.random() - 0.5) * (parentHeight / 4)
    local spritesheetWindow = SpritesheetWindow.new(self, filePath, 32, 32, x, y) 

    self.workspace.hierarchy:addWidget(spritesheetWindow)
end
