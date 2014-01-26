-- ====================================
-- ADVENTURE PIG - A GAME BY JOE HANLEY
-- ====================================

---- requires ----
require("camera")
require("playerController")
require("apple")
require("tiledLoader")

---- stuff that happens upon game initialization ----
function love.load()
	---- load assets ----	
	song = love.audio.newSource("assets/sounds/song.mp3", "stream")
	shotgun = love.audio.newSource("assets/sounds/shotgun.wav", "static")
	appleBite = love.audio.newSource("assets/sounds/appleBite.mp3", "static")
	
	---- initialize variables ----
	score = 0 																	-- player's current score
	highScore = 0 																-- player's all-time high score
	
	---- setup the stage ----
	loadLevel()
	camera:setBounts(0, 0, map.width, map.height)								-- set the bounderies of the camera
	love.mouse.setVisible(false) 												-- make default mouse invisible	
	love.graphics.setBackgroundColor(50,25,255) 								-- set the background color
	--love.audio.play(song) 
	
	player:respawn()
	apple:spawn()
	apple:respawn(400, 440)
end

---- graphics drawings ----
function love.draw()
	camera:set()	
	drawLevel()
	
	---- gui ----
	love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), camera._x + 655, camera._y + 16)	
	love.graphics.print("Score: "..tostring(score), camera._x + 350, camera._y + 48)
	love.graphics.print("Adventure Pig!", 250, 50, 0, 3, 3)
	love.graphics.print(string.format("Player at (%06.2f , %06.2f) jumping = %s | falling = %s | onGround = %s", player.x, player.y, tostring(player.motion.jumping), tostring(player.motion.falling), tostring(player.motion.onGround)), camera._x + 16, camera._y + 16)
	love.graphics.print(string.format("X Velocity (Max %06.2f): %06.2f", player.motion.maxVelocityX, player.motion.velocityX), camera._x + 16, camera._y + 32)
	love.graphics.print(string.format("Y Velocity (Max %06.2f): %06.2f", player.motion.maxVelocityY, player.motion.velocityY), camera._x + 16, camera._y + 48)
	
	---- sprites ----
	player:draw()	
	apple:draw()
	
	camera:unset()	
end

---- misc. functions ----
function math.clamp(x, min, max)
	return x < min and min or (x > max and max or x)
end

---- keyboard events ----
function love.keypressed(key)
	if key == "escape" then
		love.event.push("quit")
	end
	if key =="return" then
		print(player.motion.maxVelocity)
	end
end

---- test collision ----
function bump(a, b)		
	if (a.x > b.x and a.x < b.x + b.w) or (b.x > a.x and b.x < a.x + a.w) then
		if (a.y > b.y and a.y < b.y + b.h) or (b.y > a.y and b.y < a.y + a.h) then
			return true
		else
			return false
		end
	else
		return false
	end
end

function tileBump(x, y)
	-- find out which tile the point is in
	local tx, ty = math.floor(x / 32), math.floor(y / 32)
	-- check the tile
	if map[tx][ty] == solid then
		return true
	else
		return false
	end
end


---- THIS IS A TEST ----

-- is user off map?
function isOffMap(x, y)
  if x<32 or x+64> (1+#map[1])*32
   or y<32 or y+64>(1+#map)*32 
  then
    return true
  else
    return false
  end
end

-- which tile is that?
function posToTile(x, y)
  local tx, ty = math.floor(x / 32), math.floor(y / 32)
  return tx, ty
end

-- Find out which cells are occupied by a player (check for each corner)
function playerOnCells(x, y)
  local Cells={}
  local tx,ty=posToTile(x, y)
  local key=tx..','..ty
  Cells[key]=true
  Cells[#Cells+1]=key

  tx,ty=posToTile(x+64, y)
  key=tx..','..ty
  if not Cells[key] then
    Cells[key]=true
    Cells[#Cells+1]=key
  end

  tx,ty=posToTile(x+64, y+64)
  key=tx..','..ty
  if not Cells[key] then
    Cells[key]=true
    Cells[#Cells+1]=key
  end

  tx,ty=posToTile(x, y+64)
  key=tx..','..ty
  if not Cells[key] then
    Cells[key]=true
    Cells[#Cells+1]=key
  end
  return Cells
end

-- list of tiles
function isColliding(T)
  local collision=false
  for k,v in ipairs(T) do
    local x,y=v:match('(%d+),(%d+)')
    x,y=tonumber(x), tonumber(y)
    if not map[y] or not map[y][x] then
      collision=true -- off-map
    elseif map[tonumber(y)][tonumber(x)] ~= 6 then
      collision=true
    end
    if map[tonumber(y)][tonumber(x)] == 1 then -- test to see if the player dies
    	player:kill()
    end
  end
  return collision
end

---- END OF PREVIOUS (^) TEST ----









---- things that happen all the time ----
function love.update(dt)
	---- limit FPS ----
	if dt < 1/60 then
		love.timer.sleep(1/60 - dt)
  	end

	player:update(dt)
	camera:setPosition(player.x - map.width / 2 , player.y - map.height / 2)

	---- collision detection ----	
	apple:bump()
	if isOffMap(player.x, player.y) then
		player:kill()
	end
end
