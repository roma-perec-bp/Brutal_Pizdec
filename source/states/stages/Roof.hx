package states.stages;

import states.stages.objects.*;
import objects.Character;

class Roof extends BaseStage
{
	override function create()
	{
		var bg:BGSprite = new BGSprite('sky', 0, 0, 0.75, 0.75);
		bg.setGraphicSize(Std.int(bg.width * 3));
		add(bg);

		var roof:BGSprite = new BGSprite('home', 0, 0);
		roof.setGraphicSize(Std.int(roof.width * 3));
		add(roof);
	}
}