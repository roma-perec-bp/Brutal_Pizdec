package substates;

import backend.WeekData;
import backend.Highscore;
import backend.Song;

import flixel.addons.transition.FlxTransitionableState;

import flixel.util.FlxStringUtil;

import states.StoryMenuState;
import states.FreeplayState;
import options.OptionsState;


class PauseSubState extends MusicBeatSubstate
{
	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String> = ['Resume', 'Toggle Botplay', 'Restart Song', 'Exit to menu'];

	var menuItemsGroup:FlxTypedGroup<FlxSprite>;

	var menuItemsAdvanced:Dynamic = [
		["resume", 426, 575],
		["botplay", 544, 359],
		["restart", 544, 412],
		["exit", 544, 464]
	];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var bpText:FlxText;
	//var botplayText:FlxText;

	var dragDropObj:FlxSprite;
	var bg2:FlxSprite;

	var desc:FlxText;

	public static var songName:String = null;
	
	public function new(x:Float, y:Float)
	{
		super();

		menuItems = menuItemsOG;

		//НАХУЙ КАСТОП ПАУЗА БУДЕТ ТОК СВОЯЯЯЯЯЯ
		pauseMusic = new FlxSound();
		pauseMusic.loadEmbedded(Paths.music('pizdec'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);
		FlxG.sound.play(Paths.sound("buzzer"));

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		bpText = new FlxText(20, 15, 0, "BOTPLAY ON", 32);
		bpText.scrollFactor.set();
		bpText.setFormat(Paths.font('vcr.ttf'), 32);
		bpText.x = FlxG.width - (bpText.width + 20);
		bpText.updateHitbox();
		bpText.visible = PlayState.instance.cpuControlled;
		add(bpText);

		var chartingText:FlxText = new FlxText(20, 15 + 101, 0, "CHARTING MODE", 32);
		chartingText.scrollFactor.set();
		chartingText.setFormat(Paths.font('vcr.ttf'), 32);
		chartingText.x = FlxG.width - (chartingText.width + 20);
		chartingText.y = FlxG.height - (chartingText.height + 20);
		chartingText.updateHitbox();
		chartingText.visible = PlayState.chartingMode;
		add(chartingText);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});

		changeSelection();

		// new stuff
		bg2 = new FlxSprite(0, 0).loadGraphic(Paths.image("pause_pvz_menu/background"));
		bg2.screenCenter();
		bg2.scrollFactor.set();
		bg2.updateHitbox();
		add(bg2);

		FlxG.mouse.visible = true;

		menuItemsGroup = new FlxTypedGroup<FlxSprite>();
		add(menuItemsGroup);

		for(i in 0...menuItemsAdvanced.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0,0);
			menuItem.frames = Paths.getSparrowAtlas('pause_pvz_menu/button_' + menuItemsAdvanced[i][0]);
			menuItem.animation.addByPrefix('idle', "button_" + menuItemsAdvanced[i][0] + "_idle", 24);
			menuItem.animation.addByPrefix('selected', "button_" + menuItemsAdvanced[i][0] + "_selected", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItemsGroup.add(menuItem);
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
			menuItem.scrollFactor.set();
			menuItem.updateHitbox();

			menuItem.x = menuItemsAdvanced[i][1];
			menuItem.y = menuItemsAdvanced[i][2];
		}

		desc = new FlxText(20, 15 + 64, 0, "", 25);
		desc.text = "Song: " + Std.string(PlayState.SONG.song)
		+ "\nBlueballed: " + Std.string(PlayState.deathCounter);
		desc.scrollFactor.set();
		desc.setFormat(Paths.font("serio.ttf"), 26, 0xFF6B6D91, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		desc.borderSize = 3;
		desc.screenCenter();
		desc.y -= 85;
		desc.updateHitbox();
		add(desc);

		dragDropObj = new FlxSprite(0, 0).loadGraphic(Paths.image("pause_pvz_menu/hitbox"));
		dragDropObj.setPosition(bg2.x, bg2.y);
		dragDropObj.screenCenter(X);
		dragDropObj.scrollFactor.set();
		dragDropObj.updateHitbox();
		dragDropObj.visible = false;
		add(dragDropObj);

		changeButtons();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		changeButtons();

		if (FlxG.mouse.overlaps(dragDropObj) && FlxG.mouse.pressed)
		{
			dragDropObj.x = FlxG.mouse.screenX - (142/2);
			dragDropObj.y = FlxG.mouse.screenY - (79/2);
		}

		bg2.offset.set(-(dragDropObj.x - 569), -(dragDropObj.y - 38));

		desc.offset.set(0 - (dragDropObj.x - 569), 0 - (dragDropObj.y - 38));

		menuItemsGroup.forEach(function(spr:FlxSprite)
		{
			// spr.offset.x = 0 - (dragDropObj.x - 569);
			// spr.offset.y = 0 - (dragDropObj.y - 38);

			spr.x = menuItemsAdvanced[spr.ID][1]+(dragDropObj.x - 569);
			spr.y = menuItemsAdvanced[spr.ID][2]+(dragDropObj.y - 38);

			if (FlxG.mouse.overlaps(spr) && FlxG.mouse.justPressed)
			{
				var daSelected:String = menuItems[curSelected];

				switch (daSelected)
				{
					case "Resume":
						close();
					case "Restart Song":
						restartSong();
					case 'Toggle Botplay':
						PlayState.instance.cpuControlled = !PlayState.instance.cpuControlled;
						PlayState.changedDifficulty = true;
						PlayState.instance.botplayTxt.visible = PlayState.instance.cpuControlled;
						PlayState.instance.botplayTxt.alpha = 1;
						PlayState.instance.botplaySine = 0;
						bpText.visible = PlayState.instance.cpuControlled;
					case "Exit to menu":
						PlayState.deathCounter = 0;
						PlayState.seenCutscene = false;
						if(PlayState.isStoryMode) {
							MusicBeatState.switchState(new StoryMenuState());
						} else {
							MusicBeatState.switchState(new FreeplayState());
						}
						FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);
						PlayState.changedDifficulty = false;
						PlayState.chartingMode = false;
				}
			}
		});

		if(accepted)
		{
			close();
		}
	}

	public static function restartSong(noTrans:Bool = false)
	{
		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;

		if(noTrans)
		{
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
		}
		else
		{
			MusicBeatState.resetState();
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;
	}

	function changeButtons()
	{
		menuItemsGroup.forEach(function(spr:FlxSprite)
		{
			if(FlxG.mouse.overlaps(spr))
			{
				curSelected = spr.ID;
				spr.animation.play('selected');
			} else {
				spr.animation.play('idle');
			}
		});
	}
}