function onSongStart()
    runHaxeCode([[
        game.songLength = (136 * 1000);
    ]]);
end

function onStepHit()
    if curStep == 1728 then
        runHaxeCode([[
             game.updateTime = true;
             FlxTween.tween(game, {songLength: (341 * 1000)}, 8, {ease: FlxEase.smootherStepInOut});
        ]]);
    end
end

function onUpdatePost(elapsed)
    if curStep > 4224 then
        setProperty('timeTxt.text', 'END OF THE LINE BUDDY')
    end
end