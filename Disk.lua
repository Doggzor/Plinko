Vec2 = require("Vec2")

local Disk = {}
Disk.__index = Disk
local G = Vec2.new(0, 9.81 * 100) --Gravity
math.randomseed(os.time())

function IsRect(t)
  return getmetatable(t) == Rect
end

function Disk.new(pos, r, color, elasticity)
  assert(IsVec2(pos) and type(r) == "number" or "nil" and type(color) == "table" or "nil", "Invalid Disk params")
  assert(type(r) == "nil" or r > 3, "Radius must be greater than 3")
  assert(type(elasticity) == "nil" or (elasticity >= 0.1 and elasticity <= 0.9),
    "Elasticity must be a value between 0.1 and 0.9")
  return setmetatable({
      pos = pos,
      r = r or 8,
      color = color or {0.5, 1, 0.75},
      vel = Vec2.new(0, 0),
      elasticity = elasticity or 0.8  , --How "bouncy" the disk is
      placing = 0 --For race level
      }, Disk)
end

function Disk:Update(dt, board)

  if self.pos.y < love.graphics.getHeight() - (self.r * 1.05) then --If disk is on the ground, ignore G factor
    self.vel = self.vel + G * dt
  end
  self.pos = self.pos + self.vel * dt
  self:ProcessBouncing(board) 

end

function Disk:ProcessBouncing(board)
  --Left
  if self.pos.x - self.r < board.rect.left then
    self.pos.x = board.rect.left + self.r
    self.vel.x = -self.vel.x * self.elasticity
    return true
  --Right
  elseif self.pos.x + self.r >= board.rect.right then
    self.pos.x = board.rect.right - self.r
    self.vel.x = -self.vel.x * self.elasticity
    return true
  end
  --Bottom
  if self.pos.y + self.r >= love.graphics.getHeight() - 1 then
    self.pos.y = love.graphics.getHeight() - self.r
    self.vel.y = -self.vel.y * self.elasticity
    self.vel.x = self.vel.x * self.elasticity
    return true
  end
  --No real need to bounce off top, just let it go out of screen and drop back
  return false
end

function Disk:ProcessCollision(peg, lights_mode)
  if self.pos:distanceSq(peg.pos) < (self.r + peg.r)^2 then
    local distance = self.pos:distance(peg.pos)
    local overlap_len = self.r + peg.r - distance
    local new_dir = (self.pos - peg.pos):normalized()
    new_dir.x = new_dir.x + math.random(-0.05, 0.05) --Add some randomness when bouncing
    self.pos = self.pos + new_dir * overlap_len --Adjust the position
    self.vel = self.vel:length() * new_dir * self.elasticity --Set the new velocity
    peg:LightUp(self.color, lights_mode)
    return true
  end
end

function Disk:HasStopped()
  return self.pos.y > love.graphics.getHeight() - (self.r * 1.1) and
    self.vel:lengthSq() < 20
end

function Disk:GetRect()
  local rect = Rect.new(
        self.pos.x - self.r,
        self.pos.x + self.r,
        self.pos.y - self.r,
        self.pos.y + self.r)
  return rect
end

function Disk:Draw()
  love.graphics.setColor(self.color)
  love.graphics.circle("fill", self.pos.x, self.pos.y, self.r)
  
--  Always draw placings in a race, maybe there is no need for that  
  if self.placing ~= 0 then
  love.graphics.setColor(1, 1, 1)
    love.graphics.print(self.placing, self.pos.x - self.r - 8, self.pos.y - self.r - 12, 0, 1.2)
  end
end

return Disk