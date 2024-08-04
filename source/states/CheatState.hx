package states;

import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.text.FlxText;

import backend.Achievements;

class CheatState extends MusicBeatState
{
	var text:FlxText;
	var scary:FlxSprite;
	override function create()
	{
		super.create();

		ClientPrefs.data.downScroll = false;	
		ClientPrefs.data.middleScroll = false;

		scary = new FlxSprite().loadGraphic(Paths.image('uh oh'));
		scary.screenCenter();
		scary.alpha = 0;
		add(scary);

        text = new FlxText(0, 0, FlxG.width, '', 32);
		text.setFormat(Paths.font("scary.otf"), 32, FlxColor.RED, CENTER);
		text.x += 10;
		text.screenCenter(Y);
        add(text);

		text.text = 'Warning, scroll change was detected\n\nディックディックお尻ディック弄す吸盤';
		new FlxTimer().start(4, function(tmr:FlxTimer)
		{
			text.text = 'It is illegal to use middle and down scroll types in this mod\n\n何もしなかったのか臭いホモか?';
			new FlxTimer().start(4, function(tmr:FlxTimer)
			{
				text.text = 'Immediately remove the script and then continue playing\n\n今すぐこのクソを出さなければ、あなたは犯されています！!!';
				new FlxTimer().start(4, function(tmr:FlxTimer)
				{
					text.text = 'Cheating is really really bad thing buddy, next time be aware\n\nあなたはクソ野郎ではなく、あなたはそのようなたわごとをする必要がないことを知っていますよね？';
					new FlxTimer().start(4, function(tmr:FlxTimer)
					{
						text.text = 'Иди нахуй';
						new FlxTimer().start(0.4, function(tmr:FlxTimer)
						{
							Sys.exit(1);
						});
					});
				});
			});
		});

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			scary.alpha += 0.01;
			tmr.reset(1);
		});
	}
}
