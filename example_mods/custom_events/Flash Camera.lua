function onCreate()
	makeLuaSprite('flash', '', 0, 0);
	makeGraphic('flash',1280,720,'ffffff')
	setObjectCamera('flash', 'hud')
	setObjectOrder('flash', 0)
	addLuaSprite('flash', true);
	setProperty('flash.scale.x',2)
	setProperty('flash.scale.y',2)
	setProperty('flash.alpha',0)
end

function onEvent(eventName, value1, value2)
	if eventName == "Flash Camera" then
		setProperty('flash.alpha',1)
		if value2 ~= nil and value2 ~= '' then
			setProperty('flash.color', getColorFromHex(tostring(value2)))
		else
			setProperty('flash.color', getColorFromHex('ffffff'))
		end
		doTweenAlpha('BOO', 'flash', 0, value1, 'Linear')
	end
end