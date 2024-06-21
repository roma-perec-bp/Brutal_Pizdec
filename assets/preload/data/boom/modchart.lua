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
    makeLuaSprite('maniaPart', null, 360, 0)
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
end

function onUpdate(elapsed)
	songPos = getPropertyFromClass('backend.Conductor', 'songPosition'); -- Note Movements
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
    if curStep == 32 then
        doTweenAlpha('suka','blackFlash', 0, 1, 'linear')
    end
    if curStep == 288 then
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
    if curStep == 3072 then
        setProperty('vin.visible', true)
    end
  if curStep == 3184 then
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
    if curStep == 3584 then
        setProperty('vin.visible', false)
    end
end