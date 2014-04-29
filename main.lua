function love.load()
  love.graphics.setMode(560, 560, {})

  map = {
        { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
        { 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 },
        { 1, 0, 1, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1 },
        { 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1 },
        { 1, 1, 0, 1, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1 },
        { 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 },
        { 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
        { 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
        { 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
        { 1, 0, 0, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 1 },
        { 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 },
        { 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 },
        { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 }
  }

  current_status = ""

  player = {
    dest = { x = 8, y = 8 },
    grid = { x = 8, y = 8 },
    screen = { x = 0, y = 0 },
    speed = 15,
    range = 8,
    color = {
      red = 40,
      green = 200,
      blue = 40
    }
  }

  player.screen.y = player.grid.y * 32
  player.screen.x = player.grid.x * 32

  path = nil
  route = {}

  Grid = require ("jumper.grid")
  Pathfinder = require ("jumper.pathfinder")

  grid = Grid(map)
  myFinder = Pathfinder(grid, 'ASTAR', 0)
  myFinder:setMode('ORTHOGONAL')

end

function processNodes()
  if playerAtDest() then
    if route and #route then
      head = route[1]
      node = table.remove(route, 1)
      if node then
        player.dest.x = node.x
        player.dest.y = node.y
        current_status = ("sending player to (%2d, %2d)..."):format(player.dest.x, player.dest.y)
      else
        path = nil
      end
    end
  end
end

function playerAtDest()
  return player.grid.x == player.dest.x and player.grid.y == player.dest.y
end

function equalizePlayerColor()
  if player.color.red > 40 then
    player.color.red = player.color.red - 5
  elseif player.color.red < 40 then
    plaer.color.red = player.color.red + 5
  end

  if player.color.green < 200 then
    player.color.green = player.color.green + 4
  elseif player.color.green > 200 then
    player.color.green = 200
  end

  if player.color.blue < 40 then
    player.color.blue = player.color.blue + 5
  elseif player.color.blue > 40 then
    player.color.blue = player.color.blue - 5
  end
end

function resolveCoords(dt)
  -- move the screen coords towards the destination
  if player.grid.y > player.dest.y then
    player.screen.y = player.screen.y - math.ceil((player.screen.y - (player.dest.y * 32)) * player.speed * dt)
  elseif player.grid.y < player.dest.y then
    player.screen.y = player.screen.y - math.floor((player.screen.y - (player.dest.y * 32)) * player.speed * dt)
  end

  if player.grid.x > player.dest.x then
    player.screen.x = player.screen.x - math.ceil((player.screen.x - (player.dest.x * 32)) * player.speed * dt)
  elseif player.grid.x < player.dest.x then
    player.screen.x = player.screen.x - math.floor((player.screen.x - (player.dest.x * 32)) * player.speed * dt)
  end

  -- update the grid if the screen coords have reached the destination
  if player.screen.y == player.dest.y * 32 and
     player.screen.x == player.dest.x * 32 then
    player.grid.x = player.dest.x
    player.grid.y = player.dest.y
  end
end

function love.update(dt)
  processNodes()
  equalizePlayerColor()
  resolveCoords(dt)
end

function love.draw()
  for y=1, #map do
    for x=1, #map[y] do
      if map[y][x] == 1 then
        love.graphics.setColor(200, 40, 200)
      else
        love.graphics.setColor(50, 50, 50)
      end
      love.graphics.rectangle("line", x * 32 + 2, y * 32 + 2, 32 - 4, 32 - 4)
    end
  end

  love.graphics.setColor(player.color.red, player.color.green, player.color.blue)
  love.graphics.rectangle("fill", player.screen.x, player.screen.y, 32, 32)

  love.graphics.print(current_status, 32, 512)
end

function testMap(x, y)
  if map[(player.grid.y) + y][(player.grid.x) + x] == 1 then
    return false
  end
  return true
end

function love.keypressed(key)
  if key == "up" then
    if testMap(0,-1) then
      player.dest.y = player.dest.y - 1
    end
  elseif key == "down" then
    if testMap(0,1) then
      player.dest.y = player.dest.y + 1
    end
  elseif key == "left" then
    if testMap(-1,0) then
      player.dest.x = player.dest.x - 1
    end
  elseif key == "right" then
    if testMap(1,0) then
      player.dest.x = player.dest.x + 1
    end
  end
end

function love.mousereleased(x, y, button)
  if button ~= "l" then return end
  cursor_x = math.floor(x / 32)
  cursor_y = math.floor(y / 32)

  if cursor_y < 2 or
     cursor_x < 2 or
     cursor_y >= #map or
     cursor_x >= #(map[cursor_y]) then
    return
  end

  path = myFinder:getPath(player.grid.x, player.grid.y, cursor_x, cursor_y)
  if route then
    for k in pairs(route) do
      route[k] = nil
    end
  end
  nodes = path:nodes()
  for node, count in path:nodes() do
    table.insert(route, node)
  end
  table.remove(route, 1)

  if #route > player.range then
    current_status = ("route length %d too long! bailing..."):format(#route)
    for k in pairs(route) do
      route[k] = nil
    end
    player.color.red = 255
    player.color.green = 0
    player.color.blue = 0
  end
end
