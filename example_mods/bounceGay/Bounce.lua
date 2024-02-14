function onBeatHit()
	if getProperty('curBeat') % 1 == 0 then
			setProperty('iconP1.angle',1 * -10)
			setProperty('iconP2.angle',1 * 10)
			doTweenAngle('playericon', 'iconP1', 0, 0.5, 'linear')
			doTweenAngle('opponenticon', 'iconP2', 0, 0.5, 'linear')
	end

	if getProperty('curBeat') % 2 == 0 then
			setProperty('iconP1.angle',1 * 10)
			setProperty('iconP2.angle',1 * -10)
			doTweenAngle('playericon', 'iconP1', 0, 0.5, 'linear')
			doTweenAngle('opponenticon', 'iconP2', 0, 0.5, 'linear')
   end
end
