function onCreate()
    makeLuaSprite('blammedLightsBlack', '', getPropertyFromClass('flixel.FlxG', 'width') * -0.5, getPropertyFromClass('flixel.FlxG', 'height') * -0.5)
	makeGraphic('blammedLightsBlack', getPropertyFromClass('flixel.FlxG', 'width') * 2, getPropertyFromClass('flixel.FlxG', 'height') * 2, '000000')
	setScrollFactor('blammedLightsBlack', 0)
	setProperty('blammedLightsBlack.scale.x', 5)
	setProperty('blammedLightsBlack.scale.y', 5)
    setProperty('blammedLightsBlack.alpha', 0.001)
	addLuaSprite('blammedLightsBlack', false)

    makeLuaSprite('blackScreenSonicCount','',0,0)
    setObjectCamera('blackScreenSonicCount','hud')
    makeGraphic('blackScreenSonicCount',screenWidth,screenHeight,'000000')
    setProperty('blackScreenSonicCount.alpha', 0.001)
    addLuaSprite('blackScreenSonicCount',false)
end

function onBeatHit()
    if curBeat == 368 then
        setProperty('blackScreenSonicCount.alpha', 1)
    end
    if curBeat == 376 then
        setProperty('blackScreenSonicCount.alpha', 0)
    end
    if curBeat == 600 then
        setProperty('blackScreenSonicCount.alpha', 1)
        cameraFlash('camhud', '0xFFFFFFFF', 1)
    end
    if curBeat == 608 then
        setProperty('blackScreenSonicCount.alpha', 0)
    end
    if curBeat == 752 then
        setProperty('blackScreenSonicCount.alpha', 1)
        setProperty('blammedLightsBlack.alpha', 1)
        setProperty('dad.color', getColorFromHex('FF2a1c4d'))
        setProperty('boyfriend.color', getColorFromHex('FF2a1c4d'))
        setProperty('gf.color', getColorFromHex('FF2a1c4d'))
        cameraFlash('camhud', '0xFFFFFFFF', 1)
    end
    if curBeat == 756 then
        doTweenAlpha('sex', 'blackScreenSonicCount', 0, 10)
    end

    if curBeat == 816 then
        doTweenAlpha('sex1', 'blammedLightsBlack', 0, 20)
        doTweenColor('dad', 'dad', 'ffffff', 20)
        doTweenColor('gf', 'gf', 'ffffff', 20)
        doTweenColor('bf', 'boyfriend', 'ffffff', 20)
    end

    if curBeat == 872 then
        cameraFade('camhud', '000000', 2)
    end
end