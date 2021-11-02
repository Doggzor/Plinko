Vec2 = require("Vec2")

local Rect = {}
Rect.__index = Rect

function IsRect(t)
  return getmetatable(t) == Rect
end

function Rect.new(left, right, top, bottom)
  assert(type(left) == "number" and type(right) == "number" and
    type(top) == "number" and type(bottom) == "number", "Invalid Rect params")
  return setmetatable({
      left = left,
      right = right,
      top = top,
      bottom = bottom,
      contents = {}
      }, Rect)
end

function Rect:copy()
  return Rect.new(self.left, self.right, self.top, self.bottom)
end

function Rect:GetWidth()
  return self.right - self.left
end

function Rect:GetHeight()
  return self.bottom - self.top
end

--Why didn't I just think of this function sooner... I'll have to revisit the code and use it in more places, if I have time
function Rect:GetCenter()
  return Vec2.new( self.left + (self.right - self.left) / 2, self.top + (self.bottom - self.top) / 2)
end

function Rect:MoveHorizontal(n)
  return Rect.new(self.left + n, self.right + n, self.top, self.bottom)
end

function Rect:Flatten(n)
  return Rect.new(self.left, self.right, self.top + n, self.bottom - n)
end

function Rect:MoveVertical(n)
  return Rect.new(self.left, self.right, self.top + n, self.bottom + n)
end

function Rect:Move(x, y)
  return Rect.new(self.left + x, self.right + x, self.top + y, self.bottom + y)
end


function Rect:GetQuadrants() --Returns a table of 4 quadrants
  local quadrant = {}
  local q_width = (self.right - self.left) / 2
  local q_height = (self.bottom - self.top) / 2
  for i = 0, 3 do
    quadrant[i + 1] = Rect.new(
      self.left + q_width * (i % 2),
      self.left + q_width * (i % 2) + q_width,
      self.top + q_height * math.floor(i / 2),
      self.top + q_height * math.floor(i / 2) + q_height
    )
  end
  return quadrant
end
function Rect:IsContaining(o) --Checks if the given vector or rectangle is inside this rectangle (including edges)
  if IsVec2(o) then
    return o.x >= self.left and o.x <= self.right and o.y >= self.top and o.y <= self.bottom
  elseif IsRect(o) then
    return o.left >= self.left and o.right <= self.right and o.top >= self.top and o.bottom <= self.bottom
  else
    error("Invalid argument. Expected a Vec2 or a Rect.")
  end
end

function Rect:IsOverlapping(rect) --Checks if 2 rectangles are overlapping (or touching)
  assert(IsRect(rect), "Invalind argument. Expected a Rect.")
  return self.left <= rect.right and self.right >= rect.left and self.top <= rect.bottom and self.bottom >= rect.top
end

function Rect.AddContents(rect, val)
  rect.contents[#rect.contents + 1] = val
end

function Rect:__tostring()
  return "("..self.left..", "..self.right..", "..self.top..", "..self.bottom..")"
end

return Rect