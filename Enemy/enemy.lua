local anim8 = require "lib.anim8"

local Enemy = {}
Enemy.__index = Enemy
Enemy._idCounter = 0

function Enemy:init(sprite, frameW, frameH, walkFrameCount, deathFrameCount, walkRow, deathRow)
    self.sprite = sprite
    Enemy._idCounter = Enemy._idCounter + 1
    self.id = Enemy._idCounter
    sprite:setFilter("nearest", "nearest")
    self.frameW = frameW
    self.frameH = frameH
    self.walkFrameCount = walkFrameCount
    self.deathFrameCount = deathFrameCount
    self.walkRow = walkRow
    self.deathRow = deathRow
    self.scale = 1
    self.direction = "right"
    self.x = math.random(0, VIRTUAL_WIDTH)
    self.y = math.random(0, VIRTUAL_HEIGHT)
    self.pendingDeath = false
    self.hitShader = love.graphics.newShader("Shaders/enemy_hit_shader.glsl")
    self.hitFlashTimer = 0
    self.hitFlashDuration = 0.2

    self.killedByBook = self.killedByBook or false

    -- Enemy stats
    self.speed = 60
    self.alive = true
    self.damage = 0.1
    self.hp = 5
    self.xpValue = 3

    -- Default direction (For sprites that have different default rotations)
    self.flipDirection = false

    -- Animation
    local g = anim8.newGrid(self.frameW, self.frameH, self.sprite:getWidth(), self.sprite:getHeight())

    self.animations = {
        walk = anim8.newAnimation(g(self.walkFrameCount, self.walkRow), 0.1),
        death = anim8.newAnimation(g(self.deathFrameCount, self.deathRow), 0.05, "pauseAtEnd")
    }

    self.currentAnim = self.animations.walk

    self:updateHitbox()
end

function Enemy:update(dt, player)
    if self.alive then
        if self.pendingDeath and not Player.timeStop.transitionActive then
            self.pendingDeath = false
            self:die()
        end
        if self.hitFlashTimer > 0 then
            self.hitFlashTimer = self.hitFlashTimer - dt
            if self.hitFlashTimer < 0 then
                self.hitFlashTimer = 0
            end
        end

        self.currentAnim:update(dt)

        self:updateHitbox()
        local dx, dy = player.x + 80 - self.x, player.y + 80 - self.y
        local dist = math.sqrt(dx * dx + dy * dy)
        if dist > 0 then
            local bonusSpeed = math.min(dist * 0.05, 500)  -- max 200 bonus
            local moveSpeed = self.speed + bonusSpeed

            self.x = self.x + (dx / dist) * moveSpeed * dt
            self.y = self.y + (dy / dist) * moveSpeed * dt

            if math.abs(dx) > 4 then
                if self.flipDirection then
                    self.direction = dx < 0 and "right" or "left"
                else
                    self.direction = dx < 0 and "left" or "right"
                end
            end
        end
        if dist > 3000 then
            local screenW = love.graphics.getWidth()
            local screenH = love.graphics.getHeight()
            local margin = 300
            local angle = math.rad(math.random(0, 360))
            self.x = player.x + math.cos(angle) * (screenW / 2 + margin)
            self.y = player.y + math.sin(angle) * (screenH / 2 + margin)
        end

        if self:checkCollisionWithPlayer(player) then
                player:takeDamage(self.damage)
                self.attackTimer = 0
            end
    else
        self.currentAnim:update(dt)
    end
end


function Enemy:draw()

    local shader = nil
    if self.hitFlashTimer > 0 then
        shader = self.hitShader
        shader:send("hitAmount", self.hitFlashTimer / self.hitFlashDuration)
        love.graphics.setShader(shader)
    end
    local sx = (self.direction == "left") and -self.scale or self.scale
    local ox = self.frameW / 2
    local oy = self.frameH / 2

    
    self.currentAnim:draw(self.sprite, self.x, self.y, 0, sx, self.scale, ox, oy)
    love.graphics.setShader()
end

function Enemy:checkCollisionWithPlayer(player)
    local pw, ph = player.width, player.height
    local ew, eh = self.frameW-50, self.frameH-50

    return self.x < player.x + pw and
           self.x + ew > player.x and
           self.y < player.y + ph and
           self.y + eh > player.y
end

function Enemy:takeDamage(amount)
    if not self.alive then return end

    self.hp = self.hp - amount
    self.hitFlashTimer = self.hitFlashDuration
    if self.hp <= 0 then
        self.hp = 0
        if Player.timeStop.transitionActive then
            self.pendingDeath = true
        end
        self:die()
    end
end

function Enemy:die()
    self.alive = false
    self.currentAnim = self.animations.death
    self.currentAnim:gotoFrame(1)
end


function Enemy:isOnScreen(cameraX, cameraY, screenW, screenH)
    local margin = 64
    local width = self.frameW * self.scale
    local height = self.frameH * self.scale

    return self.x + width > cameraX - margin and
           self.x < cameraX + screenW + margin and
           self.y + height > cameraY - margin and
           self.y < cameraY + screenH + margin
end

function Enemy:updateHitbox()
    self.hitboxX = self.x - self.frameW - self.scale / 2
    self.hitboxY = self.y - self.frameH - self.scale / 2
    self.hitboxW =  self.frameW * self.scale
    self.hitboxH = self.frameH * self.scale
    self.hitBox = love.graphics.rectangle("fill", self.hitboxX, self.hitboxY, self.hitboxW, self.frameH * self.scale)
end

return Enemy
