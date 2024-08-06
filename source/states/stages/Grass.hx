package states.stages;

import states.stages.objects.*;
import objects.Character;
import substates.GameOverSubstate;

class Grass extends BaseStage
{
	var day:BGSprite;
	override function create()
	{
		game.skipCountdown = true;
		GameOverSubstate.loopSoundName = 'gameOverKlork';
		
		day = new BGSprite('day', 0, 0);
		day.screenCenter();
		day.setGraphicSize(Std.int(day.width * 1.5));
		add(day);
	}

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case 'evening time':
				var curColorDad:FlxColor = game.dad.color;
				var curColorBF:FlxColor = game.boyfriend.color;
				var curColorGF:FlxColor = game.gf.color;
				var curColorBg:FlxColor = day.color;

				curColorDad.alphaFloat = game.dad.alpha;
				curColorBF.alphaFloat = game.boyfriend.alpha;
				curColorGF.alphaFloat = game.gf.alpha;
				curColorBg.alphaFloat = day.alpha;

				FlxTween.color(day, 3, curColorBg, 0xffff8fb2);
				FlxTween.color(game.dad, 3, curColorDad, 0xffff8fb2);
				FlxTween.color(game.gf, 3, curColorGF, 0xffff8fb2);
				FlxTween.color(game.boyfriend, 3, curColorBF, 0xffff8fb2);
			case 'slow evening time':
				var curColorDad:FlxColor = game.dad.color;
				var curColorBF:FlxColor = game.boyfriend.color;
				var curColorGF:FlxColor = game.gf.color;
				var curColorBg:FlxColor = day.color;

				curColorDad.alphaFloat = game.dad.alpha;
				curColorBF.alphaFloat = game.boyfriend.alpha;
				curColorGF.alphaFloat = game.gf.alpha;
				curColorBg.alphaFloat = day.alpha;

				FlxTween.color(day, 15, curColorBg, 0xffff8fb2);
				FlxTween.color(game.dad, 15, curColorDad, 0xffff8fb2);
				FlxTween.color(game.boyfriend, 15, curColorBF, 0xffff8fb2);
				FlxTween.color(game.gf, 15, curColorGF, 0xffff8fb2);
			case 'night time':
				var curColorDad:FlxColor = game.dad.color;
				var curColorBF:FlxColor = game.boyfriend.color;
				var curColorGF:FlxColor = game.gf.color;
				var curColorBg:FlxColor = day.color;

				curColorDad.alphaFloat = game.dad.alpha;
				curColorBF.alphaFloat = game.boyfriend.alpha;
				curColorGF.alphaFloat = game.gf.alpha;
				curColorBg.alphaFloat = day.alpha;

				FlxTween.color(day, 10, curColorBg, 0xFF878787);
				FlxTween.color(game.gf, 10, curColorGF, 0xFF878787);
				FlxTween.color(game.dad, 10, curColorDad, 0xFF878787);
				FlxTween.color(game.boyfriend, 10, curColorBF, 0xFF878787);
			case 'day time':
				var curColorDad:FlxColor = game.dad.color;
				var curColorBF:FlxColor = game.boyfriend.color;
				var curColorGF:FlxColor = game.gf.color;
				var curColorBg:FlxColor = day.color;

				curColorDad.alphaFloat = game.dad.alpha;
				curColorBF.alphaFloat = game.boyfriend.alpha;
				curColorGF.alphaFloat = game.gf.alpha;
				curColorBg.alphaFloat = day.alpha;

				FlxTween.color(day, 10, curColorBg, 0xffFFFFFF);
				FlxTween.color(game.gf, 10, curColorGF, 0xffFFFFFF);
				FlxTween.color(game.boyfriend, 10, curColorBF, 0xffFFFFFF);
				FlxTween.color(game.dad, 10, curColorDad, 0xffFFFFFF);
		}
	}
}