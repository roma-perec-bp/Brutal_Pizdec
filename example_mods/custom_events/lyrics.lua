---@diagnostic disable: undefined-global, lowercase-global
local textStringStart = 0
local textStringLast = 0

local rus = ''
local eng = ''

function onCreate()
    makeLuaText('lyrics', 'nothin', 0, 0, 450)

    setTextAlignment('lyrics', 'center')
    setTextSize('lyrics', 30)
    updateHitbox('lyrics')
    screenCenter('lyrics', 'x')
    setTextFont('lyrics', 'HouseofTerror.ttf')

    setProperty('lyrics.alpha', 0)
    addLuaText('lyrics')
end

function onEvent(eventName, value1, value2)
    if eventName == 'lyrics' then
        cancelTimer('lyricsTMR')
        cancelTween('lyricsBye')
        cancelTween('lyricsShrinkX')
        cancelTween('lyricsShrinkY')
        setProperty('lyrics.alpha', 1)

        tableV1 = stringSplit(value1,'$')
        rus = stringTrim(split[2])
        eng = stringTrim(split[1])

        if getPropertyFromClass('ClientPrefs', 'language') == 'Russian' then
            setTextString('lyrics', rus)
        else
            setTextString('lyrics', eng)
        end

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