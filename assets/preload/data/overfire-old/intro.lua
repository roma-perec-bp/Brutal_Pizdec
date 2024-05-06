function onCreate()
    makeLuaSprite('intro', 'song_credits-old', 0, -60)
    scaleObject('intro', 0.8, 0.8)
    setObjectCamera('intro', 'other')
    addLuaSprite('intro', false)

    makeLuaText('nameSong', 'Overfire', 0, 480, 250)
    setTextFont('nameSong', 'HouseofTerror.ttf')
    setTextAlignment('nameSong', 'center')
    setTextColor('nameSong', '0xFFff8600')
    setTextSize('nameSong', 100)
    setObjectCamera('nameSong', 'other')
    addLuaText('nameSong')

    makeLuaText('creditSong', 'og song by: Sock.Clip || mix by: Rom4chek', 0, 350, 400)
    setTextFont('creditSong', 'HouseofTerror.ttf')
    setTextAlignment('creditSong', 'center')
    setTextSize('creditSong', 35)
    setObjectCamera('creditSong', 'other')
    addLuaText('creditSong')

    doTweenX('hey', 'intro', -1500, 0.0001, 'quadinout')
    doTweenX('heyName', 'nameSong', -1050, 0.0001, 'quadinout')
    doTweenX('heyCred', 'creditSong', -1150, 0.0001, 'quadinout')
end

function onSongStart()
    doTweenX('hey', 'intro', 0, 1, 'quadinout')
    doTweenX('heyName', 'nameSong', 480, 1, 'quadinout')
    doTweenX('heyCred', 'creditSong', 350, 1, 'quadinout')
end

function onBeatHit()
    if curBeat == 8 then
        doTweenX('bye', 'intro', -1500, 2, 'quadinout')
        doTweenX('byeName', 'nameSong', -1050, 2, 'quadinout')
        doTweenX('byecree', 'creditSong', -1150, 2, 'quadinout')
    end
end