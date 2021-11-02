Button = require("Button")
Rect = require("Rect")

Menu = {}

local MB_W = 170
local MB_H = 60
local MB_POS = Vec2.new((love.graphics.getHeight() - MB_W) / 2, 200)
local MB_SPACING = 30
local MB_RECT = Rect.new(MB_POS.x, MB_POS.x + MB_W, MB_POS.y, MB_POS.y + MB_H)

function Menu:new()
  setmetatable({}, self)
  self.__index = self
  self.buttons = {}
  self.settings = {level = "", size = "", mode = ""}
  self.bStart = false
  return self
end

function Menu:Load()
  
  self.buttons = {
    --Levels
      Button.new(MB_RECT:copy():Move(-(MB_W + MB_SPACING), 0), "CLASSIC", {1, 1, 1},
        function()
          self.settings[1] = "classic"
          self.buttons[2]:Reset()
          self.buttons[3]:Reset()
          end),
      Button.new(MB_RECT:copy():Move(-(MB_W + MB_SPACING), MB_H + MB_SPACING), "RACE", {1, 1, 1},
        function()
          self.settings[1] = "race" 
          self.buttons[1]:Reset()
          self.buttons[3]:Reset()
          end),
      Button.new(MB_RECT:copy():Move(-(MB_W + MB_SPACING), (MB_H + MB_SPACING) *2), "PAINT", {1, 1, 1},
        function()
          self.settings[1] = "paint"
          self.buttons[1]:Reset()
          self.buttons[2]:Reset()
          end),
    --Sizes
      Button.new(MB_RECT:copy(), "SMALL", {1, 1, 1},
        function()
          self.settings[2] = "small"
          self.buttons[5]:Reset()
          self.buttons[6]:Reset()
          end),
      Button.new(MB_RECT:copy():Move(0, MB_H + MB_SPACING), "MEDIUM", {1, 1, 1},
        function()
          self.settings[2] = "medium"
          self.buttons[4]:Reset()
          self.buttons[6]:Reset()
          end),
      Button.new(MB_RECT:copy():Move(0, (MB_H + MB_SPACING) * 2), "LARGE", {1, 1, 1},
        function()
          self.settings[2] = "large"
          self.buttons[4]:Reset()
          self.buttons[5]:Reset()
          end),
    --Modes
      Button.new(MB_RECT:copy():Move(MB_W + MB_SPACING, 0), "STANDARD", {1, 1, 1},
        function()
          self.settings[3] = "standard"
          self.buttons[8]:Reset()
          end),
      Button.new(MB_RECT:copy():Move(MB_W + MB_SPACING, MB_H + MB_SPACING), "DARK", {1, 1, 1},
        function()
          self.settings[3] = "dark"
          self.buttons[7]:Reset()
          end),
    --Other
      Button.new(MB_RECT:copy():Move(0, (MB_H + MB_SPACING) * 5), "EXIT", {1, 1, 1},
        function() love.event.quit(0) end)
  }
end

function Menu:Update(dt)
  for i = 1, #self.buttons do self.buttons[i]:Update() end
end

function Menu:Draw()
  for i = 1, #self.buttons do self.buttons[i]:Draw() end
  love.graphics.setColor(0.5, 0.75, 1)
  love.graphics.printf("LEVEL", self.buttons[1].font, self.buttons[1].rect.left, MB_POS.y - 100, MB_W, "center")
  love.graphics.printf("SIZE", self.buttons[1].font, self.buttons[4].rect.left, MB_POS.y - 100, MB_W, "center")
  love.graphics.printf("MODE", self.buttons[1].font, self.buttons[7].rect.left, MB_POS.y - 100, MB_W, "center")
end
