local chromOn = false;
local Chromacrap = 0;
local fire = false

function boundTo(value, min, max)
    return math.max(min, math.min(max, value))
end

function math.lerp(from,to,i)return from+(to-from)*i end

function lerp(a, b, ratio)
	return a + ratio * (b - a);
end

function onCreate()
    if not (shadersEnabled) then
        close()
    end
end

function onCreatePost()
    luaDebugMode = true
    initLuaShader("vcr")
    initLuaShader("radialBlur")
    
    makeLuaSprite("temporaryShader")
    makeGraphic("temporaryShader", screenWidth, screenHeight)
    
    setSpriteShader("temporaryShader", "vcr")

    makeLuaSprite("temporaryShader2")
    makeGraphic("temporaryShader2", screenWidth, screenHeight)
    
    setSpriteShader("temporaryShader2", "radialBlur")

    setShaderFloat('temporaryShader2','cx',0.5) --center x
	setShaderFloat('temporaryShader2','cy',0.5) --center y
	setShaderFloat('temporaryShader2','blurWidth',0)-- blur amount

    initLuaShader("sandstorm");
    makeLuaSprite("temporaryShader3");
    makeGraphic("temporaryShader3", screenWidth, screenHeight);
    setSpriteShader("temporaryShader3", "sandstorm");
    setShaderSampler2D('temporaryShader3', 'distortTexture', 'heatwave')

    makeLuaSprite('fullscreen', '',-1200,-900)
    setScrollFactor('fullscreen', 0, 0)
    makeGraphic('fullscreen', 3840, 2160, 'FF7700')
    addLuaSprite('fullscreen',true)
    setObjectCamera('fullscreen','other')
    setBlendMode('fullscreen','add')
    setProperty('fullscreen.alpha',0.0001)
end

function onBeatHit()
    if chromOn == true then
        Chromacrap = Chromacrap + 0.02 -- edit this
        setShaderFloat('temporaryShader2', 'blurWidth', getShaderFloat('temporaryShader2', 'blurWidth') + 0.07);
    end
end

function setChrome(chromeOffset)
    setShaderFloat("temporaryShader", "rOffset", chromeOffset);
    setShaderFloat("temporaryShader", "gOffset", 0.0);
    setShaderFloat("temporaryShader", "bOffset", chromeOffset * -1);
end

function onUpdate(elapsed)
    if chromOn == true then
        Chromacrap = math.lerp(Chromacrap, 0, boundTo(elapsed * 20, 0, 1))
        setChrome(Chromacrap)
        setShaderFloat('temporaryShader2','blurWidth', lerp(0, getShaderFloat('temporaryShader2', 'blurWidth'), 0.85));
    end
end

function onUpdatePost()
    if fire == true then
        setShaderFloat('temporaryShader3','iTime',os.clock()/2)
    end
end

function onSectionHit()
    if fire == true then
        setProperty('fullscreen.alpha',0.225)
        doTweenAlpha('bluebluebyebye','fullscreen',0.15,1)
    end
end

function onEvent(eventName, value1, value2)
    if eventName == 'fire boom' then        
        addHaxeLibrary("ShaderFilter", "openfl.filters");
        chromOn = true
        addHaxeLibrary("ShaderFilter", "openfl.filters")
        runHaxeCode([[
            game.camGame.setFilters([new ShaderFilter(game.getLuaObject("temporaryShader").shader), new ShaderFilter(game.getLuaObject("temporaryShader2").shader), new ShaderFilter(game.getLuaObject("temporaryShader3").shader)]);
            game.camHUD.setFilters([new ShaderFilter(game.getLuaObject("temporaryShader").shader), new ShaderFilter(game.getLuaObject("temporaryShader3").shader)]);
        ]])
        setProperty('fullscreen.alpha',0.195)
        fire = true;
    end
end

function onStepHit()
    if curStep == 1664 then
        chromOn = true
        addHaxeLibrary("ShaderFilter", "openfl.filters")
        runHaxeCode([[
            game.camGame.setFilters([new ShaderFilter(game.getLuaObject("temporaryShader").shader), new ShaderFilter(game.getLuaObject("temporaryShader2").shader)]);
            game.camHUD.setFilters([new ShaderFilter(game.getLuaObject("temporaryShader").shader)]);
        ]])
    end
    if curStep == 2176 then
        chromOn = false
        addHaxeLibrary("ShaderFilter", "openfl.filters")
        runHaxeCode([[
            game.camGame.setFilters([]);
            game.camHUD.setFilters([]);
        ]])
    end
    if curStep == 3840 then
        addHaxeLibrary("ShaderFilter", "openfl.filters");
        runHaxeCode([[
            game.camGame.setFilters([new ShaderFilter(game.getLuaObject("temporaryShader3").shader)]);
            game.camHUD.setFilters([new ShaderFilter(game.getLuaObject("temporaryShader3").shader)]);
        ]]);
        chromOn = false
    end
    if curStep == 4096 then
        addHaxeLibrary("ShaderFilter", "openfl.filters");
        runHaxeCode([[
            game.camGame.setFilters([]);
            game.camHUD.setFilters([]);
        ]]);
        setProperty('fullscreen.alpha',0)
        fire = false;
    end
end