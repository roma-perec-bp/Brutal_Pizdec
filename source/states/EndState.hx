package states;

import flixel.addons.transition.FlxTransitionableState;
import backend.Achievements;
import objects.AchievementPopup;

class EndState extends MusicBeatState
{
	public static var end:Int;
	public static var gift:Bool = false;

	var lang:String = 'noteRUS-';

	var dark:FlxSprite;

	var press:Bool = true;

	//the end
	public var trophy:FlxSprite;
	var centerVarX:Float = 0;
	var centerVarY:Float = 0;
	var canGrab:Bool = false;
	private var camAchievement:FlxCamera;

	override function create()
	{
		if(ClientPrefs.data.language == 'English')
			lang = 'noteENG-';

		super.create();

		var bg:FlxSprite = new FlxSprite();

		if(end != 6)
			bg.loadGraphic(Paths.image('endScreen/'+lang+end));
		else
			bg.loadGraphic(Paths.image('endScreen/fuck'));
		
		bg.screenCenter();
		bg.alpha = 0;
		add(bg);

		var te:FlxText = new FlxText(0, FlxG.height-135, 1200, 'Press ACCEPT to continue', 32);
        te.setFormat(Paths.font("HouseofTerror.ttf"), 32, 0xFFd4a967, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        te.screenCenter(X);
        add(te);

		dark = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		dark.alpha = 0;
		add(dark);

		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;
		FlxG.cameras.add(camAchievement, false);
		
		FlxTween.tween(bg, {alpha: 1}, 1);

		if(end != 6)
			FlxG.sound.play(Paths.sound('paper'));
		else
			FlxG.sound.play(Paths.sound('comatose'));

		ClientPrefs.saveSettings();
	}

	function there()
	{
		Achievements.loadAchievements();
		var achieveID:Int = Achievements.getAchievementIndex('allweeks2');
		FlxG.sound.play(Paths.sound('confirmAch'), 0.7);
		Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
		var achievementObj:AchievementPopup = new AchievementPopup('allweeks2', camAchievement);
		achievementObj.onFinish = function()
		{
			MusicBeatState.switchState(new CreditsState());
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);
		};
		add(achievementObj);
		ClientPrefs.saveSettings();
	}

	override function update(elapsed:Float)
	{
		if(canGrab)
		{
			if((FlxG.mouse.overlaps(trophy)))
			{
				select();
			}
			else
			{
				trophy.color = 0xFFFFFFFF;
			}
		}

		if(press == true)
		{
			if (controls.ACCEPT)
			{
				ClientPrefs.data.ends[end] = 1;
				ClientPrefs.saveSettings();

				if(gift)
					giveTrophy();
				else
				{
					if(FlxG.save.data.playedSongs.contains('with-cone') && FlxG.save.data.playedSongs.contains('boom') && FlxG.save.data.playedSongs.contains('overfire') 
						&& FlxG.save.data.playedSongs.contains('klork') && FlxG.save.data.playedSongs.contains('anekdot') && FlxG.save.data.playedSongs.contains('t-short')
						&& FlxG.save.data.playedSongs.contains('monochrome') && FlxG.save.data.playedSongs.contains('lore')
						&& FlxG.save.data.playedSongs.contains('s6x-boom') && FlxG.save.data.playedSongs.contains('lamar-tut-voobshe-ne-nujen')
						&&FlxG.save.data.playedSongs.contains('with-cone-old') && FlxG.save.data.playedSongs.contains('boom-old')
						&& FlxG.save.data.playedSongs.contains('overfire-old') && FlxG.save.data.playedSongs.contains('klork-old'))
					{
						if(ClientPrefs.data.ends[4] == 0)
						{
							EndState.end = 4;
							EndState.gift = false;
							MusicBeatState.switchState(new EndState());
						}
						else
						{
							MusicBeatState.switchState(new CreditsState());
							FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);
						}
					}
					else if((FlxG.save.data.playedSongsFC.contains('with-cone') && FlxG.save.data.playedSongsFC.contains('boom') && FlxG.save.data.playedSongsFC.contains('overfire') 
						&& FlxG.save.data.playedSongsFC.contains('klork') && FlxG.save.data.playedSongsFC.contains('anekdot') && FlxG.save.data.playedSongsFC.contains('t-short')
						&& FlxG.save.data.playedSongsFC.contains('monochrome') && FlxG.save.data.playedSongsFC.contains('lore')
						&& FlxG.save.data.playedSongsFC.contains('s6x-boom') && FlxG.save.data.playedSongsFC.contains('lamar-tut-voobshe-ne-nujen')
						&&FlxG.save.data.playedSongsFC.contains('with-cone-old') && FlxG.save.data.playedSongsFC.contains('klork-old')))
					{
						if(ClientPrefs.data.ends[5] == 0)
						{
							EndState.end = 5;
							EndState.gift = true;
							MusicBeatState.switchState(new EndState());
						}
						else
						{
							MusicBeatState.switchState(new CreditsState());
							FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);	
						}
					}
					else
					{
						MusicBeatState.switchState(new CreditsState());
						FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);	
					}
				}
				press = false;
			}
		}

		super.update(elapsed);
	}

	function giveTrophy()
	{
		if(end != 6)
		{
			FlxTween.tween(dark, {alpha: 0.6}, 1, {
				onComplete: function(twn:FlxTween)
				{
					trophy = new FlxSprite(0, 0);
	
					if(end == 5)
						trophy.loadGraphic(Paths.image('endScreen/awards'));
					else
						trophy.loadGraphic(Paths.image('endScreen/awards_ew'));
	
					trophy.setGraphicSize(Std.int(trophy.width * 0.2));
					add(trophy);
			
					trophy.x = -1000;
					trophy.y = FlxG.random.float(100, 300);
					trophy.updateHitbox();
			
					FlxTween.tween(trophy, {x: FlxG.random.float(200, 500)}, 2.1, {ease: FlxEase.cubeInOut});
			
					FlxTween.tween(trophy, {y: trophy.y - 90}, 0.1, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							FlxTween.tween(trophy, {y: trophy.y + 200}, 2, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									canGrab = true;
								}
							});
						}
					});
				}
			});
		}
		else
		{
			there();
		}
	}

	function select()
	{
		trophy.color = 0xFF6c6c6c;
		if(FlxG.mouse.justPressed)
		{
			canGrab = false;
			trophy.color = 0xFFFFFFFF;
			FlxTween.tween(trophy, {x: 542.8, y: 185.1}, 5, {ease: FlxEase.quadOut});
			FlxTween.tween(trophy.scale, {x: 0.36, y: 0.36}, 5, {ease: FlxEase.quadOut});
			FlxG.camera.fade(0xFFFFFFFF, 6);
			FlxG.sound.play(Paths.sound('winMusic'));
			FlxG.sound.play(Paths.sound('lightfill'));
			new FlxTimer().start(7, function(tmr:FlxTimer)
			{
				MusicBeatState.switchState(new CreditsState());
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);
			});
		}
	}
}
