function onCreate()
    makeLuaSprite('blackFlash', nil, 0, 0)
    makeGraphic('blackFlash', 1280, 720, '000000')
    setObjectCamera('blackFlash', 'camgame')
    addLuaSprite('blackFlash', true)
end

function onBeatHit()
    if curBeat % 2 == 0 then
        setProperty('iconP1.flipX', true)
    else
        setProperty('iconP1.flipX', false)
    end
    if curBeat == 1 then
        doTweenAlpha('suka','blackFlash', 0, 40, 'quardOut')
    end
    if curBeat == 746 then
        doTweenAlpha('suka','blackFlash', 1, 25, 'linear')
    end
end