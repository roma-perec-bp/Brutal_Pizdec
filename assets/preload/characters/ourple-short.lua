flipped = true

function onBeatHit() 
        if getProperty('healthBar.percent') > 20 then
                flipped = not flipped
                setProperty('iconP1.flipY', flipped)
        end
end

function onStepHit() 
        if getProperty('healthBar.percent') < 20 and curStep % 2 == 0 then
                flipped = not flipped
                setProperty('iconP1.flipY', flipped)
        end
end
function onUpdate(e)
        local angleOfs = math.random(-5, 5)
        if getProperty('healthBar.percent') < 20 then
                setProperty('iconP1.angle', angleOfs)
        else
                setProperty('iconP1.angle', 0)
        end
end










--[[function onNuke()
        setNuke(home == "RandomShort57")
        id = home
        activeNuke('accept')
        print(setNuke)
end]]--