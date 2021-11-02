
local Bucket = {}
Bucket.__index = Bucket
math.randomseed(os.time())

function Bucket.new(rect, value_max)
  assert(IsRect(rect) and type(value_max) == "number", "Invalid Bucket params")
  return setmetatable({
      rect = rect,
      value = math.floor(math.random(value_max * 0.1, value_max)),
      color = {0.3, 0.3, 0.3}, --If I see this color, I forgot to initialize the colors
      rect_collision = rect:Flatten(rect:GetHeight() * 0.2)
      }, Bucket)
end
function Bucket:Update(dt, disks, level)
  assert(type(disks) == "table", "Invalid argument #2. Expected a table")
  for d = 1, #disks do
    if self.rect_collision:IsOverlapping(disks[d]:GetRect()) then
      level.points = level.points + self.value
      table.remove(disks, d)
      break
    end
  end
  
end
--Call this after creating the buckets to give them some life!
function Bucket:InitializeColor(disk_cost)
  assert(disk_cost > 0, "Disk cost must be higher than 0")
  --Set color parameters based on the value of the bucket compared to the cost to drop the disk. Highest values are very red (HOT!), then as the value drops, the color slowly changes to green. Don't need blue parameter for this, as it always remains the same (0 to 0.4)
  --Red is equal to 1 if value is at or above double the cost of the disk, then slowly decreases the lower the value is 
  local r = math.min(self.value / (disk_cost * 2), 1)
  --Green is equal to 1 if value is at or below double the cost of the disk, then slowly decreases the higher the value is
  local g = math.min(disk_cost * 2 / self.value, 1)
  
  self.color = {r, g, 0, 0.4}
end

function Bucket:Draw()
  love.graphics.setColor(self.color)
  love.graphics.rectangle("fill", self.rect.left, self.rect.top, self.rect:GetWidth(), self.rect:GetHeight())
  love.graphics.setColor(1, 1, 1)
  love.graphics.printf(tostring(self.value), self.rect.left, self.rect.top + self.rect:GetHeight() / 2 - 8, self.rect:GetWidth(), "center")
end

return Bucket