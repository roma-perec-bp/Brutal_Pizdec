package states.stages;

import states.stages.objects.*;
import substates.GameOverSubstate;
import objects.Character;

class OldRoof extends BaseStage
{
	var bg2:BGSprite;
	override function create()
	{
		var _song = PlayState.SONG;
		if(_song.gameOverLoop == null || _song.gameOverLoop.trim().length < 1) GameOverSubstate.loopSoundName = 'gameOver-old';
		if(_song.gameOverEnd == null || _song.gameOverEnd.trim().length < 1) GameOverSubstate.endSoundName = 'gameOverEnd-old';

		var bg:BGSprite = new BGSprite('roof', -600, -200, 0.9, 0.9);
		bg.setGraphicSize(Std.int(bg.width * 1.4));
		bg.updateHitbox();
		add(bg);

		if(PlayState.SONG.song == 'Overfire OLD')
		{
			bg2 = new BGSprite('grasswalk', -600, -200, 0.9, 0.9);
			bg2.setGraphicSize(Std.int(bg.width * 1.4));
			bg2.updateHitbox();
			bg2.alpha = 0.001;
			add(bg2);
		}

		PlayState.stageUI = "old";
	}

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case 'GrassHey':
				FlxG.camera.flash(FlxColor.WHITE, 1, null, true);
				if(value1 == 'on')
					bg2.alpha = 1;
				else
					bg2.alpha = 0.000001;
		}
	}
}