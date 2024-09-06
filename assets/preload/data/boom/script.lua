local gf = false

function onCreate()
    if not lowQuality then
        setProperty('skipCountdown', true)
    end
        makeLuaSprite('blammedLightsBlack', '', getPropertyFromClass('flixel.FlxG', 'width') * -0.5, getPropertyFromClass('flixel.FlxG', 'height') * -0.5)
        makeGraphic('blammedLightsBlack', getPropertyFromClass('flixel.FlxG', 'width') * 2, getPropertyFromClass('flixel.FlxG', 'height') * 2, '000000')
        setScrollFactor('blammedLightsBlack', 0)
        setProperty('blammedLightsBlack.scale.x', 5)
        setProperty('blammedLightsBlack.scale.y', 5)
        setProperty('blammedLightsBlack.alpha', 0.001)
        addLuaSprite('blammedLightsBlack', false)

    makeLuaSprite('hui', '', getPropertyFromClass('flixel.FlxG', 'width') * -0.5, getPropertyFromClass('flixel.FlxG', 'height') * -0.5)
	makeGraphic('hui', getPropertyFromClass('flixel.FlxG', 'width') * 2, getPropertyFromClass('flixel.FlxG', 'height') * 2, 'ff0000')
	setScrollFactor('hui', 0)
	setProperty('hui.scale.x', 5)
	setProperty('hui.scale.y', 5)
    setProperty('hui.alpha', 0.001)
	addLuaSprite('hui', false)
    
    if not lowQuality then
    precacheImage('flashback1')
    precacheImage('flashback2')
    precacheImage('flashback3')
    precacheImage('flashback4')
    precacheImage('flashback5')
    precacheImage('flashback6')
    precacheImage('flashback7')
    precacheImage('flashback8')

    makeLuaSprite('flex', 'boom_gitara', 50, 2000)
    setObjectCamera('flex', 'camhud')
    scaleObject('flex', 0.75, 0.75)
    addLuaSprite('flex', false)

    makeLuaSprite('flex2', 'boom_gitara', 850, 2000)
    setProperty('flex2.flipX', true)
    setObjectCamera('flex2', 'camhud')
    scaleObject('flex2', 0.75, 0.75)
    addLuaSprite('flex2', false)
    end
end

function onBeatHit()
    if not lowQuality then
     if gf == false then
        setProperty('flex.angle', 12)
        doTweenAngle('flexA', 'flex', 0, 0.5, 'quadout')
        setProperty('flex2.angle', -12)
        doTweenAngle('flexB', 'flex2', 0, 0.5, 'quadout')
        gf = true
     else
        setProperty('flex.angle', -12)
        doTweenAngle('flexA', 'flex', 0, 0.5, 'quadout')
        setProperty('flex2.angle', 12)
        doTweenAngle('flexB', 'flex2', 0, 0.5, 'quadout')
        gf = false
    end
end
end

function onCreatePost()
    makeAnimatedLuaSprite('hand', 'nelzya', 795, 300)
    addAnimationByPrefix('hand', 'raise', 'hand rise', 24, false)
    setObjectCamera('hand', 'camhud')
    addLuaSprite('hand', true)
    setProperty('hand.visible', false)
    if not lowQuality then
    makeLuaSprite('flashback', 'flashback1')
    setObjectCamera('flashback', 'camhud')
    setProperty('flashback.alpha', 0.0001)
    addLuaSprite('flashback', false)
    end
end

function onSongStart()
    setProperty('hand.visible', true)
    playAnim('hand', 'raise', true)
    runTimer('why', 4.18)
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'why' then
        setProperty('hand.visible', false) --for some reason it buggy after anim ends soooooo
    end
end

function onStepHit()
    if not lowQuality then
    if curStep == 1408 then
        doTweenAlpha('watafak', 'blammedLightsBlack', 0.7, 3)
    end

    if curStep == 1536 then
        setProperty('flashback.alpha', 0.3)
    end
    if curStep == 1552 then
        loadGraphic('flashback', 'flashback2')
    end
    if curStep == 1568 then
        loadGraphic('flashback', 'flashback3')
    end
    if curStep == 1584 then
        loadGraphic('flashback', 'flashback4')
    end
    if curStep == 1600 then
        loadGraphic('flashback', 'flashback5')
    end
    if curStep == 1608 then
        loadGraphic('flashback', 'flashback6')
    end
    if curStep == 1616 then
        loadGraphic('flashback', 'flashback7')
    end
    if curStep == 1624 then
        loadGraphic('flashback', 'flashback8')
    end
end
    if curStep == 1632 then
        doTweenAlpha('flashbackBye', 'flashback', 0, 0.5)
        doTweenAlpha('sex', 'blammedLightsBlack', 1, 2)
    end

    if curStep == 1664 then
        setProperty('blammedLightsBlack.alpha', 0)
        setProperty('hui.alpha', 1)
    end

    if curStep == 2176 then
        setProperty('hui.alpha', 0)
    end

    if curStep == 2720 then
        doTweenY('hui', 'flex', 200, 1, 'elasticout')
        doTweenY('pizda', 'flex2', 200, 1, 'elasticout')
    end

    if curStep == 2972 then
        doTweenY('hui', 'flex', 2000, 0.5, 'expoin')
        doTweenY('pizda', 'flex2', 2000, 0.5, 'expoin')
    end

    if curStep == 3056 then
        setProperty('blammedLightsBlack.alpha', 1)
        setProperty('camHUD.alpha')
    end

    if curStep == 3072 then
        setProperty('blammedLightsBlack.alpha', 0)
        doTweenAlpha('chlen', 'camHUD', 1, 0.67)
    end

    if curStep == 4096 then
        doTweenAlpha('sex', 'blammedLightsBlack', 1, 0.0001)
        doTweenAlpha('pokaHwaw', 'boyfriend', 1, 0.0001)
        doTweenX('perecZhmih', 'dad.scale', 3, 5)
        doTweenY('perecZhmihY', 'dad.scale', 0.1, 5)
        doTweenY('downJap', 'dad', 800, 5)
    end
end