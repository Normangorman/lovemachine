require "Animation.Animation"
require "Animation.SpritesheetData"
require "UI.UIManager"
require "UI.Widgets.SpritesheetPanel"
require "UI.Widgets.SpritesheetWidget"
require "UI.Widgets.Workspace" 

local UI

function love.load()
    love.window.setMode(1366, 768, {resizable=false})
    love.window.setTitle("lovemachine")

    UI = UIManager.new()
	UI:registerEvents()

    local workspace = Workspace.new(0,0, love.window.getWidth(), love.window.getHeight())
    UI:addWidget(workspace)
end

function love.update(dt)
    UI:update(dt)
end

function love.draw()
    UI:draw()
end
