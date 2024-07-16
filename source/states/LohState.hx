package states;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

import objects.VideoSprite;

var videoShow:String = 'brutal-pizdec';

class LohState extends MusicBeatState
{
    public var videoCutscene:VideoSprite = null;
    override function create()
	{
        if (FlxG.random.bool(0.1))
        {
            videoShow = 'leaks'; //гыгыгы
        }
		#if VIDEOS_ALLOWED
		var foundFile:Bool = false;
		var fileName:String = Paths.video(videoShow);

		#if sys
		if (FileSystem.exists(fileName))
		#else
		if (OpenFlAssets.exists(fileName))
		#end
		foundFile = true;

		if (foundFile)
		{
			var cutscene:VideoSprite = new VideoSprite(fileName, false, true, false, false);

			cutscene.finishCallback = function()
			{
                remove(cutscene);
				LoadingState.loadAndSwitchState(new PlayState());
			};

			// Skip callback
			cutscene.onSkip = function()
			{
                remove(cutscene);
				LoadingState.loadAndSwitchState(new PlayState());
			};

            add(cutscene);

            cutscene.videoSprite.play();
		}
		#else
		FlxG.log.warn('Platform not supported!');
		LoadingState.loadAndSwitchState(new PlayState());
		#end
    }
}