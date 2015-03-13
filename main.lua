require "SpritesheetData"
require "SpritesheetWidget"
require "Workspace" 
require "UIManager"
require "Animation"

local UI

function love.load()
    UI = UIManager.new()
	UI:registerEvents()

    workspace = Workspace.new(0,0, 800, 600)
    UI:addWidget(workspace)

end

function love.update(dt)
    UI:updateWidgets(dt)
end

function love.draw()
    UI:drawWidgets()
end
