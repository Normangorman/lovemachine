require "UI.UIManager"
require "UI.Settings"
require "UI.Widgets.ControllerWorkspace" 
require "UI.Widgets.SpritesheetWorkspace" 
require "UI.Widgets.Tabs"
require "UI.Widgets.Text"

local UI
local backgroundColor = Settings.applicationBackgroundColor

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
    workspaceTabs:addWidget("Controllers", ControllerWorkspace.new(x, y))
end

function love.update(dt)
    UI:update(dt)
end

function love.draw()
    -- Draw background.
    love.graphics.setColor(backgroundColor)
    love.graphics.rectangle("fill", 0, 0, love.window.getDimensions())
    love.graphics.setColor(255,255,255,255)
    
    UI:draw()
end
