package states;

import backend.Achievements;

import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;

import lime.app.Application;

import objects.AchievementPopup;
import states.editors.MasterEditorMenu;
import options.OptionsState;

import shaders.ColorSwap;

enum MainMenuColumn {
	LEFT;
	CENTER;
	RIGHT;
}

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '1.0.0'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;
	public static var curColumn:MainMenuColumn = CENTER;

	var menuItems:FlxTypedGroup<FlxSprite>;
	var leftItems:FlxTypedGroup<FlxSprite>;
	var rightItem:FlxSprite;

	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;

	var canPress:Bool = false;

	//Centered/Text options
	var optionShit:Array<String> = [
		'story',
		'freeplay',
		#if ACHIEVEMENTS_ALLOWED 'awards', #end
		'credits',
		'gallery',
		'awards'
	];

	//Left/Text options
	var leftOptions:Array<String> = [
		'awards',
		'gallery'
	];

	var rightOption:String = 'options';

	var origSaturTrophy:Float;
	var shaderMonochrome:ColorSwap;

	var bros:FlxSprite;

	override function create()
	{
		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		//Mods.loadTopMod();

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

		for (num => option in optionShit)
		{
			switch(num) {
				case 0:
					createMenuItem(option, 670, 26);
				case 1:
					createMenuItem(option, 670, 185);
				case 2:
					createMenuItem(option, 690, 338);
				case 3:
					createMenuItem(option, 700, 478);
				case 4:
					createMenuItem(option, 490, 569);
				case 5:
					for(i in 0...Achievements.achievementsStuff.length)
					{
						if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[i][0]))
							createMenuItem(option, 330, 335, true);
					}
			}
		}

		if (rightOption != null)
		{
			rightItem = createMenuItem(rightOption, 1150, 460);
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

	function createMenuItem(name:String, x:Float, y:Float, ?trophy:Bool = false):FlxSprite
	{
		var menuItem:FlxSprite = new FlxSprite(x, y);
		if(trophy == false)
		{
			if(name == 'story' || name == 'awards' || name == 'freeplay' || name == 'credits')
				menuItem.frames = Paths.getSparrowAtlas('buttons_mainmenu');
			else
				menuItem.frames = Paths.getSparrowAtlas('${name}_button');

			menuItem.animation.addByPrefix('idle', '${name}_normal', 24, true);
			menuItem.animation.addByPrefix('selected', '${name}_hover', 24, true);
			menuItem.animation.play('idle');
		}
		else
		{
			menuItem.frames = Paths.getSparrowAtlas('awards');
			menuItem.animation.addByPrefix('idle', 'awards_normal', 24, true);
			menuItem.animation.addByPrefix('selected', 'awards_hover', 24, true);
			menuItem.scale.set(0.30, 0.30);
			shaderMonochrome = new ColorSwap();
			menuItem.shader = shaderMonochrome.shader;
			if(monochrome() == false)
			{
				shaderMonochrome.saturation = -1;
				shaderMonochrome.brightness = -0.05;
			}
			origSaturTrophy = shaderMonochrome.brightness;
		}
		menuItem.updateHitbox();
		
		menuItem.antialiasing = ClientPrefs.data.antialiasing;
		menuItems.add(menuItem);
		return menuItem;
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
				if (FlxG.mouse.deltaScreenX != 0 && FlxG.mouse.deltaScreenY != 0) //more accurate than FlxG.mouse.justMoved
				{
					var selectedItem:FlxSprite;
					switch(curColumn)
					{
						case CENTER: selectedItem = menuItems.members[curSelected];
						case LEFT: selectedItem = leftItems.members[curSelected];
						case RIGHT:selectedItem = rightItem;
					}

					if(leftItems != null && FlxG.mouse.overlaps(leftItems))
					{
						var dist:Float = -1;
						var distItem:Int = -1;
						for (i in 0...leftOptions.length)
						{
							var memb:FlxSprite = leftItems.members[i];
							if(FlxG.mouse.overlaps(memb))
							{
								var distance:Float = Math.sqrt(Math.pow(memb.getGraphicMidpoint().x - FlxG.mouse.screenX, 2) + Math.pow(memb.getGraphicMidpoint().y - FlxG.mouse.screenY, 2));
								if (dist < 0 || distance < dist)
								{
									dist = distance;
									distItem = i;
								}
							}
						}
		
						if(distItem != -1 && curSelected != distItem)
						{
							curColumn = LEFT;
							curSelected = distItem;
							changeItem();
						}
					}
					else if(rightItem != null && FlxG.mouse.overlaps(rightItem))
					{
						if(selectedItem != rightItem)
						{
							curColumn = RIGHT;
							changeItem();
						}
					}
					else
					{
						var dist:Float = -1;
						var distItem:Int = -1;
						for (i in 0...optionShit.length)
						{
							var memb:FlxSprite = menuItems.members[i];
							if(FlxG.mouse.overlaps(memb))
							{
								var distance:Float = Math.sqrt(Math.pow(memb.getGraphicMidpoint().x - FlxG.mouse.screenX, 2) + Math.pow(memb.getGraphicMidpoint().y - FlxG.mouse.screenY, 2));
								if (dist < 0 || distance < dist)
								{
									dist = distance;
									distItem = i;
								}
							}
						}
		
						if(distItem != -1 && curSelected != distItem)
						{
							curColumn = CENTER;
							curSelected = distItem;
							changeItem();
						}
					}
				}

				if (controls.ACCEPT || (FlxG.mouse.justPressed))
				{
					FlxG.sound.play(Paths.sound('confirmMenu'));
					selectedSomethin = true;

					FlxTween.tween(FlxG.camera, {zoom:1.03}, 0.7, {ease: FlxEase.quadOut, type: BACKWARD});
					FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);

					var item:FlxSprite;
					var option:String;
					switch(curColumn)
					{
						case CENTER:
							option = optionShit[curSelected];
							item = menuItems.members[curSelected];

						case LEFT:
							option = leftOptions[curSelected];
							item = leftItems.members[curSelected];

						case RIGHT:
							option = rightOption;
							item = rightItem;
					}

					FlxFlicker.flicker(item, 1, 0.06, true, false, function(flick:FlxFlicker)
					{
						switch (option)
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
							case 'gallery': MusicBeatState.switchState(new GalleryState());
							default: MusicBeatState.switchState(new MainMenuState());
						}
					});
				}
	
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

	function changeItem(change:Int = 0)
	{
		var prevEntry:Int = curSelected;

		if(change != 0) curColumn = CENTER;
		curSelected = FlxMath.wrap(curSelected + change, 0, optionShit.length - 1);
		if (curSelected != prevEntry) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		for (item in menuItems)
			item.animation.play('idle');

		var selectedItem:FlxSprite;
		switch(curColumn)
		{
			case CENTER:
				selectedItem = menuItems.members[curSelected];
			case LEFT:
				selectedItem = leftItems.members[curSelected];
			case RIGHT:
				selectedItem = rightItem;
		}
		selectedItem.animation.play('selected');
	}
}
