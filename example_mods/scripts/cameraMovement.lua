offset = 30
notes = {'Hurt Note','note1','note2'}
idlemov = false

function goodNoteHit(_, d, t)
	if not getProperty("isCameraOnForcedPos") and mustHitSection then
		camera(d, true, type)
	end
end
function opponentNoteHit(_, d, t)
	if not getProperty("isCameraOnForcedPos") and not mustHitSection then
		camera(d, false, t)
	end
end
function noteMiss(_, _, t)
	if not getProperty("isCameraOnForcedPos") then
		camera(nil, true, t)
	end
end

function onEvent(name, v1, v2)
	if name == "Camera Follow Pos" and v1 ~= '0' or v2 ~= '0' then
		camera()
	end
end


function camera(d,mp,t)	
x = 0
y = 0
secs = 1.27 *  getProperty("cameraSpeed") * getPropertyFromClass("flixel.FlxG", "sound.music.pitch")
	for _, n in ipairs(notes) do
		if t ~= n and (gfSection or mp == nil or mp == mustHitSection) then
			if d ~= nil then
				x = (d == 0 and -offset or d == 3 and offset)
				y = (d == 1 and offset or d == 2 and -offset) 
				runTimer('moveshit',stepCrochet * (0.0011 / getPropertyFromClass("flixel.FlxG", "sound.music.pitch")) * getProperty((gfSection and "gf" or (mp and "boyfriend" or "dad")) .. ".singDuration") )
			else
				cancelTimer('moveshit')
			end
		end
		--cancelTween('camXidle')
		--cancelTween('camYidle')
		doTweenX("camX", "camGame.targetOffset",x, secs, "quintOut")
		doTweenY("camY", "camGame.targetOffset",y, secs, "quintOut")
	end
end

function onTimerCompleted(t)
	if t == "moveshit" then
		camera()
	end	
end

function onUpdatePost()
	if idlemov and not getProperty("isCameraOnForcedPos") then
		secsidle = 1.27 *  getProperty("cameraSpeed") * getPropertyFromClass("flixel.FlxG", "sound.music.pitch")
		char = (gfSection and 'gf' or (mustHitSection and 'boyfriend' or 'dad'))
		frames = getProperty(char..'.animation.curAnim.numFrames')
			if getProperty(char..'.danceIdle') then
				if getProperty(char..'.animation.curAnim.curFrame') == tonumber(math.floor(frames/2)) then
					xid = (stringStartsWith(getProperty(char..'.animation.curAnim.name'),'danceLeft') and offset or stringStartsWith(getProperty(char..'.animation.curAnim.name'),'danceRight') and -offset)
					doTweenX("camXidle", "camGame.targetOffset",xid, secsidle, "quintOut")
				end
				if getProperty(char..'.animation.curAnim.curFrame') == 0 and (stringStartsWith(getProperty(char..'.animation.curAnim.name'),'danceLeft') or stringStartsWith(getProperty(char..'.animation.curAnim.name'),'danceRight')) then
					doTweenX("camXidle", "camGame.targetOffset",0, secsidle, "quintOut")
				end	
			else
				if getProperty(char..'.animation.curAnim.curFrame') == 0 then
					yid = (stringStartsWith(getProperty(char..'.animation.curAnim.name'),'idle') and offset)
					doTweenY("camYidle", "camGame.targetOffset",yid, secsidle, "quintOut")
				elseif getProperty(char..'.animation.curAnim.curFrame') == tonumber(math.floor(frames/2)) and not stringStartsWith(getProperty(char..'.animation.curAnim.name'),'sing') then
					doTweenY("camYidle", "camGame.targetOffset",0, secsidle, "quintOut")
				end
			end
	end
end