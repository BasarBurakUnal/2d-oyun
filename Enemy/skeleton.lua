local Enemy = require("Enemy/enemy")

local Skeleton = {}
Skeleton.__index = Skeleton
setmetatable(Skeleton, { __index = Enemy })

function Skeleton:new()
    local self = setmetatable({}, Skeleton)
    Skeleton.__type = "Skeleton"

    local sprite = love.graphics.newImage("Enemy/Assets/skeleton_sheet.png")
    local frameW, frameH = 48, 48

    Enemy.init(self, sprite, frameW, frameH, '1-12', '1-12', 1, 2)

    -- Skeleton stats
    self.speed = 100
    self.hp = 15
    self.damage = 0.05
    self.xpValue = 10

    self.scale = 2

    return self
end

function Skeleton:update(dt, player)
    Enemy.update(self, dt, player)

    if not self.alive and self.currentAnim ~= self.animations.death then
        self.currentAnim = self.animations.death
        self.currentAnim:gotoFrame(1)
    end
end

return Skeleton
