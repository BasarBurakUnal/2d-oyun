local UI = require("ui")
local XpOrb = {}
XpOrb.__index = XpOrb

XpOrb.globalCombo = 0
XpOrb.globalComboTimer = 0

function XpOrb:new(x, y, amount, sound)
    local self = setmetatable({}, XpOrb)
    if not XpOrb.image then
        XpOrb.image = love.graphics.newImage("Player/Assets/Sprites/xp.png")
        XpOrb.image:setFilter("nearest", "nearest")
    end


    self.x = x
    self.y = y
    self.amount = amount
    self.radius = 12

    self.tracking = false
    self.trackingDuration = 0
    self.baseSpeed = 100
    self.acceleration = 1000
    self.maxSpeed = 1000
    self.collected = false
    
    self.pulseTimer = 0
    self.pulseSpeed = 5
    self.pulseScale = 1
    self.sineOffset = math.random() * math.pi * 2
    self.wiggleStrength = 16
    self.wiggleSpeed = 10
    self.trail = {}  -- { {x, y, timeLeft}, ... }


    self.xpSound = sound:clone()

    return self
end

function XpOrb:update(dt, player)
    self.xpSound:setVolume(Player.ui.sfxVolume)
    self.pulseTimer = self.pulseTimer + dt
    local px = player.x + player.width / 2
    local py = player.y + player.height / 2

    local dx = px - self.x
    local dy = py - self.y
    local dist = math.sqrt(dx * dx + dy * dy)

    -- Start tracking
    if not self.tracking and dist < player.xpRadius then
        self.tracking = true
    end

    if self.tracking then
        self.trackingDuration = self.trackingDuration + dt

        local speed = math.min(
            self.baseSpeed + self.trackingDuration * self.acceleration,
            self.maxSpeed
         )

         local dirX, dirY = dx / dist, dy / dist
        -- Sine oscillation direction will be perpendicular (normal vector)
        local normalX = -dirY
        local normalY = dirX
        local wiggle = math.sin(love.timer.getTime() * self.wiggleSpeed + self.sineOffset) * self.wiggleStrength

        -- Final movement
        self.x = self.x + (dirX * speed * dt + normalX * wiggle * dt)
        self.y = self.y + (dirY * speed * dt + normalY * wiggle * dt)
    end

    -- Leave a trail every 0.05 seconds
    self.trailTimer = (self.trailTimer or 0) + dt
    if self.trailTimer > 0.05 then
        self.trailTimer = 0
        table.insert(self.trail, {x = self.x, y = self.y, time = 0.3})
    end

    -- Age the trail
    for i = #self.trail, 1, -1 do
        local t = self.trail[i]
        t.time = t.time - dt
        if t.time <= 0 then
            table.remove(self.trail, i)
        end
    end

    if dist < 10 then
        self.collected = true
        GameStats.xpCollected = GameStats.xpCollected + self.amount
        player:addXp(self.amount)

        XpOrb.globalCombo = XpOrb.globalCombo + 1
        XpOrb.globalComboTimer = 0

        local pitch = math.min(1 + XpOrb.globalCombo * 0.05, 5.0)

        self.xpSound:setPitch(pitch)
        self.xpSound:stop()
        self.xpSound:play()
    end

    if XpOrb.globalCombo > 0 then
        XpOrb.globalComboTimer = XpOrb.globalComboTimer + dt
        if XpOrb.globalComboTimer > 0.3 then
            XpOrb.globalCombo = 0
            XpOrb.globalComboTimer = 0
        end
    end

end

function XpOrb:draw()
    love.graphics.setShader()
    for _, t in ipairs(self.trail) do
        love.graphics.setColor(1.0, 1.0, 0.3, t.time / 0.3)
        love.graphics.circle("fill", t.x, t.y, self.radius * 0.6)
    end
    
    self.pulseScale = 1 + 0.2 * math.sin(self.pulseTimer * self.pulseSpeed)
    local img = XpOrb.image
    local sx = (self.radius * 2 * self.pulseScale) / img:getWidth()
    local sy = (self.radius * 2 * self.pulseScale) / img:getHeight()

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(img, self.x, self.y, 0, sx, sy, img:getWidth() / 2, img:getHeight() / 2)

    love.graphics.setColor(1, 1, 1)
end



return XpOrb
