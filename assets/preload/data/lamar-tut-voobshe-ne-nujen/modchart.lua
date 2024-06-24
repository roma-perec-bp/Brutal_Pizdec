local angleshit = 2;
local anglevar = 2;
local Meow1 = 0
local Meow2 = 112
local Meow3 = 112 * 2
local Meow4 = 112 * 3

-- rizzfest is best rizz ohio skibidi toilet

function onCreate()
    makeLuaSprite('iconScale', nil, 0, 0)
end

function onUpdatePost(elapsed)
    if curBeat >= 32 and curBeat < 96 or curBeat >= 192 and curBeat < 256 then
    setProperty('iconP1.scale.x', getProperty('iconScale.scale.x'))
    setProperty('iconP1.scale.y', getProperty('iconScale.scale.y'))
    setProperty('iconP2.scale.x', getProperty('iconScale.scale.x'))
    setProperty('iconP2.scale.y', getProperty('iconScale.scale.y'))
    end
end

function onBeatHit()
	if curBeat >= 32 and curBeat < 96 then
	  if curBeat % 2 == 0 then
        setProperty('iconScale.scale.x', 2)
        setProperty('iconScale.scale.y', 0.5)

        setProperty('iconP1.angle', -20)
        setProperty('iconP2.angle', 20)

        doTweenX('scale1', 'iconScale.scale', 1, 3.5, 'elasticOut')
        doTweenY('scale2', 'iconScale.scale', 1, 3.5, 'elasticOut')

        doTweenAngle('p1Ang', 'iconP1', 0, 1, 'elasticOut')
        doTweenAngle('p2Ang', 'iconP2', 0, 1, 'elasticOut')
        
        angleshit = anglevar;
    else
        setProperty('iconScale.scale.x', 0.5)
        setProperty('iconScale.scale.y', 2)

        setProperty('iconP1.angle', 20)
        setProperty('iconP2.angle', -20)

        doTweenX('scale1', 'iconScale.scale', 1, 3.5, 'elasticOut')
        doTweenY('scale2', 'iconScale.scale', 1, 3.5, 'elasticOut')

        doTweenAngle('p1Ang', 'iconP1', 0, 1, 'elasticOut')
        doTweenAngle('p2Ang', 'iconP2', 0, 1, 'elasticOut')
        angleshit = -anglevar;
    end

		setProperty('camHUD.angle',angleshit*3)
		setProperty('camGame.angle',angleshit*3)
		doTweenAngle('turn', 'camHUD', angleshit, stepCrochet*0.002, 'circOut')
		doTweenX('tuin', 'camHUD', -angleshit*8, crochet*0.001, 'linear')
		doTweenAngle('tt', 'camGame', angleshit, stepCrochet*0.002, 'circOut')
		doTweenX('ttrn', 'camGame', -angleshit*8, crochet*0.001, 'linear')
	elseif curBeat >= 96 and curBeat < 192 then
	    setProperty('camHUD.angle',0)
		setProperty('camHUD.x',0)
		setProperty('camHUD.y',0)
	elseif curBeat >= 192 and curBeat < 256 then
			
	        if curBeat % 2 == 0 then
        setProperty('iconScale.scale.x', 2)
        setProperty('iconScale.scale.y', 0.5)

        setProperty('iconP1.angle', -20)
        setProperty('iconP2.angle', 20)

        doTweenX('scale1', 'iconScale.scale', 1, 3.5, 'elasticOut')
        doTweenY('scale2', 'iconScale.scale', 1, 3.5, 'elasticOut')

        doTweenAngle('p1Ang', 'iconP1', 0, 1, 'elasticOut')
        doTweenAngle('p2Ang', 'iconP2', 0, 1, 'elasticOut')
        
        angleshit = anglevar;
    else
        setProperty('iconScale.scale.x', 0.5)
        setProperty('iconScale.scale.y', 2)

        setProperty('iconP1.angle', 20)
        setProperty('iconP2.angle', -20)

        doTweenX('scale1', 'iconScale.scale', 1, 3.5, 'elasticOut')
        doTweenY('scale2', 'iconScale.scale', 1, 3.5, 'elasticOut')

        doTweenAngle('p1Ang', 'iconP1', 0, 1, 'elasticOut')
        doTweenAngle('p2Ang', 'iconP2', 0, 1, 'elasticOut')
        angleshit = -anglevar;
    end
		setProperty('camHUD.angle',angleshit*3)
		setProperty('camGame.angle',angleshit*3)
		doTweenAngle('turn', 'camHUD', angleshit, stepCrochet*0.002, 'circOut')
		doTweenX('tuin', 'camHUD', -angleshit*8, crochet*0.001, 'linear')
		doTweenAngle('tt', 'camGame', angleshit, stepCrochet*0.002, 'circOut')
		doTweenX('ttrn', 'camGame', -angleshit*8, crochet*0.001, 'linear')
	elseif curBeat >= 256 then
		setProperty('camHUD.angle',0)
		setProperty('camHUD.x',0)
		setProperty('camHUD.y',0)
	end
		
end