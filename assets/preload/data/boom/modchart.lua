local defaultNotePos = {};
local shake = 4;
local Meow1 = 0
local Meow2 = 112
local Meow3 = 112 * 2
local Meow4 = 112 * 3
setProperty('skipArrowStartTween', true)

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
    screenCenter("vin", 'xy')
    setObjectCamera('vin', 'hud')
    addLuaSprite('vin', true)

    setProperty('scoreTxt.visible', false)
    setProperty('timeTxt.visible', false)
    setProperty('timeBar.visible', false)
    setProperty('timeBarBG.visible', false)
    setProperty('medal.visible', false)
    setProperty('healthBar.visible', false)
    setProperty('healthBarBGOverlay.visible', false)
    setProperty('iconP1.visible', false)
    setProperty('iconP2.visible', false)
    setProperty('accuracyShit.visible', false)
end

function onCountdownStarted()
    for i = 0, 7 do
        setPropertyFromGroup('strumLineNotes', i, 'alpha', 0)
    end
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
        for i = 0, 3 do
            setPropertyFromGroup('strumLineNotes', i, 'alpha', 1)
        end
    end
    if curStep == 30 then
        for i = 4, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'alpha', 1)
        end
    end
end

function onBeatHit()
    if curBeat == 8 then
        doTweenAlpha('suka','blackFlash', 0, 1, 'linear')
    end
    if curBeat == 92 then
        if not timeBarType == 'Disabled' then
            setProperty('timeTxt.visible', true)
            setProperty('timeBar.visible', true)
            setProperty('timeBarBG.visible', true)
        end
        if not hideHud then
            setProperty('scoreTxt.visible', true)
            setProperty('accuracyShit.visible', true)
            setProperty('healthBar.visible', true)
            setProperty('healthBarBGOverlay.visible', true)
            setProperty('iconP1.visible', true)
            setProperty('iconP2.visible', true)
            setProperty('medal.visible', true)
        end
    end
    if curBeat == 72 then
        setProperty('vin.visible', false)
    end
    if curBeat == 348 then
        for i = 4, 7 do
            noteTweenAngle("hwaw"..i, i, -360, 1.5, "quartInOut")
        end
        for i = 0, 3 do
            noteTweenAlpha("perec"..i, i, 0, 1, "quartInOut")
        end
        noteTweenX('foxTween1', 4, 415 + Meow1, 1.5, 'quartInOut');
        noteTweenX('foxTween2', 5, 415 + Meow2, 1.5, 'quartInOut');
        noteTweenX('foxTween3', 6, 415 + Meow3, 1.5, 'quartInOut');
        noteTweenX('foxTween4', 7, 415 + Meow4, 1.5, 'quartInOut');
    end
    if curBeat == 384 then
        for i = 0, 3 do
            noteTweenAlpha("perec"..i, i, 1, 10, "quartInOut")
        end
        noteTweenX('foxTween1', 4, 740 + Meow1, 8, 'quartInOut');
    	noteTweenX('foxTween2', 5, 740 + Meow2, 8, 'quartInOut');
    	noteTweenX('foxTween3', 6, 744 + Meow3, 8, 'quartInOut');
    	noteTweenX('foxTween4', 7, 744 + Meow4, 8, 'quartInOut');
    end
    if curBeat == 416 then
        setProperty('vin.visible', true)
        for i = 4, 7 do
            noteTweenAlpha("hwaw"..i, i, 0.6, 0.6, "quartInOut")
        end
    end
    if curBeat == 448 then
        for i = 0, 3 do
            noteTweenAlpha("perec"..i, i, 0.6, 0.6, "quartInOut")
        end
        for i = 4, 7 do
            noteTweenAlpha("hwaw"..i, i, 1, 0.6, "quartInOut")
        end
    end
    if curBeat == 480 then
        for i = 0, 3 do
            noteTweenAlpha("perec"..i, i, 1, 0.6, "quartInOut")
        end
        for i = 4, 7 do
            noteTweenAlpha("hwaw"..i, i, 0.6, 0.6, "quartInOut")
        end
    end
    if curBeat == 512 then
        for i = 0, 3 do
            noteTweenAlpha("perec"..i, i, 0.6, 0.6, "quartInOut")
        end
        for i = 4, 7 do
            noteTweenAlpha("hwaw"..i, i, 1, 0.6, "quartInOut")
        end
    end
    if curBeat == 544 then
        for i = 0, 3 do
            noteTweenAlpha("perec"..i, i, 1, 0.6, "quartInOut")
        end
        setProperty('vin.visible', false)
    end
    if curBeat == 680 then
        doTweenAlpha('maniaPartYea','maniaPart', 1, 0.5, 'linear')
        noteTweenX("Pizdec1", 0, 420, 0.5, "quartInOut")
        noteTweenX("Pizdec2", 1, 530, 0.5, "quartInOut")
        noteTweenX("Pizdec3", 2, 640, 0.5, "quartInOut")
        noteTweenX("Pizdec4", 3, 750, 0.5, "quartInOut")
        for i = 0, 3 do
            noteTweenAngle("perec"..i, i, 360, 1, "quartInOut")
        end
        for i = 4, 7 do
            noteTweenAlpha("hwaw"..i, i, 0, 1, "quartInOut")
        end
    end
    if curBeat == 744 then
        doTweenAlpha('Fucked','maniaPart', 0, 0.1, 'linear')
        noteTweenX('Pizdec1', 0,110, 1, 'quartInOut');
        noteTweenX('Pizdec2', 1, 220, 1, 'quartInOut');
        noteTweenX('Pizdec3', 2, 330, 1, 'quartInOut');
        noteTweenX('Pizdec4', 3,440, 1, 'quartInOut');
        for i = 0, 3 do
            noteTweenAngle("perec"..i, i, -360, 1, "quartInOut")
        end
        for i = 4, 7 do
            noteTweenAlpha("hwaw"..i, i, 1, 1, "quartInOut")
        end
    end
    if curBeat == 768 then
        setProperty('vin.visible', true)
    end
    if curBeat == 896 then
        setProperty('vin.visible', false)
    end
    if curBeat == 830 then
        for i = 0, 7 do
            noteTweenAngle("mod"..i, i, 360, 1, "quartInOut")
        end
    end
    if curBeat == 960 then
        setProperty('vin.visible', true) 
    end
    if curBeat == 1024 then
        setProperty('scoreTxt.visible', false)
        setProperty('timeTxt.visible', false)
        setProperty('timeBar.visible', false)
        setProperty('timeBarBG.visible', false)
        setProperty('medal.visible', false)
        setProperty('healthBar.visible', false)
        setProperty('healthBarBGOverlay.visible', false)
        setProperty('iconP1.visible', false)
        setProperty('iconP2.visible', false)
        setProperty('accuracyShit.visible', false)
        for i = 0, 3 do
            noteTweenAlpha("perec"..i, i, 0, 0.01, "quartInOut")
        end
        for i = 4, 7 do
            noteTweenAlpha("hwaw"..i, i, 0, 3, "quartInOut")
        end
    end
end