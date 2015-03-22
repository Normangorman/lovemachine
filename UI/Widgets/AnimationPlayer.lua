require "UI.Settings"
require "UI.Widgets.Widget"

AnimationPlayer = {}
AnimationPlayer.__index = AnimationPlayer
setmetatable(AnimationPlayer, Widget)

function AnimationPlayer.new(animation, x, y)
    local self = Widget.new(x,y, animation.width, animation.height)

    self.animation = animation
    self.x = x
    self.y = y

    self.backgroundColor = Settings.animationPlayerBackgroundColor

    setmetatable(self, AnimationPlayer)
    return self
end

function AnimationPlayer:update(dt)
    self.animation:update(dt)
end

function AnimationPlayer:draw()
    love.graphics.setColor( unpack(self.backgroundColor) )
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.setColor(255,255,255)

    self.animation:draw(self.x, self.y)
end

function AnimationPlayer:changeAnimation(newAnimation)
    newAnimation:play()
    self.animation = newAnimation
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
