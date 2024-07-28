function onSongStart()
    for i = 0,3 do
        setPropertyFromGroup('opponentStrums', i, 'alpha', 0)
    end
end

function onBeatHit()
    if curBeat == 300 then
        cameraFade('game', '000000', 2, true)
    end
end