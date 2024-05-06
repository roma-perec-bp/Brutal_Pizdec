function onCreate()
    makeLuaSprite('intro', 'songIntro', 0, -60)
    scaleObject('intro', 0.8, 0.8)
    setObjectCamera('intro', 'other')
    addLuaSprite('intro', false)

    makeLuaText('nameSong', 'BOOM', 0, 520, 250)
    setTextAlignment('nameSong', 'center')
    setTextColor('nameSong', '0xFFff0000')
    setTextSize('nameSong', 100)
    setObjectCamera('nameSong', 'other')
    addLuaText('nameSong')

    makeLuaText('creditSong', 'song by: Rom4chek', 0, 450, 400)
    setTextAlignment('creditSong', 'center')
    setTextSize('creditSong', 50)
    setObjectCamera('creditSong', 'other')
    addLuaText('creditSong')

    doTweenX('hey', 'intro', -1500, 0.0001, 'quadinout')
    doTweenX('heyName', 'nameSong', -950, 0.0001, 'quadinout')
    doTweenX('heyCred', 'creditSong', -1000, 0.0001, 'quadinout')
end

function onSongStart()
    doTweenX('hey', 'intro', 0, 1, 'quadinout')
    doTweenX('heyName', 'nameSong', 520, 1, 'quadinout')
    doTweenX('heyCred', 'creditSong', 450, 1, 'quadinout')
end

function onBeatHit()
    if curBeat == 8 then
        doTweenX('bye', 'intro', -1500, 2, 'quadinout')
        doTweenX('byeName', 'nameSong', -950, 2, 'quadinout')
        doTweenX('byecree', 'creditSong', -1000, 2, 'quadinout')
    end
end