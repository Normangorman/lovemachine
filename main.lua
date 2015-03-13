require "SpritesheetData"
require "SpritesheetWidget"
require "Workspace" 
require "UIManager"

local UI

function love.load()
    UI = UIManager.new()
	UI:registerEvents()

    hero_image = love.graphics.newImage("assets/hero_60x92.png")
    spritesheetData = SpritesheetData.new(hero_image, 60, 92)
    spritesheetWidget = SpritesheetWidget.new(spritesheetData, 100, 100)

    workspace = Workspace.new(0,0, 800, 600)
    UI:addWidget(workspace)
end

function love.update(dt)
    UI:updateWidgets(dt)
end

function love.draw()
    UI:drawWidgets()
end
