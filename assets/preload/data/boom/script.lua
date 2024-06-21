function onCreatePost()
    makeAnimatedLuaSprite('hand', 'nelzya', 795, 300)
    addAnimationByPrefix('hand', 'raise', 'hand rise', 24, false)
    setObjectCamera('hand', 'camhud')
    addLuaSprite('hand', true)
    setProperty('hand.visible', false)
end

function onSongStart()
    setProperty('hand.visible', true)
    playAnim('hand', 'raise', true)
    runTimer('why', 4.18)
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'why' then
        setProperty('hand.visible', false) --for some reason it buggy after anim ends soooooo
    end
end