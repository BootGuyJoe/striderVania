-- ===================================
-- PLAYER CONTROLLER FOR ADVENTURE PIG
-- ===================================

---- initialize global variables ----
player = {}
player.__index = player

---- initialize local variables ----
local width = love.graphics.getWidth()
local height = love.graphics.getHeight()
local runSpeed = 150
local maxWalkSpeed = 200
local maxRunSpeed = 250
local jumpForce = 450
local gravity = 1000

---- initial player spawning ----
function player:spawn(x, y, dir)
	local self = {}
	setmetatable(self, player)
	
	return self
end

-------------------------------
---- post-death respawning ----
-------------------------------
function player:respawn(x, y, dir)	
	self.x = x or map.playerStartX -- map.playerStartX currently set in tiledLoader.lua
	self.y = y or map.playerStartY -- map.playerStartY currently set in tiledLoader.lua
	self.dir = dir or 1 -- -1 = left, 1 = right

	self.sprite = love.graphics.newImage("assets/pig.png")
	self.quad = love.graphics.newQuad(0, 0, 64, 64, 64, 64)
	self.w = player.sprite:getWidth()
	self.h = player.sprite:getHeight()
	self.alive = true
	self.motion =
	{
		velocityX = 0,
		velocityY = 0,
		maxVelocityX = 4,
		maxVelocityY = 4,
		accelerationX = 0,
		accelerationY = 0,
		friction = 0.90,
		--jumpForce = 0,
		--runSpeed = 3,
		onGround = false,
		jumping = false,
		falling = false,
		Cells = {}
	}	
end

---- drawing the player on-screen ----
function player:draw()
	if self.alive == true then
		love.graphics.draw(self.sprite, self.quad, self.x, self.y, 0, self.dir, 1, self.w / 2, self.h / 2)
	end
end

---- killing the player ----
function player:kill(...)
	self.alive = false
	self:respawn(...)
end

----------------------------
---- walk functionality ----
----------------------------
function player:moveX(amount)
	local newX

	---- apply accelerationX to velocityX ----
	self.motion.velocityX = self.motion.velocityX + amount
	
	---- apply friction ----
	self.motion.velocityX = self.motion.velocityX * self.motion.friction		
	
	---- set vertical speed limit ----
	if self.motion.velocityX > self.motion.maxVelocityX then
		self.motion.velocityX = self.motion.maxVelocityX
	end
	if self.motion.velocityX < -self.motion.maxVelocityX then
		self.motion.velocityX = -self.motion.maxVelocityX
	end
	
	---- store movement in varible, then check for collision ----
	newX = self.x + self.motion.velocityX
	
	if newX then
		local offMap = isOffMap(newX, self.y)
		local colliding = isColliding(playerOnCells(newX, self.y))
		if not offMap and not colliding then
			self.x = newX
		end
	end
end

----------------------------
---- jump functionality ----
----------------------------
function player:moveY(amount)
	local newY

	---- apply accelerationY to velocityY ----
	self.motion.velocityY = self.motion.velocityY + amount
	
	---- set terminal velocity ----
	if self.motion.velocityY > (self.motion.maxVelocityY * 2) then
		self.motion.velocityY = (self.motion.maxVelocityY *2)
		print("Terminal velocity reached!")
	end
	if self.motion.velocityY < -self.motion.maxVelocityY then
		self.motion.velocityY = -self.motion.maxVelocityY
	end
	
	---- store movement in varible, then check for collision ----
	newY = self.y + self.motion.velocityY
	
	if newY then
		local offMap = isOffMap(self.x, newY)
		local colliding = isColliding(playerOnCells(self.x, newY))
		if not offMap and not colliding then
			self.y = newY
		end
	end
end

-----------------------------------------
---- stuff that happens all the time ----
-----------------------------------------
function player:update(dt)
	local newY, originalSpeed

	---- what happens when you move left or right ----
	if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
		self.dir = -1
		self.motion.accelerationX = -runSpeed
	end
	if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
		self.dir = 1
		self.motion.accelerationX = runSpeed
	end
	---- what happens when hit the jump button ----
	if love.keyboard.isDown(" ") then
		if self.motion.onGround and not self.motion.jumping then
			self.motion.jumping = true
			self.motion.accelerationY = -20
			love.audio.play(appleBite) -- need a new sound for this
		end
	end
	---- what happens you hold the run button ----
	if love.keyboard.isDown("lshift") or love.keyboard.isDown("rctrl") then
		 originalSpeed = maxWalkSpeed
		 maxWalkSpeed = maxRunSpeed
	end
	
	---- what happens when you release any of the above buttons ----
	function love.keyreleased(key)
		if key == "left" or key == "right" or key == "a" or key == "d" then
			self.motion.accelerationX = 0
		end
		if key == " " then
			self.motion.accelerationY = 0
		end
		if key == "lshift" or key == "rctrl" then
			maxWalkSpeed = originalSpeed
		end
	end	
	
	---- always apply acceleration ----
	self:moveX(self.motion.accelerationX * dt)
	self:moveY(self.motion.accelerationY * dt)

	---- prevent horizontal velocity from falling below 0 ----
	if math.abs(self.motion.velocityX) < 0.1 then
		self.motion.velocityX = 0
	end

	---- always apply gravity ----	
	gravity = gravity + jumpForce * dt
	newY = self.y + gravity * dt
	
	---- check only for upper or lower collision ----
	local coll = isColliding(playerOnCells(self.x, newY))
	if coll then
		if gravity >= 0 then
			self.motion.onGround = true
			self.motion.falling = false
			self.motion.velocityY = 0
		end
		gravity = 0
		self.motion.jumping = false
	else
		self.motion.onGround = false
		self.motion.falling = true
	end
	if not isOffMap(self.x, newY) and not coll then
		self.y = newY
	end
end
