-- ===================================
-- APPLE PICKUP ITEM FOR ADVENTURE PIG
-- ===================================

---- initialize global variables ----
apple = {}
apple.__index = apple

---- initialize local variables ----
local width = love.graphics.getWidth()
local height = love.graphics.getHeight()

---- initial apple spawning ----
function apple:spawn(x, y, dir)
	local self = {}
	setmetatable(self, apple)
	
	return self
end

function apple:respawn(x, y, dir)
	self.x = x
	self.y = y
	self.dir = -1
	
	self.sprite = love.graphics.newImage("assets/apple.png")
	self.quad = love.graphics.newQuad(0, 0, 24, 24, 24, 24)
	self.w = self.sprite:getWidth()
	self.h = self.sprite:getHeight()	
	self.taken = false
end

---- drawing the apple to the screen ----
function apple:draw()
	if self.taken == false then
		love.graphics.draw(self.sprite, self.quad, self.x, self.y)
	end
end

---- collision with player ----
function apple:bump()
	if bump(player, self) == true and not self.taken then 
		--love.audio.play("assets/sounds/appleBite.mp3")
		self.taken = true
		score = score + 1
	end
end
