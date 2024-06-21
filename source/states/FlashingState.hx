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

	var flashDick:Alphabet;
	var yesText:Alphabet;
	var noText:Alphabet;

	var canChoose:Bool = false;
	var startTimer:FlxTimer;
	var whatWillPlay:Int = 1;
	override function create()
	{
		super.create();

		disclaimer = new FlxText(0, 0, FlxG.width, "WARNING!!!", 48);
		disclaimer.setFormat("HouseofTerror.ttf", 80, FlxColor.RED, CENTER);
		disclaimer.alpha = 0.00001;
		disclaimer.y += 120;
		add(disclaimer);

		warnText = new FlxText(0, 0, FlxG.width,
			"This mod has slurs and bad words, it's recommended to play\nthis mod with headphones and censore some audios if you\nfamily friendly youtube content maker",
			32);
		warnText.setFormat("HouseofTerror.ttf", 32, FlxColor.WHITE, CENTER);
		warnText.x += 10;
		warnText.alpha = 0;
		warnText.screenCenter(Y);
		add(warnText);

		flashDick = new Alphabet(0, 180, "Leave option\nFLASHING LIGHTS enabled?", true);
		flashDick.screenCenter(X);
		flashDick.alpha = 0;
		add(flashDick);

		yesText = new Alphabet(0, flashDick.y + 250, 'Yes', true);
		yesText.screenCenter(X);
		yesText.x -= 200;
		yesText.alpha = 0;
		add(yesText);
		noText = new Alphabet(0, flashDick.y + 250, 'No', true);
		noText.screenCenter(X);
		noText.x += 200;
		noText.alpha = 0;
		add(noText);

		FlxTween.tween(disclaimer, {alpha: 1}, 1);

		FlxG.sound.play(Paths.sound('disclamer/intro-1'), 1, false, null, true, function() {
			FlxTween.tween(warnText, {alpha: 1}, 1);
			FlxG.sound.play(Paths.sound('disclamer/intro-2'), 1, false, null, true, function() {
				warnText.text += '\nOh and also it has flashing lights, shaking screen\n and stuff that bad for epileptic guys';
				FlxG.sound.play(Paths.sound('disclamer/intro-3'), 1, false, null, true, function() {
					warnText.visible = false;
					disclaimer.visible = false;
					FlxG.sound.play(Paths.sound('disclamer/intro-4'), 1, false, null, true, function() {
						FlxTween.tween(flashDick, {alpha: 1}, 1);
						FlxTween.tween(noText, {alpha: 1}, 1);
						FlxTween.tween(yesText, {alpha: 1}, 1);
						FlxG.sound.play(Paths.sound('disclamer/flash-1'), 1, false, null, true, function() {
							canChoose = true;
							FlxG.sound.play(Paths.sound('disclamer/flash-2'));
							timerOfWaiting();
							FlxG.mouse.unload();
							FlxG.mouse.load(Paths.image("cursor1").bitmap, 1.5, 0);// you can't hide what you did
							FlxG.mouse.visible = true;
						});
					});
				});
			});
		});
	}

	var swagCounter:Int = 1;
	function timerOfWaiting()
	{
		startTimer = new FlxTimer().start(60, function(tmr:FlxTimer)
		{
			FlxG.sound.play(Paths.sound('disclamer/waiting-'+ FlxG.random.int(1, 18)));

			switch (swagCounter)
			{
				case 1 | 5 | 15 | 30 | 68:
					whatWillPlay += 1;
				case 69:
				    leftState = true;
					canChoose = false;
					FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
					ClientPrefs.data.flashing = true;
					ClientPrefs.saveSettings();
					FlxFlicker.flicker(yesText, 1, 0.06, true, false, function(flick:FlxFlicker)
					{
						FlxTween.tween(flashDick, {alpha: 0}, 0.6);
						FlxTween.tween(noText, {alpha: 0}, 0.6);
						FlxTween.tween(yesText, {alpha: 0}, 0.6);
					});
					soWhat(true);
			}

			swagCounter += 1;
		}, 69);
	}

	function goAwayBruh()
	{
		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;
		MusicBeatState.switchState(new TitleState());
	}

	function soWhat(sad:Bool = false)
	{
		if(sad)
		{
			FlxG.sound.play(Paths.sound('disclamer/enough'), 1, false, null, true, function() {

			});
		}
		else
		{
			FlxG.sound.play(Paths.sound('disclamer/accept-'+ whatWillPlay), 1, false, null, true, function() {

			});
		}
	}

	override function update(elapsed:Float)
	{
		if(canChoose)
		{
			if(FlxG.mouse.overlaps(yesText))
			{
				yesText.alpha = 0.6;
				if(FlxG.mouse.justPressed)
				{
					leftState = true;
					canChoose = false;
					FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
					ClientPrefs.data.flashing = true;
					ClientPrefs.saveSettings();
					startTimer.cancel();
					FlxFlicker.flicker(yesText, 1, 0.06, true, false, function(flick:FlxFlicker)
					{
						FlxTween.tween(flashDick, {alpha: 0}, 0.6);
						FlxTween.tween(noText, {alpha: 0}, 0.6);
						FlxTween.tween(yesText, {alpha: 0}, 0.6);
					});
					soWhat(false);
				}
			} else {
				yesText.alpha = 1;
			}

			if(FlxG.mouse.overlaps(noText))
			{
				noText.alpha = 0.6;
				if(FlxG.mouse.justPressed)
				{
					leftState = true;
					canChoose = false;
					FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
					ClientPrefs.data.flashing = true;
					ClientPrefs.saveSettings();
					startTimer.cancel();
					FlxFlicker.flicker(noText, 1, 0.06, true, false, function(flick:FlxFlicker)
					{
						FlxTween.tween(flashDick, {alpha: 0}, 0.6);
						FlxTween.tween(noText, {alpha: 0}, 0.6);
						FlxTween.tween(yesText, {alpha: 0}, 0.6);
					});
					soWhat(false);
				}
			} else {
				noText.alpha = 1;
			}
		}
		super.update(elapsed);
	}
}
