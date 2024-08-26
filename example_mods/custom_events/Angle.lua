function onEvent(n)
    if n == "Angle" then
        if getRandomBool(50) then
            setProperty('camGame.angle', -7)
        else
            setProperty('camGame.angle', 7)
        end

        doTweenAngle('dick', 'camHUD', 0, stepCrochet * 0.005, 'circOut')
        doTweenAngle('boobs', 'camGame', 0, stepCrochet * 0.005, 'circOut')
    end
end