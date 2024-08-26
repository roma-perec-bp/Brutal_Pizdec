package states;

import states.editors.ChartingState;
import backend.WeekData;
import objects.HealthIcon;
import backend.Highscore;
import backend.Song;
import substates.ResetScoreSubState;
import backend.Mods;
import states.FreeplaySelectState;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

import shaders.RimlightShader;

import flixel.effects.FlxFlicker;

using StringTools;
import lime.app.Application;

#if sys
import sys.FileSystem;
#end

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	static var curSelected:Array<Int> = [0, 0, 0];
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = Difficulty.getDefault();
	public static var freeplayType = 0;

	var scoreBG:FlxSprite;
	var scoreMedal:FlxSprite;
	var scoreText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	var portrait:FlxSprite;
	var cantDo:Bool = false;

	private var grpSongs:FlxTypedGroup<FlxText>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	var rimlight:RimlightShader;

	var bg:FlxSprite;
	public static var intendedColor:Int;
	var colorTween:FlxTween;

	var displayName:String;
	public var medal:FlxSprite;

	var mainColors:Array<Int> = [
		0xff4d250e,
		0xffff0000,
		0xffff5800
	];

	var bonusColors:Array<Int> = [
		0xffbdbdbd,
		0xff61de35,
		0xff7a7a7a,
		0xff171717,
		0xff3b4dee
	];

	var coverColors:Array<Int> = [
		0xffcd2061,
		0xff7afb77
	];

	var oldColors:Array<Int> = [
		0xff4d250e,
		0xffff0000,
		0xff642800,
		0xff61de35
	];

	var jalapenis:String = 'jap_3';
	override function create()
	{

		Paths.clearStoredMemory();
		
		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if(FlxG.save.data.playedSongs.contains(CoolUtil.spaceToDash('overfire')))
			jalapenis = 'jap_4';

		switch (freeplayType)
		{
			case 0:
				addWeek(['With Cone', 'BOOM', 'Overfire'], 1, mainColors, ['jap-pixel', 'jap-pixel', 'jap-wheel-pixel'], ['jap_1', 'jap_2', jalapenis]);
			case 1:
				addWeek(['Anekdot', 'Klork', 'T-SHORT', 'Monochrome', 'Lore'], 1, bonusColors, ['box-pixel', 'lork-pixel', 'short-pixel', 'deadjap-pixel', 'lore-pixel'], ['zombie', 'lork', 'tshort', 'dead', 'gandons']);
			case 2:
				addWeek(['S6x Boom', 'Lamar Tut Voobshe Ne Nujen'], 1, coverColors, ['sex-pixel', 'jamar-pixel'], ['bbg', 'lamar']);
			case 3:
				addWeek(['With Cone ORIGINAL','BOOM OLD', 'Overfire OLD', 'Klork OLD'], 1, oldColors, ['jap-pixel', 'jap-old-pixel', 'jap-wheel-old-pixel', 'lork-pixel'], ['jap_1', 'jap-old', 'jap2-old', 'lork']);
		};

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);
		bg.screenCenter();

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(40, 40);
		grid.alpha = 0;
		FlxTween.tween(grid, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		add(grid);

		portrait = new FlxSprite();
		portrait.loadGraphic(Paths.image('freeplay_chars/lamar'));
		portrait.antialiasing = ClientPrefs.data.antialiasing;
		portrait.setPosition(750, 150);
		portrait.updateHitbox();
		portrait.scrollFactor.set();
		add(portrait);

		rimlight = new RimlightShader(315, 10, 0xFFff0000, portrait);
		add(rimlight);
		portrait.shader = rimlight.shader;

		FlxTween.tween(portrait, {x: 550}, 1, {ease: FlxEase.quadOut});

		grpSongs = new FlxTypedGroup<FlxText>();
		add(grpSongs);

		var curID:Int = -1;
		for (i in 0...songs.length)
		{
			curID += 1;
			var songText:FlxText;
			displayName = songs[i].songName;
			if(!FlxG.save.data.playedSongs.contains(CoolUtil.spaceToDash(songs[i].songName.toLowerCase())))
			{
				var stringArray:Array<String> = displayName.split('');
				displayName = '';
				for (j in stringArray)
				{
					if (j == '-')
						displayName += '-';
					else
						displayName += '?';
				}
			}
			songText = new FlxText(0, 0, 0, displayName, 87);
			songText.setFormat(Paths.font("HouseofTerror.ttf"), 87,  FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songText.borderSize = 4;
			songText.ID = curID;
			grpSongs.add(songText);

			songText.scale.x = Math.min(1, 980 / songText.width);

			Mods.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;
			// using a FlxGroup is too much fuss!
			if(!FlxG.save.data.playedSongs.contains(CoolUtil.spaceToDash(songs[i].songName.toLowerCase())))
				if (FlxG.random.bool(0.1))
					icon.animation.curAnim.curFrame = 2;
				else
					icon.animation.curAnim.curFrame = 1;

			iconArray.push(icon);
			add(icon);
		}
		WeekData.setDirectoryFromWeek();

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("HouseofTerror.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		scoreMedal = new FlxSprite(FlxG.width - 195, 66).makeGraphic(195, 170, 0xFF000000);
		scoreMedal.alpha = 0.6;
		add(scoreMedal);

		add(scoreText);

		// медальки
		medal = new FlxSprite(FlxG.width - 285, -235).loadGraphic(Paths.image('medals/medal_7'));
		medal.scale.set(0.2, 0.2);
		medal.updateHitbox();
		medal.antialiasing = ClientPrefs.data.antialiasing;
		medal.visible = false;
		add(medal);

		if(curSelected[freeplayType] >= songs.length) curSelected[freeplayType] = 0;
		bg.color = songs[curSelected[freeplayType]].color;
		intendedColor = bg.color;

		curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));
		
		changeSelection();
		changePortrait(songs[curSelected[freeplayType]].charPort);
		changeDiff();

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		var leText:String = "Press RESET to Reset your Score and Accuracy.";
		var size:Int = 18;
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, size);
		text.setFormat(Paths.font("HouseofTerror.ttf"), size, FlxColor.WHITE, CENTER);
		text.scrollFactor.set();
		add(text);
		super.create();
	}

	override function closeSubState() {
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int, charPort:String)
	{
		if(!FlxG.save.data.playedSongs.contains(CoolUtil.spaceToDash(songName.toLowerCase())))
			color = 0xff737373;

		songs.push(new SongMetadata(songName, weekNum, songCharacter, color, charPort));
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, weekColor:Array<Int>, ?songCharacters:Array<String>, charPort:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];
		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num], weekColor[num], charPort[num]);
			if (songCharacters.length != 1)
				num++;
		}
	}

	var instPlaying:Int = -1;
	public static var vocals:FlxSound = null;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(CoolUtil.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) { //No decimals, add an empty space
			ratingSplit.push('');
		}
		
		while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
		positionHighscore();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var ctrl = FlxG.keys.justPressed.CONTROL;

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if(!cantDo)
		{
			if(songs.length > 1)
			{		
				if (upP)
				{
					changeSelection(-shiftMult);
					changePortrait(songs[curSelected[freeplayType]].charPort);
					holdTime = 0;
				}
				if (downP)
				{
					changeSelection(shiftMult);
					changePortrait(songs[curSelected[freeplayType]].charPort);
					holdTime = 0;
				}
		
				if(controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);
		
					if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
						changePortrait(songs[curSelected[freeplayType]].charPort);
						changeDiff();
					}
				}
		
				if(FlxG.mouse.wheel != 0)
				{
					changeSelection(-FlxG.mouse.wheel);
					changePortrait(songs[curSelected[freeplayType]].charPort);
					changeDiff();
				}
			}
		
			if (upP || downP) changeDiff();
		
			if (controls.BACK)
			{
				persistentUpdate = false;
				if(colorTween != null) {
					colorTween.cancel();
				}
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new FreeplaySelectState());
			}
				
			if (accepted || FlxG.mouse.justPressed)
			{
				persistentUpdate = false;
				var songLowercase:String = Paths.formatToSongPath(songs[curSelected[freeplayType]].songName);
				var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
				//trace(poop);
		
				#if sys
				if(FileSystem.exists(Paths.json(songLowercase + '/' + poop)))
				{
				#end
					PlayState.SONG = Song.loadFromJson(poop, songLowercase);
					PlayState.isStoryMode = false;
					PlayState.storyDifficulty = curDifficulty;
	
					trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
					if(colorTween != null) {
						colorTween.cancel();
					}
						
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxG.sound.music.volume = 0;
					FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1, true);
					cantDo = true;
					destroyFreeplayVocals();
					
					for (i in 0...grpSongs.members.length)
					{
						if (i == curSelected[freeplayType])
						{
							FlxFlicker.flicker(grpSongs.members[i], 1, 0.06, false, false);
							FlxFlicker.flicker(iconArray[i], 1, 0.06, false, false);
						}
					}

					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						LoadingState.loadAndSwitchState(new PlayState(), true);
						FreeplayState.destroyFreeplayVocals();
					});
				#if sys
				} else {
					Application.current.window.alert('Null Song Reference: "' + poop + '". ', "Critical Error!");
				}
				#end
			}
			else if(controls.RESET)
			{
				persistentUpdate = false;
				openSubState(new ResetScoreSubState(songs[curSelected[freeplayType]].songName, curDifficulty, songs[curSelected[freeplayType]].songCharacter));
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
		}

		grpSongs.forEach(function(spr:FlxText)
        {
			var centX = (FlxG.height/2) - (spr.width /2);
            var centY = (FlxG.height/2) - (spr.height /2);
            spr.y = FlxMath.lerp(spr.y, centY - (curSelected[freeplayType]-spr.ID) * 200, CoolUtil.boundTo(elapsed * 10, 0, 1));

            var contrY = centX - Math.abs((curSelected[freeplayType]-spr.ID))*200;

            spr.x = FlxMath.lerp(spr.x, contrY + 150, CoolUtil.boundTo(elapsed * 10, 0, 1));

            spr.scale.set(
                spr.ID == curSelected[freeplayType] ?
                    FlxMath.lerp(spr.scale.x, 1, CoolUtil.boundTo(elapsed * 10.2, 0, 1))
                    :
                    FlxMath.lerp(spr.scale.x, 0.8, CoolUtil.boundTo(elapsed * 10.2, 0, 1)),
                spr.ID == curSelected[freeplayType] ?
                    FlxMath.lerp(spr.scale.x, 1, CoolUtil.boundTo(elapsed * 10.2, 0, 1))
                    :
                    FlxMath.lerp(spr.scale.x, 0.8, CoolUtil.boundTo(elapsed * 10.2, 0, 1))
            );
            spr.alpha = (
                spr.ID == curSelected[freeplayType] ?
                    FlxMath.lerp(spr.alpha, 1, CoolUtil.boundTo(elapsed * 5, 0, 1))
                    :
                    FlxMath.lerp(spr.alpha, 0.7, CoolUtil.boundTo(elapsed * 5, 0, 1))
            );
        });


		for (spr in 0...iconArray.length)
        {
            iconArray[spr].scale.set(
                spr == curSelected[freeplayType] ?
                    FlxMath.lerp(iconArray[spr].scale.x, 1, CoolUtil.boundTo(elapsed * 10.2, 0, 1))
                    :
                    FlxMath.lerp(iconArray[spr].scale.x, 0.8, CoolUtil.boundTo(elapsed * 10.2, 0, 1)),
				spr == curSelected[freeplayType] ?
                    FlxMath.lerp(iconArray[spr].scale.x, 1, CoolUtil.boundTo(elapsed * 10.2, 0, 1))
                    :
                    FlxMath.lerp(iconArray[spr].scale.x, 0.8, CoolUtil.boundTo(elapsed * 10.2, 0, 1))
            );
            iconArray[spr].alpha = (
				spr == curSelected[freeplayType] ?
                    FlxMath.lerp(iconArray[spr].alpha, 1, CoolUtil.boundTo(elapsed * 5, 0, 1))
                    :
                    FlxMath.lerp(iconArray[spr].alpha, 0.6, CoolUtil.boundTo(elapsed * 5, 0, 1))
            );
        };

		super.update(elapsed);
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = Difficulty.list.length-1;
		if (curDifficulty >= Difficulty.list.length)
			curDifficulty = 0;

		lastDifficultyName = Difficulty.getString(curDifficulty);

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected[freeplayType]].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected[freeplayType]].songName, curDifficulty);
		#end

		positionHighscore();

		_updateSongLastDifficulty();
	}

	function uniqueMedalChange(medalInt:Int) //почему не LERP? потому что Ease
	{
		medal.visible = true;

		FlxTween.cancelTweensOf(medal);
		FlxTween.cancelTweensOf(medal.scale);
		FlxTween.cancelTweensOf(medal.color);
		FlxTween.cancelTweensOf(medal.colorTransform);
		medal.scale.set(0.2, 0.2);
		medal.angle = 0;
		medal.color = 0xFFFFFFFF;

		medal.colorTransform.redOffset = 0;
		medal.colorTransform.greenOffset = 0;
		medal.colorTransform.blueOffset = 0;

		medal.colorTransform.redMultiplier = 1;
		medal.colorTransform.greenMultiplier = 1;
		medal.colorTransform.blueMultiplier = 1;
		switch(medalInt)
		{
			case 7:
				//вообще нихуя сосите
			case 6:
				//вообще нихуя сосите
			case 5:
				FlxTween.tween(medal.scale, {x: 0.3, y: 0.3}, 0.6, {ease: FlxEase.quadOut, type: BACKWARD});
			case 4:
				FlxTween.tween(medal.scale, {x: 0.4, y: 0.4}, 0.6, {ease: FlxEase.backOut, type: BACKWARD});
			case 3:
				FlxTween.tween(medal.scale, {x: 0.4, y: 0.4}, 0.6, {ease: FlxEase.bounceOut, type: BACKWARD});
				FlxTween.tween(medal, {angle: 7}, 0.6, {ease: FlxEase.backOut, type: BACKWARD});
			case 2:
				medal.color = 0xff7400ff;
				FlxTween.tween(medal.scale, {x: 0.5, y: 0.5}, 0.6, {ease: FlxEase.expoOut, type: BACKWARD});
				FlxTween.tween(medal, {angle: 12}, 0.6, {ease: FlxEase.bounceOut, type: BACKWARD});
				FlxTween.color(medal, 0.6, medal.color, 0xffFFFFFF);
			case 1:
				medal.colorTransform.redOffset = 134;
				medal.colorTransform.greenOffset = 248;
				medal.colorTransform.blueOffset = 255;

				medal.colorTransform.redMultiplier = 0;
				medal.colorTransform.greenMultiplier = 0;
				medal.colorTransform.blueMultiplier = 0;

				FlxTween.tween(medal.scale, {x: 0.6, y: 0.6}, 0.6, {ease: FlxEase.elasticOut, type: BACKWARD});
				FlxTween.tween(medal, {angle: 23}, 0.6, {ease: FlxEase.expoOut, type: BACKWARD});
				FlxTween.tween(medal.colorTransform, {redOffset: 0, greenOffset: 0, blueOffset: 0, redMultiplier: 1, greenMultiplier: 1, blueMultiplier: 1}, 0.6);

				//medal.x -= 50; //ТЫ ЧЕ ОХУЕЛ
		}

		medal.loadGraphic(Paths.image('medals/medal_'+Highscore.getMedal(songs[curSelected[freeplayType]].songName, curDifficulty)));

		if(Highscore.getMedal(songs[curSelected[freeplayType]].songName, curDifficulty) == 1)
		{
			medal.offset.x = 75;
			medal.offset.y = 0;
		}
		else if(Highscore.getMedal(songs[curSelected[freeplayType]].songName, curDifficulty) == 2)
		{
			medal.offset.x = 25;
			medal.offset.y = 15;
		}
		else
		{
			medal.offset.x = 0;
			medal.offset.y = 0;
		}
	}

	var portTween:FlxTween;
	function changePortrait(char:String = 'lamar')
	{
		portrait.loadGraphic(Paths.image('freeplay_chars/'+char));

		if(!FlxG.save.data.playedSongs.contains(CoolUtil.spaceToDash(songs[curSelected[freeplayType]].songName.toLowerCase())))
		{
			portrait.shader = rimlight.shader;
			portrait.color = 0xff000000;
		}
		else
		{
			portrait.shader = null;
			portrait.color = 0xffffffff;
		}

		switch(char)
		{
			case 'jap_1':
				portrait.offset.set(-190, 110);
			case 'jap_2':
				portrait.offset.set(-196, 70);
			case 'jap_3':
				portrait.offset.set(-190, 110);
			case 'jap_4':
				portrait.offset.set(-198, 110);
			case 'zombie':
				portrait.offset.set(-82, 140);
			case 'tshort':
				portrait.offset.set(-80, 160);
			case 'lork':
				portrait.offset.set(49, 100);
			case 'dead':
				portrait.offset.set(-300, 100);
			case 'lamar':
				portrait.offset.set(0, 70);
			case 'bbg':
				portrait.offset.set(-210, 60);
			case 'gandons':
				portrait.offset.set(-13, 147);
			case 'jap-old':
				portrait.offset.set(-237, 136);
			case 'jap2-old':
				portrait.offset.set(-237, 136);
			default:
				portrait.offset.set(0, 0);
		}
		if(portTween != null) portTween.cancel();
		portrait.y == 150;
		portrait.y += 30;
		portTween = FlxTween.tween(portrait, {y: 150}, 0.3, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)
            {
                portTween = null;
            }});
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected[freeplayType] += change;

		if (curSelected[freeplayType] < 0)
			curSelected[freeplayType] = songs.length - 1;
		if (curSelected[freeplayType] >= songs.length)
			curSelected[freeplayType] = 0;

		var lastList:Array<String> = Difficulty.list;
			
		var newColor:Int = songs[curSelected[freeplayType]].color;
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected[freeplayType]].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected[freeplayType]].songName, curDifficulty);
		#end
		
		Mods.currentModDirectory = songs[curSelected[freeplayType]].folder;
		PlayState.storyWeek = songs[curSelected[freeplayType]].week;

		Difficulty.resetList();
		
		var savedDiff:String = songs[curSelected[freeplayType]].lastDifficulty;
		var lastDiff:Int = Difficulty.list.indexOf(lastDifficultyName);
		if(savedDiff != null && !lastList.contains(savedDiff) && Difficulty.list.contains(savedDiff))
			curDifficulty = Math.round(Math.max(0, Difficulty.list.indexOf(savedDiff)));
		else if(lastDiff > -1)
			curDifficulty = lastDiff;
		else if(Difficulty.list.contains(Difficulty.getDefault()))
			curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
		else
			curDifficulty = 0;

		changeDiff();
		_updateSongLastDifficulty();

		uniqueMedalChange(Highscore.getMedal(songs[curSelected[freeplayType]].songName, curDifficulty));
	}

	private function positionHighscore() {
		scoreText.x = FlxG.width - scoreText.width - 6;

		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
	}

	inline private function _updateSongLastDifficulty()
	{
		songs[curSelected[freeplayType]].lastDifficulty = Difficulty.getString(curDifficulty);
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";
	public var charPort:String = "";
	public var lastDifficulty:String = null;

	public function new(song:String, week:Int, songCharacter:String, color:Int, charPort:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.charPort = charPort;
		this.folder = Mods.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}
