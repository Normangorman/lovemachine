Animation = {}
Animation.__index = Animation

function Animation.new(spritesheetData, frames, settings)
    -- frames is a list of frame objects e.g. {x=1, y=3, duration=0.2, callback=function()...end, ownerCallback="foo" }
    local self = {}
    self.spritesheetData = spritesheetData
    self.width = spritesheetData.frameWidth
    self.height = spritesheetData.frameHeight
    self.frames = frames
    self.numFrames = #self.frames -- calculated here so it doesn't have to be recomputed all the time.

    -- Set defaults 
    self.delay = 0.25
    self.playing = false
    self.timeDelayCounter = self.delay
    self.startingFrameNumber = 1
    self.currentFrameNumber = 1
    self.currentFrame = self.frames[ self.currentFrameNumber ]
    self.loop = true -- should I begin again from frame 1 upon ending?
    self.bounce = false -- should I play back in reverse upon hitting the first/last frame?
    self.playingDirection = 1 -- should I advance forwards or backwards through the frames?
    self.owner = nil

    -- Override defaults if present in settings
    if settings then
        if settings.delay then
            self.delay = settings.delay
            self.timeDelayCounter = settings.delay
        end
        if settings.loop then self.loop = settings.loop end
        if settings.bounce then self.bounce = settings.bounce end
        if settings.playingDirection then self.playingDirection = settings.playingDirection end
        if settings.owner then self.owner = settings.owner end
    end

    setmetatable(self, Animation)
    return self 
end

function Animation:update(dt)
    if self.playing and self.currentFrame then
        self.timeDelayCounter = self.timeDelayCounter - dt
        if self.timeDelayCounter < 0 then
            self.timeDelayCounter = self.delay
            self.currentFrameNumber = self.currentFrameNumber + self.playingDirection

            if self.currentFrameNumber > self.numFrames then
                if self.bounce then
                    self.currentFrameNumber = self.numFrames - 1
                    self.playingDirection = -1 
                elseif self.loop then
                    self.currentFrameNumber = 1
                else
                    self.playing = false
                end
            elseif self.currentFrameNumber < 1 then
                if self.bounce then
                    self.currentFrameNumber = 2
                    self.playingDirection = 1
                else
                    self.playing = false
                end
            end

            self.currentFrame = self.frames[self.currentFrameNumber]
            if self.currentFrame.duration then self.timeDelayCounter = frame.duration end
            if self.currentFrame.callback then frame.callback() end
            if self.currentFrame.ownerCallback and self.owner then self.owner[frame.ownerCallback]() end
        end
    end
end

function Animation:draw(x,y)
    if self.currentFrame then
        local frame_x = (self.currentFrame.x - 1) * self.spritesheetData.frameWidth
        local frame_y = (self.currentFrame.y - 1) * self.spritesheetData.frameHeight
        local q = love.graphics.newQuad(frame_x, frame_y, 
                                        self.spritesheetData.frameWidth, self.spritesheetData.frameHeight,
                                        self.spritesheetData.imageWidth, self.spritesheetData.imageHeight)
        love.graphics.draw(self.spritesheetData.image, q, x, y)
    end
end

function Animation:play()
    self.playing = true
end

function Animation:pause()
    self.playing = false
end

function Animation:reset()
    self.currentFrameNumber = self.startingFrameNumber
    self.timeDelayCounter = self.delay
    self.playingDirection = 1
    self.playing = false
end
