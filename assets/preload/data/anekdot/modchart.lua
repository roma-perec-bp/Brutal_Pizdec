local angleshit = 0.5;
local anglevar = 0.5;

function onBeatHit()
	if curBeat >= 224 and curBeat < 288 and curBeat >= 384 and curBeat < 448 then
		triggerEvent('Add Camera Zoom', 0.04,0.05)

		if curBeat % 2 == 0 then
		        angleshit = anglevar;
		else
			angleshit = -anglevar;
		end
		setProperty('camHUD.angle',angleshit*3)
		setProperty('camGame.angle',angleshit*3)
		doTweenAngle('turn', 'camHUD', angleshit, stepCrochet*0.002, 'circOut')
		doTweenX('tuin', 'camHUD', -angleshit*8, crochet*0.001, 'linear')
		doTweenAngle('tt', 'camGame', angleshit, stepCrochet*0.002, 'circOut')
		doTweenX('ttrn', 'camGame', -angleshit*8, crochet*0.001, 'linear')
	else
		doTweenAngle('dick', 'camHUD', 0, stepCrochet * 0.005, 'circOut')
                doTweenAngle('boobs', 'camGame', 0, stepCrochet * 0.005, 'circOut')
	        doTweenX('dickB', 'camHUD', 0, stepCrochet * 0.005, 'circOut')
                doTweenX('boobsB', 'camGame', 0, stepCrochet * 0.005, 'circOut')
	end
		
end
