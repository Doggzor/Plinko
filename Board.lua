Vec2 = require("Vec2")
Peg = require("Peg")
Rect = require("Rect")

Board = {}

local PEGS_PER_QUADRANT_MIN, PEGS_PER_QUADRANT_MAX = 16, 80

function Board:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.width = 0
  self.height = 0
  self.peg_r = 0
  self.peg_c = {1, 1, 1}
  self.spacing = 0
  self.offset = Vec2.new(0, 0)
  self.rect = Rect.new(0, 0, 0, 0)
  self.play_area = Rect.new(0, 0, 0, 0)
  self.pegs = {}
  self.lights_mode = "standard"
  return o
end

function Board:Create(width, height, spacing, peg_radius, peg_color, lights_mode)
  self.width, self.height, self.spacing, self.peg_r = width, height, spacing, peg_radius
  self.peg_c, self.lights_mode = peg_color, lights_mode
  --Calculate the top left position of the first Peg based on the board parameters
  self.offset = Vec2.new(65 + (love.graphics.getWidth() - ( (self.width - 1) * self.spacing ) ) / 2,
  love.graphics.getHeight() - ( (self.height - 1) * self.spacing ) - self.spacing * 2.5)

  --Calculate the Board rectangle
  local left = self.offset.x - self.peg_r
  local right = left + (self.width - 1) * self.spacing + self.peg_r * 2
  local top = self.offset.y - self.peg_r
  local bottom = top + (self.height - 1) * self.spacing + self.peg_r * 2
  self.rect = Rect.new(left, right, top, bottom)
  assert(self.rect.right - self.peg_r <= love.graphics.getWidth(), "Board too wide")
  assert(self.spacing > self.peg_r * 2, "Pegs way too big")
  --Calculate where can the Disk be dropped
  self.play_area = Rect.new(left, right, top - self.spacing * 3, top - self.spacing)
  assert(self.play_area.top > self.spacing, "Board too tall")
  
  --Divide the board into Quadrants (performance reasons)
  local pegs_per_rect = self.width * self.height
  local times_to_divide = 0
  while  pegs_per_rect > PEGS_PER_QUADRANT_MAX do
    times_to_divide = times_to_divide + 1
    pegs_per_rect = math.floor(pegs_per_rect / 4)
  end
  self:Divide(times_to_divide)
  --Populate the board with Pegs
  self:Populate()

end

local ProcessCollision
ProcessCollision = function (rect, disk, pegs, lights_mode)
  assert(IsRect(rect), "Invalid argument #1. Expected a Rect")
  local disk_rect = disk:GetRect()
  --Only go on if Disk is inside the Quadrant
  if rect:IsOverlapping(disk_rect) then
    --If contents[1] of rect is another rect, it means it is divided into smaller quadrants
    if IsRect(rect.contents[1]) then
      for i = 1, #rect.contents do
        ProcessCollision(rect.contents[i], disk, pegs, lights_mode)
      end
    --Otherwise, its contents must be peg indices so we can continue to check for collisions inside this quadrant
    else
      assert(type(rect.contents[1]) == "number", "Invalid rect contents. Expected a number. Board might be divided too much.")
      for i = 1, #rect.contents do
        --If collision is found, break immediately. Disk can't collide with more than one Peg at the exact same time
        if disk:ProcessCollision(pegs[rect.contents[i]], lights_mode) then break end
      end
    end
  end
end


function Board:Update(dt, disks)
  assert(type(disks) == "table", "Invalid argument #2. Expected a table")
  --Update all Pegs
  for i = 1, #self.pegs do self.pegs[i]:Update(dt) end
  
  --Go through active Disks and process collisions
  for d = 1, #disks do
    --This will only check collision vs Pegs in the quadrant that the disk is overlapping with
    ProcessCollision(self.rect, disks[d], self.pegs, self.lights_mode)
  end
end

function Board:Draw()
  for i = 1, #self.pegs do self.pegs[i]:Draw() end
end

local DivideFurther
--Divides the board into smaller areas n times
function Board:Divide(n)
  n = n or 0
  if n <= 0 then return end
  --If there are less Pegs in one area than the stated minimum, we are not actually gaining any performance boost
  assert((self.width * self.height) / (4^n) > PEGS_PER_QUADRANT_MIN, "Board is being divided too many times")
  self.rect.contents = self.rect:GetQuadrants()
  DivideFurther(self.rect.contents, n - 1)
end
DivideFurther = function(quadrants, n)
  if n > 0 then
    for i = 1, #quadrants do
      quadrants[i].contents = quadrants[i]:GetQuadrants()
      DivideFurther(quadrants[i].contents, n - 1)
    end
  end
end

local PopulateQuadrant
function Board:Populate()
    --Populate the Board with Pegs
  for h = 1, self.height do
    local b2i_even = ((h + 1) % 2) --0 for odd rows and 1 for even rows, used to help determine position of the peg
    for w = 1, self.width - b2i_even do
      --Calculate Peg position
      local peg_pos = self.offset + Vec2.new((w - 1) * self.spacing + b2i_even * (self.spacing / 2), (h - 1) * self.spacing)
      self.pegs[#self.pegs + 1] = Peg.new(peg_pos, self.peg_r, self.peg_c)
    end
  end
  PopulateQuadrant(self.rect, self.pegs)
end
PopulateQuadrant = function(quadrant, pegs)
  assert(IsRect(quadrant), "Invalid argument. Expected a Rect.")
  --If contents are not empty, that means there  are more quadrants inside the current one
  if #quadrant.contents ~= 0 then
    for i = 1, #quadrant.contents do
      PopulateQuadrant(quadrant.contents[i], pegs)
    end
  --Otherwise, populate the quadrant contents with Peg indices
  else
    for p = 1, #pegs do
      if quadrant:IsContaining(pegs[p].pos) then
        quadrant:AddContents(p)
      end
    end
  end
end

