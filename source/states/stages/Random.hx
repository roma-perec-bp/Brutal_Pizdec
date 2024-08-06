package states.stages;

import states.stages.objects.*;
import objects.Character;
import substates.GameOverSubstate;

class Random extends BaseStage
{
	override function create()
	{	
		GameOverSubstate.loopSoundName = 'gameOverT-Short';
		var bg:BGSprite = new BGSprite('bg', 0, 0, 0.3, 0.3);
		bg.setGraphicSize(Std.int(bg.width * 1.5));
		add(bg);

		var clouds:BGSprite = new BGSprite('clouds', 0, 0, 0.3, 0.3);
		clouds.setGraphicSize(Std.int(clouds.width * 1.5));
		add(clouds);

		var trees:BGSprite = new BGSprite('trees', 0, 0, 0.9, 0.9);
		trees.setGraphicSize(Std.int(trees.width * 1.5));
		add(trees);

		var zabor:BGSprite = new BGSprite('zabor', 0, 0);
		zabor.setGraphicSize(Std.int(zabor.width * 1.5));
		add(zabor);

		var shit:BGSprite = new BGSprite('stuff', 0, 0);
		shit.setGraphicSize(Std.int(shit.width * 1.5));
		add(shit);
	}
}