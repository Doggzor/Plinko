local Vec2 = {}
Vec2.__index = Vec2

function IsVec2(t)
  return getmetatable(t) == Vec2
end

function Vec2.new(x, y)
  assert(type(x) == "number" and type(y) == "number", "Invalid Vec2 params")
  return setmetatable({x = x, y = y}, Vec2)
end

-- OPERATORS --
function Vec2.__add(lhs, rhs)
  assert(IsVec2(lhs) and IsVec2(rhs), "Invalid operand type")
  return Vec2.new(lhs.x + rhs.x, lhs.y + rhs.y)
end

function Vec2.__sub(lhs, rhs)
  assert(IsVec2(lhs) and IsVec2(rhs), "Invalid operand type")
  return Vec2.new(lhs.x - rhs.x, lhs.y - rhs.y)
end

function Vec2.__mul(lhs, rhs)
  assert( (IsVec2(lhs) and type(rhs) == "number") or (IsVec2(rhs) and type(lhs) == "number"), "Invalid operand type")
  if type(lhs) == "number" then
    return Vec2.new(rhs.x * lhs, rhs.y * lhs)
  else
    return Vec2.new(lhs.x * rhs, lhs.y * rhs)
  end
end

function Vec2.__div(lhs, rhs)
  assert( (IsVec2(lhs) and type(rhs) == "number"), "Invalid operand type")
  return Vec2.new(lhs.x / rhs, lhs.y / rhs)
end

function Vec2.__eq(lhs, rhs)
  return lhs.x == rhs.x and lhs.y == rhs.y
end

function Vec2.__unm(t)
  return Vec2.new(-t.x, -t.y)
end

function Vec2:__tostring()
  return "("..self.x..", "..self.y..")"
end

-- FUNCTIONS --
function Vec2:copy()
  return Vec2.new(self.x, self.y)
end

function Vec2:length()
  return math.sqrt(self:lengthSq())
end

function Vec2:lengthSq()
  return self.x * self.x + self.y * self.y
end

function Vec2:normalize() --Normalize the vector
  local len = self:length()
  if len ~= 0 and len ~= 1 then
    self.x = self.x / len
    self.y = self.y / len
  end
end

function Vec2:normalized() --Get the normalized vector without changing the original
  local vec = self:copy()
  vec:normalize()
  return vec
end

function Vec2:distance(rhs)
  return math.sqrt(Vec2.distanceSq(self, rhs))
end

function Vec2:distanceSq(rhs)
  assert(IsVec2(rhs), "Invalid argument. Expected a Vec2.")
  local dx, dy = self.x - rhs.x, self.y - rhs.y
  return dx * dx + dy * dy
end

return Vec2
