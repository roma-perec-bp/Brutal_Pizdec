package states.stages;

import states.stages.objects.*;
import objects.Character;

class Grass extends BaseStage
{
	override function create()
	{
		game.skipCountdown = true;
		
		var day:BGSprite = new BGSprite('day', 0, 0);
		day.screenCenter();
		day.setGraphicSize(Std.int(day.width * 1.5));
		add(day);
	}
}