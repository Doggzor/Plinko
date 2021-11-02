require("Menu")
require("Level")

local state = {initialize = "initialize",menu = "menu", running = "running"}
local level = {classic = "classic", race = "race", paint = "paint"}
local size = {small = "small", medium = "medium", large = "large"}
local mode = {standard = "standard", dark = "dark"}

function love.load(arg)
  if arg[#arg] == "-debug" then require("mobdebug").start() end
  STATE = state.menu
  LEVEL = level.paint
  SIZE = size.small
  MODE = mode.standard
  level = Level:new()
  menu = Menu:new()
  menu:Load()
  btn_menu = Button.new(Rect.new(10, 120, love.graphics.getHeight() - 60,love.graphics.getHeight() - 20), "MENU", {1, 1, 1},
function()
  btn_menu:Reset()
  STATE = state.initialize
end)
  
end

function love.update(dt)
  if STATE == state.initialize then
    menu:new()
    menu:Load()
    STATE = state.menu
  elseif STATE == state.menu then
    menu:Update()
    if #menu.settings == 3 then
      level:new()
      level:Load(unpack(menu.settings))
      STATE = state.running
    end
  elseif STATE == state.running then
    level:Update(dt)
    btn_menu:Update(dt)
  end

end

function love.draw()
  
  if  STATE == state.menu then
    menu:Draw()
  elseif STATE == state.running then
    level:Draw()
    btn_menu:Draw()
  end
end
