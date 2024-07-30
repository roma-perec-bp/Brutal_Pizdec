setProperty('skipArrowStartTween', true)
local defaultNotePos = {};

function onCreate()
  setProperty('healthBar.visible', false)
  setProperty('healthBarBGOverlay.visible', false)
  setProperty('iconP1.visible', false)
  setProperty('iconP2.visible', false)
  setProperty('timeBar.visible', false)
  setProperty('timeTxt.visible', false)
  setProperty('timeBarBG.visible', false)
  setProperty('scoreTxt.visible', false)
  setProperty('accuracyShit.visible', false)

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

  makeLuaSprite('blackFlash', nil, 0, 0)
  makeGraphic('blackFlash', 1280, 720, '000000')
  setObjectCamera('blackFlash', 'hud')
  addLuaSprite('blackFlash', false)
  setProperty('blackFlash.alpha', 0.001)
end

function onCountdownStarted()
  if isStoryMode == true then
    doTweenAlpha('startBlack', 'blackFlash', 1, 1)
  else
    setProperty('blackFlash.alpha', 1)
  end
end

function onSongStart()
	for i = 0,7 do 
		x = getPropertyFromGroup('strumLineNotes', i, 'x')

		y = getPropertyFromGroup('strumLineNotes', i, 'y')

		table.insert(defaultNotePos, {x,y})
	end
end

local staticArrowWave = 0
local function lerp(a,b,t) return a+(b-a)*t end
function onUpdate(elapsed)
    if curBeat <= 112 or curBeat <= 176 or curBeat <= 400 then
        for i =0,7 do
            local noteX = 120 * i
            local offsetX = 140
            local thingy = 1
            if curBeat % 2 == 0 then
                thingy = -1
            end
            if i<4 then
                offsetX = 0
            end
            setPropertyFromGroup("strumLineNotes", i, "y", defaultOpponentStrumY0+(math.sin((getSongPosition()-getPropertyFromClass('backend.ClientPrefs','data.noteOffset')) / crochet + (noteX-120)*2) * staticArrowWave + staticArrowWave * 0.5))

            setPropertyFromGroup("strumLineNotes", i, "x", defaultOpponentStrumX0+noteX+offsetX+(thingy*staticArrowWave)*0.7)
        end
        staticArrowWave = lerp(staticArrowWave,0,elapsed*8)
    end

    songPos = getPropertyFromClass('backend.Conductor', 'songPosition');
    currentBeat = (songPos / 1750) * (bpm / 100)
    if curBeat >= 112 and curBeat < 144 then
      for i = 0,7 do
        setPropertyFromGroup('strumLineNotes', i, 'x', defaultNotePos[i + 1][1] + 10 *math.sin((currentBeat + i*0.25) * math.pi))
        setPropertyFromGroup('strumLineNotes', i, 'y', defaultNotePos[i + 1][2] + 10 *math.cos((currentBeat + i*0.25) * math.pi))
      end
    end
    if curStep == 144 then
      for i = 0,7 do 
        setPropertyFromGroup('strumLineNotes', i, 'x', defaultNotePos[i + 1][1])
        setPropertyFromGroup('strumLineNotes', i, 'y', defaultNotePos[i + 1][2])
      end
    end
end
function onCreatePost()
    for i = 0, 7 do
        setPropertyFromGroup('strumLineNotes', i, 'alpha', 0)
    end
end

function onStepHit()
  if curStep == 2 then
    setProperty('blammedLightsBlack.alpha', 1)
  end
  if curStep == 16 then
    doTweenAlpha('gameover', 'blackFlash', 0, 1)
    setProperty('boyfriend.alpha', 0.0001)
  end
  if curStep == 48 then
    setProperty('red.alpha', 1)
    setProperty('dad.color', 0xff000000)
  end
  if curStep == 64 then
    setProperty('red.alpha', 0)
    setProperty('blammedLightsBlack.alpha', 0.0001)
    setProperty('boyfriend.alpha', 1)
  end
  if curStep == 704 then
    doTweenAlpha('pizdos', 'blammedLightsBlack', 0.6, 1)
  end
  if curStep == 816 then
    setProperty('red.alpha', 1)
    setProperty('blammedLightsBlack.alpha', 1)
    setProperty('dad.color', 0xff000000)
  end
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
  if curStep == 832 then
    setProperty('red.alpha', 0)
    setProperty('blammedLightsBlack.alpha', 0)
    doTweenColor('obnegrel', 'dad', 'FFFFFF', 0.001)
  end
  if curStep == 1088 then
    setProperty('blammedLightsBlack.alpha', 1)
  end
end

function onBeatHit()
  if curBeat == 12 then
    setPropertyFromGroup('strumLineNotes', 0, 'alpha', 1)
    setPropertyFromGroup('strumLineNotes', 7, 'alpha', 1)
    setProperty('healthBar.visible', true)
    setProperty('healthBarBGOverlay.visible', true)
  end
  if curBeat == 13 then
    setPropertyFromGroup('strumLineNotes', 1, 'alpha', 1)
    setPropertyFromGroup('strumLineNotes', 6, 'alpha', 1)
    setProperty('timeBar.visible', true)
    setProperty('timeTxt.visible', true)
    setProperty('timeBarBG.visible', true)
  end
  if curBeat == 14 then
    setPropertyFromGroup('strumLineNotes', 2, 'alpha', 1)
    setPropertyFromGroup('strumLineNotes', 5, 'alpha', 1)
    setProperty('scoreTxt.visible', true)
    setProperty('accuracyShit.visible', true)
  end
  if curBeat == 15 then
    setPropertyFromGroup('strumLineNotes', 3, 'alpha', 1)
    setPropertyFromGroup('strumLineNotes', 4, 'alpha', 1)
    setProperty('iconP1.visible', true)
    setProperty('iconP2.visible', true)
  end
  if curBeat >= 48 and curBeat <= 112 or curBeat >= 144 and curBeat <= 176 or curBeat >= 336 and curBeat <= 400 then
      staticArrowWave = 40
  end
  if curBeat == 111 then
      for i = 0,7 do
        setPropertyFromGroup('strumLineNotes', i, 'x', defaultNotePos[i + 1][1])
        setPropertyFromGroup('strumLineNotes', i, 'y', defaultNotePos[i + 1][2])
      end
      noteTweenAngle("salto", 0, 360, 0.7, "quartInOut");
      noteTweenAngle("saltyhyEbanyl", 1, 360, 0.7, "quartInOut");
      noteTweenAngle("fuckingSalto", 2, 360, 0.7, "quartInOut");
      noteTweenAngle("SaltoPizdec", 3, 360, 0.7, "quartInOut");
      noteTweenAngle("salto1", 4, 360, 0.7, "quartInOut");
      noteTweenAngle("1saltyhyEbanyl", 5, 360, 0.7, "quartInOut");
      noteTweenAngle("fuckingfrSalto", 6, 360, 0.7, "quartInOut");
      noteTweenAngle("SaltoPizdecsex", 7, 360, 0.7, "quartInOut");
  end
end