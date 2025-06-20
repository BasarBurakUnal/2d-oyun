local Enemy = require("Enemy/enemy")

local FlyingDemon = {}
FlyingDemon.__index = FlyingDemon
setmetatable(FlyingDemon, { __index = Enemy })

function FlyingDemon:new()
    local self = setmetatable({}, FlyingDemon)
    FlyingDemon.__type = "Flying Demon"

    local sprite = love.graphics.newImage("Enemy/Assets/flyingdemon_sheet.png")
    local frameW, frameH = 81, 71

    Enemy.init(self, sprite, frameW, frameH, '1-4', '1-6', 2, 1)

    -- Flying Demon stats
    self.speed = 120
    self.hp = 25
    self.damage = 0.10
    self.xpValue = 20

    self.scale = 1.5
    self.flipDirection = true

    return self
end

function FlyingDemon:update(dt, player)
    Enemy.update(self, dt, player)

    if not self.alive and self.currentAnim ~= self.animations.death then
        self.currentAnim = self.animations.death
        self.currentAnim:gotoFrame(1)
    end
end

return FlyingDemon
