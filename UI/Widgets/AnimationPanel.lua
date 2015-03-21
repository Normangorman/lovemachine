require "UI.Widgets.Panel"
require "UI.Widgets.Widget"

AnimationPanel = {}
AnimationPanel.__index = AnimationPanel
setmetatable(AnimationPanel, Panel)

function AnimationPanel.new()
    local self = Widget.new()
    

    setmetatable(self, AnimationPanel)
    return self
end
