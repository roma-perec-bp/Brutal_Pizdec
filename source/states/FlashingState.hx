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

		disclaimer = new FlxText(0, 0, FlxG.width, "WARNING!!!", 48);
		disclaimer.setFormat("HouseofTerror.ttf", 80, FlxColor.RED, CENTER);
		disclaimer.alpha = 0.00001;
		disclaimer.y += 120;
		add(disclaimer);

		warnText = new FlxText(0, 0, FlxG.width,
			"This mod has slurs and bad words, it's recommended to play\n
			this mod with headphones and censore some audios if you\n
			family friendly youtube content maker",
			32);
		warnText.setFormat("HouseofTerror.ttf", 32, FlxColor.WHITE, CENTER);
		warnText.x += 10;
		warnText.screenCenter(Y);
		add(warnText);

		FlxTween.tween(disclaimer, {alpha: 1}, 0.6);

		FlxG.sound.play(Paths.sound('discalmer/intro-1'), 1, false, null, true, function() {
			FlxTween.tween(warnText, {alpha: 1}, 0.6);
			FlxG.sound.play(Paths.sound('discalmer/intro-2'), 1, false, null, true, function() {
				warnText.txt += '\nOh and also it has flashing lights, shaking screen\n and stuff that bad for epileptic guys'
				FlxG.sound.play(Paths.sound('discalmer/intro-3'), 1, false, null, true, function() {
					FlxG.sound.play(Paths.sound('discalmer/intro-4'), 1, false, null, true, function() {
						warnText.visible = false;
						disclaimer.visible = false;
					});
				});
			});
		});
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
