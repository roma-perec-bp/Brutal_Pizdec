function onBeatHit()
    if curBeat % 2 == 0 then
        setProperty('iconP1.flipX', true)
    else
        setProperty('iconP1.flipX', false)
    end
end