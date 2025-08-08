package states;

import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.text.FlxText;

class BdayState extends MusicBeatState
{
	var bday:FlxSprite;
	override function create()
	{
		super.create();

		FlxG.sound.playMusic(Paths.music('pixel_roof'));

		bday = new FlxSprite();
		bday.frames = Paths.getSparrowAtlas('bday_secret/bday_thing');
		bday.animation.addByPrefix('idle', 'lol', 6);
		bday.animation.play('idle');
		bday.screenCenter();
		bday.scale.set(1.3, 1.3);
		add(bday);
	}

	override function update(elapsed:Float)
	{
		if(controls.BACK)
        {
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
            FlxG.sound.play(Paths.sound('cancelMenu'));
            MusicBeatState.switchState(new MainMenuState());
        }

		if(controls.ACCEPT)
        {
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			FlxG.sound.play(Paths.sound('cancelMenu'));
            MusicBeatState.switchState(new MainMenuState());
        }

		super.update(elapsed);
	}
}
