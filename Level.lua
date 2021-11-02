Button = require("Button")
Rect = require("Rect")
Disk = require("Disk")
Bucket = require("Bucket")
require("Board")

Level = {}

--Level buttons 
local GB_W = 110
local GB_H = 40
local GB_POS = Vec2.new(10, 60)
local GB_RECT = Rect.new(GB_POS.x, GB_POS.x + GB_W, GB_POS.y, GB_POS.y + GB_H)
local GB_SPACING = 20
local font_game = love.graphics.newFont(32)

function Level:new()
  setmetatable({}, self)
  self.__index = self
  self.level = ""
  self.size = ""
  self.mode = ""
  self.board = Board:new()
  self.buttons = {}
  self.disks = {}
  self.points = 0
  self.disk_cost = 0
  self.can_drop_disk = false
  self.disk_r = 0
  --For classic level
  self.buckets = {}
  --For race level
  self.winner_pick = 0
  self.place_finish = self:GetCurrentPlacing()
  --For paint level
  self.disks_available = 0
  self.painted_percentage = 0
  self.disk_color = {0, 1, 0.75}
  return self
end

function Level:Load(level, size,  mode)
  assert(type(level) == "string" and type(size) == "string" and type(mode) == "string", "Invalid arguments")
  self.level, self.size, self.mode = level, size, mode
  self.buttons = {}
  self.disks = {}
  self.buckets = {}
  local brd_w, brd_h, peg_spacing, peg_r, disk_r, peg_c, lights_mode
  peg_c = {1, 1, 1}
  if size == "small" then
    brd_w, brd_h, peg_r, self.disk_r = 11, 9, 7, 13
  elseif size == "medium" then
    brd_w, brd_h, peg_r, self.disk_r= 16, 13, 6, 10
  elseif size=="large" then
    brd_w, brd_h, peg_r, self.disk_r = 23, 21, 4, 7
  end
  peg_spacing = (peg_r + self.disk_r) * 2.66
  --Set Peg color and lights mode
  if mode == "standard" then
    peg_c = {1, 1, 1}
    lights_mode = mode
  elseif mode == "dark" then
    peg_c = {0, 0, 0}
    lights_mode = "lightshow"
  end
  if level == "race" then
    lights_mode = level
  elseif level == "paint" then
    lights_mode = level
  end
  --Construct the board--
  self.board:Create(brd_w, brd_h, peg_spacing, peg_r, peg_c, lights_mode)  
  
  -- LEVELS --
  self:CreateLevel()
end

function Level:CreateLevel()
  --CLASSIC LEVEL:
  if self.level == "classic" then
    self.points = 500
    self.disk_cost = 10
    self:CreateBuckets()
--RACE LEVEL:
  elseif self.level == "race" then
    self.points = 500
    self.disk_cost = 50
--PAINT LEVEL:
  elseif self.level == "paint" then
    self.disks_available = math.ceil( (self.board.width * self.board.height) / 33 ) + 3
    self.disk_color = {math.random(), math.random(), math.random()}
    self.buckets = {}
  end
  self:CreateButtons()
end
--BUCKETS
function Level:CreateBuckets()
    local buckets_N = self.board.width - 1
    local buckets_W = self.board.spacing
    local buckets_rect = Rect.new(
      self.board.rect.left + self.board.peg_r,
      self.board.rect.left + buckets_W,
      self.board.rect.bottom + self.board.spacing / 2,
      math.min(love.graphics.getHeight() - self.board.spacing / 2, self.board.rect.bottom + self.board.spacing * 3)
    )
    --Calculate buckets max value depending on the number of buckets and the disk cost
    local buckets_maxV = buckets_N / 4 * self.disk_cost * 2
    --This will be used to calculate the new max value based on the position of the bucket
    local buckets_newV
    for i = 1, buckets_N do
      --Values in the middle are usualy worth the most in this version, because edges seem easier to aim for (of course, there is still some randomness involved)
      buckets_newV = buckets_maxV - math.abs(i * 2 - (buckets_N + 1)  ) * (buckets_maxV / buckets_N)
      self.buckets[i] = Bucket.new(buckets_rect:copy():MoveHorizontal(buckets_W * (i - 1)), buckets_newV)
      self.buckets[i]:InitializeColor(self.disk_cost)
    end
end
--BUTTONS
function Level:CreateButtons()
  if self.level == "classic" then
    self.buttons = {
      Button.new(self.board.play_area, "", {0, 0, 0},
      function()
        if self.points >= self.disk_cost then
          self.points = self.points - self.disk_cost
          self.disks[#self.disks + 1] = Disk.new(Vec2.new(love.mouse.getPosition()), self.disk_r)
        end
      end),
    Button.new(GB_RECT, "RANDOM", {1, 1, 1},
      function()
        self.points = self.points - self.disk_cost
        self.disks[#self.disks + 1] = Disk.new(Vec2.new(math.random(self.board.rect.left, self.board.rect.right),  self.board.play_area.top + self.board.play_area:GetHeight() / 2), self.disk_r)
        self:ButtonsReset()
      end)
    }
  elseif self.level == "race" then
    self.buttons = {
      Button.new(GB_RECT, "RED", {1, 0, 0}, function() self:PickWinner(1) end),
      Button.new(GB_RECT:copy():MoveVertical(GB_H + GB_SPACING), "GREEN", {0, 1, 0}, function() self:PickWinner(2) end),
      Button.new(GB_RECT:copy():MoveVertical((GB_H + GB_SPACING) * 2), "BLUE", {0, 0.5, 1}, function() self:PickWinner(3) end),
      Button.new(GB_RECT:copy():MoveVertical((GB_H + GB_SPACING) * 3), "YELLOW", {1, 1, 0}, function() self:PickWinner(4) end),
      Button.new(GB_RECT:copy():MoveVertical((GB_H + GB_SPACING) * 4), "PINK", {1, 0, 1}, function() self:PickWinner(5) end)
    }
  elseif self.level == "paint" then
    self.buttons = {
      Button.new(self.board.play_area, "", {0, 0, 0},
      function()
        if self.disks_available > 0 then
          self.disks_available = self.disks_available - 1
          self.disks[#self.disks + 1] = Disk.new(Vec2.new(love.mouse.getPosition()), self.disk_r, self.disk_color)
        end
      end),
      Button.new(GB_RECT:copy():MoveVertical(GB_SPACING), "RESTART", {1, 1, 1}, function() self:RestartPaint() end)
    }
  end
end
--RACE LEVEL FUNCTIONS
function Level:PickWinner(n) 
  self.points = self.points - self.disk_cost
  self:ButtonsDeactivate()
  self:DropDisks()
  self.winner_pick = n
end

function Level:DropDisks()
  self.disks = {
      Disk.new(Vec2.new(math.random(self.board.rect.left, self.board.rect.right), self.board.play_area:GetCenter().y), self.disk_r, {1, 0, 0}), --RED
      Disk.new(Vec2.new(math.random(self.board.rect.left, self.board.rect.right), self.board.play_area:GetCenter().y), self.disk_r, {0, 1, 0}), --GREEN
      Disk.new(Vec2.new(math.random(self.board.rect.left, self.board.rect.right), self.board.play_area:GetCenter().y), self.disk_r, {0, 0.5, 1}), --BLUE
      Disk.new(Vec2.new(math.random(self.board.rect.left, self.board.rect.right), self.board.play_area:GetCenter().y), self.disk_r, {1, 1, 0}), --YELLOW
      Disk.new(Vec2.new(math.random(self.board.rect.left, self.board.rect.right), self.board.play_area:GetCenter().y), self.disk_r, {1, 0, 1}) --PINK
    }
end

function Level:GetCurrentPlacing()
  local placing = 0
  return function()
    placing = placing + 1
    if placing == #self.disks + 1 then placing = 1 end
    return placing
  end
end
-------------------------

--PAINT LEVEL FUNCTIONS
function Level:RestartPaint()
    self.points = 0
    self.painted_percentage = 0
    self.disks = {}
    self.disks_available = math.ceil( (self.board.width * self.board.height) / 33 ) + 3
    self.disk_color = {math.random(), math.random(), math.random()}
    for i = 1, #self.board.pegs do self.board.pegs[i].light_timer = 0 end
    self:ButtonsReset()
end
-------------------------
function Level:ButtonsDeactivate()
  for i = 1, #self.buttons do
    self.buttons[i]:Deactivate()
  end
end

function Level:ButtonsReset()
  for i = 1, #self.buttons do
    self.buttons[i]:Reset()
  end
end

function Level:Update(dt)
  --CLASSIC--
  if self.level == "classic" then
    for i = 1, #self.buckets do self.buckets[i]:Update(dt, self.disks, self) end
    for i = 1, #self.disks do self.disks[i]:Update(dt, self.board) end
    for i = 1, #self.buttons do self.buttons[i]:Update(dt) end
    
  --RACE--
  elseif self.level == "race" then
    for i = 1, #self.buttons do self.buttons[i]:Update(dt) end
    --Start the race when bet is placed
    if self.winner_pick ~= 0 then
      for i = 1, #self.disks do
        self.disks[i]:Update(dt, self.board)
        --Check if the disk finished the race
        if self.disks[i].pos.y >= love.graphics.getHeight() - self.disks[i].r - 1 and self.disks[i].placing == 0 then
          
          self.disks[i].placing = self.place_finish()
          
          --Get prize points based on your pick if the race is over
          if self.disks[i].placing == #self.disks then
            self.points = self.points + (2^(#self.disks - self.disks[self.winner_pick].placing) * self.disk_cost * 0.25) --0.25, 0.5, 1, 2, 4  *  disk cost
          --Reactivate buttons
            for i = 1, #self.buttons do self.buttons[i]:Reset() end
            break
          end
        end
      end
    end
    
  --PAINT--
  elseif self.level == "paint" then
    for i = 1, #self.buttons do self.buttons[i]:Update(dt) end
    for i = 1, #self.disks do
      self.disks[i]:Update(dt, self.board)
    end
    --Calculate the percentage of the board that has been painted (points are used for this purpose in paint mode)
    self.points = 0
    for i = 1, #self.board.pegs do
      if self.board.pegs[i].light_timer > 0 then self.points = self.points + 1 end
    end
  end
  self.board:Update(dt, self.disks)
  
end

function Level:Draw()
  self.board:Draw()
  for i = 1, #self.buttons do self.buttons[i]:Draw() end

--Classic or Paint
  if self.level == "classic" or self.level == "paint" then
    --Draw notification of the playable area
    love.graphics.setColor(0.4, 0.4, 0.4)
  love.graphics.rectangle("line", self.board.play_area.left, self.board.play_area.top, self.board.play_area:GetWidth(), self.board.play_area:GetHeight())
    love.graphics.printf("CLICK HERE TO DROP A DISK", font_game, self.board.play_area.left, self.board.play_area.top + (self.board.play_area:GetHeight() - font_game:getHeight()) / 2, self.board.play_area:GetWidth(), "center")
    if self.buttons[1].bHovered then
        love.graphics.setColor(self.disk_color[1], self.disk_color[2], self.disk_color[3], 0.5)
        love.graphics.circle("fill", love.mouse.getX(), love.mouse.getY(), self.disk_r)
    end
  
  --Just Classic
    if self.level == "classic" then
    for i = 1, #self.buckets do self.buckets[i]:Draw() end
    --Just Paint
    elseif self.level == "paint" then
      love.graphics.setColor(0.5, 1, 0.75)
      love.graphics.print("Available Disks: " .. self.disks_available, 10, 40)
    end
    --Race
  else
    love.graphics.setColor(0.4, 0.4, 0.4)
    love.graphics.printf("Bet on a color to start the race", font_game, self.board.play_area.left, 40, self.board.play_area:GetWidth(), "center")
    
    -------------------
    -------------------
    
  end
  if self.level ~= "paint" then
    love.graphics.setColor(0.5, 1, 0.75)
    love.graphics.print("Points: " .. self.points, 10, 10, 0, 1.5)
  else
    love.graphics.setColor(0.5, 1, 0.75)
    love.graphics.print("Painted: ".. math.floor((self.points / #self.board.pegs) * 100) .. "%", 10, 10, 0, 1.5)
  end
  for i = 1, #self.disks do self.disks[i]:Draw() end
  
--  --Diagnostics, if needed
--  love.graphics.print("BET: " .. self.winner_pick, 10, 500, 0, 1.5)
--  love.graphics.print("2nd: " .. (2^(#self.disks - 2) * self.disk_cost * 0.25), 10, 550, 0, 1.5)
--  love.graphics.print("3rd: " .. (2^(#self.disks - 3) * self.disk_cost * 0.25), 10, 600, 0, 1.5)
--  love.graphics.print("4th: " .. (2^(#self.disks - 4) * self.disk_cost * 0.25), 10, 650, 0, 1.5)
--  love.graphics.print("5th: " .. (2^(#self.disks - 5) * self.disk_cost * 0.25), 10, 700, 0, 1.5)
--  if #self.disks > 0 then love.graphics.print("Radius: " .. self.disks[1].r, 10, 550, 0, 1.5) end
--  end
end