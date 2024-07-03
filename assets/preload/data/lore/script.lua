function onCreate()
    makeLuaSprite('blammedLightsBlack', '', getPropertyFromClass('flixel.FlxG', 'width') * -0.5, getPropertyFromClass('flixel.FlxG', 'height') * -0.5)
	makeGraphic('blammedLightsBlack', getPropertyFromClass('flixel.FlxG', 'width') * 2, getPropertyFromClass('flixel.FlxG', 'height') * 2, '000000')
	setScrollFactor('blammedLightsBlack', 0)
	setProperty('blammedLightsBlack.scale.x', 5)
	setProperty('blammedLightsBlack.scale.y', 5)
    setProperty('blammedLightsBlack.alpha', 0.001)
	addLuaSprite('blammedLightsBlack', false)

    makeLuaSprite('blackFlash', nil, 0, 0)
    makeGraphic('blackFlash', 1280, 720, '000000')
    setObjectCamera('blackFlash', 'camhud')
    addLuaSprite('blackFlash', false)

    setProperty('rom.alpha', 0.0001)
    setProperty('iconROM.visible', false)
    setProperty('iconGF.alpha', 0.0001)

    setProperty('gf.alpha', 0.001)
end

function onCreatePost()
    makeLuaSprite('pizdec', 'hornyJump')
    setObjectCamera('pizdec', 'camhud')
    setProperty('pizdec.alpha', 0.0001)
    addLuaSprite('pizdec', false)
end

function onBeatHit()
    if curBeat == 1 then
        doTweenAlpha('suka','blackFlash', 0, 40, 'quardOut')
    end
    if curBeat == 144 then
        setProperty('pizdec.alpha', 1)
        doTweenAlpha('pizdec','pizdec', 0, 1, 'bounceOut')
    end
    if curBeat == 320 then
        makeAnimatedLuaSprite('hwaw', 'characters/oink_guy_cuts', defaultBoyfriendX + 150, defaultBoyfriendY + 100)
        addAnimationByPrefix('hwaw', 'scary', 'scary', 24, false)
        addAnimationByPrefix('hwaw', 'shot', 'shot', 24, true)
        addLuaSprite('hwaw', false)
        scaleObject('hwaw', 0.75, 0.75)
        playAnim('hwaw', 'scary', true)
        doTweenX('wayy', 'hwaw', defaultBoyfriendX + 350, 0.6, 'quadout')
    end
    if curBeat == 335 then
        doTweenX('nahui', 'hwaw', defaultBoyfriendX + 200, 0.6, 'quadout')
    end
    if curBeat == 336 then
        playAnim('hwaw', 'shot', true)
    end
    if curBeat == 344 then
        removeLuaSprite('hwaw')
    end
    if curBeat == 352 then
        setProperty('blackFlash.alpha', 1)
        doTweenAlpha('suka','blackFlash', 0, 20, 'quardOut')
    end
    if curBeat == 448 then
        makeAnimatedLuaSprite('romy', 'rom_coming', defaultOpponentX - 500, defaultOpponentY)
        addAnimationByPrefix('romy', 'cut', 'cutscene', 24, false)
        addLuaSprite('romy', false)
        scaleObject('romy', 0.75, 0.75)
        playAnim('romy', 'cut', true)
        doTweenX('romocoming', 'romy', defaultOpponentX + 200, 5, 'quadout')
    end
    if curBeat == 480 then
        setProperty('blammedLightsBlack.alpha', 1)
        setProperty('dad.visible', false)
        setProperty('boyfriend.visible', false)
        doTweenAlpha('privet', 'rom', 1, 0.7)
        removeLuaSprite('romy')
    end
    if curBeat == 482 then
        setProperty('blammedLightsBlack.alpha', 0)
        setProperty('dad.visible', true)
        setProperty('boyfriend.visible', true)
        setProperty('iconROM.visible', true)
        setProperty('iconROM.angle', -25)
        doTweenAngle('sex', 'iconROM', 0, 0.5, 'elasticOut')
    end
    if curBeat == 598 then
        doTweenAlpha('random','gf', 1, 5)
        doTweenAlpha('boobs','iconGF', 1, 5)
    end
    if curBeat == 736 then
        setProperty('blammedLightsBlack.alpha', 1)
    end
    if curBeat == 746 then
        doTweenAlpha('suka','blackFlash', 1, 25, 'linear')
    end
end