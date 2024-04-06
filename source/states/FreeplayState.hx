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

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	static var curSelected:Array<Int> = [0, 0, 0];
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = Difficulty.getDefault();
	public static var freeplayType = 0;

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	var curCategory:FlxText;

	private var grpSongs:FlxTypedGroup<FlxText>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	var bg:FlxSprite;
	public static var intendedColor:Int;
	var colorTween:FlxTween;

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

		switch (freeplayType)
		{
			case 0:
				addWeek(['With Cone', 'BOOM', 'Overfire'], 1, 0xFFbc0000, ['jap', 'jap', 'jap-wheel']);
			case 1:
				addWeek(['Anekdot', 'Klork', 'T short', 'Monochrome', '64 rubl', 'Lore'], 1, 0xfffe9797, ['box', 'lork', 'short', 'deadjap', 'bf', 'bf']);
			case 2:
				addWeek(['S6x Boom', 'Lamar Tut Voobshe Ne Nujen '], 1, 0xff23cb64, ['jap', 'jamar']);
			case 3:
				addWeek(['BOOM Old', 'Overfire Old', 'Klork Old'], 1, 0xFF898989, ['dad', 'dad', 'lork']);
		};

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
//		bg.antialiasing = backend.ClientPrefs.globalAntialiasing;
		add(bg);
		bg.screenCenter();

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(40, 40);
		grid.alpha = 0;
		FlxTween.tween(grid, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		add(grid);

		grpSongs = new FlxTypedGroup<FlxText>();
		add(grpSongs);

		var curID:Int = -1;
		for (i in 0...songs.length)
		{
			curID += 1;
			var songText:FlxText = new FlxText(0, 0, 0, songs[i].songName, 87);
			songText.setFormat(Paths.font("HouseofTerror.ttf"), 87,  FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songText.borderSize = 4;
			songText.ID = curID;
			grpSongs.add(songText);

			songText.scale.x = Math.min(1, 980 / songText.width);

			Mods.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;
			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);
		}
		WeekData.setDirectoryFromWeek();

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("HouseofTerror.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		add(scoreText);

		curCategory = new FlxText(0, scoreText.y, 0, FreeplaySelectState.freeplayCats[freeplayType], 32);
		curCategory.font = scoreText.font;
		curCategory.screenCenter(X);
		add(curCategory);

		if(curSelected[freeplayType] >= songs.length) curSelected[freeplayType] = 0;
		bg.color = songs[curSelected[freeplayType]].color;
		intendedColor = bg.color;

		curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));
		
		changeSelection();
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

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, weekColor:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];
		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num], weekColor);
			if (songCharacters.length != 1)
				num++;
		}
	}

	var instPlaying:Int = -1;
	public static var vocals:FlxSound = null;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

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

		if(songs.length > 1)
		{
			if (upP)
			{
				changeSelection(-shiftMult);
				holdTime = 0;
			}
			if (downP)
			{
				changeSelection(shiftMult);
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
					changeDiff();
				}
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
		
		if (accepted)
		{
			persistentUpdate = false;
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected[freeplayType]].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
			trace(poop);

			PlayState.SONG = Song.loadFromJson(poop, songLowercase);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
			if(colorTween != null) {
				colorTween.cancel();
			}
			
			if (FlxG.keys.pressed.SHIFT){
				LoadingState.loadAndSwitchState(new ChartingState());
			}else{
			//	LoadingState.loadAndSwitchState(new CharSelectState()); //just tryna fix a bunch of shit
				LoadingState.loadAndSwitchState(new PlayState());
			}

			FlxG.sound.music.volume = 0;
					
			destroyFreeplayVocals();
		}
		else if(controls.RESET)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected[freeplayType]].songName, curDifficulty, songs[curSelected[freeplayType]].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}

		grpSongs.forEach(function(spr:FlxText)
        {
			var cent = (FlxG.height/2) - (spr.height /2);
            spr.y = FlxMath.lerp(spr.y, cent - (curSelected[freeplayType]-spr.ID) * 200, CoolUtil.boundTo(elapsed * 10, 0, 1));
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
			spr.x = (
                spr.ID == curSelected[freeplayType] ?
                    FlxMath.lerp(spr.x, 150, CoolUtil.boundTo(elapsed * 5, 0, 1))
                    :
                    FlxMath.lerp(spr.x, 50, CoolUtil.boundTo(elapsed * 5, 0, 1))
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

		Difficulty.loadFromWeek();
		
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
	public var lastDifficulty:String = null;

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Mods.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}
