package states;

import backend.WeekData;
import backend.Achievements;

import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;

import lime.app.Application;

import objects.AchievementPopup;
import states.editors.MasterEditorMenu;
import options.OptionsState;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '1.0.0'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;

	var canPress:Bool = false;
	
	var optionShit:Array<String> = [
		'story',
		'freeplay',
		#if ACHIEVEMENTS_ALLOWED 'awards', #end
		'credits',
		'options',
		'gallery'
	];

	override function create()
	{
		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBanger'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.screenCenter();
		add(bg);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 0);
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
			menuItem.ID = i;

			switch(i)
			{
				case 4: menuItem.frames = Paths.getSparrowAtlas('options_button');

				case 5: menuItem.frames = Paths.getSparrowAtlas('gallery_button');

				default: menuItem.frames = Paths.getSparrowAtlas('buttons_mainmenu');
			}

			menuItem.animation.addByPrefix('idle', optionShit[i] + "_normal", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + "_hover", 24);
			menuItem.animation.play('idle');
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));

			switch(i) {
				case 0:
					menuItem.setPosition(670, 26);
				case 1:
					menuItem.setPosition(670, 185);
				case 2:
					menuItem.setPosition(690, 338);
				case 3:
					menuItem.setPosition(700, 478);
				case 4:
					menuItem.setPosition(1150, 460);
				case 5:
					menuItem.setPosition(490, 569);
			}
			menuItem.updateHitbox();
			menuItems.add(menuItem);
		}

		var bros:FlxSprite = new FlxSprite(-50, 270);
		bros.frames = Paths.getSparrowAtlas('main_menu_chars/'+FlxG.random.int(0,4));
		bros.animation.addByPrefix('idle', 'menu', 24);
		bros.animation.play('idle');
		bros.antialiasing = ClientPrefs.data.antialiasing;
		bros.scale.set(1, 1);
		add(bros);

		var overlay:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBangerOverlay'));
		overlay.antialiasing = ClientPrefs.data.antialiasing;
		overlay.screenCenter();
		add(overlay);

		var versionShit:FlxText = new FlxText(-200, 800, 0, "FNF` BRUTAL PIZDEC v" + psychEngineVersion, 24);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		FlxG.camera.zoom = 3;
		FlxTween.tween(FlxG.camera, {zoom: 0.75}, 1.1, {ease: FlxEase.expoInOut, onComplete: function(twn:FlxTween) {
			canPress = true;
		}});

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end
		
		super.create();

		FlxG.mouse.unload();
		FlxG.mouse.load(Paths.image("cursor1").bitmap, 1.5, 0);// you can't hide what you did
		FlxG.mouse.visible = true;
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementPopup('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		FlxG.camera.scroll.x = FlxMath.lerp(FlxG.camera.scroll.x, (FlxG.mouse.screenX-(FlxG.width/2)) * 0.015, (1/30)*240*elapsed);
		FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, (FlxG.mouse.screenY-6-(FlxG.height/2)) * 0.015, (1/30)*240*elapsed);

		if (!selectedSomethin)
		{
			if(canPress)
			{
				changeItem();

				menuItems.forEach(function(spr:FlxSprite)
				{
					if (FlxG.mouse.overlaps(spr) && FlxG.mouse.justPressed)
					{
						selectedSomethin = true;
						FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
						FlxTween.tween(FlxG.camera, {zoom:1.03}, 0.7, {ease: FlxEase.quadOut, type: BACKWARD});
						FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);
						FlxFlicker.flicker(menuItems.members[curSelected], 1, 0.06, true, false, function(flick:FlxFlicker)
						{
							pressedMenu(optionShit[curSelected]);
						});
					}
				});
	
				if (controls.BACK)
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('cancelMenu'));
					MusicBeatState.switchState(new TitleState());
				}
	
				#if desktop
				else if (controls.justPressed('debug_1'))
				{
					selectedSomethin = true;
					MusicBeatState.switchState(new MasterEditorMenu());
				}
				#end	
			}
		}

		super.update(elapsed);
	}

	function pressedMenu(choise:String = null)
	{
		switch (choise)
		{
			case 'story': MusicBeatState.switchState(new StoryMenuState());
			case 'freeplay': MusicBeatState.switchState(new FreeplaySelectState());
			#if ACHIEVEMENTS_ALLOWED
			case 'awards': MusicBeatState.switchState(new AchievementsMenuState());
			#end
			case 'credits': MusicBeatState.switchState(new CreditsState());
			case 'options':
				LoadingState.loadAndSwitchState(new OptionsState());
				OptionsState.onPlayState = false;
				if (PlayState.SONG != null)
				{
					PlayState.SONG.arrowSkin = null;
					PlayState.SONG.splashSkin = null;
					PlayState.stageUI = 'normal';
				}
			case 'gallery': MusicBeatState.switchState(new GalleryState()); //пусть функция пока бует а потом добавлю кнопАЧКУ

			default: MusicBeatState.switchState(new MainMenuState());
		}
	}

	function changeItem(huh:Int = 0)
	{
		menuItems.forEach(function(spr:FlxSprite)
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
