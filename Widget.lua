Widget = {}

function Widget.new(x,y,width,height)
    local self = {}
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.closed = false -- closed widgets will eventually be deleted from the hierarchy.

    return self 
end
