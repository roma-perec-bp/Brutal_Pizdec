function onCreate()
    makeLuaSprite('black', nil, 0, 0)
    setObjectCamera('black', 'hud')
    makeGraphic('black', screenWidth, screenHeight, '000000')
    setProperty('black.visible', false)
    addLuaSprite('black', false)
end

function onBeatHit()
    if curBeat == 548 then
        setProperty('black.visible', true)
    end
    if curBeat == 552 then
        setProperty('black.visible', false)
    end
    if curBeat == 696 then
        setProperty('black.visible', true)
        cameraFlash('camhud', '0xFFFFFFFF', 1)
    end
    if curBeat == 712 then
        setProperty('black.visible', false)
    end
    if curBeat == 844 then
        cameraFade('camhud', '000000', 2)
    end
end