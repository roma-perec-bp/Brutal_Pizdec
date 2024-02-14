function onCreate()
    makeLuaSprite('iconScale', nil, 0, 0)
end

function onUpdatePost(elapsed)
    setProperty('iconP1.scale.x', getProperty('iconScale.scale.x'))
    setProperty('iconP1.scale.y', getProperty('iconScale.scale.y'))
    setProperty('iconP2.scale.x', getProperty('iconScale.scale.x'))
    setProperty('iconP2.scale.y', getProperty('iconScale.scale.y'))
end

function onBeatHit()
    if curBeat % 2 == 0 then
        setProperty('iconScale.scale.x', 2)
        setProperty('iconScale.scale.y', 0.5)

        setProperty('iconP1.angle', -20)
        setProperty('iconP2.angle', 20)

        doTweenX('scale1', 'iconScale.scale', 1, 3.5, 'elasticOut')
        doTweenY('scale2', 'iconScale.scale', 1, 3.5, 'elasticOut')

        doTweenAngle('p1Ang', 'iconP1', 0, 1, 'elasticOut')
        doTweenAngle('p2Ang', 'iconP2', 0, 1, 'elasticOut')
    else
        setProperty('iconScale.scale.x', 0.5)
        setProperty('iconScale.scale.y', 2)

        setProperty('iconP1.angle', 20)
        setProperty('iconP2.angle', -20)

        doTweenX('scale1', 'iconScale.scale', 1, 3.5, 'elasticOut')
        doTweenY('scale2', 'iconScale.scale', 1, 3.5, 'elasticOut')

        doTweenAngle('p1Ang', 'iconP1', 0, 1, 'elasticOut')
        doTweenAngle('p2Ang', 'iconP2', 0, 1, 'elasticOut')
    end
end