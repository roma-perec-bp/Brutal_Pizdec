function onCreate() 
    makeLuaSprite('blammedLightsBlack', '', getPropertyFromClass('flixel.FlxG', 'width') * -0.5, getPropertyFromClass('flixel.FlxG', 'height') * -0.5)
      makeGraphic('blammedLightsBlack', getPropertyFromClass('flixel.FlxG', 'width') * 2, getPropertyFromClass('flixel.FlxG', 'height') * 2, '000000')
      setScrollFactor('blammedLightsBlack', 0)
      setProperty('blammedLightsBlack.scale.x', 5)
      setProperty('blammedLightsBlack.scale.y', 5)
      setProperty('blammedLightsBlack.alpha', 0.001)
      addLuaSprite('blammedLightsBlack', false)
end

function onStepHit()
    if curStep == 1472 then
      setProperty('blammedLightsBlack.alpha', 1)
    end
    if curStep == 1728 then
        setProperty('blammedLightsBlack.alpha', 0)
      end
     if curStep == 1888 then
        cameraFade('camhud', '000000', 10)
    end
end