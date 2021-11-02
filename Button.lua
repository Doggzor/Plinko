Vec2 = require("Vec2")
Rect = require("Rect")

Button = {}
Button.__index = Button
  
function Button.new(rect, text, color, on_click)
  assert(IsRect(rect) and type(on_click) == "function" or type(on_click) == "nil", "Invalid Button params")
  o = setmetatable({
    rect = rect,
    on_click = on_click or nil,
    text = text or "",
    font = love.graphics.newFont(24),
    color = color or {1, 1, 1},
    bClicked = false,
    bSelected = false,
    bActive = true,
    bHovered = false,
    can_click = false,
    can_select = true
    }, Button)
  return o
end
function Button:Update(dt)
  local mouse_pos = Vec2.new(love.mouse.getPosition())
  self.bHovered = self.rect:IsContaining(mouse_pos)
  --Check if button is hovered and change color alpha if it is
  if self.bHovered and self.bActive then
    self.color[4] = 1 
    --Check if left mouse button is pressed (process just once per click)
    if love.mouse.isDown(1) and self.can_click then
      self.bClicked = true
      if self.can_select then self.bSelected = true end
      if type(self.on_click) ~= "nil" then self.on_click() end
    end
  elseif not self.can_select or not self.bSelected then
    self.color[4] = 0.25
  end
  self.can_click = not love.mouse.isDown(1)
  if self.can_click then self.bClicked = false end
end

function Button:Draw()
  love.graphics.setColor(self.color)
  love.graphics.rectangle("line", self.rect.left, self.rect.top, self.rect:GetWidth(), self.rect:GetHeight(), self.rect:GetWidth()/ 7, self.rect:GetHeight() / 7)
  love.graphics.printf(self.text, self.font, self.rect.left, self.rect.top + (self.rect:GetHeight() - self.font:getHeight()) / 2, self.rect:GetWidth(), "center")
end

function Button:Deactivate()
  self.bActive = false
end
function Button:Activate()
  self.bActive = true
end
function Button:Reset()
  self.bSelected = false
  self.bActive = true
end

return Button