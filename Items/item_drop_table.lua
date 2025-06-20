local ItemDropTable = {

    { name = "Health Potion",
    dropRate = 0.05,
    sprite = love.graphics.newImage("Items/Assets/pepperoni.png"),
    scale = 2,
    effect = function(player)
        -- player.healSound:play()
        player.hp = math.min(player.maxHp, player.hp + 50)
        player.healFlashTimer = player.healFlashDuration
    end },

    {
        name = "Xp Collector",
        dropRate = 0.05,
        sprite = love.graphics.newImage("Items/Assets/shard.png"),
        scale = 2,
        effect = function(player)
            for _, orb in ipairs(EnemySpawner.orbs) do
                orb.tracking = true
                orb.trackingDuration = 0.5
            end
        end
    },

}

return ItemDropTable
