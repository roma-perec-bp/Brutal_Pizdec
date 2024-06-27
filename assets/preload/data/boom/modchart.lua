local defaultNotePos = {};
local shake = 4;
local Meow1 = 0
local Meow2 = 112
local Meow3 = 112 * 2
local Meow4 = 112 * 3

function onSongStart()
	for i = 0,7 do 
		x = getPropertyFromGroup('strumLineNotes', i, 'x')

		y = getPropertyFromGroup('strumLineNotes', i, 'y')

		table.insert(defaultNotePos, {x,y})
	end
end

function onCreate()
    makeLuaSprite('maniaPart', nil, 360, 0)
	makeGraphic('maniaPart', 560, 720, '000000')
	setObjectCamera('maniaPart', 'hud')
	setProperty('maniaPart.alpha', 0.00001)
	addLuaSprite('maniaPart', false)
    --начало модчарта хахаха
    makeLuaSprite('blackFlash', nil, 0, 0)
    makeGraphic('blackFlash', 1280, 720, '000000')
    setObjectCamera('blackFlash', 'hud')
    addLuaSprite('blackFlash', false)
    makeLuaSprite('vin', 'vin', 0, 0)
    setObjectCamera('vin', 'hud')
    addLuaSprite('vin', true)

    setProperty('scoreTxt.visible', false)
    setProperty('timeTxt.visible', false)
    setProperty('timeBar.visible', false)
    setProperty('timeBarBG.visible', false)

    setProperty('healthBar.visible', false)
    setProperty('healthBarBGOverlay.visible', false)
    setProperty('iconP1.visible', false)
    setProperty('iconP2.visible', false)
    setProperty('accuracyShit.visible', false)
end

function onUpdate(elapsed)
	songPos = getPropertyFromClass('backend.Conductor', 'songPosition');
	currentBeat = (songPos / 1750) * (bpm / 100)

	if curStep >= 3328 and curStep < 3584 then
		for i = 0,7 do
			setPropertyFromGroup('strumLineNotes', i, 'x', defaultNotePos[i + 1][1] + 10 *math.sin((currentBeat + i*0.25) * math.pi))
			setPropertyFromGroup('strumLineNotes', i, 'y', defaultNotePos[i + 1][2] + 10 *math.cos((currentBeat + i*0.25) * math.pi))
		end                                                  
	end

	if curStep == 3584 then
		for i = 0,7 do 
			setPropertyFromGroup('strumLineNotes', i, 'x', defaultNotePos[i + 1][1])
			setPropertyFromGroup('strumLineNotes', i, 'y', defaultNotePos[i + 1][2])
		end
	end
end

function onStepHit()
    if curStep == 28 then
        setProperty('scoreTxt.visible', true)
        setProperty('timeTxt.visible', true)
        setProperty('timeBar.visible', true)
        setProperty('timeBarBG.visible', true)
        setProperty('accuracyShit.visible', true)
    end
    if curStep == 30 then
        setProperty('healthBar.visible', true)
        setProperty('healthBarBGOverlay.visible', true)
        setProperty('iconP1.visible', true)
        setProperty('iconP2.visible', true)
    end
    if curStep == 32 then
        doTweenAlpha('suka','blackFlash', 0, 1, 'linear')
    end
    if curStep == 288 then
        setProperty('vin.visible', false)
    end
    if curStep == 1398 then
        noteTweenAlpha("sex1", 0, 0, 1, "quartInOut")
        noteTweenAngle("saltoHWAW1", 4, -360, 0.6, "quartInOut");
        noteTweenX('foxTween1', 4, 415 + Meow1, 1, 'quartInOut');
    end
    if curStep == 1400 then
        noteTweenAlpha("sex2", 1, 0, 1, "quartInOut")
        noteTweenAngle("saltoHWAW2", 5, -360, 0.6, "quartInOut");
        noteTweenX('foxTween2', 5, 415 + Meow2, 1, 'quartInOut');
    end
    if curStep == 1402 then
        noteTweenAlpha("sex3", 2, 0, 1, "quartInOut")
        noteTweenAngle("saltoHWAW3", 6, -360, 0.6, "quartInOut");
        noteTweenX('foxTween3', 6, 415 + Meow3, 1, 'quartInOut');
    end
    if curStep == 1404 then
        noteTweenAlpha("sex4", 3, 0, 1, "quartInOut")
        noteTweenAngle("saltoHWAW4", 7, -360, 0.6, "quartInOut");
        noteTweenX('foxTween4', 7, 415 + Meow4, 1, 'quartInOut');
    end
    if curStep == 1536 then
        noteTweenAlpha("ssex1", 0, 1, 10, "quartInOut")
        noteTweenAlpha("ssss", 1, 1, 10, "quartInOut")
        noteTweenAlpha("sssex1", 2, 1, 10, "quartInOut")
        noteTweenAlpha("sex69", 3, 1, 1, "quartInOut")
        noteTweenAngle("saltoHWAW1", 4, 360, 10, "quartInOut");
        noteTweenAngle("saltoHWAW2", 5, 360, 10, "quartInOut");
        noteTweenAngle("saltoHWAW3", 6, 360, 10, "quartInOut");
        noteTweenAngle("saltoHWAW4", 7, 360, 10, "quartInOut");
        noteTweenX('foxTween1', 4, 740 + Meow1, 10, 'quartInOut');
    	noteTweenX('foxTween2', 5, 740 + Meow2, 10, 'quartInOut');
    	noteTweenX('foxTween3', 6, 744 + Meow3, 10, 'quartInOut');
    	noteTweenX('foxTween4', 7, 744 + Meow4, 10, 'quartInOut');
    end
    if curStep == 1664 then
        setProperty('vin.visible', true)
        noteTweenAlpha("hwaw1", 4, 0.6, 0.6, "quartInOut")
        noteTweenAlpha("hwaw2", 5, 0.6, 0.6, "quartInOut")
        noteTweenAlpha("hwaw3", 6, 0.6, 0.6, "quartInOut")
        noteTweenAlpha("hwaw4", 7, 0.6, 0.6, "quartInOut")
    end
    if curStep == 1792 then
        noteTweenAlpha("sex1", 0, 0.6, 0.6, "quartInOut")
        noteTweenAlpha("sex2", 1, 0.6, 0.6, "quartInOut")
        noteTweenAlpha("sex3", 2, 0.6, 0.6, "quartInOut")
        noteTweenAlpha("sex4", 3, 0.6, 0.6, "quartInOut")
        noteTweenAlpha("sex14", 4, 1, 0.6, "quartInOut")
        noteTweenAlpha("sex25", 5, 1, 0.6, "quartInOut")
        noteTweenAlpha("sex39", 6, 1, 0.6, "quartInOut")
        noteTweenAlpha("sex42", 7, 1, 0.6, "quartInOut")
    end
    if curStep == 1920 then
        noteTweenAlpha("sex1", 0, 1, 0.6, "quartInOut")
        noteTweenAlpha("sex2", 1, 1, 0.6, "quartInOut")
        noteTweenAlpha("sex3", 2, 1, 0.6, "quartInOut")
        noteTweenAlpha("sex4", 3, 1, 0.6, "quartInOut")
        noteTweenAlpha("sex14", 4, 0.6, 0.6, "quartInOut")
        noteTweenAlpha("sex25", 5, 0.6, 0.6, "quartInOut")
        noteTweenAlpha("sex39", 6, 0.6, 0.6, "quartInOut")
        noteTweenAlpha("sex42", 7, 0.6, 0.6, "quartInOut")
    end
    if curStep == 2048 then
        noteTweenAlpha("sex1", 0, 0.6, 0.6, "quartInOut")
        noteTweenAlpha("sex2", 1, 0.6, 0.6, "quartInOut")
        noteTweenAlpha("sex3", 2, 0.6, 0.6, "quartInOut")
        noteTweenAlpha("sex4", 3, 0.6, 0.6, "quartInOut")
        noteTweenAlpha("sex14", 4, 1, 0.6, "quartInOut")
        noteTweenAlpha("sex25", 5, 1, 0.6, "quartInOut")
        noteTweenAlpha("sex39", 6, 1, 0.6, "quartInOut")
        noteTweenAlpha("sex42", 7, 1, 0.6, "quartInOut")
    end
    if curStep == 2176 then
        noteTweenAlpha("sex1", 0, 1, 0.6, "quartInOut")
        noteTweenAlpha("sex2", 1, 1, 0.6, "quartInOut")
        noteTweenAlpha("sex3", 2, 1, 0.6, "quartInOut")
        noteTweenAlpha("sex4", 3, 1, 0.6, "quartInOut")
    end

    if curStep == 2176 then
        setProperty('vin.visible', false)
    end
    if curStep == 2720 then
        doTweenAlpha('maniaPartYea','maniaPart', 1, 0.5, 'linear')
        noteTweenX("Pizdec1", 0, 420, 0.5, "quartInOut")
        noteTweenX("Pizdec2", 1, 530, 0.5, "quartInOut")
        noteTweenX("Pizdec3", 2, 640, 0.5, "quartInOut")
        noteTweenX("Pizdec4", 3, 750, 0.5, "quartInOut")
        noteTweenAlpha("hwaw1", 4, 0, 1, "quartInOut")
        noteTweenAlpha("hwaw2", 5, 0, 1, "quartInOut")
        noteTweenAlpha("hwaw3", 6, 0, 1, "quartInOut")
        noteTweenAlpha("hwaw4", 7, 0, 1, "quartInOut")
        noteTweenAngle("salto", 0, 360, 0.5, "quartInOut");
        noteTweenAngle("saltyhyEbanyl", 1, 360, 0.5, "quartInOut");
        noteTweenAngle("fuckingSalto", 2, 360, 0.5, "quartInOut");
        noteTweenAngle("SaltoPizdec", 3, 360, 0.5, "quartInOut");
    end
    if curStep == 2971 then
        doTweenAlpha('Fucked','maniaPart', 0, 0.1, 'linear')
    end
    if curStep == 2972 then
        noteTweenX('Pizdec1', 0,110, 1, 'quartInOut');
        noteTweenX('Pizdec2', 1, 220, 1, 'quartInOut');
        noteTweenX('Pizdec3', 2, 330, 1, 'quartInOut');
        noteTweenX('Pizdec4', 3,440, 1, 'quartInOut');
        noteTweenAlpha("hwaw1", 4, 1,2, "quartInOut")
        noteTweenAlpha("hwaw2", 5, 1, 2, "quartInOut")
        noteTweenAlpha("hwaw3", 6, 1, 2, "quartInOut")
        noteTweenAlpha("hwaw4", 7, 1, 2, "quartInOut")
        noteTweenAngle("salto", 0, -360, 1, "quartInOut");
        noteTweenAngle("saltyhyEbanyl", 1, -360, 1, "quartInOut");
        noteTweenAngle("fuckingSalto", 2, -360, 1, "quartInOut");
        noteTweenAngle("SaltoPizdec", 3, -360, 1, "quartInOut");
    end
    if curStep == 3072 then
        setProperty('vin.visible', true)
    end
    if curStep == 3584 then
        setProperty('vin.visible', false)
    end
    if curStep == 3840 then
        setProperty('vin.visible', true)
    end
    if curStep == 4096 then
        setProperty('vin.visible', false)
    end
end