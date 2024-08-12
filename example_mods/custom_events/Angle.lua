function onEvent(n)
    if n == "Angle" then
        setProperty('camHUD.angle', 5)
        setProperty('camGame.angle', 7)
        doTweenAngle('dick', 'camHUD', 0, stepCrochet * 0.005, 'circOut')
        doTweenAngle('boobs', 'camGame', 0, stepCrochet * 0.005, 'circOut')
    end
end