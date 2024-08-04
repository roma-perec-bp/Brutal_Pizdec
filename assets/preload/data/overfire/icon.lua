-- игры кончились чмо

local turnvalue = 20
local x1 = 0
local x2 = 0

function onCreate()
    makeLuaSprite('iconP1obj', nil)
    makeLuaSprite('iconP2obj', nil)
end

function onUpdatePost(elapsed)
    if curBeat >= 144 and curBeat < 176 or curBeat >= 208 and curBeat < 272 or curBeat >= 336 and curBeat < 400 or curBeat >= 960 and curBeat < 1052 then -- DnB сын пизды
        x1 = screenWidth - getProperty('healthBar.x') - (getProperty('healthBar.width') * (getProperty('healthBar.percent') * 0.01))
        + (150 * getProperty('iconP1obj.scale.x') - 150) / 2 - 26
        
        x2 = screenWidth - getProperty('healthBar.x') - (getProperty('healthBar.width') * (getProperty('healthBar.percent') * 0.01))
        - (150 * getProperty('iconP2obj.scale.x')) / 2 - 26 * 2
        
        setProperty('iconP1.x', x1)
        setProperty('iconP2.x', x2)
        setProperty('iconP1.scale.x', getProperty('iconP1obj.scale.x'))
        setProperty('iconP2.scale.x', getProperty('iconP2obj.scale.x'))
        setProperty('iconP1.scale.y', getProperty('iconP1obj.scale.y'))
        setProperty('iconP2.scale.y', getProperty('iconP2obj.scale.y'))
        setProperty('iconP1.y', getProperty('healthBar.y') - 150 - (150 * getProperty('iconP1.scale.y') / -2))
        setProperty('iconP2.y', getProperty('healthBar.y') - 150 - (150 * getProperty('iconP2.scale.y') / -2))
    end
end


function onBeatHit()
    if curBeat >= 16 and curBeat < 48 or curBeat >= 592 and curBeat < 656 or curBeat >= 928 and curBeat < 960 then -- Circle
        turnvalue = 20
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
    if curBeat >= 48 and curBeat < 112 or curBeat >= 304 and curBeat < 336 or curBeat >= 528 and curBeat < 592 or curBeat >= 1056 and curBeat < 1120 then -- bounce
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
    if curBeat >= 496 and curBeat < 528 then -- bounce 8 beat
        if getProperty('curBeat') % 2 == 0 then
			setProperty('iconP1.angle',1 * -20)
			setProperty('iconP2.angle',1 * 20)
			doTweenAngle('playericon', 'iconP1', 0, 0.5, 'linear')
			doTweenAngle('opponenticon', 'iconP2', 0, 0.5, 'linear')
    	end
    
    	if getProperty('curBeat') % 4 == 0 then
    			setProperty('iconP1.angle',1 * 20)
    			setProperty('iconP2.angle',1 * -20)
    			doTweenAngle('playericon', 'iconP1', 0, 0.5, 'linear')
    			doTweenAngle('opponenticon', 'iconP2', 0, 0.5, 'linear')
        end
    end
    if curBeat >= 144 and curBeat < 176 or curBeat >= 208 and curBeat < 272 or curBeat >= 336 and curBeat < 400 or curBeat >= 960 and curBeat < 1052 then -- DnB сын пизды
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
end

-- у ромы хуй маленки