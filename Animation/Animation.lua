Animation = {}
Animation.__index = Animation

function Animation.new(spritesheetData, frames, settings, owner, onFinishCallback)
    -- required spritesheetData:  A SpritesheetData object.
    --
    -- required frames: A list of frame objects which must have the following fields:
    --  - integer x: x-coordinate in the spritesheet.
    --  - integer y: y-coordinate in the spritesheet.
    --  And may have any of the following fields:
    --  - float duration: frame duration in seconds.
    --  - string callback: the name of a function to call on the animation's owner when the frame is played.
    --  
    -- optional settings: An optional table of keys and values. Available settings are:
    --  - float defaultDuration: the default duration in seconds for frames.
    --  - boolean loop: should the animation begin again from the beginning once finished?
    --  - boolean bounce: should the animation play backwards upon reaching the final frame / returning to the starting frame. 
    --  - boolean drawOnFinish: should the final frame continue to be drawn after the animation has finished?
    --  - integer playingDirection: either 1 or -1. If 1, advance forwards through the frames. If -1 then start at the end and go backwards.
    --
    -- optional owner: Any table is a valid owner. Frames which have callbacks will attempt to call a field on the owner.
    --
    -- optional onFinishCallback: Function to call when the animation finishes.
    
    if not spritesheetData then
        print "[ERROR] Animation.new - spritesheetData was nil. Returning nil."
        return nil
    elseif not frames then
        print "[ERROR] Animation.new - no frames were given. Returning nil."
        return nil
    elseif #frames == 0 then
        print "[ERROR] Animation.new - empty list of frames. Returning nil."
        return nil
    end
    
    local self = {}
    self.spritesheetData  = spritesheetData
    self.frames           = frames
    self.owner            = owner
    self.onFinishCallback = onFinishCallback

    -- Default settings: 
    self.defaultDuration         = 0.2
    self.loop                    = true 
    self.bounce                  = false
    self.initialPlayingDirection = 1
    self.drawOnFinish            = true
 
    -- Override defaults if present in settings
    if settings then
        if settings.defaultDuration     then self.defaultDuration         = settings.defaultDuration  end
        if settings.loop   ~= nil       then self.loop                    = settings.loop             end
        if settings.bounce ~= nil       then self.bounce                  = settings.bounce           end
        if settings.playingDirection    then self.initialPlayingDirection = settings.playingDirection end
        if settings.drawOnFinish ~= nil then self.drawOnFinish            = settings.drawOnFinish     end
    end

    -- Internal settings:
    self.numFrames         = #frames
    self.width             = spritesheetData.frameWidth
    self.height            = spritesheetData.frameHeight
    self.playing           = false
    if self.initialPlayingDirection == 1 then
        self.currentFrameIndex = 1
    else
        self.currentFrameIndex = #frames
    end
    self.currentPlayingDirection = self.initialPlayingDirection
    self.durationTimer           = self.frames[self.currentFrameIndex].duration or self.defaultDuration 

    print("New animation made with loop="..tostring(self.loop))
    setmetatable(self, Animation)
    return self 
end

function Animation:update(dt)
    if not self.playing then return end

    self.durationTimer = self.durationTimer - dt
    if self.durationTimer < 0 then 
        self.currentFrameIndex = self.currentFrameIndex + self.currentPlayingDirection
        
        -- Direction switching logic:
        if self.currentFrameIndex > self.numFrames then
            if self.bounce then
                if self.loop or self.initialPlayingDirection == 1 then 
                    self.currentFrameIndex = self.numFrames - 1
                    self.currentPlayingDirection = -1 
                else
                    self:_finish()
                    return
                end
            elseif self.loop then
                self.currentFrameIndex = 1
            else
                self:_finish()
                return
            end
        elseif self.currentFrameIndex < 1 then
            if self.bounce then
                if self.loop or self.initialPlayingDirection == -1 then
                    self.currentFrameIndex = 1
                    self.currentPlayingDirection = 1
                else
                    self:_finish()
                    return
                end
            elseif self.loop then
                self.currentFrameIndex = self.numFrames
            else
                self:_finish()
                return
            end
        end

        -- Reset durationTimer and call the frame's callback if it has one.
        local currentFrame = self.frames[self.currentFrameIndex]

        self.durationTimer = currentFrame.duration or self.defaultDuration

        if currentFrame.callback then
            if self.owner then 
                if self.owner[currentFrame.callback] then
                    self.owner[currentFrame.callback]()
                else
                    printf("[WARNING] Animation:update - a frame has a callback named '%s' but the animation owner has no property named '%s'.", currentFrame.callback, currentFrame.callback)
                end
            else
                printf("[WARNING] Animation:update - a frame has a callback named '%s' but the animation has no owner.", currentFrame.callback)
            end
        end

        self:_setCurrentFrameQuad()
    end
end

function Animation:draw(x,y)
    if self.playing or self.drawOnFinish then
        love.graphics.draw(self.spritesheetData.image, self.currentFrameQuad, x, y)
    end
end

function Animation:play()
    self.playing = true
    self:_setCurrentFrameQuad()
end

function Animation:pause()
    self.playing = false
end

function Animation:reset()
    if self.initialPlayingDirection == 1 then
        self.currentFrameIndex = 1
    else
        self.currentFrameIndex = self.numFrames
    end
    self.durationTimer = self.frames[self.currentFrameIndex].duration or self.defaultDuration 
    self.playingDirection = self.initialPlayingDirection 
    self.playing = false
    self:_setCurrentFrameQuad()
end

-- Private functions:
function Animation:_finish()
    print "Animation finished."
    self.playing = false

    if self.onFinishCallback then
        self.onFinishCallback()
    end
end

function Animation:_setCurrentFrameQuad()
    -- By storing the quad it doesn't have to be recomputed all the time:
    local currentFrame = self.frames[ self.currentFrameIndex ]
    local frameWidth, frameHeight = self.spritesheetData.frameWidth, self.spritesheetData.frameHeight
    local imageWidth, imageHeight = self.spritesheetData.imageWidth, self.spritesheetData.imageHeight

    local frame_x = (currentFrame.x - 1) * frameWidth
    local frame_y = (currentFrame.y - 1) * frameHeight

    self.currentFrameQuad = love.graphics.newQuad(frame_x, frame_y, frameWidth, frameHeight, imageWidth, imageHeight)
end
