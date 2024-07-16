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

	var randomNum:Int = FlxG.random.int(0, 11);

	var stageSuffix:String = "";

	public static var characterName:String = 'bf-dead';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';

	private var camAchievement:FlxCamera;

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
		add(boyfriend);

		FlxG.sound.play(Paths.sound(deathSoundName));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		boyfriend.playAnim('firstDeath');

		fuckedText = new FlxSprite(boyfriend.x - 75, boyfriend.y + 10);
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
				fuckedText.offset.x = 145;
			case 1:
				fuckedText.offset.x = 90;
			case 2:
				fuckedText.offset.x = 9;
			case 3:
				fuckedText.offset.x = 10;
			case 4:
				fuckedText.offset.x = 6;
			case 5:
				fuckedText.offset.x = 10;
			case 6:
				fuckedText.offset.x = -2;
			case 7:
				fuckedText.offset.x = 110;
			case 8:
				fuckedText.offset.x = -65;
			case 9:
				fuckedText.offset.x = -15;
			case 10:
				fuckedText.offset.x = -70;
			case 11:
				fuckedText.offset.x = 70;
		}
		add(fuckedText);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(boyfriend.getGraphicMidpoint().x, boyfriend.getGraphicMidpoint().y);
		FlxG.camera.focusOn(new FlxPoint(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2)));
		add(camFollow);

		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;
		FlxG.cameras.add(camAchievement, false);

		achievements();
	}

	public var startedDeath:Bool = false;
	var isFollowingAlready:Bool = false;

	#if ACHIEVEMENTS_ALLOWED
	function giveAchievement(name) {
		add(new AchievementPopup(name, camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
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

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		PlayState.instance.callOnScripts('onUpdate', [elapsed]);

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.RESET)
		{
			randomNum = FlxG.random.int(0, 11);
			fuckedText.frames = Paths.getSparrowAtlas('gays/gameover'+randomNum);
			fuckedText.animation.addByPrefix('start', 'RETRY_START', 24, false);
			fuckedText.animation.addByPrefix('loop', 'RETRY_LOOP', 24);
			fuckedText.animation.addByPrefix('end', 'RETRY_END', 24, false);
			fuckedText.animation.play('loop');

			switch(randomNum)
			{
				case 0:
					fuckedText.offset.x = 145;
				case 1:
					fuckedText.offset.x = 90;
				case 2:
					fuckedText.offset.x = 9;
				case 3:
					fuckedText.offset.x = 10;
				case 4:
					fuckedText.offset.x = 6;
				case 5:
					fuckedText.offset.x = 10;
				case 6:
					fuckedText.offset.x = -2;
				case 7:
					fuckedText.offset.x = 110;
				case 8:
					fuckedText.offset.x = -65;
				case 9:
					fuckedText.offset.x = -15;
				case 10:
					fuckedText.offset.x = -70;
				case 11:
					fuckedText.offset.x = 70;
			}
		}

		if (controls.BACK)
		{
			#if desktop DiscordClient.resetClientID(); #end
			FlxG.sound.music.stop();
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;
			PlayState.chartingMode = false;

//			Mods.loadTopMod();
			if (PlayState.isStoryMode)
				MusicBeatState.switchState(new StoryMenuState());
			else
				MusicBeatState.switchState(new FreeplayState());

			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			PlayState.instance.callOnScripts('onGameOverConfirm', [false]);
		}
		
		if (boyfriend.animation.curAnim != null)
		{
			if (boyfriend.animation.curAnim.name == 'firstDeath' && boyfriend.animation.curAnim.finished && startedDeath)
			{
				boyfriend.playAnim('deathLoop');
				fuckedText.animation.play('loop');
				fuckedText.x = boyfriend.x;
				fuckedText.y = boyfriend.y + 50;
			}

			if(boyfriend.animation.curAnim.name == 'firstDeath')
			{
				if(boyfriend.animation.curAnim.curFrame >= 12 && !isFollowingAlready)
				{
					FlxG.camera.follow(camFollow, LOCKON, 0);
					updateCamera = true;
					isFollowingAlready = true;
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

		var sexu = FlxG.keys.anyJustPressed([I]);
		var rightP = FlxG.keys.anyJustPressed([L]);
		var sexa = FlxG.keys.anyJustPressed([K]);
		var leftP = FlxG.keys.anyJustPressed([J]);

		var holdShift = FlxG.keys.pressed.SHIFT;
		var multiplier = 1;
		if (holdShift)
			multiplier = 10;

		if (sexu || rightP || sexa || leftP)
		{
			if (sexu)
				fuckedText.offset.y += 1 * multiplier;
			if (sexa)
				fuckedText.offset.y -= 1 * multiplier;
			if (leftP)
				fuckedText.offset.x += 1 * multiplier;
			if (rightP)
				fuckedText.offset.x -= 1 * multiplier;

			trace(fuckedText.offset);
		}
		
		if(updateCamera) FlxG.camera.followLerp = FlxMath.bound(elapsed * 0.6 / (FlxG.updateFramerate / 60), 0, 1);
		else FlxG.camera.followLerp = 0;

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
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
			fuckedText.animation.play('end');
			fuckedText.x = boyfriend.x - 550;
			fuckedText.y = boyfriend.y - 230;
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
