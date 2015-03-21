SpritesheetData = {}
SpritesheetData.__index = Spritesheet

function SpritesheetData.new(imagePath, frameWidth, frameHeight)
    self = {}
    self.imagePath = imagePath
    self.image = love.graphics.newImage(imagePath)
    self.imageWidth, self.imageHeight = self.image:getDimensions()
    self.frameWidth = frameWidth
    self.frameHeight = frameHeight

    self.numCols = self.imageWidth / frameWidth
    self.numRows = self.imageHeight / frameHeight

    self.frames = {}
    for i=1, self.numRows do
        self.frames[i] = {}
        for j=1, self.numCols do
            self.frames[i][j] = Frame.new(i,j)
        end
    end
    self.animations = {} -- an animation is a set of frames

    setmetatable(self, SpritesheetData)
    return self
end


Frame = {}
Frame.__index = Frame

function Frame.new(row, col)
    local self = {}
    self.row = row
    self.col = col
    setmetatable(self, Frame)
    return self 
end
