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