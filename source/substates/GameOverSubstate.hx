package substates;

import backend.WeekData;

import objects.Character;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;

import states.StoryMenuState;
import states.FreeplayState;

import backend.Achievements;
import objects.AchievementPopup;

class GameOverSubstate extends MusicBeatSubstate
{
	public var boyfriend:Character;
	var camFollow:FlxObject;
	var updateCamera:Bool = false;
	var playingDeathSound:Bool = false;

	public var fuckedText:FlxSprite;
	public var retry:FlxSprite;

	var sexValue:Float = 1;

	var randomNum:Int = FlxG.random.int(0, 11);

	var stageSuffix:String = "";

	public static var characterName:String = 'bf-dead';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';

	private var camAchievement:FlxCamera;

	var titleTextColors:Array<FlxColor> = [0xffFFFFFF, 0xffb0b0b0];

	public static var instance:GameOverSubstate;

	public static function resetVariables() {
		characterName = 'bf-dead';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'gameOver';
		endSoundName = 'gameOverEnd';

		var _song = PlayState.SONG;
		if(_song != null)
		{
			if(_song.gameOverChar != null && _song.gameOverChar.trim().length > 0) characterName = _song.gameOverChar;
			if(_song.gameOverSound != null && _song.gameOverSound.trim().length > 0) deathSoundName = _song.gameOverSound;
			if(_song.gameOverLoop != null && _song.gameOverLoop.trim().length > 0) loopSoundName = _song.gameOverLoop;
			if(_song.gameOverEnd != null && _song.gameOverEnd.trim().length > 0) endSoundName = _song.gameOverEnd;
		}
	}

	override function create()
	{
		instance = this;
		PlayState.instance.callOnScripts('onGameOverStart', []);

		super.create();
	}

	public function new(x:Float, y:Float, camX:Float, camY:Float)
	{
		super();

		PlayState.instance.setOnScripts('inGameOver', true);

		Conductor.songPosition = 0;

		boyfriend = new Character(x, y, characterName, true);
		boyfriend.x += boyfriend.positionArray[0];
		boyfriend.y += boyfriend.positionArray[1];
		if(PlayState.SONG.stage != 'flipaclip') add(boyfriend);

		FlxG.sound.play(Paths.sound(deathSoundName));
		if(PlayState.SONG.stage == 'flipaclip') FlxG.sound.play(Paths.sound('bbg_death'), 1, false, null, true, 
		function() {
			Sys.command('mshta vbscript:Execute("msgbox ""ВЫ БЫЛИ ОТРАХНУТЫ"":close")');
			Sys.exit(1);
		});
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		boyfriend.playAnim('firstDeath');

		if (PlayState.SONG.stage != 'roof-old')
		{
			fuckedText = new FlxSprite(boyfriend.x - 510, boyfriend.y - 190);
			fuckedText.frames = Paths.getSparrowAtlas('gays/gameover'+randomNum);
			fuckedText.animation.addByPrefix('start', 'RETRY_START', 24, false);
			fuckedText.animation.addByPrefix('loop', 'RETRY_LOOP', 24);
			fuckedText.animation.addByPrefix('end', 'RETRY_END', 24, false);
			fuckedText.antialiasing = ClientPrefs.data.antialiasing;
			fuckedText.updateHitbox();
			fuckedText.animation.play('start');
	
			switch(randomNum)
			{
				case 0:
					fuckedText.x = boyfriend.x - 820;
				case 1:
					fuckedText.x = boyfriend.x - 740;
				case 2:
					fuckedText.x = boyfriend.x - 580;
				case 3:
					fuckedText.x = boyfriend.x - 620;
				case 4:
					fuckedText.x = boyfriend.x - 570;
				case 5:
					fuckedText.x = boyfriend.x - 610;
				case 6:
					fuckedText.x = boyfriend.x - 580;
				case 7:
					fuckedText.x = boyfriend.x - 750;
				case 8:
					fuckedText.x = boyfriend.x - 470;
				case 9:
					fuckedText.x = boyfriend.x - 550;
				case 10:
					fuckedText.x = boyfriend.x - 480;
				case 11:
					fuckedText.x = boyfriend.x - 690;
			}

			if(characterName == 'dead-guy') fuckedText.x += 100;
			if(characterName == 'bf-dead') fuckedText.x += 75;

			if(PlayState.SONG.stage == 'flipaclip')
				fuckedText.screenCenter();
			
			fuckedText.centerOffsets();
			add(fuckedText);

			if(characterName != 'bf-dead' && PlayState.SONG.stage != 'flipaclip')
			{
				retry = new FlxSprite(boyfriend.x, boyfriend.y + 100).loadGraphic(Paths.image('txt'));
				if(characterName == 'dead-guy') retry.x += 100;
				retry.alpha = 0.001;
				retry.updateHitbox();
				add(retry);
			}
		}

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(boyfriend.getGraphicMidpoint().x, boyfriend.getGraphicMidpoint().y);
		if(PlayState.SONG.stage != 'flipaclip') FlxG.camera.focusOn(new FlxPoint(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2)));
		add(camFollow);

		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;
		FlxG.cameras.add(camAchievement, false);

		achievements();

		if(PlayState.SONG.stage == 'flipaclip')
		{
			new FlxTimer().start(0.5, function(tmr:FlxTimer)
			{
				FlxG.sound.play(Paths.sound('pizdos'));
				FlxG.sound.play(Paths.sound('zamn/'+randomNum));
			});
		
			new FlxTimer().start(3, function(tmr:FlxTimer)
			{
				FlxG.camera.shake(0.0025, 0.15);
				FlxG.sound.play(Paths.sound('sex'));
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					FlxG.camera.shake(0.0025, 0.15);
					FlxG.sound.play(Paths.sound('sex'));
					new FlxTimer().start(sexValue, function(tmr:FlxTimer)
					{
						FlxG.camera.shake(0.0025, 0.15);
						FlxG.sound.play(Paths.sound('sex'));
						sexValue -= FlxG.random.float(0.01, 0.09);
						tmr.reset(sexValue);
					});
				});
			});
		}
	}

	public var startedDeath:Bool = false;
	var isFollowingAlready:Bool = false;

	#if ACHIEVEMENTS_ALLOWED
	function giveAchievement(name) {
		add(new AchievementPopup(name, camAchievement));
		FlxG.sound.play(Paths.sound('confirmAch'), 0.7);
		trace('Giving achievement: ${name}');
	}
	function checkAchievement(achievementName) {
		Achievements.loadAchievements();
		var achieveID:Int = Achievements.getAchievementIndex(achievementName);
		if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) {
			Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
			giveAchievement(achievementName);
			ClientPrefs.saveSettings();
		}
	}
	function achievements() {
		var achievementLists = [];
		// songs
		if(PlayState.songName.toLowerCase() == "anekdot")
			checkAchievement("anekdot_death");
		// deaths
		if(Achievements.getAchievementCurNum("skill") < 11)
			Achievements.setAchievementCurNum("skill", Achievements.getAchievementCurNum("skill") + 1);
		
		if (Achievements.getAchievementCurNum("skill") == Achievements.achievementsStuff[Achievements.getAchievementIndex("skill")][4]) {
			checkAchievement("skill");
		}
		if(PlayState.instance.cpuControlled)
			checkAchievement("bot");
		ClientPrefs.saveSettings();
		//trace(Achievements.getAchievementCurNum("skill") + ", " + Achievements.achievementsStuff[Achievements.getAchievementIndex("skill")][4]);
	}
	#end

	var titleTimer:Float = 0;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		PlayState.instance.callOnScripts('onUpdate', [elapsed]);

		if (PlayState.SONG.stage != 'roof-old' && PlayState.SONG.stage != 'flipaclip' && !isEnding)
		{
			titleTimer += FlxMath.bound(elapsed, 0, 1);
			if (titleTimer > 2) titleTimer -= 2;

			var timer:Float = titleTimer;
			if (timer >= 1)
				timer = (-timer) + 2;
			
			timer = FlxEase.quadInOut(timer);
			
			boyfriend.color = FlxColor.interpolate(titleTextColors[0], titleTextColors[1], timer);
		}

		if(PlayState.SONG.stage != 'flipaclip')
		{
			if (controls.ACCEPT)
			{
				endBullshit();
			}

			if (controls.BACK)
			{
				#if desktop DiscordClient.resetClientID(); #end
				FlxG.sound.music.stop();
				PlayState.deathCounter = 0;
				PlayState.seenCutscene = false;
				PlayState.chartingMode = false;
		
				if (PlayState.isStoryMode)
					MusicBeatState.switchState(new StoryMenuState());
				else
					MusicBeatState.switchState(new FreeplayState());
		
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);
				PlayState.instance.callOnScripts('onGameOverConfirm', [false]);
			}

			if (boyfriend.animation.curAnim != null)
			{
				if (boyfriend.animation.curAnim.name == 'firstDeath' && boyfriend.animation.curAnim.finished && startedDeath)
				{
					boyfriend.playAnim('deathLoop');
					if (PlayState.SONG.stage != 'roof-old')
					{
						fuckedText.animation.play('loop');
						fuckedText.centerOffsets();
					}
				}
		
				if(boyfriend.animation.curAnim.name == 'firstDeath')
				{
					if(boyfriend.animation.curAnim.curFrame >= 12 && !isFollowingAlready)
					{
						FlxG.camera.follow(camFollow, LOCKON, 0);
						updateCamera = true;
						isFollowingAlready = true;
							
						if (PlayState.SONG.stage != 'roof-old')
						{
							FlxG.sound.play(Paths.sound('pizdos'));
							FlxG.sound.play(Paths.sound('zamn/'+randomNum));
						}
					}
		
					if(boyfriend.animation.curAnim.curFrame >= 25)
					{
						if (PlayState.SONG.stage != 'roof-old' && characterName != 'bf-dead')
						{
							FlxTween.tween(retry, {y: boyfriend.y - 50, alpha: 1}, 4, {
								ease: FlxEase.expoOut
							});
						}
					}
		
					if (boyfriend.animation.curAnim.finished && !playingDeathSound)
					{
						startedDeath = true;
						if (PlayState.SONG.stage == 'night')
						{
							playingDeathSound = true;
							coolStartDeath(0.2);
		
							FlxG.sound.play(Paths.sound('game_over/line_' + FlxG.random.int(0, 33)), 1, false, null, true, function() {
								if(!isEnding)
								{
									FlxG.sound.music.fadeIn(4, 0.2, 1);
								}
							});
						}
						else coolStartDeath();
					}
				}
			}
				
			if(updateCamera) FlxG.camera.followLerp = FlxMath.bound(elapsed * 0.6 / (FlxG.updateFramerate / 60), 0, 1);
			else FlxG.camera.followLerp = 0;
		
			if (FlxG.sound.music.playing)
			{
				Conductor.songPosition = FlxG.sound.music.time;
			}
		}
	
		PlayState.instance.callOnScripts('onUpdatePost', [elapsed]);
	}

	var isEnding:Bool = false;

	function coolStartDeath(?volume:Float = 1):Void
	{
		FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
		FlxTween.tween(FlxG.camera, {zoom: 0.9}, 4, {ease: FlxEase.quadInOut}); //если камера в такой пизде то идем в зум 0.9
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			if (PlayState.SONG.stage != 'roof-old')
			{
				fuckedText.animation.play('end');
				fuckedText.centerOffsets();
			}
			boyfriend.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(endSoundName));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					MusicBeatState.resetState();
				});
			});
			PlayState.instance.callOnScripts('onGameOverConfirm', [true]);
		}
	}

	override function destroy()
	{
		instance = null;
		super.destroy();
	}
}
