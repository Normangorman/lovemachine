require "Widget"

Frame = {}
Frame.__index = Frame

function Frame.new(x,y)
    local default_width, default_height = 10,10
    local self = Widget.new(x,y,default_width, default_height)
    setmetatable(self, Frame)
    return self 
end
