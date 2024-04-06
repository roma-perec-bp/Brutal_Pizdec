function onEvent(eventName, value1, value2)
	if eventName == "Flash Camera" then
		if value2 ~= nil and value2 ~= '' then
			cameraFlash('camGame', (tostring(value2)), v1)
		else
			cameraFlash('camGame', 'ffffff', v1)
		end
	end
end