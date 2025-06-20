local Item = {}
Item.__index = Item

function Item:new(x, y, scale, data)
    local self = setmetatable({}, Item)
    self.x = x
    self.y = y
    self.scale = scale
    self.sprite = data.sprite
    self.effect = data.effect
    self.collected = false
    self.radius = 20
    self.tracking = false
    self.trackingDuration = 0
    self.baseSpeed = 100
    self.acceleration = 100
    self.maxSpeed = 800
    
    if not Item.shader then
        Item.shader = love.graphics.newShader("Shaders/item_shader.glsl")
    end

    return self

end

function Item:update(dt, player)
    local px = player.x + player.width / 2
    local py = player.y + player.height / 2

    local dx = px - self.x
    local dy = py - self.y
    local dist = math.sqrt(dx * dx + dy * dy)

    if not self.tracking and dist < player.xpRadius then
        self.tracking = true
    end

    if self.tracking then
        self.trackingDuration = self.trackingDuration + dt
        local speed = math.min(self.baseSpeed + self.trackingDuration * self.acceleration, self.maxSpeed)
        local dirX = dx / dist
        local dirY = dy / dist
        self.x = self.x + dirX * speed * dt
        self.y = self.y + dirY * speed * dt
    end

    if dist < 10 then
        self.collected = true
        self.effect(player)
    end
end


function Item:draw()
    love.graphics.setShader(Item.shader)
    Item.shader:send("time", love.timer.getTime())

    local ox = self.sprite:getWidth() / 2
    local oy = self.sprite:getHeight() / 2

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.sprite, self.x, self.y, 0, self.scale, self.scale, ox, oy)

    love.graphics.setShader()
end


return Item
