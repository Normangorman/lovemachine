require "UI.Settings"
require "UI.Widgets.Text"
require "UI.Widgets.Widget"

TextInput = {}
TextInput.__index = TextInput
setmetatable(TextInput, Widget)

function TextInput.new(x,y,width, inputCallback)
    local padding = Settings.textInputPadding
    print("line height: ".. love.graphics.getFont():getLineHeight())
    local height = love.graphics.getFont():getHeight() + padding * 2
    local self = Widget.new(x,y,width,height)

    self.inputCallback = inputCallback or function() end -- called once text input is finished.

    self.padding = padding
    self.textWidget = Text.new("", self.x + self.padding, self.y + self.padding, width, "left")
    self.selected = false
    self.isMouseover = false
    self.borderWidth = Settings.textInputBorderWidth
    self.borderColor = Settings.textInputBorderColor
    self.backgroundColor = Settings.textInputBackgroundColor
    self.cursorColor = Settings.textInputCursorColor
    self.mouseoverBorderColor = Settings.textInputMouseoverBorderColor
    self.selectedBackgroundColor = Settings.textInputSelectedBackgroundColor

    self.string = {}
    self.cursorPosition = 1

    setmetatable(self, TextInput)
    return self
end

function TextInput:update()
    self.textWidget.x = self.x + self.padding
    self.textWidget.y = self.y + self.padding
    self.isMouseover = false
end

function TextInput:draw()
    if self.selected then
        love.graphics.setColor( unpack(self.selectedBackgroundColor) )
    else
        love.graphics.setColor( unpack(self.backgroundColor) )
    end

    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    local oldLineWidth = love.graphics.getLineWidth()
    love.graphics.setLineWidth(self.borderWidth)

    if self.isMouseover then
        love.graphics.setColor( unpack(self.mouseoverBorderColor) )
    else
        love.graphics.setColor( unpack(self.borderColor) )
    end
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

    love.graphics.setColor(255,255,255)
    love.graphics.setLineWidth(oldLineWidth)

    self.textWidget:draw()

    -- Draw the cursor:
    if self.selected then
        local font = self.textWidget.font

        local text_x = self.textWidget.x
        local text_y = self.textWidget.y

        local cursor_x = text_x
        for i=1, self.cursorPosition-1 do
            if i <= #self.string then
                local char_width = font:getWidth(self.string[i])
                cursor_x = cursor_x + char_width
            end
        end
        local cursor_y = text_y

        local cursor_width
        if self.cursorPosition > #self.string then
            cursor_width = font:getWidth('A')
        else
            cursor_width = font:getWidth( self.string[self.cursorPosition] )
        end
        local cursor_height = font:getHeight()

        love.graphics.setColor( unpack(self.cursorColor) )
        love.graphics.rectangle("fill", cursor_x, cursor_y, cursor_width, cursor_height)
        love.graphics.setColor(255,255,255)
    end
end

function TextInput:mouseover(mx, my)
    self.isMouseover = true
end

function TextInput:mousepressed(mx, my, button)
    print("Text input was clicked. Bound a listener function to the next love.mousepressed event.")

    -- A bit of a hack, but works very nicely.
    local oldCallback = love.mousepressed
    love.mousepressed = function(...)
        print("Deselecting textinput...")
        self:deselect()
        love.mousepressed = oldCallback
        oldCallback(...)
        print("Removed the listener function")
    end

    self.selected = true
    self.cursorPosition = #self.string + 1
end

function TextInput:textinput(c)
    print("TextInput's textinput callback was triggered.")
    if self.selected then 
        self:insertChar(c)
    end
end
 
function TextInput:keypressed(key)
    if not self.selected then return end

    if key == 'backspace' then
        print("Backspace was pressed on text input.")
        self:backspace()
    elseif key == 'delete' then
        print("deleted was pressed on text input.")
        self:deleteChar()
    elseif key == 'left' then
        print("TextInput is moving cursor left")
        self:moveCursor(-1)
    elseif key == 'right' then
        self:moveCursor(1)
    elseif key == 'return' then
        self:deselect()
    end
end

function TextInput:getText()
    local text = ""
    for _, c in ipairs(self.string) do
        text = text..c
    end
    return text
end

function TextInput:updateTextWidget()
    print("Updated text to: "..self:getText())
    self.textWidget:setText( self:getText() )
end

function TextInput:setText(newText)
    newText = tostring(newText)
    self.string = {}
    for i=1, #newText do
        local c = newText:sub(i,i)
        self.string[i] = c
    end

    self:updateTextWidget()
end

function TextInput:insertChar(c)
    -- don't insert if it would overflow the width
    local font = self.textWidget.font
    local text_width = font:getWidth(self:getText()) + font:getWidth(c)

    if text_width <= self.width - 2 * self.padding then
        table.insert(self.string, self.cursorPosition, c)
        self:moveCursor(1)

        self:updateTextWidget()
    end
end

function TextInput:moveCursor(d)
    if self.cursorPosition == 1 and d < 0 then
        return
    elseif self.cursorPosition == #self.string + 1 and d > 0 then
        return
    else
        self.cursorPosition = self.cursorPosition + d
    end
    print("Moved cursor to: "..self.cursorPosition)
end

function TextInput:backspace()
    print("Backspace called on textinput")
    if self.cursorPosition == 1 then
        return
    else
        table.remove(self.string, self.cursorPosition - 1)
        self:moveCursor(-1)
        self:updateTextWidget()
    end
end

function TextInput:deleteChar()
    if self.cursorPosition <= #self.string then
        table.remove(self.string, self.cursorPosition)
        self:updateTextWidget()
    end
end

function TextInput:deselect()
    self.selected = false
    self.inputCallback(self:getText())
end
