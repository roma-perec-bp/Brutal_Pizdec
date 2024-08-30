package options;

import objects.Alphabet;

class DeleteSubstate extends MusicBeatSubstate
{
	var delPhase:Int = 0;
	var timer:Float = 1;
	var text:FlxText;
	var darkbg:FlxSprite;

	public function new()
		{
			super();

			darkbg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			darkbg.scrollFactor.set(0, 0);
			darkbg.setGraphicSize(Std.int(darkbg.width * 3));
			darkbg.alpha = 0.2;
			add(darkbg);

			text = new FlxText(0, 0, 1000, 'Do you want to delete all your progress?\n\n\nPress Enter to continue', 64);
			text.setFormat(Paths.font("HouseofTerror.ttf"), 36, FlxColor.RED, "center", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.screenCenter(XY);
			add(text);
		}

	override function update(elapsed:Float)
	{
		if(timer > 0){
			timer -= elapsed;
		}else{
			timer = 0;
		}
		if (controls.BACK && delPhase != 4)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
            FlxG.sound.music.volume = 0.7;
			close();
		}
			
		if(controls.ACCEPT && delPhase <= 3 && timer == 0){
			switch(delPhase){
				case 0:
					timer = 1;
					text.text = 'to make it clear, you will lose all your progress in the mod\n\nPress enter if you REALLY want to delete it';
					text.screenCenter(XY);
				case 1:
					FlxG.mouse.visible = true;
					timer = 1;
                    text.text = 'Are you REALLY SURE?\nYou will lose everything\nScore, progress and etc';
                    text.screenCenter(XY);
				case 2:
					timer = 1;
					text.y = 0;
					text.text = 'Press enter For real this time to delete your progress';
					text.screenCenter(XY);
				case 3:
					FlxG.save.erase();
					text.text = 'All your data was succesfully deleted\n\nrestart the game to continue';
					text.screenCenter(XY);
			}
			delPhase++;
			FlxG.sound.music.volume -= 0.3;
			darkbg.alpha += 0.2;
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
	}
}