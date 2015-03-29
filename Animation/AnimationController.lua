AnimationController = {}
AnimationController.__index = AnimationController

function AnimationController.new()
    local self = {}

    self.animations = {}
    self.states = {}
    self.activeAnimation = nil
    self.playing = false

    setmetatable(self, AnimationController)
    return self 
end

function AnimationController:addAnimation(name, animation)
    self.animations[name] = animation
end

function AnimationController:update(dt)
    self.activeAnimation:update(dt) 
end

function AnimationController:draw(x,y)
    self.activeAnimation:draw(x,y)
end

function AnimationController:play()
    self.playing = true
    self.activeAnimation:play()
end

function AnimationController:pause()
    self.playing = false
    self.activeAnimation:pause()
end
