package states;

import flixel.FlxSubState;

import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;

class FlashingState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var warnText:FlxText;
	var disclaimer:FlxText;
	var enterText:FlxText;
	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		disclaimer = new FlxText(0, 0, FlxG.width, "WATCH OUT!", 48);
		disclaimer.setFormat("vcr.ttf", 80, FlxColor.RED, CENTER);
		disclaimer.y += 120;
		add(disclaimer);

		warnText = new FlxText(0, 0, FlxG.width,
			"In this mod there will be unsencored words and there will also be flashing lights!
			If you have a low PC or your FPS is down,
			then I recommend checking the
			settings in the \"Graphics\" categories",
			32);
		warnText.setFormat("vcr.ttf", 32, FlxColor.WHITE, CENTER);
		warnText.x += 10;
		warnText.screenCenter(Y);
		add(warnText);

		enterText = new FlxText(0, 0, FlxG.width,
			"PRESS ENTER TO START",
			32);
		enterText.setFormat("vcr.ttf", 64, FlxColor.GREEN, CENTER);
		enterText.y += 520;
		add(enterText);
	}


	override function update(elapsed:Float)
	{
		if(!leftState) {
			if (controls.ACCEPT) {
				leftState = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					ClientPrefs.saveSettings();
					FlxFlicker.flicker(enterText, 1, 0.1, false, true, function(flk:FlxFlicker) {
							FlxTween.tween(disclaimer, {alpha: 0}, 1);
							FlxTween.tween(warnText, {alpha: 0}, 1, {
								onComplete: function (twn:FlxTween) {
									MusicBeatState.switchState(new TitleState());
								}
					
						});
					});
			}
		}
		super.update(elapsed);
	}
}
