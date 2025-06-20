local UI = require("ui")
push = require "lib/push"
Player = require "Player/player"
camera = require "lib/camera"
EnemySpawner = require "Enemy/enemy_spawner"
local ui

math.randomseed(os.time())

local WINDOW_WIDTH, WINDOW_HEIGHT = love.window.getDesktopDimensions()
VIRTUAL_WIDTH = WINDOW_WIDTH
VIRTUAL_HEIGHT = WINDOW_HEIGHT

GameState = {
    MENU = "menu",
    PLAYING = "playing",
    PAUSED = "paused",
    DEAD = "dead",
    SETTINGS = "settings",
    LEVEL = "level"
}

GameStats = {
    enemiesKilled = 0,
    xpCollected = 0,
    enemiesByType = {},
    timeSurvived = 0,
    timeStopped = 0,
    wingBonusPercent = 0,
    lionHeartHealed = 0,
    enemiesKilledByWeapon = {}
}

function GameStats:reset()
    self.enemiesKilled = 0
    self.xpCollected = 0
    self.timeSurvived = 0
    self.enemiesByType = {}
    self.timeStopped = 0
    self.wingBonusPercent = 0
    self.lionHeartHealed = 0
    self.enemiesKilledByWeapon = {}
end

function love.load()
    timeStopShader = love.graphics.newShader("Shaders/timestop_shader.glsl")
    bookShader = love.graphics.newShader("Shaders/book_shader.glsl")
    menuBgShader = love.graphics.newShader("Shaders/menu_background.glsl")
    sceneCanvas = love.graphics.newCanvas(VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
    ui = UI:new()
    ui:setState(GameState.MENU)

    music = love.audio.newSource("Assets/music/out_of_body_loop.mp3", "stream")
    music:setLooping(true)
    music:setVolume(0.5)

    music_effect = love.audio.newSource("Assets/music/out_of_body_pause.mp3", "stream")
    music_effect:setLooping(true)
    music_effect:setVolume(0.5)

    menuMusic = love.audio.newSource("Assets/music/out_of_what.mp3", "stream")
    menuMusic:setLooping(true)
    menuMusic:setVolume(0.5)

    xpSound = love.audio.newSource("Player/Assets/Sounds/xpsound.ogg", "static")

    love.graphics.setDefaultFilter("nearest", "nearest")
    defaultFont = love.graphics.newFont("Assets/font/pixelfont.ttf", 32)
    xsFont = love.graphics.newFont("Assets/font/pixelfont.ttf", 15)
    love.graphics.setFont(defaultFont)
    spaceShader = love.graphics.newShader("Shaders/space_shader.glsl")
    nebulaShader = love.graphics.newShader("Shaders/nebula_shader.glsl")

    cam = camera()

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true,
        canvas = true,
        pixelperfect = true
    })

    Player:load(ui)
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    ui:update(dt)
    if ui.state == GameState.MENU  or ui.state == GameState.SETTINGS then
        if not menuMusic:isPlaying() then
            menuMusic:play()
        end
        music:stop()
        music_effect:stop()
        menuBgShader:send("iTime", love.timer.getTime())
        menuBgShader:send("iResolution", {love.graphics.getWidth(), love.graphics.getHeight(), 1.0})
    end
    
    music:setVolume(ui.musicVolume)
    music_effect:setVolume(ui.musicVolume)
    menuMusic:setVolume(ui.musicVolume)
    xpSound:setVolume(ui.sfxVolume)
    Player.guardianAngel.sound:setVolume(ui.sfxVolume)
    Player.hitSound:setVolume(ui.sfxVolume)
    Player.lightning.sound:setVolume(ui.sfxVolume)
    Player.whip.sound:setVolume(ui.sfxVolume)
    Player.healSound:setVolume(ui.sfxVolume)
    Player.timeStop.sound:setVolume(ui.sfxVolume)
    Player.book.sound:setVolume(ui.sfxVolume)

    if ui.state == GameState.PLAYING or ui.state == GameState.LEVEL then
        Player:LevelUpAnim(dt)
    end
    
    if ui.state == GameState.PLAYING then
        if menuMusic:isPlaying() then
            menuMusic:stop()
        end
        if music_effect:isPlaying() then
            local musicCurrentPos = music_effect:tell()
            music_effect:pause()
            music:seek(musicCurrentPos)
            music:play()
        end
        love.mouse.setVisible(false)
        if not music:isPlaying() then
            music:play()
        end
        GameStats.wingBonusPercent = Player.wing.level * 10
        camera.x = Player.x + Player.width / 2 - love.graphics.getWidth() / 2
        camera.y = Player.y + Player.height / 2 - love.graphics.getHeight() / 2

        EnemySpawner:update(dt, Player)

        Player:update(dt, EnemySpawner.enemies)
        cam:lookAt(Player.x + Player.width / 2, Player.y + Player.height / 2)
        if Player.deathAnimDone and music:isPlaying() then
                music:stop()
            end
        if Player.deathAnimDone then
            GameStats.timeSurvived = EnemySpawner.timeSinceStart
           ui:setState(GameState.DEAD)
        end
    elseif ui.state == GameState.LEVEL then
        love.mouse.setVisible(true)
        if music:isPlaying() then
            local musicCurrentPos = music:tell()
            music:pause()
            music_effect:seek(musicCurrentPos)
            music_effect:play()
        end
    else
        love.mouse.setVisible(true)
    end
end

function love.draw()
    love.graphics.setCanvas(sceneCanvas)
    love.graphics.clear()

    if ui.state == GameState.MENU or ui.state == GameState.SETTINGS then
        love.graphics.setShader(menuBgShader)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setShader()
        music:stop()
    end

    if ui.state ~= GameState.MENU and ui.state ~= GameState.SETTINGS then
        love.graphics.setShader(spaceShader)
        spaceShader:send("time", love.timer.getTime())
        spaceShader:send("cameraPos", {camera.x, camera.y})
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setShader()

        love.graphics.setShader(nebulaShader)
        nebulaShader:send("time", love.timer.getTime())
        nebulaShader:send("cameraPos", {camera.x, camera.y})
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setShader()

        cam:attach()
        EnemySpawner:draw()
        Player:draw()
        cam:detach()

        Player:drawXpBar()
    end

    ui:draw()

    love.graphics.setCanvas()

    Player:drawTimeStopEffect(sceneCanvas)
    Player:drawBookEffect(sceneCanvas)

    push:start()
    love.graphics.draw(sceneCanvas, 0, 0)
    love.graphics.setShader()
    push:finish()

    if ui.state == GameState.PLAYING or ui.state == GameState.LEVEL and not Player.frozen then
        Player:drawLevelUpText()
    end
    love.graphics.setFont(xsFont)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
    love.graphics.setFont(defaultFont)
end

function love.mousereleased(x, y, button)
    if button == 1 and ui then
        ui:mousereleased(x, y)
    end
end

function love.mousepressed(x, y, button)
    if button == 1 and ui then
        ui:mousepressed(x, y)
    end
end

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        if ui.state == GameState.SETTINGS then
            ui:setState(GameState.MENU)
        elseif ui.state == GameState.PLAYING then
            ui:setState(GameState.PAUSED)
            local musicPos = music:tell()
            music:pause()
            if not music_effect:isPlaying() then
                music_effect:seek(musicPos)
                music_effect:play()
            end
        elseif ui.state == GameState.PAUSED then
            ui:setState(GameState.PLAYING)
            local musicPos = music_effect:tell()
            music_effect:pause()
            music:seek(musicPos)
            music:play()
        end
    end
    -- if key == "k" then
    --     Player:takeDamage(40)
    -- end
    -- if key == "m" then
    --     ui:setState(GameState.MENU)
    -- end
    -- if key == "t" then
    --     Player.timeStop.level = 1
    --     Player:activateTimeStop()
    -- end
    -- if key == "o" then
    --     Player.book.level = 1
    --     Player:activateBook(EnemySpawner.enemies)
    -- end
    -- if key == "j" then
    --     Player:addXp(40)
    -- end
    -- if key == "r" then
    --     Player.guardianAngel.level = 1
    -- end
end