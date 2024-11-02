local defaultNotePos = {};
local spin = 3
setProperty('skipArrowStartTween', true)

function onSongStart()
	for i = 0,7 do 
		x = getPropertyFromGroup('strumLineNotes', i, 'x')
		y = getPropertyFromGroup('strumLineNotes', i, 'y')

		table.insert(defaultNotePos, {x,y})
	end
end

function onCreatePost()
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

	for i = 0, 7 do
		setPropertyFromGroup('strumLineNotes', i, 'alpha', 0)
	end
end


function onUpdate(elapsed)
	local songPos = getPropertyFromClass('backend.Conductor', 'songPosition');
  	local songPosSpeed = getPropertyFromClass('backend.Conductor', 'songPosition') / 500
	currentBeat = (songPos / 1750) * (bpm / 100)
	currentBeatAlt = (songPos / 1250) * (bpm / 100)
  	if curBeat >= 704 and curBeat < 768 then
		for i = 0,7 do
			setPropertyFromGroup('strumLineNotes', i, 'x', defaultNotePos[i + 1][1] + 10 *math.sin((currentBeat + i*0.25) * math.pi))
			setPropertyFromGroup('strumLineNotes', i, 'y', defaultNotePos[i + 1][2] + 10 *math.cos((currentBeat + i*0.25) * math.pi))
		end
	end
	if curBeat == 768 then
		for i = 0,7 do 
			setPropertyFromGroup('strumLineNotes', i, 'x', defaultNotePos[i + 1][1])
			setPropertyFromGroup('strumLineNotes', i, 'y', defaultNotePos[i + 1][2])
		end
	end
	if curBeat >= 771 and curBeat < 834 then
		for i = 0,7 do
			setPropertyFromGroup('strumLineNotes', i, 'x', defaultNotePos[i + 1][1] + 10 *math.sin((currentBeatAlt + i*0.25) * math.pi))
			setPropertyFromGroup('strumLineNotes', i, 'y', defaultNotePos[i + 1][2] + 10 *math.cos((currentBeatAlt + i*0.25) * math.pi))
		  setProperty("camHUD.angle", spin * math.sin(songPosSpeed))
		end                                                
	end
  	if curBeat == 834 then
    	setProperty("camHUD.angle", 0)
		for i = 0,7 do 
			setPropertyFromGroup('strumLineNotes', i, 'x', defaultNotePos[i + 1][1])
			setPropertyFromGroup('strumLineNotes', i, 'y', defaultNotePos[i + 1][2])
		end
	end
end

function onBeatHit()
	if curBeat == 24 then
		for i = 4, 7 do
			noteTweenAlpha("note"..i, i, 1, 1, "linear")
		end
	end

	if curBeat == 48 then
		for i = 0, 3 do
			noteTweenAlpha("note"..i, i, 1, 1, "linear")
		end
		setProperty('healthBar.visible', true)
		setProperty('healthBarBGOverlay.visible', true)
		setProperty('iconP1.visible', true)
		setProperty('iconP2.visible', true)
		setProperty('timeBar.visible', true)
		setProperty('timeTxt.visible', true)
		setProperty('timeBarBG.visible', true)
		setProperty('scoreTxt.visible', true)
		setProperty('accuracyShit.visible', true)
		setProperty('medal.visible', true)
	end
	if curBeat == 702 then
		for i = 0, 7 do
			noteTweenAngle("note"..i, i, 360, 1, "quartInOut")
		end
	end
end