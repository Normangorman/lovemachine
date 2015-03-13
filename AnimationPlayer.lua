require "Settings"

AnimationPlayer = {}
AnimationPlayer.__index = AnimationPlayer

function AnimationPlayer.new(animation, x, y)
    local self = Widget.new(x,y, animation.width, animation.height)

    self.animation = animation
    self.x = x
    self.y = y

    setmetatable(self, AnimationPlayer)
    return self
end

function AnimationPlayer:prevFrame()
    self.animation:prevFrame()
end

function AnimationPlayer:nextFrame()
    self.animation:nextFrame()
end

function AnimationPlayer:play()
    self.animation:play()
end

function AnimationPlayer:pause()
    self.animation:pause()
end

function AnimationPlayer:update(dt)
    self.animation:update(dt)
end

function AnimationPlayer:draw()
    -- Draw border
    self.animation:draw(self.x, self.y)
end
