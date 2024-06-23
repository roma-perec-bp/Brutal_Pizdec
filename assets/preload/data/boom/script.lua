function onCreate()
    setProperty('skipCountdown', true)

    makeLuaSprite('blammedLightsBlack', '', getPropertyFromClass('flixel.FlxG', 'width') * -0.5, getPropertyFromClass('flixel.FlxG', 'height') * -0.5)
	makeGraphic('blammedLightsBlack', getPropertyFromClass('flixel.FlxG', 'width') * 2, getPropertyFromClass('flixel.FlxG', 'height') * 2, '000000')
	setScrollFactor('blammedLightsBlack', 0)
	setProperty('blammedLightsBlack.scale.x', 5)
	setProperty('blammedLightsBlack.scale.y', 5)
    setProperty('blammedLightsBlack.alpha', 0.001)
	addLuaSprite('blammedLightsBlack', false)

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
end

function onCreatePost()
    makeAnimatedLuaSprite('hand', 'nelzya', 795, 300)
    addAnimationByPrefix('hand', 'raise', 'hand rise', 24, false)
    setObjectCamera('hand', 'camhud')
    addLuaSprite('hand', true)
    setProperty('hand.visible', false)
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
    if curStep == 1408 then
        doTweenAlpha('watafak', 'blammedLightsBlack', 0.7, 3)
    end

    if curStep == 1536 then
        makeLuaSprite('flashback', 'flashback1')
        setObjectCamera('flashback', 'camhud')
        setProperty('flashback.alpha', 0.3)
        addLuaSprite('flashback', false)
    end
    if curStep == 1552 then
        makeLuaSprite('flashback', 'flashback2')
        setObjectCamera('flashback', 'camhud')
        setProperty('flashback.alpha', 0.3)
        addLuaSprite('flashback', false)
    end
    if curStep == 1568 then
        makeLuaSprite('flashback', 'flashback3')
        setObjectCamera('flashback', 'camhud')
        setProperty('flashback.alpha', 0.3)
        addLuaSprite('flashback', false)
    end
    if curStep == 1584 then
        makeLuaSprite('flashback', 'flashback4')
        setObjectCamera('flashback', 'camhud')
        setProperty('flashback.alpha', 0.3)
        addLuaSprite('flashback', false)
    end
    if curStep == 1600 then
        makeLuaSprite('flashback', 'flashback5')
        setObjectCamera('flashback', 'camhud')
        setProperty('flashback.alpha', 0.3)
        addLuaSprite('flashback', false)
    end
    if curStep == 1608 then
        makeLuaSprite('flashback', 'flashback6')
        setObjectCamera('flashback', 'camhud')
        setProperty('flashback.alpha', 0.3)
        addLuaSprite('flashback', false)
    end
    if curStep == 1616 then
        makeLuaSprite('flashback', 'flashback7')
        setObjectCamera('flashback', 'camhud')
        setProperty('flashback.alpha', 0.3)
        addLuaSprite('flashback', false)
    end
    if curStep == 1624 then
        makeLuaSprite('flashback', 'flashback8')
        setObjectCamera('flashback', 'camhud')
        setProperty('flashback.alpha', 0.3)
        addLuaSprite('flashback', false)
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
end