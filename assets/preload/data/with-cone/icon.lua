local turnvalue = 20
local x1 = 0
local x2 = 0

function onCreate()
    makeLuaSprite('iconP1obj', nil, 0, 0)
    makeLuaSprite('iconP2obj', nil, 0, 0)
end

function onUpdatePost(elapsed)
    if curBeat >= 208 and curBeat < 240 or curBeat >= 496 and curBeat < 624 then --DnB
        x1 = screenWidth - getProperty('healthBar.x') - (getProperty('healthBar.width') * (getProperty('healthBar.percent') * 0.01)) + (150 * getProperty('iconP1obj.scale.x') - 150) / 2 - 26
        x2 = screenWidth - getProperty('healthBar.x') - (getProperty('healthBar.width') * (getProperty('healthBar.percent') * 0.01)) - (150 * getProperty('iconP2obj.scale.x')) / 2 - 26 * 2
        setProperty('iconP1.x', x1)
        setProperty('iconP2.x', x2)
        setProperty('iconP1.scale.x', getProperty('iconP1obj.scale.x'))
        setProperty('iconP2.scale.x', getProperty('iconP2obj.scale.x'))
        setProperty('iconP1.scale.y', getProperty('iconP1obj.scale.y'))
        setProperty('iconP2.scale.y', getProperty('iconP2obj.scale.y'))
        setProperty('iconP1.y', getProperty('healthBar.y') - 150 - (150 * getProperty('iconP1.scale.y') / -2))
        setProperty('iconP2.y', getProperty('healthBar.y') - 150 - (150 * getProperty('iconP2.scale.y') / -2))
    end
    if curBeat >= 770 and curBeat < 836 then -- это для пиздец момента 🤫🧏🏻‍♂️
        setProperty('iconP1.offset.x', getRandomFloat(-4, 4))
        setProperty('iconP1.offset.y', getRandomFloat(-4, 4))
        setProperty('iconP2.offset.x', getRandomFloat(-4, 4))
        setProperty('iconP2.offset.y', getRandomFloat(-4, 4))
    end
end

function onBeatHit()
    if curBeat >= 208 and curBeat < 240 or curBeat >= 496 and curBeat < 624 then --DnB
        if curBeat % getProperty('gfSpeed') == 0 then
            if curBeat % (getProperty('gfSpeed') * 2) == 0 then
                scaleObject('iconP1obj', 1.1, 0.8)
                scaleObject('iconP2obj', 1.1, 1.3)
                setProperty('iconP1.angle', -15)
                setProperty('iconP2.angle', 15)
            else
                scaleObject('iconP1obj', 1.1, 1.3)
                scaleObject('iconP2obj', 1.1, 0.8)
                setProperty('iconP1.angle', 15)
                setProperty('iconP2.angle', -15)
            end
        end
        doTweenAngle('icon1tween', 'iconP1', 0, crochet / 1300 * getProperty('gfSpeed'), 'quadOut')
        doTweenAngle('icon2tween', 'iconP2', 0, crochet / 1300 * getProperty('gfSpeed') , 'quadOut')
        doTweenX('icon1objx', 'iconP1obj.scale', 1, crochet / 1300 * getProperty('gfSpeed'), 'quadOut')
        doTweenX('icon2objx', 'iconP2obj.scale', 1, crochet / 1300 * getProperty('gfSpeed'), 'quadOut')
        doTweenY('icon1objy', 'iconP1obj.scale', 1, crochet / 1300 * getProperty('gfSpeed'), 'quadOut')
        doTweenY('icon2objy', 'iconP2obj.scale', 1, crochet / 1300 * getProperty('gfSpeed'), 'quadOut')
    end

    if curBeat >= 48 and curBeat < 80 or curBeat >= 240 and curBeat < 272 or curBeat >= 624 and curBeat < 768 then --сальто
        turnvalue = 20 -- the icon shit
            if curBeat % 4 == 0 then
                turnvalue = 120
            else
                turnvalue = -20
            end

        setProperty('iconP2.angle',-turnvalue)
        setProperty('iconP1.angle',turnvalue)

        doTweenAngle('iconTween1','iconP1',0,crochet/1000,'circOut')
        doTweenAngle('iconTween2','iconP2',0,crochet/1000,'circOut')
    end

    if curBeat >= 80 and curBeat < 208 or curBeat >= 400 and curBeat < 496 then --баунс
        if getProperty('curBeat') % 1 == 0 then
            setProperty('iconP1.angle',1 * -20)
            setProperty('iconP2.angle',1 * 20)
            doTweenAngle('playericon', 'iconP1', 0, 0.5, 'linear')
            doTweenAngle('opponenticon', 'iconP2', 0, 0.5, 'linear')
        end

        if getProperty('curBeat') % 2 == 0 then
            setProperty('iconP1.angle',1 * 20)
            setProperty('iconP2.angle',1 * -20)
            doTweenAngle('playericon', 'iconP1', 0, 0.5, 'linear')
            doTweenAngle('opponenticon', 'iconP2', 0, 0.5, 'linear')
        end
    end
end