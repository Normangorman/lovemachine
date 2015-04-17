require "UI.Settings"
require "UI.Widgets.AnimationPlayer"
require "UI.Widgets.SpritesheetWindow"
require "UI.Widgets.SpritesheetPanel"
require "UI.Widgets.Widget"
require "UI.Widgets.Workspace"

SpritesheetWorkspace = {}
SpritesheetWorkspace.__index = SpritesheetWorkspace
setmetatable(SpritesheetWorkspace, Workspace)

function SpritesheetWorkspace.new(x, y)
    local width = love.window.getWidth() - x
    local height = love.window.getHeight() - y

    local self = Workspace.new(x,y,width,height)
    
    -- Startup widgets:
    local spritesheetPanel = SpritesheetPanel.new(self, x + width * 0.75, y)
    self.staticHierarchy:addWidget(spritesheetPanel)

    local hero_image_path = "UI/Assets/hero_60x92.png"
    local heroSpritesheetWindow = SpritesheetWindow.new(spritesheetPanel, hero_image_path, 60, 92, 100, 100)
    self.hierarchy:addWidget(heroSpritesheetWindow)

    local wibletSpritesheetWindow = SpritesheetWindow.new(spritesheetPanel, "UI/Assets/wiblet_48x64.png", 48,64, 800,100)
    self.hierarchy:addWidget(wibletSpritesheetWindow)

    setmetatable(self, SpritesheetWorkspace)
    return self
end
