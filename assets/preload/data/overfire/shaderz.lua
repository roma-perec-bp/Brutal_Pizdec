local fire = false

function onCreatePost()
    if (shadersEnabled) then
        initLuaShader("sandstorm");
        makeLuaSprite("temporaryShader");
        makeGraphic("temporaryShader", screenWidth, screenHeight);
        setSpriteShader("temporaryShader", "sandstorm");
        setShaderSampler2D('temporaryShader', 'distortTexture', 'heatwave')
    end

    makeLuaSprite('fullscreen', '',-1200,-900)
    setScrollFactor('fullscreen', 0, 0)
    makeGraphic('fullscreen', 3840, 2160, 'FF7700')
    addLuaSprite('fullscreen',true)
    setObjectCamera('fullscreen','other')
    setBlendMode('fullscreen','add')
    setProperty('fullscreen.alpha',0.0001)
end

function onUpdatePost()
    if fire == true then
        setShaderFloat('temporaryShader','iTime',os.clock()/2)
    end
end

function onEvent(eventName, value1, value2)
    if eventName == 'fire boom' then        
        if (shadersEnabled) then
            addHaxeLibrary("ShaderFilter", "openfl.filters");
            runHaxeCode([[
                game.camGame.setFilters([new ShaderFilter(game.getLuaObject("temporaryShader").shader)]);
                game.camHUD.setFilters([new ShaderFilter(game.getLuaObject("temporaryShader").shader)]);
            ]]);
        end
        setProperty('fullscreen.alpha',0.195)
        fire = true;
    end

    if eventName == 'end' then        
        runHaxeCode([[
            game.camGame.setFilters([]);
             game.camHUD.setFilters([]);
        ]]);
        fire = false
        setProperty('fullscreen.visible',false)
    end
end

function onSectionHit()
    if fire == true then
        setProperty('fullscreen.alpha',0.225)
        doTweenAlpha('bluebluebyebye','fullscreen',0.15,1)
    end
end