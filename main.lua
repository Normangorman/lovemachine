require "UI.UIManager"
require "UI.Widgets.SpritesheetWorkspace" 
require "UI.Widgets.Tabs"
require "UI.Widgets.Text"

local UI

function love.load()
    love.window.setMode(1366, 768, {resizable=false})
    love.window.setTitle("lovemachine")

    UI = UIManager.new()
	UI:registerEvents()


    local workspaceTabs = Tabs.new(0,0,love.window.getDimensions())
    UI:addWidget(workspaceTabs)
    local x, y = workspaceTabs.innerX, workspaceTabs.innerY

    workspaceTabs:createTab("Spritesheets")
    workspaceTabs:addWidget("Spritesheets", SpritesheetWorkspace.new(x, y))

    workspaceTabs:createTab("Controllers")
    workspaceTabs:addWidget("Controllers", Text.new("Hello world!", x+10, y+10, 300))
end

function love.update(dt)
    UI:update(dt)
end

function love.draw()
    UI:draw()
end
