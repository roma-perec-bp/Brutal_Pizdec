function onCreate()
    makeLuaSprite('blackFlash', nil, 0, 0)
    makeGraphic('blackFlash', 1280, 720, '000000')
    setObjectCamera('blackFlash', 'camhud')
    addLuaSprite('blackFlash', false)

    setProperty('rom.visible', false)
    setProperty('iconROM.visible', false)
    setProperty('iconGF.visible', false)

    setProperty('gf.y', -600)
end

function onBeatHit()
    if curBeat == 1 then
        doTweenAlpha('suka','blackFlash', 0, 40, 'quardOut')
    end
    if curBeat == 480 then
        setProperty('rom.visible', true)
        setProperty('iconROM.visible', true)
    end
    if curBeat == 604 then
        doTweenY('random','gf', 270, 2, 'bounceInOut')
        setProperty('iconGF.visible', true)
    end
    if curBeat == 746 then
        doTweenAlpha('suka','blackFlash', 1, 25, 'linear')
    end
end