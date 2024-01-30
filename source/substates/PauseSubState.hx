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
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String> = ['Resume', 'Toggle Botplay', 'Restart Song', 'Exit to menu'];

	var menuItemsGroup:FlxTypedGroup<FlxSprite>;

	var menuItemsAdvanced:Dynamic = [
		["resume", 426, 575],
		["botplay", 544, 359],
		["restart", 544, 412],
		["exit", 544, 464]
	];
	var difficultyChoices = [];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var practiceText:FlxText;
	//var botplayText:FlxText;

	public static var transCamera:FlxCamera;

	var dragDropObj:FlxSprite;
	var bg2:FlxSprite;

	var desc:FlxText;

	var fuckingTest:FlxText;
	
	public function new(x:Float, y:Float)
	{
		super();

		if(CoolUtil.difficulties.length < 2) menuItemsOG.remove('Change Difficulty'); //No need to change difficulty if there is only one!

		// if(PlayState.chartingMode)
		// {
		// 	menuItemsOG.insert(2, 'Toggle Practice Mode');
		// 	menuItemsOG.insert(3, 'Toggle Botplay');
		// }
		menuItems = menuItemsOG;

		for (i in 0...Difficulty.list.length) {
			var diff:String = Difficulty.getString(i);
			difficultyChoices.push(diff);
		}
		difficultyChoices.push('BACK');

		pauseMusic = new FlxSound();
		if(songName != null) {
			pauseMusic.loadEmbedded(Paths.music(songName), true, true);
		} else if (songName != 'None') {
			pauseMusic.loadEmbedded(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)), true, true);
		}
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);
		FlxG.sound.play(Paths.sound("buzzer"));

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		// add(levelInfo);

	var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, Difficulty.getString().toUpperCase(), 32);
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		// add(levelDifficulty);

		var blueballedTxt:FlxText = new FlxText(20, 15 + 64, 0, "", 32);
		blueballedTxt.text = "Blueballed: " + PlayState.deathCounter;
		blueballedTxt.scrollFactor.set();
		blueballedTxt.setFormat(Paths.font('vcr.ttf'), 32);
		blueballedTxt.updateHitbox();
		// add(blueballedTxt);

		practiceText = new FlxText(20, 15 + 101, 0, "PRACTICE MODE", 32);
		practiceText.scrollFactor.set();
		practiceText.setFormat(Paths.font('vcr.ttf'), 32);
		practiceText.x = FlxG.width - (practiceText.width + 20);
		practiceText.updateHitbox();
		practiceText.visible = PlayState.instance.practiceMode;
		//add(practiceText);

		var chartingText:FlxText = new FlxText(20, 15 + 101, 0, "CHARTING MODE", 32);
		chartingText.scrollFactor.set();
		chartingText.setFormat(Paths.font('vcr.ttf'), 32);
		chartingText.x = FlxG.width - (chartingText.width + 20);
		chartingText.y = FlxG.height - (chartingText.height + 20);
		chartingText.updateHitbox();
		chartingText.visible = PlayState.chartingMode;
		add(chartingText);

		blueballedTxt.alpha = 0;
		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		blueballedTxt.x = FlxG.width - (blueballedTxt.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(blueballedTxt, {alpha: 1, y: blueballedTxt.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			//grpMenuShit.add(songText);
		}

		changeSelection();

		// new stuff
		bg2 = new FlxSprite(0, 0).loadGraphic(Paths.image("pause_pvz_menu/background"));
		bg2.screenCenter();
		bg2.scrollFactor.set();
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
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			menuItem.scrollFactor.set();

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

		fuckingTest = new FlxText(20, 20, 0, "TEXT", 64);
		fuckingTest.setFormat(Paths.font("vcr.ttf"), 32, 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		fuckingTest.borderSize = 3;
		//add(fuckingTest);


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

		// if (upP)
		// {
		// 	changeSelection(-1);
		// }
		// if (downP)
		// {
		// 	changeSelection(1);
		// }

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

			fuckingTest.text = "true: " + Std.string(spr.x) + " | " + Std.string(spr.y);
			spr.x = menuItemsAdvanced[spr.ID][1]+(dragDropObj.x - 569);
			spr.y = menuItemsAdvanced[spr.ID][2]+(dragDropObj.y - 38);

			if (FlxG.mouse.overlaps(spr) && FlxG.mouse.justPressed)
			{
				var daSelected:String = menuItems[curSelected];
				if(difficultyChoices.contains(daSelected)) {
					var name:String = PlayState.SONG.song.toLowerCase();
					var poop = Highscore.formatSong(name, curSelected);
					PlayState.SONG = Song.loadFromJson(poop, name);
					PlayState.storyDifficulty = curSelected;
					CustomFadeTransition.nextCamera = transCamera;
					MusicBeatState.resetState();
					FlxG.sound.music.volume = 0;
					PlayState.changedDifficulty = true;
					PlayState.chartingMode = false;
					return;
				}

				switch (daSelected)
				{
					case "Resume":
						close();
					case 'Change Difficulty':
						menuItems = difficultyChoices;
						regenMenu();
					case 'Toggle Practice Mode':
						PlayState.instance.practiceMode = !PlayState.instance.practiceMode;
						PlayState.changedDifficulty = true;
						practiceText.visible = PlayState.instance.practiceMode;
					case "Restart Song":
						restartSong();
					case 'Toggle Botplay':
						PlayState.instance.cpuControlled = !PlayState.instance.cpuControlled;
						PlayState.changedDifficulty = true;
						PlayState.instance.botplayTxt.visible = PlayState.instance.cpuControlled;
						PlayState.instance.botplayTxt.alpha = 1;
						PlayState.instance.botplaySine = 0;
					case "Exit to menu":
						PlayState.deathCounter = 0;
						PlayState.seenCutscene = false;
						if(PlayState.isStoryMode) {
							MusicBeatState.switchState(new StoryMenuState());
						} else {
							MusicBeatState.switchState(new FreeplayState());
						}
						FlxG.sound.playMusic(Paths.music('freakyMenu'));
						PlayState.changedDifficulty = false;
						PlayState.chartingMode = false;

					case 'BACK':
						menuItems = menuItemsOG;
						regenMenu();
				}
			}
		});
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

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
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

	function regenMenu():Void {
		for (i in 0...grpMenuShit.members.length) {
			this.grpMenuShit.remove(this.grpMenuShit.members[0], true);
		}
		for (i in 0...menuItems.length) {
			var item = new Alphabet(0, 70 * i + 30, menuItems[i], true, false);
			item.isMenuItem = true;
			item.targetY = i;
			grpMenuShit.add(item);
		}
		curSelected = 0;
		changeSelection();
	}
}
