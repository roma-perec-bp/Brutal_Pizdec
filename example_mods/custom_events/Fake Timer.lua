local songLengthOriginal;
local songLengthChange;

function onEvent(name, var1, var2)
	if name == "Fake Timer" then
        setProperty("songLength", var1);
        songLengthChange = var1;

        if tostring(var2) == "1" then
            songLengthChange = songLengthOriginal;

            runHaxeCode('FlxTween.tween(game, {songLength: '..songLengthOriginal..'}, 2);');
        end
	end
end

function onSongStart()
    songLengthOriginal = getProperty("songLength");
end