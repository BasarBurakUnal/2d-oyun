-- Balanced Enemy Spawner (No Boss)

local Slime = require("Enemy/slime")
local Skeleton = require("Enemy/skeleton")
local FlyingDemon = require("Enemy/flying_demon")
local Undead = require("Enemy/undead")
local XpOrb = require("Player/xp_orb")
local ItemDropTable = require("Items.item_drop_table")
local Item = require("Items.item")

local EnemySpawner = {}
EnemySpawner.enemies = {}
EnemySpawner.orbs = {}
EnemySpawner.items = {}
EnemySpawner.spawnTimer = 0
EnemySpawner.spawnInterval = 1.0
EnemySpawner.waveTimer = 0
EnemySpawner.nextWaveTime = 10
EnemySpawner.waveSize = 10
EnemySpawner.timeSinceStart = 0
EnemySpawner.lastItemDropTime = 0
EnemySpawner.itemDropCooldown = 100
EnemySpawner.activeItemKeys = {}
EnemySpawner.lastPlayerPos = {x = 0, y = 0}
EnemySpawner.moveDir = {x = 0, y = 0}
EnemySpawner.wallSpawnTimer = 0

EnemySpawner.enemyTypes = {
    { class = Slime, unlockTime = 0 },
    { class = Skeleton, unlockTime = 20 },
    { class = FlyingDemon, unlockTime = 40 },
    { class = Undead, unlockTime = 60 }
}

function EnemySpawner:update(dt, player)
    if self.timeSinceStart == 0 then
        self:spawnInitialWave(player, 5)
    end

    self.spawnTimer = self.spawnTimer - dt
    self.waveTimer = self.waveTimer + dt
    self.timeSinceStart = self.timeSinceStart + dt

    if self.spawnTimer <= 0 then
        self:spawnSingle(player)
        self.spawnTimer = math.max(0.5, self.spawnInterval * math.exp(-self.timeSinceStart / 90))
    end

    if self.waveTimer >= self.nextWaveTime then
        self:spawnWave(player, math.floor(5 + self.timeSinceStart / 15))
        self.waveTimer = 0
        self.nextWaveTime = math.random(10, 20)
    end

    if not Player.timeStop.transitionActive then
        for i = #self.enemies, 1, -1 do
            local enemy = self.enemies[i]
            enemy:update(dt, player)
            if not enemy.alive and not enemy.counted then
                GameStats.enemiesKilled = GameStats.enemiesKilled + 1
                GameStats.enemiesByType[enemy.__type or "Unknown"] = 
                    (GameStats.enemiesByType[enemy.__type or "Unknown"] or 0) + 1
                enemy.counted = true
            end
            if not enemy.alive and enemy.currentAnim.status == "paused" then
                if not enemy.killedByBook then
                    local orb = XpOrb:new(enemy.x, enemy.y, enemy.xpValue, xpSound)
                    table.insert(self.orbs, orb)
                end
                if enemy.__type == "Undead" or enemy.__type == "Flying Demon" then
                    local currentTime = love.timer.getTime()
                    if currentTime - self.lastItemDropTime >= self.itemDropCooldown then
                        for _, drop in ipairs(ItemDropTable) do
                            if math.random() < drop.dropRate then
                                local item = Item:new(enemy.x, enemy.y, drop.scale, drop)
                                table.insert(self.items, item)
                                self.lastItemDropTime = currentTime
                                break
                            end
                        end
                    end
                end
                table.remove(self.enemies, i)
            end
        end
    end

    for i = #self.orbs, 1, -1 do
        local orb = self.orbs[i]
        orb:update(dt, player)
        if orb.collected then
            table.remove(self.orbs, i)
        end
    end

    for i = #self.items, 1, -1 do
        local item = self.items[i]
        item:update(dt, player)
        if item.collected then
            table.remove(self.items, i)
        end
    end

    local dx = player.x - self.lastPlayerPos.x
    local dy = player.y - self.lastPlayerPos.y
    local magnitude = math.sqrt(dx * dx + dy * dy)
    if magnitude > 0.1 then
        self.moveDir.x = dx / magnitude
        self.moveDir.y = dy / magnitude
    end
    self.lastPlayerPos.x = player.x
    self.lastPlayerPos.y = player.y

    self.wallSpawnTimer = self.wallSpawnTimer + dt
    if self.wallSpawnTimer > 10 then
        self.wallSpawnTimer = 0
        self:spawnWallAhead(player, 6, 80)
    end
end

function EnemySpawner:draw()
    for _, enemy in ipairs(self.enemies) do
        if enemy:isOnScreen(camera.x, camera.y, love.graphics.getWidth(), love.graphics.getHeight()) then
            enemy:draw()
        end
    end
    for _, orb in ipairs(self.orbs) do orb:draw() end
    for _, item in ipairs(self.items) do item:draw() end
end

function EnemySpawner:getAvailableEnemyTypes()
    local available = {}
    for _, e in ipairs(self.enemyTypes) do
        if self.timeSinceStart >= e.unlockTime then
            table.insert(available, e.class)
        end
    end
    return available
end

function EnemySpawner:pickRandomEnemy()
    local available = self:getAvailableEnemyTypes()
    local weighted = {}
    for _, enemyClass in ipairs(available) do
        local t = enemyClass.__type or tostring(enemyClass)
        if t == "Slime" then
            for _ = 1, 5 do table.insert(weighted, enemyClass) end
        elseif t == "Skeleton" then
            for _ = 1, 3 do table.insert(weighted, enemyClass) end
        else
            table.insert(weighted, enemyClass)
        end
    end
    return weighted[math.random(#weighted)]
end

function EnemySpawner:getOffscreenSpawnPos(player)
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    local margin = (self.timeSinceStart < 10) and 100 or 200
    local dir = math.random(1, 4)
    local px, py = player.x, player.y
    if dir == 1 then return px - screenW / 2 - margin, py + math.random(-screenH, screenH) end
    if dir == 2 then return px + screenW / 2 + margin, py + math.random(-screenH, screenH) end
    if dir == 3 then return px + math.random(-screenW, screenW), py - screenH / 2 - margin end
    return px + math.random(-screenW, screenW), py + screenH / 2 + margin
end

function EnemySpawner:spawnInitialWave(player, count)
    for i = 1, count do
        local angle = math.rad(math.random(0, 360))
        local x = player.x + math.cos(angle) * 1920
        local y = player.y + math.sin(angle) * 1080
        local enemy = self:pickRandomEnemy():new()
        enemy.x = x
        enemy.y = y
        table.insert(self.enemies, enemy)
    end
end

function EnemySpawner:spawnSingle(player)
    local x, y = self:getOffscreenSpawnPos(player)
    local enemy = self:pickRandomEnemy():new()
    enemy.x = x
    enemy.y = y
    table.insert(self.enemies, enemy)
end

function EnemySpawner:spawnWave(player, count)
    local baseX, baseY = self:getOffscreenSpawnPos(player)
    for i = 1, count do
        local enemy = self:pickRandomEnemy():new()
        enemy.x = baseX + (i % 5) * 60
        enemy.y = baseY + math.floor(i / 5) * 60
        table.insert(self.enemies, enemy)
    end
end

function EnemySpawner:spawnWallAhead(player, length, spacing)
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    local px, py = player.x, player.y
    local dirX, dirY = self.moveDir.x, self.moveDir.y
    if dirX == 0 and dirY == 0 then return end
    local spawnDist = math.max(screenW, screenH) / 2 + 200
    local centerX = px + dirX * spawnDist
    local centerY = py + dirY * spawnDist
    local normalX = -dirY
    local normalY = dirX
    for i = -length, length do
        local offsetX = normalX * i * spacing
        local offsetY = normalY * i * spacing
        local enemy = self:pickRandomEnemy():new()
        enemy.x = centerX + offsetX
        enemy.y = centerY + offsetY
        table.insert(self.enemies, enemy)
    end
end

return EnemySpawner