local canDrain = false

function opponentNoteHit(membersIndex, noteData, noteType, isSustainNote)
    if canDrain == true then
        if isSustainNote == false then
            if getHealth() - 0.02 > 0.05 then addHealth(-0.02) end
        end
    end
end

function onSongStart()
    for i = 0,3 do
        setPropertyFromGroup('opponentStrums', i, 'alpha', 0)
    end
end

function onEvent(eventName, value1, value2)
    if eventName == 'monochrome pizdec' then        
        if canDrain == true then
            canDrain = false
        elseif canDrain == false then
            canDrain = true
        end
    end
end

function onBeatHit()
    if curBeat == 406 then
        cameraFade('game', '000000', 2, true)
    end
end