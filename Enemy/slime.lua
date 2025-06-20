local Enemy = require("Enemy/enemy")

local Slime = {}
Slime.__index = Slime
setmetatable(Slime, { __index = Enemy })

function Slime:new()
    local self = setmetatable({}, Slime)
    Slime.__type = "Slime"

    local sprite = love.graphics.newImage("Enemy/Assets/slime_sheet.png")
    local frameW, frameH = 32, 25

    Enemy.init(self, sprite, frameW, frameH, '1-8', '1-5', 1, 3)

    -- Slime stats
    self.speed = 90
    self.hp = 5
    self.damage = 0.02
    self.xpValue = 5

    self.scale = 2
    self.flipDirection = true

    return self
end

function Slime:update(dt, player)
    Enemy.update(self, dt, player)

    if not self.alive and self.currentAnim ~= self.animations.death then
        self.currentAnim = self.animations.death
        self.currentAnim:gotoFrame(1)
    end
end

return Slime
