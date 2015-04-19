AnimationPanel = {}
AnimationPanel.__index = AnimationPanel
setmetatable(AnimationPanel, Panel)

function AnimationPanel.new()
    local self = Widget.new()
    

    setmetatable(self, AnimationPanel)
    return self
end
