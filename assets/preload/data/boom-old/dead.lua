function onStepHit()
    if curStep == 1856 then
        doTweenX('dadScaleTweenX', 'dad.scale', 10, 3, 'linear')
        doTweenY('dadScaleTweenY', 'dad.scale', 10, 3, 'linear')
        doTweenAlpha('dadBye', 'dad', 0.001, 3, 'linear')
    end
end