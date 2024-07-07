package states.stages;

import states.stages.objects.*;
import objects.Character;

class Lamar extends BaseStage
{
	override function create()
	{	
		var day:BGSprite = new BGSprite('lamar', 0, 0);
		day.screenCenter();
		day.setGraphicSize(Std.int(day.width * 1.5));
		add(day);
	}
}