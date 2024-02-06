function onCreate()
    makeLuaText('lyrics', 'nothin', 0, 0, 450)

    setTextAlignment('lyrics', 'center')
    setTextSize('lyrics', 30)
    updateHitbox('lyrics')
    screenCenter('lyrics', 'x')

    setProperty('lyrics.alpha', 0)
    addLuaText('lyrics')
end

function onEvent(eventName, value1, value2)
    if eventName == 'Lyrics' then
        cancelTimer('lyricsTMR')
        cancelTween('lyricsBye')
        cancelTween('lyricsShrinkX')
        cancelTween('lyricsShrinkY')
        setProperty('lyrics.alpha', 1)
        setTextString('lyrics', value1)
        if value2 ~= nil and value2 ~= '' then
            setTextColor('lyrics', value2)
        else
            setTextColor('lyrics', 'ffffff')
        end

        setProperty('lyrics.scale.x', 1.2)
        setProperty('lyrics.scale.y', 1.2)

        doTweenX('lyricsShrinkX', 'lyrics.scale', 1, 0.45, 'cubeOut' )
        doTweenY('lyricsShrinkY', 'lyrics.scale', 1, 0.45, 'cubeOut' )

        updateHitbox('lyrics')
        screenCenter('lyrics', 'x')

        runTimer('lyricsTMR', 0.5)

    end
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'lyricsTMR' then
        doTweenAlpha('lyricsBye', 'lyrics', 0, 1)
    end
end