local canDrain = false

function opponentNoteHit(membersIndex, noteData, noteType, isSustainNote)
    if canDrain == true then
        if isSustainNote == false then
            if getHealth() - 0.015 > 0.05 then addHealth(-0.015) end
        end
    end
end

function onCreate()
    if getPropertyFromClass('backend.ClientPrefs','data.optimize') == false then
    makeLuaSprite('blammedLightsBlack', '', getPropertyFromClass('flixel.FlxG', 'width') * -0.5, getPropertyFromClass('flixel.FlxG', 'height') * -0.5)
	makeGraphic('blammedLightsBlack', getPropertyFromClass('flixel.FlxG', 'width') * 2, getPropertyFromClass('flixel.FlxG', 'height') * 2, '000000')
	setScrollFactor('blammedLightsBlack', 0)
	setProperty('blammedLightsBlack.scale.x', 5)
	setProperty('blammedLightsBlack.scale.y', 5)
    setProperty('blammedLightsBlack.alpha', 0.001)
	addLuaSprite('blammedLightsBlack', false)
	
    makeLuaSprite('red', '', getPropertyFromClass('flixel.FlxG', 'width') * -0.5, getPropertyFromClass('flixel.FlxG', 'height') * -0.5)
	makeGraphic('red', getPropertyFromClass('flixel.FlxG', 'width') * 2, getPropertyFromClass('flixel.FlxG', 'height') * 2, 'ff0000')
	setScrollFactor('red', 0)
	setProperty('red.scale.x', 5)
	setProperty('red.scale.y', 5)
    setProperty('red.alpha', 0.001)
	addLuaSprite('red', false)
    end
end

function onCreatePost()
    if getPropertyFromClass('backend.ClientPrefs','data.optimize') == false then
    makeLuaSprite('endScre', nil, 0, 0)
    makeGraphic('endScre', 1280, 720, '000000')
    setObjectCamera('endScre', 'hud')
    addLuaSprite('endScre', true)
    setProperty('endScre.alpha', 0.001)
  
    makeLuaSprite('zrya', 'zrya')
    setObjectCamera('zrya', 'camhud')
    setProperty('zrya.alpha', 0.0001)
    screenCenter('zrya', 'xy')
    addLuaSprite('zrya', false)
  
    makeLuaSprite('edn', 'end')
    setObjectCamera('edn', 'camhud')
    setProperty('edn.alpha', 0.0001)
    screenCenter('edn', 'xy')
    addLuaSprite('edn', true)
    end
end

function onCountdownStarted()
    if getPropertyFromClass('backend.ClientPrefs','data.optimize') == false then
    setProperty('blammedLightsBlack.alpha', 1)setProperty('blammedLightsBlack.alpha', 1)
    end
end

function onStepHit()
    if curStep == 16 then
        setProperty('boyfriend.alpha', 0.0001)
    end
    if curStep == 48 then
        if getPropertyFromClass('backend.ClientPrefs','data.optimize') == false then  setProperty('red.alpha', 1) end
        setProperty('dadGroup.color', getColorFromHex('000000'))
    end
    if curStep == 64 then
        if getPropertyFromClass('backend.ClientPrefs','data.optimize') == false then setProperty('red.alpha', 0) end
        setProperty('blammedLightsBlack.alpha', 0.0001)
        setProperty('boyfriend.alpha', 1)
        setProperty('dadGroup.color', getColorFromHex('FFFFFF'))
    end
    if curStep == 192 then
        canDrain = true
    end
    if curStep == 704 then
        if getPropertyFromClass('backend.ClientPrefs','data.optimize') == false then doTweenAlpha('pizdos', 'blammedLightsBlack', 0.6, 1) end
    end
    if curStep == 816 then
        if getPropertyFromClass('backend.ClientPrefs','data.optimize') == false then
        setProperty('red.alpha', 1)
        setProperty('blammedLightsBlack.alpha', 1)
        end
        setProperty('dadGroup.color', getColorFromHex('000000'))
    end
    if getPropertyFromClass('backend.ClientPrefs','data.optimize') == false then
    if curStep == 824 then
        setProperty('red.alpha', 0)
    end
    if curStep == 826 then
        setProperty('red.alpha', 1)
    end
    if curStep == 828 then
        setProperty('red.alpha', 0)
    end
    if curStep == 829 then
        setProperty('red.alpha', 1)
    end
    if curStep == 830 then
        setProperty('red.alpha', 0)
    end
    if curStep == 831 then
        setProperty('red.alpha', 1)
    end
end
    if curStep == 832 then
        if getPropertyFromClass('backend.ClientPrefs','data.optimize') == false then
        setProperty('red.alpha', 0)
        setProperty('blammedLightsBlack.alpha', 0)
        end
        setProperty('dadGroup.color', getColorFromHex('FFFFFF'))
    end
    if curStep == 1344 then
        if getPropertyFromClass('backend.ClientPrefs','data.optimize') == false then setProperty('blammedLightsBlack.alpha', 0) end
    end
    if curStep == 1600 then
        canDrain = false
    end
    if curStep == 3008 then
        setProperty('dad.alpha', 0)
    end  
    if curStep == 3009 then
        doTweenColor('oh', 'boyfriend', '44145f', 0.001)
    end  
    if curStep == 3520 then
        canDrain = true
    end  
    if curStep == 3552 then
        if getPropertyFromClass('backend.ClientPrefs','data.optimize') == false then setProperty('blammedLightsBlack.alpha', 1) end
        doTweenColor('he is no black or wtf', 'boyfriend', 'FFFFFF', 0.001) --пидорас тупой блятьь
        setProperty('dad.alpha', 1)
    end 
    if curStep == 3584 then
        if getPropertyFromClass('backend.ClientPrefs','data.optimize') == false then setProperty('blammedLightsBlack.alpha', 0) end
    end
    if curStep == 4096 then
        if getPropertyFromClass('backend.ClientPrefs','data.optimize') == false then  doTweenAlpha('watafuk', 'blammedLightsBlack', 1, 3) end
    end
    if curStep == 4208 then
        if getPropertyFromClass('backend.ClientPrefs','data.optimize') == false then doTweenAlpha('doveli', 'zrya', 1, 1) end
    end
    if curStep == 4224 then
        if getPropertyFromClass('backend.ClientPrefs','data.optimize') == false then
        setProperty('zrya.alpha',0)
        setProperty('blammedLightsBlack.alpha', 0)
        end
        canDrain = false
    end
    if curStep == 4480 then
        setProperty('boyfriend.alpha',0)
        if getPropertyFromClass('backend.ClientPrefs','data.optimize') == false then setProperty('blammedLightsBlack.alpha', 1) end
        setProperty('dadGroup.color', getColorFromHex('FFFFFF'))
    end 
    if curStep == 4544 then
        setProperty('blackFlash.alpha',1)
        if getPropertyFromClass('backend.ClientPrefs','data.optimize') == false then
        setProperty('edn.alpha', 1)
        setProperty('endScre.alpha', 1)
        end
    end  
    if curStep == 4552 then
        if getPropertyFromClass('backend.ClientPrefs','data.optimize') == false then
        doTweenAlpha('bye', 'edn', 0, 5)
        end
    end
end
