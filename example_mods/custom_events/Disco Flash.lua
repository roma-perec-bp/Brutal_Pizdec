function onCreate()
	makeLuaSprite('flash', 'discoVin', 0, 0); -- почему это зуйня не отображается имеено на песни ламара блять
	setObjectCamera('flash', 'hud')
	setObjectOrder('flash', 0)
	addLuaSprite('flash', true);
	setProperty('flash.alpha',0)
	setProperty('flash.color', getColorFromHex(value2));
end

function onEvent(eventName, value1, value2)
	if eventName == "Disco Flash" then
		setProperty('flash.alpha',1)
		if value2 ~= nil and value2 ~= '' then
			setProperty('flash.color', getColorFromHex(tostring(value2)))
		else
			setProperty('flash.color', getColorFromHex('ffffff'))
		end
		doTweenAlpha('BOO', 'flash', 0, value1, 'Linear')
	end
end
