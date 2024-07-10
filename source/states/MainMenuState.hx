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

import shaders.ColorSwap;

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

	var trophy:FlxSprite;
	var origSaturTrophy:Float;
	var shaderMonochrome:ColorSwap;

	var bros:FlxSprite;

	override function create()
	{
		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
//		Mods.loadTopMod();

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

		Achievements.loadAchievements();

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBanger'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.screenCenter();
		add(bg);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

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

		var randomNum:Int = FlxG.random.int(0,4);
		bros = new FlxSprite(-50, 270);
		bros.frames = Paths.getSparrowAtlas('main_menu_chars/${randomNum}');
		bros.animation.addByPrefix('idle', 'menu', 24);
		bros.animation.play('idle');
		bros.ID = randomNum;
		bros.antialiasing = ClientPrefs.data.antialiasing;
		bros.scale.set(1, 1);
		add(bros);

		var overlay:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBangerOverlay'));
		overlay.antialiasing = ClientPrefs.data.antialiasing;
		overlay.screenCenter();
		add(overlay);

		var versionShit:FlxText = new FlxText(-200, 800, 0, "FNF: BRUTAL PIZDEC v" + psychEngineVersion, 24);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		trophy = new FlxSprite(330, 335).loadGraphic(Paths.image('trophyPVZ'));
		trophy.scale.set(0.30, 0.30);
		shaderMonochrome = new ColorSwap();
		trophy.shader = shaderMonochrome.shader;
		if(monochrome() == false)
		{
			shaderMonochrome.saturation = -1;
			shaderMonochrome.brightness = -0.05;
		}
		origSaturTrophy = shaderMonochrome.brightness;
		trophy.updateHitbox();
		add(trophy);

		changeItem();

		FlxG.camera.zoom = 3;
		FlxTween.tween(FlxG.camera, {zoom: 0.75}, 1.1, {ease: FlxEase.expoInOut, onComplete: function(twn:FlxTween) {
			canPress = true;
		}});
		
		super.create();

		FlxG.mouse.unload();
		//FlxG.mouse.load(Paths.image("cursor1").bitmap, 1.5, 0); // you can't hide what you did
		FlxG.mouse.visible = true;
	}

	#if ACHIEVEMENTS_ALLOWED
	function checkAchievement(achievementName) {
		Achievements.loadAchievements();
		var achieveID:Int = Achievements.getAchievementIndex(achievementName);
		if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) {
			add(new AchievementPopup(achievementName, camAchievement));
			Achievements.unlockAchievement(achievementName);
			ClientPrefs.saveSettings();
		}
	}
	#end

	var selectedSomethin:Bool = false;

	function monochrome()
	{
		for(i in 0...Achievements.achievementsStuff.length)
		{
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[i][2]))
				return false;
		}
		return true;
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		FlxG.camera.scroll.x = FlxMath.lerp(FlxG.camera.scroll.x, (FlxG.mouse.screenX-(FlxG.width/2)) * 0.015, (1/30)*240*elapsed);
		FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, (FlxG.mouse.screenY-6-(FlxG.height/2)) * 0.015, (1/30)*240*elapsed);

		#if ACHIEVEMENTS_ALLOWED
		if(FlxG.keys.justPressed.ONE)
		{
			checkAchievement('friday_night_play');
		}
		if((FlxG.mouse.overlaps(bros)) && FlxG.mouse.justPressed && bros.ID == 4)
		{
			checkAchievement('menu0');
		}
		#end

		if (!selectedSomethin)
		{
			if(canPress)
			{
				changeItem();

				if(FlxG.mouse.overlaps(trophy))
				{
					shaderMonochrome.brightness = origSaturTrophy-0.3;
					if(FlxG.mouse.justPressed)
					{
						selectedSomethin = true;
						FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
						FlxTween.tween(FlxG.camera, {zoom:1.03}, 0.7, {ease: FlxEase.quadOut, type: BACKWARD});
						FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);
						FlxFlicker.flicker(trophy, 1, 0.06, true, false, function(flick:FlxFlicker)
						{
							pressedMenu('awards');
						});
					}
				} else {
					shaderMonochrome.brightness = origSaturTrophy;
				}

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
			case 'awards': MusicBeatState.switchState(new AchievementsStatePVZ());
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
