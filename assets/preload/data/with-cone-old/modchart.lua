local defaultNotePos = {};
local spin = 3

function onSongStart()
	for i = 0,7 do 
		x = getPropertyFromGroup('strumLineNotes', i, 'x')
		y = getPropertyFromGroup('strumLineNotes', i, 'y')

		table.insert(defaultNotePos, {x,y})
	end
end

function onUpdate(elapsed)
	local songPos = getPropertyFromClass('backend.Conductor', 'songPosition');
  	local songPosSpeed = getPropertyFromClass('backend.Conductor', 'songPosition') / 500
	currentBeat = (songPos / 1750) * (bpm / 100)
	currentBeatAlt = (songPos / 1250) * (bpm / 100)
  	if curBeat >= 528 and curBeat < 592 then
		for i = 0,7 do
			setPropertyFromGroup('strumLineNotes', i, 'x', defaultNotePos[i + 1][1] + 10 *math.sin((currentBeat + i*0.25) * math.pi))
			setPropertyFromGroup('strumLineNotes', i, 'y', defaultNotePos[i + 1][2] + 10 *math.cos((currentBeat + i*0.25) * math.pi))
		end
	end
	if curBeat == 592 then
		for i = 0,7 do 
			setPropertyFromGroup('strumLineNotes', i, 'x', defaultNotePos[i + 1][1])
			setPropertyFromGroup('strumLineNotes', i, 'y', defaultNotePos[i + 1][2])
		end
	end
	if curBeat >= 594 and curBeat < 658 then
		for i = 0,7 do
			setPropertyFromGroup('strumLineNotes', i, 'x', defaultNotePos[i + 1][1] + 10 *math.sin((currentBeatAlt + i*0.25) * math.pi))
			setPropertyFromGroup('strumLineNotes', i, 'y', defaultNotePos[i + 1][2] + 10 *math.cos((currentBeatAlt + i*0.25) * math.pi))
		  setProperty("camHUD.angle", spin * math.sin(songPosSpeed))
		end                                                
	end
  	if curBeat == 658 then
    	setProperty("camHUD.angle", 0)
		for i = 0,7 do 
			setPropertyFromGroup('strumLineNotes', i, 'x', defaultNotePos[i + 1][1])
			setPropertyFromGroup('strumLineNotes', i, 'y', defaultNotePos[i + 1][2])
		end
	end
end