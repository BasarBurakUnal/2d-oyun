local Enemy = require("Enemy/enemy")

local Undead = {}
Undead.__index = Undead
setmetatable(Undead, { __index = Enemy })

function Undead:new()
    local self = setmetatable({}, Undead)
    Undead.__type = "Undead"

    local sprite = love.graphics.newImage("Enemy/Assets/death-export.png")
    local frameW, frameH = 100, 100

    Enemy.init(self, sprite, frameW, frameH, '1-8', '1-18', 2, 1)

    -- Undead stats
    self.speed = 60
    self.hp = 40
    self.damage = 0.30
    self.xpValue = 40

    self.scale = 3
    self.flipDirection = false

    return self
end

function Undead:update(dt, player)
    Enemy.update(self, dt, player)

    if not self.alive and self.currentAnim ~= self.animations.death then
        self.currentAnim = self.animations.death
        self.currentAnim:gotoFrame(1)
    end
end

return Undead
