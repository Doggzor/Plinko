function love.conf(t)
  t.window.width = 800
  t.window.height = 800
  t.window.title = "Plinko"
  t.window.console = true -- disable later
  
  t.modules.joystick = false
  t.modules.physics = false
  t.modules.touch = false
  t.modules.video = false
end

