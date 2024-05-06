
function onCreate()
    makeLuaSprite('maniaPart', null, 360, 0)
	makeGraphic('maniaPart', 560, 720, '000000')
	setObjectCamera('maniaPart', 'hud')
	setProperty('maniaPart.alpha', 0.00001)
	addLuaSprite('maniaPart', false)
	
    --начало модчарта хахаха
    makeLuaSprite('blackFlash', null, 0, 0)
    makeGraphic('blackFlash', 1280, 720, '000000')
    setObjectCamera('blackFlash', 'hud')
    addLuaSprite('blackFlash', false)
    
    makeLuaSprite('vin', 'vin', 0, 0)
    setObjectCamera('vin', 'hud')
    addLuaSprite('vin', true)
end

function onStepHit()
    if curStep == 32 then
        doTweenAlpha('suka','blackFlash', 0, 1, 'linear')
    end
    if curStep == 288 then
        setProperty('vin.visible', false)
    end
    
    if curStep == 2720 then
        doTweenAlpha('maniaPartYea','maniaPart', 1, 0.5, 'linear')
    end
    if curStep == 2971 then
        doTweenAlpha('Fucked','maniaPart', 0, 0.1, 'linear')
    end
    if curStep == 3072 then
        setProperty('vin.visible', true)
    end
    if curStep == 3854 then
        setProperty('vin.visible', false)
    end
end