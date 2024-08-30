local dingle = -650
local shit = -50
local mult = shit/2

local angleShit = -20

function onCreate()
    makeAnimatedLuaSprite('fakeIcon', nil, 0, 0)
    setObjectCamera('fakeIcon','hud')
    setObjectOrder('fakeIcon',getObjectOrder('iconP2') + 1)
    addLuaSprite('fakeIcon')
    setProperty('fakeIcon.visible', false)
end

function onEvent(eventName, value1, value2)
    if eventName == 'iconFallOff' then

        dingle = -650
        shit = -50
        mult = shit/2

        loadGraphic('fakeIcon', 'icons/'..value1) -- Load stupidly first for getting the file size
        loadGraphic('fakeIcon', 'icons/'..value1, getProperty('fakeIcon.width')/3, getProperty('fakeIcon.height')) -- Then load it fr

        addAnimation('fakeIcon','lose', {1}, 0, true) 

        playAnim('fakeIcon', 'lose')

        setProperty('fakeIcon.y', getProperty('iconP2.y'))
        setProperty('fakeIcon.x', getProperty('iconP2.x'))

        setProperty('fakeIcon.scale.x', 1)
        setProperty('fakeIcon.scale.y', 1)
        setProperty('fakeIcon.alpha', 1)
        setProperty('fakeIcon.angle', 0)
        setProperty('fakeIcon.visible', true)
        setObjectOrder('fakeIcon',getObjectOrder('iconP2') + 1)
        setProperty('fakeIcon.color', getColorFromHex('000000'))
    end
end

function onUpdatePost(elapsed)
    if (getProperty('fakeIcon.visible') == true) then
        if getProperty('fakeIcon.y') < 1000 then
            shit = 800
            setProperty('fakeIcon.scale.x', getProperty('fakeIcon.scale.x') - 0.0005)
            setProperty('fakeIcon.scale.y', getProperty('fakeIcon.scale.y') - 0.0005)
            setObjectOrder('fakeIcon',getObjectOrder('healthBar') - 1)
            mult = shit/2
        end

        dingle = dingle + (shit * elapsed) 
        shit = shit + (mult * elapsed)  
        mult = shit/2
        
        setProperty('fakeIcon.alpha', getProperty('fakeIcon.alpha') - 0.001)
        setProperty('fakeIcon.velocity.y', dingle)
        
        setProperty('fakeIcon.angle', getProperty('fakeIcon.angle') + (angleShit * elapsed))
        setProperty('fakeIcon.velocity.x', (dingle/4) - 120)
    end
end