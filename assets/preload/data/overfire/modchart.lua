setProperty('skipArrowStartTween', true)
local balls = false
local defaultNotePos = {};
local defaultNoteReversePos = {};
local Meow1 = 0
local Meow2 = 112
local Meow3 = 112 * 2
local Meow4 = 112 * 3

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
  setProperty('medal.visible', false)

  makeLuaSprite('blackFlash', nil, 0, 0)
  makeGraphic('blackFlash', 1280, 720, '000000')
  setObjectCamera('blackFlash', 'hud')
  addLuaSprite('blackFlash', false)
  setProperty('blackFlash.alpha', 0.001)
end

function onCountdownStarted()
  for i = 0, 7 do
      setPropertyFromGroup('strumLineNotes', i, 'alpha', 0)
  end
  setProperty('blackFlash.alpha', 1)
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
  songPos = getPropertyFromClass('backend.Conductor', 'songPosition');
  currentBeat = (songPos / 1750) * (bpm / 100)

  if curBeat >= 48 and curBeat <= 112 or curBeat >= 144 and curBeat <= 176 or curBeat >= 208 and curBeat <= 272 or curBeat >= 336 and curBeat <= 399 or curBeat >= 960 and curBeat <= 1022 then
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

  if curBeat >= 112 and curBeat < 144 or curBeat >= 272 and curBeat < 303 then
    for i = 0,7 do
      setPropertyFromGroup('strumLineNotes', i, 'x', defaultNotePos[i + 1][1] + 10 *math.sin((currentBeat + i*0.25) * math.pi))
      setPropertyFromGroup('strumLineNotes', i, 'y', defaultNotePos[i + 1][2] + 10 *math.cos((currentBeat + i*0.25) * math.pi))
    end
  end
  if curBeat >= 592 and curBeat < 720 then
    for i = 0,7 do
      setPropertyFromGroup('strumLineNotes', i, 'x', defaultNoteReversePos[i + 1][1] + 10 *math.sin((currentBeat + i*0.25) * math.pi))
      setPropertyFromGroup('strumLineNotes', i, 'y', defaultNoteReversePos[i + 1][2] + 10 *math.cos((currentBeat + i*0.25) * math.pi))
    end
  end
end

function onStepHit()
  if curStep == 16 then
    doTweenAlpha('gameover', 'blackFlash', 0, 1)
  end
  if curStep == 144 then
    resetti()
  end
  if curStep == 1088 then
    setProperty('blammedLightsBlack.alpha', 1)
  end
  if curStep == 1212 or curStep == 1213 or curStep == 1214 or curStep == 1215 then
    funni(18)
  end
  if curStep == 1216 then
    resetti()
  end
  if curStep == 1244 or curStep == 1245 or curStep == 1246 or curStep == 1247 then
    funni(21)
  end
  if curStep == 1248 then
    resetti()
  end
  if curStep == 1276 or curStep == 1277 or curStep == 1278 or curStep == 1279 then
    funni(21)
  end
  if curStep == 1280 then
    resetti()
  end
  if curStep == 1308 or curStep == 1309 or curStep == 1310 or curStep == 1311 then
    funni(24)
  end
  if curStep == 1312 then
    resetti()
  end
  if curStep == 1340 or curStep == 1341 or curStep == 1342 or curStep == 1343 then
    funni(69) --хахахуй
  end
  if curStep == 1600 then
    doTweenAlpha('ohgodno', 'blackFlash', 1, 5)
    resetti()
  end
  if curStep == 1848 then
    setProperty('gf.alpha', 0)
    doTweenAlpha('hi', 'blackFlash', 0, 1)

		noteTweenX('dragonTween1', 0, 740 + Meow1, 0.5, 'quartInOut');
    noteTweenAngle("dragonAngle1", 0, -360, 0.5, "quartInOut");

    noteTweenX('dragonTween2', 1, 740 + Meow2, 0.5, 'quartInOut');
    noteTweenAngle("dragonAngle2", 1, -360, 0.6, "quartInOut");

    noteTweenX('dragonTween3', 2, 740 + Meow3, 0.5, 'quartInOut');
    noteTweenAngle("dragonAngle3", 2, -360, 0.6, "quartInOut");

    noteTweenX('dragonTween4', 3, 740 + Meow4, 0.5, 'quartInOut');
    noteTweenAngle("dragonAngle4", 3, -360, 0.6, "quartInOut");

		noteTweenX('foxTween1', 4, 85 + Meow1, 0.5, 'quartInOut');
    noteTweenX('foxTween2', 5, 85 + Meow2, 0.5, 'quartInOut');
    noteTweenX('foxTween3', 6, 85 + Meow3, 0.5, 'quartInOut');
    noteTweenX('foxTween4', 7, 85 + Meow4, 0.5, 'quartInOut');
  end
  if curStep == 1869 then
    for i = 0,7 do 
      x = getPropertyFromGroup('strumLineNotes', i, 'x')
  
      y = getPropertyFromGroup('strumLineNotes', i, 'y')
  
      table.insert(defaultNoteReversePos, {x,y})
    end
  end
  if curStep == 2368 then
    for i = 4,7 do
      noteTweenAlpha('se'..i, i, 0, 0.001)
    end
    setProperty('healthBar.visible', false)
    setProperty('healthBarBGOverlay.visible', false)
    setProperty('iconP1.visible', false)
    setProperty('iconP2.visible', false)
    setProperty('timeBar.visible', false)
    setProperty('timeTxt.visible', false)
    setProperty('timeBarBG.visible', false)
    setProperty('scoreTxt.visible', false)
    setProperty('accuracyShit.visible', false)
    setProperty('medal.visible', false)
    
  end
  if curStep == 2480 then
    for i = 4,7 do
      noteTweenAlpha('sex'..i, i, 1, 0.7)
    end
  end
  if curStep == 2768 then
    if not hideHud then
      setProperty('healthBar.visible', true)
      setProperty('healthBarBGOverlay.visible', true)
      setProperty('iconP1.visible', true)
      setProperty('iconP2.visible', true)
      setProperty('timeBar.visible', true)
      setProperty('timeTxt.visible', true)
      setProperty('timeBarBG.visible', true)
      setProperty('scoreTxt.visible', true)
      setProperty('medal.visible', true)
      setProperty('accuracyShit.visible', true)
    end
  end
  if curStep == 2880 then
    resettiRev()
  end
  if curStep == 2496 then
    setProperty('gf.alpha', 1)
  end
  if curStep == 2969 then
    setProperty('blackFlash.alpha', 1)
    setProperty('gf.alpha', 0)
  end
  if curStep == 3008 then
		noteTweenX('dragonTween1', 0, 85 + Meow1, 0.5, 'quartInOut');
    noteTweenX('dragonTween2', 1, 85 + Meow2, 0.5, 'quartInOut');
    noteTweenX('dragonTween3', 2, 85 + Meow3, 0.5, 'quartInOut');
    noteTweenX('dragonTween4', 3, 85 + Meow4, 0.5, 'quartInOut');
		noteTweenX('foxTween1', 4, 415 + Meow1, 0.5, 'quartInOut');
    noteTweenX('foxTween2', 5, 415 + Meow2, 0.5, 'quartInOut');
    noteTweenX('foxTween3', 6, 415 + Meow3, 0.5, 'quartInOut');
    noteTweenX('foxTween4', 7, 415 + Meow4, 0.5, 'quartInOut');
    for i = 0,7 do
      noteTweenAlpha('se'..i, i, 0, 0.001)
    end
    setProperty('healthBar.visible', false)
  setProperty('healthBarBGOverlay.visible', false)
  setProperty('iconP1.visible', false)
  setProperty('iconP2.visible', false)
  setProperty('timeBar.visible', false)
  setProperty('timeTxt.visible', false)
  setProperty('timeBarBG.visible', false)
  setProperty('scoreTxt.visible', false)
  setProperty('accuracyShit.visible', false)
  setProperty('medal.visible', false)
  end

  if curStep == 3008 then
    doTweenAlpha('welcum back', 'blackFlash', 0, 5)
  end  
  if curStep == 3120 then
    for i = 4,7 do
      noteTweenAlpha('sex'..i, i, 1, 0.7)
    end
  end
  if curStep == 3520 then
    doTweenAlpha('oh shit', 'blackFlash', 1, 1)
  end  
  if curStep == 3551 then

    noteTweenX('foxTween1', 4, 740 + Meow1, 1, 'bounceOut');
    noteTweenX('foxTween2', 5, 740 + Meow2, 1, 'bounceOut');
    noteTweenX('foxTween3', 6, 740 + Meow3, 1, 'bounceOut');
    noteTweenX('foxTween4', 7, 740 + Meow4, 1, 'bounceOut');
  end
  if curStep == 3552 then
    for i = 0,3 do
      noteTweenAlpha('sexo'..i, i, 1, 0.01)
    end
    if not hideHud then
      setProperty('healthBar.visible', true)
      setProperty('healthBarBGOverlay.visible', true)
      setProperty('iconP1.visible', true)
      setProperty('iconP2.visible', true)
      setProperty('timeBar.visible', true)
      setProperty('timeTxt.visible', true)
      setProperty('timeBarBG.visible', true)
      setProperty('scoreTxt.visible', true)
      setProperty('medal.visible', true)
      setProperty('accuracyShit.visible', true)
    end
  end
  if curStep == 3568 then
    doTweenAlpha('oh blyat', 'blackFlash', 0, 0.3)
  end  
  if curStep == 4152 or curStep == 4153 or curStep == 4154 or curStep == 4155 then
    setProperty('blackFlash.alpha', 1)
    funni(69) --хахахуй
  end  
  if curStep == 4156 or curStep == 4157 or curStep == 4158 or curStep == 4159 then
    funni(87) --хахахуй
  end  
  if curStep == 4160 then
    resetti()
    setProperty('blackFlash.alpha', 0)
  end  

  if curStep == 4208 then
    setProperty('blackFlash.alpha',1)
    noteTweenAlpha("sex1", 0, 0, 0.3, "quartInOut")
    noteTweenAngle("saltoHWAW1", 4, -360, 0.6, "quartInOut");
    noteTweenX('foxTween1', 4, 415 + Meow1, 0.6, 'quartInOut');
  end
  if curStep == 4212 then
    noteTweenAlpha("sex2", 1, 0, 0.3, "quartInOut")
    noteTweenAngle("saltoHWAW2", 5, -360, 0.6, "quartInOut");
    noteTweenX('foxTween2', 5, 415 + Meow2, 0.6, 'quartInOut');
  end
  if curStep == 4216 then
    noteTweenAlpha("sex3", 2, 0, 0.3, "quartInOut")
    noteTweenAngle("saltoHWAW3", 6, -360, 0.6, "quartInOut");
    noteTweenX('foxTween3', 6, 415 + Meow3, 0.6, 'quartInOut');
  end
  if curStep == 4220 then
    noteTweenAlpha("sex4", 3, 0, 0.3, "quartInOut")
    noteTweenAngle("saltoHWAW4", 7, -360, 0.6, "quartInOut");
    noteTweenX('foxTween4', 7, 415 + Meow4, 0.6, 'quartInOut');
  end
  if curStep == 4224 then
    setProperty('blackFlash.alpha',0)
  end 
  if curStep == 4544 then
    setProperty('blackFlash.alpha',1)
  end  
end

function onBeatHit()
  if curBeat == 12 then
    setPropertyFromGroup('strumLineNotes', 0, 'alpha', 1)
    setPropertyFromGroup('strumLineNotes', 7, 'alpha', 1)
    if not hideHud then 
      setProperty('healthBar.visible', true) 
    end
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

    if not hideHud then 
      setProperty('scoreTxt.visible', true)
      setProperty('accuracyShit.visible', true)
      setProperty('medal.visible', true)
    end
  end
  if curBeat == 15 then
    setPropertyFromGroup('strumLineNotes', 3, 'alpha', 1)
    setPropertyFromGroup('strumLineNotes', 4, 'alpha', 1)
    setProperty('iconP1.visible', true)
    setProperty('iconP2.visible', true)
  end
  if curBeat >= 48 and curBeat <= 112 or curBeat >= 144 and curBeat <= 176 then
      staticArrowWave = 40
  end
  if curBeat >= 304 and curBeat <= 310 or curBeat >= 312 and curBeat <= 318 or curBeat >= 320 and curBeat <= 325 or curBeat >= 328 and curBeat <= 333 then
    staticArrowWave = 25
end
  if curBeat >= 208 and curBeat <= 272 or curBeat >= 336 and curBeat <= 399 then
    staticArrowWave = 69

    noteAngleDance()
  end
  if curBeat >= 960 and curBeat <= 1022 then
    staticArrowWave = 87

    noteAngleDance()
  end

  if curBeat == 111 or  curBeat == 1023 then
    resetti()

    noteTweenAngle("salto", 0, 360, 0.7, "quartInOut");
    noteTweenAngle("saltyhyEbanyl", 1, 360, 0.7, "quartInOut");
    noteTweenAngle("fuckingSalto", 2, 360, 0.7, "quartInOut");
    noteTweenAngle("SaltoPizdec", 3, 360, 0.7, "quartInOut");
    noteTweenAngle("salto1", 4, 360, 0.7, "quartInOut");
    noteTweenAngle("1saltyhyEbanyl", 5, 360, 0.7, "quartInOut");
    noteTweenAngle("fuckingfrSalto", 6, 360, 0.7, "quartInOut");
    noteTweenAngle("SaltoPizdecsex", 7, 360, 0.7, "quartInOut");
  end
  if curBeat >= 528 and curBeat <= 592 then
    noteAngleDance()
  end
  
  if curBeat == 1120 then
    setProperty('healthBar.visible', false)
    setProperty('healthBarBGOverlay.visible', false)
    setProperty('iconP1.visible', false)
    setProperty('iconP2.visible', false)
    setProperty('timeBar.visible', false)
    setProperty('timeTxt.visible', false)
    setProperty('timeBarBG.visible', false)
    setProperty('scoreTxt.visible', false)
    setProperty('medal.visible', false)
    setProperty('accuracyShit.visible', false)
  end
  if curBeat == 1124 then
    noteTweenAlpha("TheEnd", 4, 0, 5, "quartInOut")
    noteTweenAlpha("TheEndForRe", 5, 0, 5, "quartInOut")
    noteTweenAlpha("The", 6, 0, 5, "quartInOut")
    noteTweenAlpha("End", 7, 0, 5, "quartInOut")
  end
end

function noteSquish(note, axis, mult)
  if axis == 'x' then
      setPropertyFromGroup('strumLineNotes', note, 'scale.x', mult)
      doTweenX('noteSquish'..axis..note, 'strumLineNotes.members['..note..'].scale', 0.7, 0.3, 'quadOut')
  else
      setPropertyFromGroup('strumLineNotes', note, 'scale.y', mult)
      doTweenY('noteSquish'..axis..note, 'strumLineNotes.members['..note..'].scale', 0.7, 0.3, 'quadOut')
  end
end

function resetti()
  for i = 0,7 do 
      setPropertyFromGroup('strumLineNotes', i, 'x', defaultNotePos[i + 1][1])
      setPropertyFromGroup('strumLineNotes', i, 'y', defaultNotePos[i + 1][2])
  end
end

function resettiRev()
  for i = 0,7 do 
      setPropertyFromGroup('strumLineNotes', i, 'x', defaultNoteReversePos[i + 1][1])
      setPropertyFromGroup('strumLineNotes', i, 'y', defaultNoteReversePos[i + 1][2])
  end
end

function noteAngleDance()
  if balls == true then
    noteTweenAngle("foxAnglP", 0, 18, 0.01, "linear")
    noteTweenAngle("foxAng2P", 1, 18, 0.01, "linear")
    noteTweenAngle("foxAle3P", 2, 18, 0.01, "linear")
    noteTweenAngle("fongel4P", 3, 18, 0.01, "linear")
    noteTweenAngle("foxAngl", 4, 18, 0.01, "linear")
    noteTweenAngle("foxAng2", 5, 18, 0.01, "linear")
    noteTweenAngle("foxAle3", 6, 18, 0.01, "linear")
    noteTweenAngle("fongel4", 7, 18, 0.01, "linear")
    noteTweenAngle("foxAngle1p", 0, 0, 0.2, "linear")
    noteTweenAngle("foxAngle2p", 1, 0, 0.2, "linear")
    noteTweenAngle("foxAngle3p", 2, 0, 0.2, "linear")
    noteTweenAngle("foxAngel4p", 3, 0, 0.2, "linear")
    noteTweenAngle("foxAngle1", 4, 0, 0.2, "linear")
    noteTweenAngle("foxAngle2", 5, 0, 0.2, "linear")
    noteTweenAngle("foxAngle3", 6, 0, 0.2, "linear")
    noteTweenAngle("foxAngel4", 7, 0, 0.2, "linear")

    for i=0,7 do
      noteSquish(i, 'x', 1)
    end
  end
  if balls == false then
    noteTweenAngle("foxAnglP", 0, -18, 0.01, "linear")
    noteTweenAngle("foxAng2P", 1, -18, 0.01, "linear")
    noteTweenAngle("foxAle3P", 2, -18, 0.01, "linear")
    noteTweenAngle("fongel4P", 3, -18, 0.01, "linear")
    noteTweenAngle("foxAngl", 4, -18, 0.01, "linear")
    noteTweenAngle("foxAng2", 5, -18, 0.01, "linear")
    noteTweenAngle("foxAle3", 6, -18, 0.01, "linear")
    noteTweenAngle("fongel4", 7, -18, 0.01, "linear")
    noteTweenAngle("foxAngle1p", 0, 0, 0.2, "linear")
    noteTweenAngle("foxAngle2p", 1, 0, 0.2, "linear")
    noteTweenAngle("foxAngle3p", 2, 0, 0.2, "linear")
    noteTweenAngle("foxAngel4p", 3, 0, 0.2, "linear")
    noteTweenAngle("foxAngle1", 4, 0, 0.2, "linear")
    noteTweenAngle("foxAngle2", 5, 0, 0.2, "linear")
    noteTweenAngle("foxAngle3", 6, 0, 0.2, "linear")
    noteTweenAngle("foxAngel4", 7, 0, 0.2, "linear")
    
    for i=0,7 do
      noteSquish(i, 'y', 1)
    end
  end
  balls = not balls
end

function funni(intense) --да да я спиздил хахахаха
    --- иди нахуй
  for i = 0,3 do
    setPropertyFromGroup('opponentStrums', i, 'x', 
    getPropertyFromGroup("opponentStrums", i, "x") + getRandomFloat(-intense, intense))

    setPropertyFromGroup('opponentStrums', i, 'y', 
    getPropertyFromGroup("opponentStrums", i, "y") + getRandomFloat(-intense, intense))

    setPropertyFromGroup('playerStrums', i, 'x', 
    getPropertyFromGroup("playerStrums", i, "x") + getRandomFloat(-intense, intense))

    setPropertyFromGroup('playerStrums', i, 'y', 
    getPropertyFromGroup("playerStrums", i, "y") + getRandomFloat(-intense, intense))
  end

  noteTweenX("blyaDad"..i, i, _G["defaultOpponentStrumX"..i], 0.1, "quadOut")
  noteTweenY("pizdecDad"..i, i, _G["defaultOpponentStrumY"..i], 0.1, "quadOut")

  noteTweenX("blyaBF"..i, i + 4, _G["defaultPlayerStrumX"..i], 0.1, "quadOut")
  noteTweenY("pizdecBF"..i, i + 4, _G["defaultPlayerStrumY"..i], 0.1, "quadOut")
end