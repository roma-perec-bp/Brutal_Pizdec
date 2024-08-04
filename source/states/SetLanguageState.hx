package states;

import backend.WeekData;
import backend.Highscore;

import flixel.FlxSubState;
import states.MainMenuState;

class SetLanguageState extends MusicBeatState
{
	var bg:FlxSprite;
	var alphabetArray:Array<Alphabet> = [];
	var onYes:Bool = false;
	var yesText:Alphabet;
	var noText:Alphabet;

	// Week -1 = Freeplay
	public function new()
	{
		super();

		var bgM = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bgM.color = 0xffd700ff;
		add(bgM);
		bgM.screenCenter();

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var text:Alphabet = new Alphabet(0, 160, "Which language you prefer?\nONLY SUBTITLES AND ENDING SCREENS\nWILL BE CHANGED", true);
		alphabetArray.push(text);
		text.alpha = 0;
		text.scaleX = 0.7;
		text.scaleY = 0.7;
		text.screenCenter(X);
		add(text);

		yesText = new Alphabet(0, text.y + 250, 'English', true);
		yesText.screenCenter(X);
		yesText.x -= 200;
		add(yesText);
		noText = new Alphabet(0, text.y + 250, 'Russian', true);
		noText.screenCenter(X);
		noText.x += 200;
		add(noText);
		updateOptions();
	}

	override function update(elapsed:Float)
	{
		bg.alpha += elapsed * 1.5;
		if(bg.alpha > 0.6) bg.alpha = 0.6;

		for (i in 0...alphabetArray.length) {
			var spr = alphabetArray[i];
			spr.alpha += elapsed * 2.5;
		}

		if(controls.UI_LEFT_P || controls.UI_RIGHT_P) {
			FlxG.sound.play(Paths.sound('scrollMenu'), 1);
			onYes = !onYes;
			updateOptions();
		}
		if(controls.ACCEPT) {
			if(onYes) {
				ClientPrefs.data.language = 'English';
			}
			else{
				ClientPrefs.data.language = 'Russian';
			}
			ClientPrefs.saveSettings();
			MusicBeatState.switchState(new MainMenuState());
		}
		super.update(elapsed);
	}

	function updateOptions() {
		var scales:Array<Float> = [0.75, 1];
		var alphas:Array<Float> = [0.6, 1.25];
		var confirmInt:Int = onYes ? 1 : 0;

		yesText.alpha = alphas[confirmInt];
		yesText.scale.set(scales[confirmInt], scales[confirmInt]);
		noText.alpha = alphas[1 - confirmInt];
		noText.scale.set(scales[1 - confirmInt], scales[1 - confirmInt]);
	}
}