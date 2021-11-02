Vec2 = require("Vec2")

local Peg = {}
Peg.__index = Peg

function Peg.new(pos, r, color)
  assert(IsVec2(pos) and type(r) == "nil" or "number" and type(color) == "nil" or "table", "Invalid Peg params")
  assert(type(r) == "nil" or r > 0, "Peg radius must be greater than 0")
  return setmetatable({
      pos = pos,
      r = r or 5,
      light_timer = 0,
      lights_dur = 0.25,
      c_lightsOFF = color or {1, 1, 1},
      c_lightsON = {0.9, 0.45, 0}
      }, Peg)
end

function Peg:Update(dt)
  --I believe it is faster to always update than to first check if it is > 0. Might  be wrong though...
  self.light_timer = self.light_timer - dt
end

function Peg:LightUp(color, lights_mode)
  if lights_mode == "lightshow" then
    self.c_lightsON = {math.random(), math.random(), math.random()}
    self.lights_dur = 0.25
  elseif lights_mode == "race" then
    self.c_lightsON = color
    self.lights_dur = 1
  elseif lights_mode == "paint" then
    self.c_lightsON = color
    self.lights_dur = 86400 --This is a quick fix for what I needed, deffinitely not the way to do it
  end
  self.light_timer = self.lights_dur
end

function Peg:Draw()
  if self.light_timer > 0 then
    love.graphics.setColor(self.c_lightsON)
  else
    love.graphics.setColor(self.c_lightsOFF)
  end
  love.graphics.circle("fill", self.pos.x, self.pos.y, self.r)
end

return Peg