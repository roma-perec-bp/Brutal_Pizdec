local gfAss = false

function onCreate()
    setProperty('skipCountdown', true)

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

function onCreatePost()
    setCharacterX('dad', -200)
end

function onBeatHit()
    if curBeat == 16 then
        doTweenX('onidet', 'dad', 300, 3, 'quadInOut')
    end

    if curBeat >= 209 and curBeat < 336 then
        if gfAss == false then
            doTweenAngle('cameraBop1', 'camGame', 10, stepCrochet*0.002, 'quadOut')
            gfAss = true
        else
            doTweenAngle('cameraBop2', 'camGame', -10, stepCrochet*0.002, 'quadOut')
            gfAss = false
        end
    end

    if curBeat == 336 then
        doTweenAngle('backCamGay', 'camGame', 0, 1, 'quadOut')
        doTweenAlpha('watafak', 'blammedLightsBlack', 1, 3)
    end

    if curBeat == 352 then
        doTweenX('opa', 'dad', 500, 1, 'quadInOut')
        doTweenX('2opa', 'boyfriend', 1350, 1, 'quadInOut')
    end

    if curBeat == 384 then
        doTweenAlpha('watafak', 'blammedLightsBlack', 0.001, 1)
        doTweenX('obratno', 'dad', 300, 3, 'quadInOut')
        doTweenX('obratnonahi', 'boyfriend', 1750, 3, 'quadInOut')
    end

    if curBeat == 448 then
        doTweenAlpha('pizda', 'blammedLightsBlack', 1, 3)
        doTweenAlpha('blacks', 'blackScreenSonicCount', 1, 3)
    end

    if curBeat == 460 then
        doTweenAlpha('aaaaa', 'blackScreenSonicCount', 0, 1)
    end

    if curBeat == 464 then
        doTweenAlpha('po', 'blammedLightsBlack', 0, 0.5)
    end

    if curBeat == 665 then
        setProperty('blackScreenSonicCount.alpha', 1)
    end
end