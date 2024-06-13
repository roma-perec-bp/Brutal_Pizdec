package states.stages;

import states.stages.objects.*;
import objects.Character;

class OldRoof extends BaseStage
{
	var bg2:BGSprite;
	override function create()
	{
		var bg:BGSprite = new BGSprite('roof', -600, -200, 0.9, 0.9);
		bg.setGraphicSize(Std.int(bg.width * 1.4));
		bg.updateHitbox();
		add(bg);

		if(songName == 'overfire-old')
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