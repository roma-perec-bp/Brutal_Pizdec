package states;

import backend.Achievements;
import backend.Highscore;
import backend.StageData;
import backend.WeekData;
import backend.Song;
import backend.Section;
import backend.Rating;

import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.math.FlxPoint;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.animation.FlxAnimationController;
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;
import openfl.events.KeyboardEvent;
import tjson.TJSON as Json;

import cutscenes.CutsceneHandler;
import cutscenes.DialogueBoxPsych;

import states.StoryMenuState;
import states.FreeplayState;
import states.EndState;

import substates.PauseSubState;
import substates.PauseSubStateold;
import substates.GameOverSubstate;

#if !flash 
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
#end

#if sys
import sys.FileSystem;
import sys.io.File;
#end

import objects.VideoSprite;

import objects.Note.EventNote;
import objects.*;
import states.stages.objects.*;

#if LUA_ALLOWED
import psychlua.*;
#else
import psychlua.FunkinLua;
import psychlua.LuaUtils;
import psychlua.HScript;
#end

#if SScript
import tea.SScript;
#end
	
class PlayState extends MusicBeatState
{
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	public static var ratingStuff:Array<Dynamic> = [
		['You Suck!', 0.2], //From 0% to 19%
		['Shit', 0.4], //From 20% to 39%
		['Bad', 0.5], //From 40% to 49%
		['Bruh', 0.6], //From 50% to 59%
		['Meh', 0.69], //From 60% to 68%
		['Nice', 0.7], //69%
		['Good', 0.8], //From 70% to 79%
		['Great', 0.9], //From 80% to 89%
		['Sick!', 1], //From 90% to 99%
		['Perfect!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];

	//event variables
	private var isCameraOnForcedPos:Bool = false;

	public var boyfriendMap:Map<String, Character> = new Map<String, Character>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var romMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();
	
	#if HSCRIPT_ALLOWED
	public var hscriptArray:Array<HScript> = [];
	public var instancesExclude:Array<String> = [];
	#end

	#if LUA_ALLOWED
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, FlxText> = new Map<String, FlxText>();
	public var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float = 350;

	public var playbackRate(default, set):Float = 1;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var romGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
	public static var curStage:String = '';
	public static var stageUI:String = "normal";
	public static var isPixelStage(get, never):Bool;

	@:noCompletion
	static function get_isPixelStage():Bool
		return stageUI == "pixel";

	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public var spawnTime:Float = 2000;

	var healthDrop:Float = 0;
	var dropTime:Float = 0;

	public var vocals:FlxSound;
	public var inst:FlxSound;

	public var dad:Character = null;
	public var gf:Character = null;
	public var boyfriend:Character = null;

	public var rom:Character = null; //ТОТ САМЫЫЫЙ!!!!111!1!1

	var direction:Bool = false; //fade camera

	private var task:SongIntro;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

	public var camFollow:FlxObject;
	private static var prevCamFollow:FlxObject;

	var cameraLocked:Bool = false;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;
	public var grpHoldSplashes:FlxTypedGroup<SustainSplash>;

	public var camZooming:Bool = false;
	public var camZoomingMult:Float = 1;
	public var camZoomingDecay:Float = 1;
	private var curSong:String = "";

	private var gameZoomAdd:Float = 0;
	private var gameZoom:Float = 1;

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var smoothHealth:Float = 1;
	public var combo:Int = 0;

	public var healthBar:HealthBar;
	public var timeBar:HealthBar;
	private var healthBarBGOverlay:FlxSprite;
	var songPercent:Float = 0;

	private var fireHalapeno:FlxSprite;
	private var fireFlash:FlxSprite;

	public var ratingsData:Array<Rating> = Rating.loadDefault();
	public var fullComboFunction:Void->Void = null;

	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;
	private var updateTime:Bool = true;
	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	public static var video1Cache:Bool = false;
	public static var video2Cache:Bool = false;

	public var vocalsFinished = false;

	//Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;
	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;

	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var iconROM:HealthIcon;
	public var iconGF:HealthIcon;
	public var camVideo:FlxCamera;
	public var camHUD:FlxCamera;
	public var camFlash:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var cameraSpeed:Float = 1;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxText;
	var timeTxt:FlxText;

	var ratingTxt:FlxText;

	var accuracyShit:FlxText;

	var scoreTxtTween:FlxTween;
	var sexcameratween:FlxTween;
	var followTween:FlxTween;

	var trail:FlxTrail;

	var japHit:Int = 0;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	//LANES
	var laneP0:FlxSprite;
	var laneP1:FlxSprite;
	var laneP2:FlxSprite;
	var laneP3:FlxSprite;

	var laneE0:FlxSprite;
	var laneE1:FlxSprite;
	var laneE2:FlxSprite;
	var laneE3:FlxSprite;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;
	var songLength:Float = 0;
	var songLengthDiscord:Float = 0; //Fake timer ломает дискодр рпс

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	//Achievement shit
	var keysPressed:Array<Int> = [];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	// Lua shit
	public static var instance:PlayState;
	public var luaArray:Array<FunkinLua> = [];
	#if LUA_ALLOWED
	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;
	#end
	public var introSoundsSuffix:String = '';

	// Less laggy controls
	private var keysArray:Array<String>;

	public var precacheList:Map<String, String> = new Map<String, String>();
	public static var songName:String;

	// Callbacks for stages
	public var startCallback:Void->Void = null;
	public var endCallback:Void->Void = null;

	// Медальки
	public var medal:FlxSprite;
	public var medal_system:Array<Dynamic> = [
		[99.9, 100.0, 'Master'],
		[95.0, 99.8, 'Super Elite'],
		[75.0, 94.9, 'Elite'],
		[74.9, 50.0, 'Advanced'],
		[38.0, 49.9, 'Specialist'],
		[0.0, 37.9, 'Skill issue']
	];
	public var medalStatus:Int = 5;
	public var medalOldStatus:Int = 5;

	override public function create()
	{
		//trace('Playback Rate: ' + playbackRate);
		Paths.clearStoredMemory();

		startCallback = startCountdown;
		endCallback = endSong;

		// for lua
		instance = this;

		PauseSubState.songName = null; //Reset to default
		playbackRate = ClientPrefs.getGameplaySetting('songspeed');
		fullComboFunction = fullComboUpdate;

		keysArray = [
			'note_left',
			'note_down',
			'note_up',
			'note_right'
		];

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		rotCam = false;
		camera.angle = 0;

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain');
		healthLoss = ClientPrefs.getGameplaySetting('healthloss');
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill');
		practiceMode = ClientPrefs.getGameplaySetting('practice');
		cpuControlled = ClientPrefs.getGameplaySetting('botplay');

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = initPsychCamera();

		camVideo = new FlxCamera();
		camFlash = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camVideo.bgColor.alpha = 0;
		camHUD.bgColor.alpha = 0;
		camFlash.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.add(camFlash, false);
		FlxG.cameras.add(camVideo, false);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);
		grpHoldSplashes = new FlxTypedGroup<SustainSplash>();
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		CustomFadeTransition.nextCamera = camOther;

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.bpm = SONG.bpm;

		#if desktop
		storyDifficultyText = Difficulty.getString();

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
			detailsText = "Story Mode: " + WeekData.getCurrentWeek().weekName;
		else
			detailsText = "Freeplay";

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		GameOverSubstate.resetVariables();
		songName = Paths.formatToSongPath(SONG.song);
		if(SONG.stage == null || SONG.stage.length < 1) {
			SONG.stage = StageData.vanillaSongStage(songName);
		}
		curStage = SONG.stage;

		var stageData:StageFile = StageData.getStageFile(curStage);
		if(stageData == null) { //Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = StageData.dummy();
		}

		defaultCamZoom = stageData.defaultZoom;

		stageUI = "normal";
		if (stageData.stageUI != null && stageData.stageUI.trim().length > 0)
			stageUI = stageData.stageUI;
		else {
			if (stageData.isPixelStage)
				stageUI = "pixel";
		}
		
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		if(stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if(boyfriendCameraOffset == null) //Fucks sake should have done it since the start :rolling_eyes:
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if(opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];

		girlfriendCameraOffset = stageData.camera_girlfriend;
		if(girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		romGroup = new FlxSpriteGroup(DAD_X + 100, DAD_Y - 150);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		if(!ClientPrefs.data.optimize)
		{
			switch (curStage)
			{
				case 'stage': new states.stages.StageWeek1(); //Default
				case 'night': new states.stages.Roof(); //Perec
				case 'anekdot': new states.stages.Anekdot(); //Shutky
				case 'day': new states.stages.Grass(); //Klork and shit
				case 'random': new states.stages.Random(); //T short
				case 'void': new states.stages.Void(); //Dead Perec
				case 'flipaclip': new states.stages.FlipaClip(); //Малыш~
				case 'lamar': new states.stages.Lamar(); //Lamar
				case 'roof-old': new states.stages.OldRoof(); //Perec Old
			}
		}

		if(isPixelStage) {
			introSoundsSuffix = '-pixel';
		}

		add(gfGroup);
		if(SONG.song == 'Lore') add(romGroup);
		add(dadGroup);
		add(boyfriendGroup);

		#if LUA_ALLOWED
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		// "GLOBAL" SCRIPTS
		#if LUA_ALLOWED
		var foldersToCheck:Array<String> = Mods.directoriesWithFile(Paths.getPreloadPath(), 'scripts/');
		for (folder in foldersToCheck)
			for (file in FileSystem.readDirectory(folder))
			{
				if(file.toLowerCase().endsWith('.lua'))
					new FunkinLua(folder + file);
				if(file.toLowerCase().endsWith('.hx'))
					initHScript(folder + file);
			}
		#end

		// STAGE SCRIPTS
		#if LUA_ALLOWED
		startLuasNamed('stages/' + curStage + '.lua');
		#end

		#if HSCRIPT_ALLOWED
		startHScriptsNamed('stages/' + curStage + '.hx');
		#end

		if (!stageData.hide_girlfriend && !ClientPrefs.data.optimize)
		{
			if(SONG.gfVersion == null || SONG.gfVersion.length < 1) SONG.gfVersion = 'gf'; //Fix for the Chart Editor
			gf = new Character(0, 0, SONG.gfVersion);
			startCharacterPos(gf);
			gf.scrollFactor.set(0.95, 0.95);
			gfGroup.add(gf);
			startCharacterScripts(gf.curCharacter);
		}

		if(SONG.song == 'Lore')
		{
			rom = new Character(0, 0, 'rom');
			startCharacterPos(rom, true);
			romGroup.add(rom);
			startCharacterScripts(rom.curCharacter);
		}

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);
		startCharacterScripts(dad.curCharacter);

		boyfriend = new Character(0, 0, SONG.player1, true);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		startCharacterScripts(boyfriend.curCharacter);

		var camPos:FlxPoint = FlxPoint.get(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		if(gf != null)
		{
			camPos.x += gf.getGraphicMidpoint().x + gf.cameraPosition[0];
			camPos.y += gf.getGraphicMidpoint().y + gf.cameraPosition[1];
		}

		if(dad.curCharacter.startsWith('gf')) {
			dad.setPosition(GF_X, GF_Y);
			if(gf != null)
				gf.visible = false;
		}

		if(ClientPrefs.data.optimize)
		{
			boyfriendGroup.alpha = 0.00001;
			dadGroup.alpha = 0.00001;
			gfGroup.alpha = 0.00001;
		}

		createLanes();

		Conductor.songPosition = -5000 / Conductor.songPosition;
		var showTime:Bool = (ClientPrefs.data.timeBarType != 'Disabled');
		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
		timeTxt.setFormat(Paths.font("HouseofTerror.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = updateTime = showTime;
		if(ClientPrefs.data.downScroll) timeTxt.y = FlxG.height - 44;
		if(ClientPrefs.data.timeBarType == 'Song Name') timeTxt.text = SONG.song;

		if(curStage != 'roof-old')
			timeBar = new HealthBar(0, timeTxt.y + (timeTxt.height / 4) - 9, 'timeBar', function() return songPercent, 0, 1);
		else
			timeBar = new HealthBar(0, timeTxt.y + (timeTxt.height / 4), 'timeBarOld', function() return songPercent, 0, 1);

		timeBar.scrollFactor.set();
		timeBar.screenCenter(X);
		timeBar.alpha = 0;
		timeBar.visible = showTime;
		if(curStage != 'roof-old') timeBar.setColors(0xffc3e942, 0xff000000);
		add(timeBar);
		add(timeTxt);

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);

		if(ClientPrefs.data.timeBarType == 'Song Name')
		{
			timeTxt.size = 24;
			timeTxt.y += 3;
		}

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(camPos.x, camPos.y);
		camPos.put();
				
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.snapToTarget();

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
		moveCameraSection();

		if(curStage != 'roof-old')
		{
			if (Assets.exists(Paths.txt(SONG.song.toLowerCase().replace(' ', '-') + "/info")))
			{
				task = new SongIntro(0, 0, SONG.song.toLowerCase().replace(' ', '-'));
				task.cameras = [camOther];
				add(task);
			}
		}

		if(curStage == 'roof-old')
		{
			healthBarBGOverlay = new FlxSprite(300, FlxG.height * (!ClientPrefs.data.downScroll ? 0.785 : 0.005));
			healthBarBGOverlay.loadGraphic(Paths.image('healthBarBG-old', 'shared'));
		}
		else
		{
			healthBarBGOverlay = new FlxSprite(0, 0);
			healthBarBGOverlay.loadGraphic(Paths.image('healthBarBG', 'shared'));
		}

		healthBarBGOverlay.visible = !ClientPrefs.data.hideHud;
		healthBarBGOverlay.alpha = ClientPrefs.data.healthBarAlpha;
		add(healthBarBGOverlay);

		healthBar = new HealthBar(0, FlxG.height * (!ClientPrefs.data.downScroll ? 0.89 : 0.11), 'healthBar', function() return smoothHealth, 0, 2);
		healthBar.screenCenter(X);
		healthBar.leftToRight = false;
		healthBar.scrollFactor.set();
		healthBar.visible = !ClientPrefs.data.hideHud;
		healthBar.alpha = ClientPrefs.data.healthBarAlpha;
		reloadHealthBarColors();
		add(healthBar);

		if(curStage != 'roof-old')
		{
			healthBarBGOverlay.x = healthBar.x - 22;
			healthBarBGOverlay.y = healthBar.y - 38;
		}

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - 75;
		iconP1.visible = !ClientPrefs.data.hideHud;
		iconP1.alpha = ClientPrefs.data.healthBarAlpha;
		add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - 75;
		iconP2.visible = !ClientPrefs.data.hideHud;
		iconP2.alpha = ClientPrefs.data.healthBarAlpha;
		add(iconP2);

		if(SONG.song == 'Lore')
		{
			iconROM = new HealthIcon(rom.healthIcon, false);
			iconROM.y = healthBar.y - 50;
			iconROM.visible = !ClientPrefs.data.hideHud;
			iconROM.alpha = ClientPrefs.data.healthBarAlpha;
			add(iconROM);

			iconGF = new HealthIcon(gf.healthIcon, true);
			iconGF.y = healthBar.y - 50;
			iconGF.visible = !ClientPrefs.data.hideHud;
			iconGF.alpha = ClientPrefs.data.healthBarAlpha;
			add(iconGF);
		}
	
		if(curStage == 'roof-old')
		{
			scoreTxt = new FlxText(0, healthBar.y + 40, FlxG.width, "", 20);
			scoreTxt.setFormat(Paths.font("HouseofTerror.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}
		else
		{
			scoreTxt = new FlxText(0, healthBar.y - 45, FlxG.width, "", 32);
			scoreTxt.setFormat(Paths.font("HouseofTerror.ttf"), 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}

		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.data.hideHud;
		add(scoreTxt);

		accuracyShit = new FlxText(0, healthBar.y + 40, FlxG.width, "Rating: Horny", 32);
		accuracyShit.setFormat(Paths.font("HouseofTerror.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		accuracyShit.scrollFactor.set();
		accuracyShit.visible = !ClientPrefs.data.hideHud;
		accuracyShit.borderSize = 1.25;

		ratingTxt = new FlxText(0, healthBar.y - 125, FlxG.width, "Lmao x69", 64);
		ratingTxt.setFormat(Paths.font("HouseofTerror.ttf"), 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		ratingTxt.scrollFactor.set();
		ratingTxt.alpha = 0.001;
		ratingTxt.borderSize = 1.5;
		ratingTxt.visible = !ClientPrefs.data.hideHud;

		if(curStage != 'roof-old')
		{
			add(accuracyShit);
			add(ratingTxt);
		}

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		var splash:NoteSplash = new NoteSplash(100, 100);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.000001; //cant make it invisible or it won't allow precaching

		SustainSplash.startCrochet = Conductor.stepCrochet;
		var splash2:SustainSplash = new SustainSplash();
		grpHoldSplashes.add(splash2);
		splash2.alpha = 0.00001;

		generateSong(SONG.song);

		add(grpHoldSplashes);
		add(grpNoteSplashes);

		if(curStage == 'roof-old')
		{
			fireHalapeno = new FlxSprite(0, scoreTxt.y - 250);
			fireHalapeno.frames = Paths.getSparrowAtlas('fireLmao');
			fireHalapeno.animation.addByPrefix('idle', 'fire', 24);
			fireHalapeno.flipX = true;
			fireHalapeno.antialiasing = ClientPrefs.data.antialiasing;
			fireHalapeno.scrollFactor.set();
			fireHalapeno.blend = ADD;
			fireHalapeno.alpha = 0.0001;
			fireHalapeno.updateHitbox();
			fireHalapeno.screenCenter(X);
			fireHalapeno.animation.play('idle');
			add(fireHalapeno);
		} else if(curStage == 'night') { 
			fireHalapeno = new FlxSprite(0, scoreTxt.y - 450);
			fireHalapeno.frames = Paths.getSparrowAtlas('fire_jap');
			fireHalapeno.animation.addByPrefix('idle', 'firing', 24, false);
			fireHalapeno.antialiasing = ClientPrefs.data.antialiasing;
			fireHalapeno.scrollFactor.set();
			fireHalapeno.blend = ADD;
			fireHalapeno.alpha = 0.00001;
			fireHalapeno.updateHitbox();
			fireHalapeno.screenCenter(X);
			fireHalapeno.animation.play('idle');
			add(fireHalapeno);
		}

		if(curStage == 'night')
		{
			fireFlash = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFFF7700);
			fireFlash.alpha = 0;
			fireFlash.blend = ADD;
			add(fireFlash);
		}

		botplayTxt = new FlxText(400, timeBar.y + 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);
		if(ClientPrefs.data.downScroll) {
			botplayTxt.y = timeBar.y - 78;
		}
		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		grpHoldSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];

		healthBar.cameras = [camHUD];
		healthBarBGOverlay.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		if(SONG.song == 'Lore') iconROM.cameras = [camHUD];
		if(SONG.song == 'Lore') iconGF.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		accuracyShit.cameras = [camHUD];
		ratingTxt.cameras = [camHUD];

		if(curStage == 'roof-old' || curStage == 'night')
			fireHalapeno.cameras = [camHUD];

		if(curStage == 'night') fireFlash.cameras = [camOther];

		// медальки
		medal = new FlxSprite(FlxG.width - 164, FlxG.height - 224).loadGraphic(Paths.image('medals/medal_6', 'shared'));
		medal.scale.set(0.3, 0.3);
		medal.origin.set(128/2, 128/2);
		medal.updateHitbox();
		medal.visible = !ClientPrefs.data.hideHud;
		add(medal);

		botplayTxt.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		medal.cameras = [camHUD];

		startingSong = true;
		
		#if LUA_ALLOWED
		for (notetype in noteTypes)
			startLuasNamed('custom_notetypes/' + notetype + '.lua');

		for (event in eventsPushed)
			startLuasNamed('custom_events/' + event + '.lua');
		#end

		#if HSCRIPT_ALLOWED
		for (notetype in noteTypes)
			startHScriptsNamed('custom_notetypes/' + notetype + '.hx');

		for (event in eventsPushed)
			startHScriptsNamed('custom_events/' + event + '.hx');
		#end
		noteTypes = null;
		eventsPushed = null;

		if(eventNotes.length > 1)
		{
			for (event in eventNotes) event.strumTime -= eventEarlyTrigger(event);
			eventNotes.sort(sortByTime);
		}

		// SONG SPECIFIC SCRIPTS
		#if LUA_ALLOWED
		var foldersToCheck:Array<String> = Mods.directoriesWithFile(Paths.getPreloadPath(), 'data/' + songName + '/');
		for (folder in foldersToCheck)
			for (file in FileSystem.readDirectory(folder))
			{
				if(file.toLowerCase().endsWith('.lua'))
					new FunkinLua(folder + file);
				if(file.toLowerCase().endsWith('.hx'))
					initHScript(folder + file);
			}
		#end

		startCallback();
		RecalculateRating();

		//PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		if(ClientPrefs.data.hitsoundVolume > 0) precacheList.set('hitsound', 'sound');
		precacheList.set('missnote1', 'sound');
		precacheList.set('missnote2', 'sound');
		precacheList.set('missnote3', 'sound');

		precacheList.set('boom', 'sound');

		if (PauseSubState.songName != null) {
			precacheList.set(PauseSubState.songName, 'music');
		} else if(ClientPrefs.data.pauseMusic != 'None') {
			precacheList.set(Paths.formatToSongPath(ClientPrefs.data.pauseMusic), 'music');
		}

		precacheList.set('alphabet', 'image');

		if(curSong == 'Anekdot')
		{
			for (i in 0...5)
				Paths.image('noteAnekdot/note_' + i);
		}

		resetRPC();

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);

		stagesFunc(function(stage:BaseStage) stage.createPost());
		callOnScripts('onCreatePost');

		cacheCountdown();
		cachePopUpScore();
		cacheMedals();
		
		for (key => type in precacheList)
		{
			//trace('Key $key is type $type');
			switch(type)
			{
				case 'image':
					Paths.image(key);
				case 'sound':
					Paths.sound(key);
				case 'music':
					Paths.music(key);
				case 'video':
					if(!ClientPrefs.data.optimize) Paths.video(key);
			}
		}

		super.create();
		Paths.clearUnusedMemory();

		FlxG.mouse.visible = true;
		
		CustomFadeTransition.nextCamera = camOther;
		if(eventNotes.length < 1) checkEventNote();
	}

	function set_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / songSpeed; //funny word huh
			if(ratio != 1)
			{
				for (note in notes.members) note.resizeByRatio(ratio);
				for (note in unspawnNotes) note.resizeByRatio(ratio);
			}
		}
		songSpeed = value;
		noteKillOffset = Math.max(Conductor.stepCrochet, 350 / songSpeed * playbackRate);
		return value;
	}

	function set_playbackRate(value:Float):Float
	{
		if(generatedMusic)
		{
			if(vocals != null) vocals.pitch = value;
			FlxG.sound.music.pitch = value;

			var ratio:Float = playbackRate / value; //funny word huh
			if(ratio != 1)
			{
				for (note in notes.members) note.resizeByRatio(ratio);
				for (note in unspawnNotes) note.resizeByRatio(ratio);
			}
		}
		playbackRate = value;
		FlxAnimationController.globalSpeed = value;
		Conductor.safeZoneOffset = (ClientPrefs.data.safeFrames / 60) * 1000 * value;
		setOnScripts('playbackRate', playbackRate);
		return value;
	}

	public function addTextToDebug(text:String, color:FlxColor) {
		#if LUA_ALLOWED
		var newText:DebugLuaText = luaDebugGroup.recycle(DebugLuaText);
		newText.text = text;
		newText.color = color;
		newText.disableTime = 6;
		newText.alpha = 1;
		newText.setPosition(10, 8 - newText.height);

		luaDebugGroup.forEachAlive(function(spr:DebugLuaText) {
			spr.y += newText.height + 2;
		});
		luaDebugGroup.add(newText);
		#end
	}

	public function reloadHealthBarColors() {
		healthBar.setColors(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
			FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Character = new Character(0, 0, newCharacter, true);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					startCharacterScripts(newBoyfriend.curCharacter);
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					startCharacterScripts(newDad.curCharacter);
				}

			case 2:
				if(gf != null && !gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					startCharacterScripts(newGf.curCharacter);
				}
		}
	}

	function startCharacterScripts(name:String)
	{
		// Lua
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'characters/' + name + '.lua';
		#if MODS_ALLOWED
		var replacePath:String = Paths.modFolders(luaFile);
		if(FileSystem.exists(replacePath))
		{
			luaFile = replacePath;
			doPush = true;
		}
		else
		{
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile))
				doPush = true;
		}
		#else
		luaFile = Paths.getPreloadPath(luaFile);
		if(Assets.exists(luaFile)) doPush = true;
		#end

		if(doPush)
		{
			for (script in luaArray)
			{
				if(script.scriptName == luaFile)
				{
					doPush = false;
					break;
				}
			}
			if(doPush) new FunkinLua(luaFile);
		}
		#end

		// HScript
		#if HSCRIPT_ALLOWED
		var doPush:Bool = false;
		var scriptFile:String = 'characters/' + name + '.hx';
		var replacePath:String = Paths.modFolders(scriptFile);
		if(FileSystem.exists(replacePath))
		{
			scriptFile = replacePath;
			doPush = true;
		}
		else
		{
			scriptFile = Paths.getPreloadPath(scriptFile);
			if(FileSystem.exists(scriptFile))
				doPush = true;
		}
		
		if(doPush)
		{
			if(SScript.global.exists(scriptFile))
				doPush = false;

			if(doPush) initHScript(scriptFile);
		}
		#end
	}

	public function getLuaObject(tag:String, text:Bool=true):FlxSprite {
		#if LUA_ALLOWED
		if(modchartSprites.exists(tag)) return modchartSprites.get(tag);
		if(text && modchartTexts.exists(tag)) return modchartTexts.get(tag);
		if(variables.exists(tag)) return variables.get(tag);
		#end
		return null;
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf')) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public var videoCutscene:VideoSprite = null;
	public function startVideo(name:String, forMidSong:Bool = false, canSkip:Bool = true, loop:Bool = false, playOnLoad:Bool = true, shouldBlend:Bool = false)
	{
		#if VIDEOS_ALLOWED
		//inCutscene = true;

		var foundFile:Bool = false;
		var fileName:String = Paths.video(name);

		#if sys
		if (FileSystem.exists(fileName))
		#else
		if (OpenFlAssets.exists(fileName))
		#end
		foundFile = true;

		if (foundFile)
		{
			videoCutscene = new VideoSprite(fileName, forMidSong, canSkip, loop);

			// Finish callback
			if (forMidSong == false)
			{
				function onVideoEnd()
				{
					if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && !endingSong && !isCameraOnForcedPos)
					{
						moveCameraSection();
						FlxG.camera.snapToTarget();
					}
					videoCutscene = null;
					inCutscene = false;
					startAndEnd();
				}
				videoCutscene.finishCallback = onVideoEnd;
				videoCutscene.onSkip = onVideoEnd;
			}
			add(videoCutscene);

			videoCutscene.videoSprite.cameras = [cameraFromString('video')];
			if(shouldBlend == true)
			{
				videoCutscene.blend = HARDLIGHT;
				videoCutscene.alpha = 0.1;
			}

			if (playOnLoad)
				videoCutscene.videoSprite.play();
			return videoCutscene;
		}
		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		else addTextToDebug("Video not found: " + fileName, FlxColor.RED);
		#else
		else FlxG.log.error("Video not found: " + fileName);
		#end
		#else
		FlxG.log.warn('Platform not supported!');
		startAndEnd();
		#end
		return null;
	}

	function startAndEnd()
	{
		if(endingSong)
			endSong();
		else
			startCountdown();
	}

	var dialogueCount:Int = 0;
	public var psychDialogue:DialogueBoxPsych;
	//You don't have to add a song, just saying. You can just do "startDialogue(DialogueBoxPsych.parseDialogue(Paths.json(songName + '/dialogue')))" and it should load dialogue.json
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if(psychDialogue != null) return;

		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			precacheList.set('dialogue', 'sound');
			precacheList.set('dialogueClose', 'sound');
			psychDialogue = new DialogueBoxPsych(dialogueFile, song);
			psychDialogue.scrollFactor.set();
			if(endingSong) {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					endSong();
				}
			} else {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					startCountdown();
				}
			}
			psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.skipDialogueThing = skipDialogue;
			psychDialogue.cameras = [camHUD];
			add(psychDialogue);
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			startAndEnd();
		}
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;
	public static var startOnTime:Float = 0;

	function cacheCountdown()
	{
		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
		var introImagesArray:Array<String> = switch(stageUI) {
			case "pixel": ['${stageUI}UI/ready-pixel', '${stageUI}UI/set-pixel', '${stageUI}UI/date-pixel'];
			case "normal": ["ready", "set" ,"go"];
			case "old": ["ready-old", "set-old" ,"go-old"];
			default: ['${stageUI}UI/ready', '${stageUI}UI/set', '${stageUI}UI/go'];
		}
		introAssets.set(stageUI, introImagesArray);
		var introAlts:Array<String> = introAssets.get(stageUI);
		for (asset in introAlts) Paths.image(asset);
		
		Paths.sound('bash' + introSoundsSuffix);
		Paths.sound('rap' + introSoundsSuffix);
	}

	public function startCountdown()
	{
		if(startedCountdown) {
			callOnScripts('onStartCountdown');
			return false;
		}

		seenCutscene = true;
		inCutscene = false;
		var ret:Dynamic = callOnScripts('onStartCountdown', null, true);
		if(ret != FunkinLua.Function_Stop) {
			if (skipCountdown || startOnTime > 0) skipArrowStartTween = true;

			generateStaticArrows(0);
			generateStaticArrows(1);
			for (i in 0...playerStrums.length) {
				setOnScripts('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnScripts('defaultPlayerStrumY' + i, playerStrums.members[i].y);
			}
			for (i in 0...opponentStrums.length) {
				setOnScripts('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnScripts('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				//if(ClientPrefs.data.middleScroll) opponentStrums.members[i].visible = false;
			}

			startedCountdown = true;
			Conductor.songPosition = -Conductor.crochet * 5;
			setOnScripts('startedCountdown', true);
			callOnScripts('onCountdownStarted', null);

			var swagCounter:Int = 0;
			if (startOnTime > 0) {
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - 350);
				return true;
			}
			else if (skipCountdown)
			{
				setSongTime(0);
				return true;
			}
			moveCameraSection();

			startTimer = new FlxTimer().start(Conductor.crochet / 1000 / playbackRate, function(tmr:FlxTimer)
			{
				if (gf != null && tmr.loopsLeft % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
					gf.dance();
				if (tmr.loopsLeft % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
					boyfriend.dance();
				if (tmr.loopsLeft % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
					dad.dance();

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				var introImagesArray:Array<String> = switch(stageUI) {
					case "pixel": ['${stageUI}UI/ready-pixel', '${stageUI}UI/set-pixel', '${stageUI}UI/date-pixel'];
					case "normal": ["ready", "set" ,"go"];
					case "old": ["ready-old", "set-old" ,"go-old"];
					default: ['${stageUI}UI/ready', '${stageUI}UI/set', '${stageUI}UI/go'];
				}
				introAssets.set(stageUI, introImagesArray);

				var introAlts:Array<String> = introAssets.get(stageUI);
				var antialias:Bool = (ClientPrefs.data.antialiasing && !isPixelStage);
				var tick:Countdown = THREE;

				switch (swagCounter)
				{
					case 0:
						tick = THREE;
					case 1:
						if(curSong != 'Lore')
						{
							countdownReady = createCountdownSprite(introAlts[0], antialias);
							FlxG.sound.play(Paths.sound('bash' + introSoundsSuffix), 0.6);
						}
						tick = TWO;
					case 2:
						if(curSong != 'Lore')
						{
							countdownSet = createCountdownSprite(introAlts[1], antialias);
							FlxG.sound.play(Paths.sound('bash' + introSoundsSuffix), 0.6);
						}
						tick = ONE;
					case 3:
						if(curSong != 'Lore')
						{
							countdownGo = createCountdownSprite(introAlts[2], antialias);
							FlxG.sound.play(Paths.sound('rap' + introSoundsSuffix), 0.6);
						}
						tick = GO;
					case 4:
						tick = START;
				}

				notes.forEachAlive(function(note:Note) {
					if(ClientPrefs.data.opponentStrums || note.mustPress)
					{
						note.copyAlpha = false;
						note.alpha = note.multAlpha;
						if(ClientPrefs.data.middleScroll && !note.mustPress)
							note.alpha *= 0.35;
					}
				});

				stagesFunc(function(stage:BaseStage) stage.countdownTick(tick, swagCounter));
				callOnLuas('onCountdownTick', [swagCounter]);
				callOnHScript('onCountdownTick', [tick, swagCounter]);

				swagCounter += 1;
			}, 5);
		}
		return true;
	}

	inline private function createCountdownSprite(image:String, antialias:Bool):FlxSprite
	{
		var spr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(image));
		spr.cameras = [camHUD];
		spr.scrollFactor.set();
		spr.updateHitbox();

		if (PlayState.isPixelStage)
			spr.setGraphicSize(Std.int(spr.width * daPixelZoom));

		spr.screenCenter();
		spr.antialiasing = antialias;
		spr.scale.set(0.9, 0.9);
		insert(members.indexOf(notes), spr);

		if(curStage == 'roof-old')
		{
			if(image == 'set-old') spr.setGraphicSize(Std.int(spr.width / 2));

			FlxTween.tween(spr, {/*y: spr.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
				ease: FlxEase.cubeInOut,
				onComplete: function(twn:FlxTween)
				{
					remove(spr);
					spr.destroy();
				}
			});
			return spr;
		}
		else
		{
			if(image != 'go' && image != 'wave' && image != 'finalwave')
			{
				FlxTween.tween(spr.scale, {x: 1, y: 1}, Conductor.crochet / 1000, {
					ease: FlxEase.linear,
				});
			}
			
			if(image == 'wave')
			{
				spr.scale.set(1.6, 1.6);
				spr.alpha = 0;
				FlxTween.tween(spr, {alpha: 1}, 0.5, {
					ease: FlxEase.expoIn
				});
				FlxTween.tween(spr.scale, {x: 1, y: 1}, 0.5, {
					ease: FlxEase.expoIn,
					onComplete: function(twn:FlxTween)
					{
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							FlxTween.tween(spr, {alpha: 0}, 1, {
								onComplete: function(twn:FlxTween)
								{
									remove(spr);
									spr.destroy();
								}
							});
						});
					}
				});
			}

			if(image == 'finalwave')
			{
				spr.scale.set(1.6, 1.6);
				spr.alpha = 0;
				FlxTween.tween(spr, {alpha: 1}, 0.3, {
					ease: FlxEase.expoIn
				});
				FlxTween.tween(spr.scale, {x: 1, y: 1}, 0.3, {
					ease: FlxEase.expoIn,
					onComplete: function(twn:FlxTween)
					{
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							FlxTween.tween(spr, {alpha: 0}, 1, {
								onComplete: function(twn:FlxTween)
								{
									remove(spr);
									spr.destroy();
								}
							});
						});
					}
				});
			}

			if(image != 'wave' && image != 'finalwave')
			{
				new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
				{
					remove(spr);
					spr.destroy();
				});
			}

			return spr;
		}
	}

	public function addBehindGF(obj:FlxBasic)
	{
		insert(members.indexOf(gfGroup), obj);
	}
	public function addBehindBF(obj:FlxBasic)
	{
		insert(members.indexOf(boyfriendGroup), obj);
	}
	public function addBehindDad(obj:FlxBasic)
	{
		insert(members.indexOf(dadGroup), obj);
	}

	public function removeBehindGF(obj:FlxBasic)
	{
		remove(obj);
		obj.destroy();
	}
	public function removeBehindBF(obj:FlxBasic)
	{
		remove(obj);
		obj.destroy();
	}
	public function removeBehindDad(obj:FlxBasic)
	{
		remove(obj);
		obj.destroy();
	}

	public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = unspawnNotes[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0) {
			var daNote:Note = notes.members[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				invalidateNote(daNote);
			}
			--i;
		}
	}

	public function updateScore(miss:Bool = false)
	{
		var str:String = '?';
		if(totalPlayed != 0)
		{
			var percent:Float = CoolUtil.floorDecimal(ratingPercent * 100, 2);
			str = ' ($percent%) - $ratingFC';
		}

		var tempScore:String;
		if(curStage == 'roof-old')
		{
			tempScore = 'Score: ' + songScore
			+ ' | Misses: ' + songMisses
			+ ' | Rating: ' + str;
		}
		else
		{
			if(cpuControlled)
			{
				tempScore = 'Score: BOT
				\nAccuracy: BOT
				\nMisses: BOT';
			}
			else
			{
				tempScore = 'Score: ' + FlxStringUtil.formatMoney(songScore, false, true)
				+ '\nAccuracy: ' + str
				+ '\nMisses: ' + songMisses;
			}

			accuracyShit.text = 'Rating: ' + ratingName;
		}

		scoreTxt.text = tempScore;

		if(curStage == 'roof-old')
		{
			if(ClientPrefs.data.scoreZoom && !miss && !cpuControlled)
			{
				if(scoreTxtTween != null)scoreTxtTween.cancel();

				scoreTxt.scale.x = 1.075;
				scoreTxt.scale.y = 1.075;
		
				scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
					onComplete: function(twn:FlxTween) {
						scoreTxtTween = null;
					}
				});
			}
		}
		else
		{
			if(ClientPrefs.data.scoreZoom && !miss && !cpuControlled)
			{
				if(scoreTxtTween != null)scoreTxtTween.cancel();

				accuracyShit.scale.x = 1.075;
				accuracyShit.scale.y = 1.075;
		
				scoreTxtTween = FlxTween.tween(accuracyShit.scale, {x: 1, y: 1}, 0.2, {
					onComplete: function(twn:FlxTween) {
						scoreTxtTween = null;
					}
				});
			}
		}
		callOnScripts('onUpdateScore', [miss]);
	}

	public function setSongTime(time:Float)
	{
		if(time < 0) time = 0;

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.time = time;
		FlxG.sound.music.pitch = playbackRate;
		FlxG.sound.music.play();

		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = time;
			vocals.pitch = playbackRate;
		}
		vocals.play();
		Conductor.songPosition = time;
	}

	public function startNextDialogue() {
		dialogueCount++;
		callOnScripts('onNextDialogue', [dialogueCount]);
	}

	public function skipDialogue() {
		callOnScripts('onSkipDialogue', [dialogueCount]);
	}

	function startSong():Void
	{
		startingSong = false;

		@:privateAccess
		FlxG.sound.playMusic(inst._sound, 1, false);
		FlxG.sound.music.pitch = playbackRate;
		FlxG.sound.music.onComplete = finishSong.bind();
		vocals.play();
		vocals.onComplete = function()
		{
			vocalsFinished = true;
		}

		if(startOnTime > 0) setSongTime(startOnTime - 500);
		startOnTime = 0;

		if(paused) {
			//trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
		}

		if(!SONG.disableAtTheStartSong)
			if (task != null) task.start();

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		songLengthDiscord = FlxG.sound.music.length;
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLengthDiscord);
		#end
		setOnScripts('songLength', songLength);
		callOnScripts('onSongStart');
	}

	private var noteTypes:Array<String> = [];
	private var eventsPushed:Array<String> = [];
	private var totalColumns: Int = 4;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());
		songSpeed = PlayState.SONG.speed;
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype');
		switch(songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed');
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed');
		}

		var songData = SONG;
		Conductor.bpm = songData.bpm;

		curSong = songData.song;

		vocals = new FlxSound();
		if (songData.needsVoices) vocals.loadEmbedded(Paths.voices(songData.song));

		vocals.pitch = playbackRate;
		FlxG.sound.list.add(vocals);

		inst = new FlxSound().loadEmbedded(Paths.inst(songData.song));
		FlxG.sound.list.add(inst);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var file:String = Paths.json(songName + '/events');
		#if MODS_ALLOWED
		if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(file)) {
		#else
		if (OpenFlAssets.exists(file)) {
		#end
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData) //Event Notes
				for (i in 0...event[1].length)
					makeEvent(event, i);
		}

		var oldNote:Note = null;
		var sectionsData:Array<SwagSection> = PlayState.SONG.notes;
		var ghostNotesCaught: Int = 0;

		var badNote:Bool = false;
	
		for (section in sectionsData)
		{
			for (i in 0...section.sectionNotes.length)
			{
				final songNotes: Array<Dynamic> = section.sectionNotes[i];
				var spawnTime: Float = songNotes[0];
				var noteColumn: Int = Std.int(songNotes[1] % totalColumns);
				var holdLength: Float = songNotes[2];
				var noteType: String = songNotes[3];
				if (Math.isNaN(holdLength))
					holdLength = 0.0;

				var gottaHitNote:Bool = (songNotes[1] < totalColumns);

				if (i != 0) {
					// CLEAR ANY POSSIBLE GHOST NOTES
					for (evilNote in unspawnNotes) {
						var matches: Bool = noteColumn == evilNote.noteData && gottaHitNote == evilNote.mustPress;
						if (matches && Math.abs(spawnTime - evilNote.strumTime) == 0.0) {
							if (evilNote.tail.length > 0)
								for (tail in evilNote.tail)
								{
									tail.destroy();
									unspawnNotes.remove(tail);
								}

							if(evilNote.noteType == 'Hurt Note')
								badNote = true;
			
							if(evilNote.noteType == 'Jap Note')
								badNote = true;
			
							if(evilNote.noteType == 'Jalapeno Note NEW')
								badNote = true;

							if (evilNote.mustPress == true && badNote == false && evilNote.isSustainNote == false)
								totalNotes -= 1;

							evilNote.destroy();

							unspawnNotes.remove(evilNote);
							ghostNotesCaught++;
							//continue;
						}
					}
				}

				var swagNote:Note = new Note(spawnTime, noteColumn, oldNote, false, false, null, false);
				var isAlt: Bool = section.altAnim && !swagNote.mustPress && !section.gfSection;
				swagNote.gfNote = (section.gfSection && gottaHitNote);
				swagNote.animSuffix = isAlt ? "-alt" : "";
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = holdLength;
				swagNote.noteType = noteType;
	
				swagNote.scrollFactor.set();

				if(swagNote.noteType == 'Hurt Note')
					badNote = true;

				if(swagNote.noteType == 'Jap Note')
					badNote = true;

				if(swagNote.noteType == 'Jalapeno Note NEW')
					badNote = true;

				if (swagNote.mustPress == true && badNote == false && swagNote.isSustainNote == false)
					totalNotes++;

				unspawnNotes.push(swagNote);

				final roundSus:Int = Math.round(swagNote.sustainLength / Conductor.stepCrochet);
				if(roundSus > 0)
				{
					for (susNote in 0...roundSus + 1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(spawnTime + (Conductor.stepCrochet * susNote), noteColumn, oldNote, true, false, null, false);
						sustainNote.animSuffix = swagNote.animSuffix;
						sustainNote.mustPress = swagNote.mustPress;
						sustainNote.gfNote = swagNote.gfNote;
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						sustainNote.parent = swagNote;
						unspawnNotes.push(sustainNote);
						swagNote.tail.push(sustainNote);

						sustainNote.correctionOffset = swagNote.height / 2;
						if(!PlayState.isPixelStage)
						{
							if(oldNote.isSustainNote)
							{
								oldNote.scale.y *= Note.SUSTAIN_SIZE / oldNote.frameHeight;
								oldNote.scale.y /= playbackRate;
								oldNote.updateHitbox();
							}

							if(ClientPrefs.data.downScroll)
								sustainNote.correctionOffset = 0;
						}
						else if(oldNote.isSustainNote)
						{
							oldNote.scale.y /= playbackRate;
							oldNote.updateHitbox();
						}

						if (sustainNote.mustPress) sustainNote.x += FlxG.width / 2; // general offset
						else if(ClientPrefs.data.middleScroll)
						{
							sustainNote.x += 310;
							if(noteColumn > 1) //Up and Right
								sustainNote.x += FlxG.width / 2 + 25;
						}
					}
				}

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if(ClientPrefs.data.middleScroll)
				{
					swagNote.x += 310;
					if(noteColumn > 1) //Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}
				if(!noteTypes.contains(swagNote.noteType))
					noteTypes.push(swagNote.noteType);

				oldNote = swagNote;
			}
		}
		trace('["${SONG.song.toUpperCase()}" CHART INFO]: Ghost Notes Cleared: $ghostNotesCaught');
		for (event in songData.events) //Event Notes
			for (i in 0...event[1].length)
				makeEvent(event, i);

		unspawnNotes.sort(sortByTime);
		generatedMusic = true;
	}

	// called only once per different event (Used for precaching)
	function eventPushed(event:EventNote) {
		eventPushedUnique(event);
		if(eventsPushed.contains(event.event)) {
			return;
		}

		stagesFunc(function(stage:BaseStage) stage.eventPushed(event));
		eventsPushed.push(event.event);
	}

	// called by every event with the same name
	function eventPushedUnique(event:EventNote) {
		switch(event.event) {
			case "Change Character":
				var charType:Int = 0;
				switch(event.value1.toLowerCase()) {
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						var val1:Int = Std.parseInt(event.value1);
						if(Math.isNaN(val1)) val1 = 0;
						charType = val1;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);
			
			case 'Play Sound':
				precacheList.set(event.value1, 'sound');
				Paths.sound(event.value1);

			case 'Play Video':
				if(ClientPrefs.data.optimize) return;

				if (video1Cache) return;
				precacheList.set(event.value1, 'video');
				Paths.video(event.value1);
				video1Cache = true;

			case 'Play OVERFIRE':
				if(ClientPrefs.data.optimize) return;

				if (video2Cache) return;
				precacheList.set(event.value1, 'video');
				Paths.video(event.value1);
				video2Cache = true;
		}
		stagesFunc(function(stage:BaseStage) stage.eventPushedUnique(event));
	}

	function eventEarlyTrigger(event:EventNote):Float {
		var returnedValue:Null<Float> = callOnScripts('eventEarlyTrigger', [event.event, event.value1, event.value2, event.strumTime], true, [], [0]);
		if(returnedValue != null && returnedValue != 0 && returnedValue != FunkinLua.Function_Continue) {
			return returnedValue;
		}

		switch(event.event) {
			case 'Kill Henchmen': //Better timing so that the kill sound matches the beat intended
				return 280; //Plays 280ms before the actual position
		}
		return 0;
	}

	public static function sortByTime(Obj1:Dynamic, Obj2:Dynamic):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);

	function makeEvent(event:Array<Dynamic>, i:Int)
	{
		var subEvent:EventNote = {
			strumTime: event[0] + ClientPrefs.data.noteOffset,
			event: event[1][i][0],
			value1: event[1][i][1],
			value2: event[1][i][2]
		};
		eventNotes.push(subEvent);
		eventPushed(subEvent);
		callOnScripts('onEventPushed', [subEvent.event, subEvent.value1 != null ? subEvent.value1 : '', subEvent.value2 != null ? subEvent.value2 : '', subEvent.strumTime]);
	}

	public var skipArrowStartTween:Bool = false; //for lua
	private function generateStaticArrows(player:Int):Void
	{
		var strumLineX:Float = ClientPrefs.data.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X;
		var strumLineY:Float = ClientPrefs.data.downScroll ? (FlxG.height - 150) : 50;
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var targetAlpha:Float = 1;
			if (player < 1)
			{
				if(ClientPrefs.data.middleScroll) targetAlpha = 0;
			}

			var babyArrow:StrumNote = new StrumNote(strumLineX, strumLineY, i, player, false);
			babyArrow.downScroll = ClientPrefs.data.downScroll;
			if (!isStoryMode && !skipArrowStartTween)
			{
				//babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {/*y: babyArrow.y + 10,*/ alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			else
				babyArrow.alpha = targetAlpha;

			if (player == 1)
				playerStrums.add(babyArrow);
			else
			{
				if(ClientPrefs.data.middleScroll)
				{
					babyArrow.x += 310;
					if(i > 1) { //Up and Right
						babyArrow.x += FlxG.width / 2 + 25;
					}
				}
				opponentStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		stagesFunc(function(stage:BaseStage) stage.openSubState(SubState));
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if(videoCutscene != null)
				videoCutscene.videoSprite.pause();

			if (startTimer != null && !startTimer.finished) startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished) finishTimer.active = false;
			if (songSpeedTween != null) songSpeedTween.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad, rom];
			for (char in chars)
				if(char != null && char.colorTween != null)
					char.colorTween.active = false;

			#if LUA_ALLOWED
			for (tween in modchartTweens) tween.active = false;
			for (timer in modchartTimers) timer.active = false;
			#end
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		stagesFunc(function(stage:BaseStage) stage.closeSubState());
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if(videoCutscene != null)
				videoCutscene.videoSprite.resume();

			if (startTimer != null && !startTimer.finished) startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished) finishTimer.active = true;
			if (songSpeedTween != null) songSpeedTween.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad, rom];
			for (char in chars)
				if(char != null && char.colorTween != null)
					char.colorTween.active = true;

			#if LUA_ALLOWED
			for (tween in modchartTweens) tween.active = true;
			for (timer in modchartTimers) timer.active = true;
			#end

			paused = false;
			callOnScripts('onResume');
			resetRPC(startTimer != null && startTimer.finished);
		}

		super.closeSubState();
	}

        // аджика/нампавс анскилл

	override public function onFocus():Void
	{
		if (health > 0 && !paused) resetRPC(Conductor.songPosition > 0.0);
		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused) DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end

		super.onFocusLost();
	}

	// Updating Discord Rich Presence.
	function resetRPC(?cond:Bool = false)
	{
		#if desktop
		if (cond)
			DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLengthDiscord - Conductor.songPosition - ClientPrefs.data.noteOffset);
		else
			DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		vocals.pause();

		FlxG.sound.music.play();
		FlxG.sound.music.pitch = playbackRate;
		Conductor.songPosition = FlxG.sound.music.time;

		if (!vocalsFinished)
		{
			if (Conductor.songPosition <= vocals.length)
			{
				vocals.time = Conductor.songPosition;
				vocals.pitch = playbackRate;
			}
			vocals.play();
		}
		else
		{
			vocals.volume = 0;
		}
	}

	public var paused:Bool = false;
	public var canReset:Bool = true;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var freezeCamera:Bool = false;

	public static var rotCam = false;
	var rotCamSpd:Float = 1;
	var rotCamRange:Float = 10;
	var rotCamInd:Float = 0;

	override public function update(elapsed:Float)
	{
		/*if (FlxG.keys.justPressed.NINE)
		{
			iconP1.swapOldIcon();
		}*/
		callOnScripts('onUpdate', [elapsed]);

		if(curStage == 'roof-old' || curStage == 'night')
		{
			if (fireHalapeno.alpha >= 0)
				fireHalapeno.alpha -= 0.01 * (elapsed/(1/60));
		}

		if(curStage == 'night')
		{
			if (fireFlash.alpha >= 0)
				fireFlash.alpha -= 0.01 * (elapsed/(1/60));
		}

		if(!inCutscene && !paused && !cameraLocked) {
			FlxG.camera.followLerp = 0.04 * cameraSpeed * playbackRate;
			if(!startingSong && !endingSong && boyfriend.animation.curAnim != null && boyfriend.animation.curAnim.name.startsWith('idle')) {
				boyfriendIdleTime += elapsed;
				if(boyfriendIdleTime >= 0.15) { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			} else {
				boyfriendIdleTime = 0;
			}
		}
		else FlxG.camera.followLerp = 0;

		if(dropTime > 0)
		{
			dropTime -= elapsed;
			if(japHit <= 4)
			{
				if(health > 0.1) health -= healthDrop * (elapsed/(1/60));
			}
			else
			{
				health -= healthDrop * (elapsed/(1/60));
			}
			healthBar.setColors(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
			FlxColor.fromRGB(255, 138, 0));
			iconP1.offset.x = FlxG.random.float(-10, 10);
			iconP1.offset.y = FlxG.random.float(-10, 10);
		}

		if(dropTime<=0)
		{
			japHit = 0; //ох вау
			iconP1.changeIcon(boyfriend.healthIcon);
			healthDrop = 0;
			dropTime = -1;
			reloadHealthBarColors();
		}

		if (rotCam)
		{
			rotCamInd += 1 / (FlxG.updateFramerate / 60);
			camera.angle = Math.sin(rotCamInd / 100 * rotCamSpd) * rotCamRange * (FlxG.updateFramerate / 60);
		}
		else
		{
			if(rotCamInd != 0) //Memory leak removing :D
				rotCamInd = 0;
		}

		super.update(elapsed);

		setOnScripts('curDecStep', curDecStep);
		setOnScripts('curDecBeat', curDecBeat);

		var mult:Float = FlxMath.lerp(smoothHealth, health, 0.15 * playbackRate);
		smoothHealth = mult;

		if(botplayTxt != null && botplayTxt.visible) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		if (controls.PAUSE && startedCountdown && canPause)
		{
			var ret:Dynamic = callOnScripts('onPause', null, true);
			if(ret != FunkinLua.Function_Stop) {
				openPauseMenu();
			}
		}

		if (controls.justPressed('debug_1') && !endingSong && !inCutscene)
		{
			if(curSong == "Lore" || curSong == "T-SHORT")
			{
				#if ACHIEVEMENTS_ALLOWED
				Achievements.loadAchievements();
				var achieveID:Int = Achievements.getAchievementIndex(curSong);
				if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) {
					FlxG.sound.play(Paths.sound('confirmAch'), 0.7);
					Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
					var achievementObj:AchievementPopup = new AchievementPopup(curSong, camOther);
					achievementObj.onFinish = ebatLoh;
					//achievementObj.onFinish = openChartEditor;
					add(achievementObj);
					ClientPrefs.saveSettings();
				}
				else
				#end
				ebatLoh();
				//openChartEditor();
			} else {
				ebatLoh();
				//openChartEditor();
			}
		}

		if(dropTime <= 0)
		{
			var mult:Float = FlxMath.lerp(1, iconP1.scale.x, FlxMath.bound(1 - (elapsed * 9 * playbackRate), 0, 1));
			iconP1.scale.set(mult, mult);
			iconP1.updateHitbox();
		}

		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, FlxMath.bound(1 - (elapsed * 9 * playbackRate), 0, 1));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();

		if(curSong == 'Lore')
		{
			var mult:Float = FlxMath.lerp(1, iconROM.scale.x, FlxMath.bound(1 - (elapsed * 9 * playbackRate), 0, 1));
			iconROM.scale.set(mult, mult);
			iconROM.updateHitbox();
		}

		if(curSong == 'Lore')
		{
			var mult:Float = FlxMath.lerp(1, iconGF.scale.x, FlxMath.bound(1 - (elapsed * 9 * playbackRate), 0, 1));
			iconGF.scale.set(mult, mult);
			iconGF.updateHitbox();
		}

		var iconOffset:Int = 26;
		if (health > 2) health = 2;

		iconP1.x = healthBar.barCenter + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
		iconP2.x = healthBar.barCenter - (150 * iconP2.scale.x) / 2 - iconOffset * 2;
		if(curSong == 'Lore') iconROM.x = healthBar.barCenter - (150 * iconROM.scale.x + 150) / 2 - iconOffset * 2;
		if(curSong == 'Lore') iconGF.x = healthBar.barCenter + (150 * iconGF.scale.x + 0) / 2 - iconOffset;

		if (healthBar.percent < 20) 
		{
			iconP1.animation.curAnim.curFrame = 1;
			if(curSong == 'Lore') iconGF.animation.curAnim.curFrame = 1;
			iconP2.animation.curAnim.curFrame = iconP2.numFrames > 2 ? 2 : 0;
			if(curSong == 'Lore') iconROM.animation.curAnim.curFrame = iconP2.numFrames > 2 ? 2 : 0;
		}
		else if (healthBar.percent > 80)
		{
			iconP1.animation.curAnim.curFrame = iconP1.numFrames > 2 ? 2 : 0;
			if(curSong == 'Lore') iconGF.animation.curAnim.curFrame = iconP2.numFrames > 2 ? 2 : 0;
			iconP2.animation.curAnim.curFrame = 1;
			if(curSong == 'Lore') iconROM.animation.curAnim.curFrame = 1;
		}
		else 
		{
			iconP1.animation.curAnim.curFrame = 0;
			if(curSong == 'Lore') iconROM.animation.curAnim.curFrame = 0;
			iconP2.animation.curAnim.curFrame = 0;
			if(curSong == 'Lore') iconGF.animation.curAnim.curFrame = 0;
		}
		
		if (startedCountdown && !paused)
			Conductor.songPosition += FlxG.elapsed * 1000 * playbackRate;

		if (startingSong)
		{
			if (startedCountdown && Conductor.songPosition >= 0)
				startSong();
			else if(!startedCountdown)
				Conductor.songPosition = -Conductor.crochet * 5;
		}
		else if (!paused && updateTime)
		{
			var curTime:Float = Math.max(0, Conductor.songPosition - ClientPrefs.data.noteOffset);
			songPercent = (curTime / songLength);

			var songCalc:Float = (songLength - curTime);
			if(ClientPrefs.data.timeBarType == 'Time Elapsed') songCalc = curTime;

			var secondsTotal:Int = Math.floor(songCalc / 1000);
			if(secondsTotal < 0) secondsTotal = 0;

			if(ClientPrefs.data.timeBarType != 'Song Name')
				timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, FlxMath.bound(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, FlxMath.bound(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
		}

		FlxG.watch.addQuick("secShit", curSection);
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.data.noReset && controls.RESET && canReset && !inCutscene && startedCountdown && !endingSong)
		{
			health = 0;
			trace("RESET = True");
		}
		doDeathCheck();

		if (unspawnNotes[0] != null)
		{
			var time:Float = spawnTime * playbackRate;
			if(songSpeed < 1) time /= songSpeed;
			if(unspawnNotes[0].multSpeed < 1) time /= unspawnNotes[0].multSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);
				dunceNote.spawned = true;

				callOnLuas('onSpawnNote', [notes.members.indexOf(dunceNote), dunceNote.noteData, dunceNote.noteType, dunceNote.isSustainNote, dunceNote.strumTime]);
				callOnHScript('onSpawnNote', [dunceNote]);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			if(!inCutscene)
			{
				if(!cpuControlled) {
					keysCheck();
				} else if(boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
					boyfriend.dance();
					//boyfriend.animation.curAnim.finish();
				}

				if(notes.length > 0)
				{
					if(startedCountdown)
					{
						var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
						notes.forEachAlive(function(daNote:Note)
						{
							var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
							if(!daNote.mustPress) strumGroup = opponentStrums;

							var strum:StrumNote = strumGroup.members[daNote.noteData];
							daNote.followStrumNote(strum, fakeCrochet, songSpeed / playbackRate);

							if(daNote.mustPress)
							{
								if(cpuControlled && !daNote.blockHit && daNote.canBeHit && (daNote.isSustainNote || daNote.strumTime <= Conductor.songPosition))
									goodNoteHit(daNote);
							}
							else if (daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
								opponentNoteHit(daNote);

							if(daNote.isSustainNote && strum.sustainReduce) daNote.clipToStrumNote(strum);

							// Kill extremely late notes and cause misses
							if (Conductor.songPosition - daNote.strumTime > noteKillOffset)
							{
								if (daNote.mustPress && !cpuControlled && !daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit)) {
									var willMiss:Bool = true;
									if (willMiss) noteMiss(daNote);
								}

								daNote.active = daNote.visible = false;
								invalidateNote(daNote);
							}
						});
					}
					else
					{
						notes.forEachAlive(function(daNote:Note)
						{
							daNote.canBeHit = false;
							daNote.wasGoodHit = false;
						});
					}
				}
			}
			checkEventNote();
		}

		for (holdNote in notes.members)
		{
			if (holdNote == null || !holdNote.alive || !holdNote.mustPress) continue;

			if (holdNote.noteWasHit && !holdNote.missed && holdNote.isSustainNote)
			{
				health += 0.15 * elapsed;

				if(!cpuControlled)
				{
					songScore += Std.int(250 * elapsed);
					updateScore(false);
				}
				else
				{
					var tempScore:String;
					tempScore = 'Score: BOT'
					+ '\nAccuracy: BOT'
					+ '\nMisses: BOT';

					scoreTxt.text = tempScore;
				}
			}
		}
		
		setOnScripts('cameraX', camFollow.x);
		setOnScripts('cameraY', camFollow.y);
		setOnScripts('botPlay', cpuControlled);
		callOnScripts('onUpdatePost', [elapsed]);

		if(generatedMusic && !inCutscene && ClientPrefs.data.laneUnderlay != 0)
		{
			laneP0.x = playerStrums.members[0].x;
			laneP1.x = playerStrums.members[1].x;
			laneP2.x = playerStrums.members[2].x;
			laneP3.x = playerStrums.members[3].x;
	
			laneE0.x = opponentStrums.members[0].x;
			laneE1.x = opponentStrums.members[1].x;
			laneE2.x = opponentStrums.members[2].x;
			laneE3.x = opponentStrums.members[3].x;
	
			laneP0.alpha = (
				playerStrums.members[0].alpha == 0 ?
					FlxMath.lerp(laneP0.alpha, 0, FlxMath.bound(elapsed * 5, 0, 1))
					:
					FlxMath.lerp(laneP0.alpha, ClientPrefs.data.laneUnderlay, FlxMath.bound(elapsed * 5, 0, 1))
			);
			laneP1.alpha = (
				playerStrums.members[1].alpha == 0 ?
					FlxMath.lerp(laneP1.alpha, 0, FlxMath.bound(elapsed * 5, 0, 1))
					:
					FlxMath.lerp(laneP1.alpha, ClientPrefs.data.laneUnderlay, FlxMath.bound(elapsed * 5, 0, 1))
			);
			laneP2.alpha = (
				playerStrums.members[2].alpha == 0 ?
					FlxMath.lerp(laneP2.alpha, 0, FlxMath.bound(elapsed * 5, 0, 1))
					:
					FlxMath.lerp(laneP2.alpha, ClientPrefs.data.laneUnderlay, FlxMath.bound(elapsed * 5, 0, 1))
			);
			laneP3.alpha = (
				playerStrums.members[3].alpha == 0 ?
					FlxMath.lerp(laneP3.alpha, 0, FlxMath.bound(elapsed * 5, 0, 1))
					:
					FlxMath.lerp(laneP3.alpha, ClientPrefs.data.laneUnderlay, FlxMath.bound(elapsed * 5, 0, 1))
			);
	
			laneE0.alpha = (
				opponentStrums.members[0].alpha == 0 ?
					FlxMath.lerp(laneE0.alpha, 0, FlxMath.bound(elapsed * 5, 0, 1))
					:
					FlxMath.lerp(laneE0.alpha, ClientPrefs.data.laneUnderlay, FlxMath.bound(elapsed * 5, 0, 1))
			);
			laneE1.alpha = (
				opponentStrums.members[1].alpha == 0 ?
					FlxMath.lerp(laneE1.alpha, 0, FlxMath.bound(elapsed * 5, 0, 1))
					:
					FlxMath.lerp(laneE1.alpha, ClientPrefs.data.laneUnderlay, FlxMath.bound(elapsed * 5, 0, 1))
			);
			laneE2.alpha = (
				opponentStrums.members[2].alpha == 0 ?
					FlxMath.lerp(laneE2.alpha, 0, FlxMath.bound(elapsed * 5, 0, 1))
					:
					FlxMath.lerp(laneE2.alpha, ClientPrefs.data.laneUnderlay, FlxMath.bound(elapsed * 5, 0, 1))
			);
			laneE3.alpha = (
				opponentStrums.members[3].alpha == 0 ?
					FlxMath.lerp(laneE3.alpha, 0, FlxMath.bound(elapsed * 5, 0, 1))
					:
					FlxMath.lerp(laneE3.alpha, ClientPrefs.data.laneUnderlay, FlxMath.bound(elapsed * 5, 0, 1))
			);
		}
	}

	function openPauseMenu()
	{
		FlxG.camera.followLerp = 0;
		persistentUpdate = false;
		persistentDraw = true;

		paused = true;

		if(FlxG.sound.music != null) {
			FlxG.sound.music.pause();
			vocals.pause();
		}
		if(!cpuControlled)
		{
			for (note in playerStrums)
				if(note.animation.curAnim != null && note.animation.curAnim.name != 'static')
				{
					note.playAnim('static');
					note.resetAnim = 0;
				}
		}

		if(curStage == 'roof-old' || chartingMode)
			openSubState(new PauseSubStateold(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		else
			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

		#if desktop
		DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end
	}

	/*function openChartEditor()
	{
		FlxG.camera.followLerp = 0;
		persistentUpdate = false;
		paused = true;
		cancelMusicFadeTween();
		chartingMode = true;

		#if desktop
		DiscordClient.changePresence("Chart Editor", null, null, true);
		DiscordClient.resetClientID();
		#end
		
		MusicBeatState.switchState(new ChartingState());
	}*/

	function ohGodNo()
	{
		FlxG.camera.followLerp = 0;
		persistentUpdate = false;
		paused = true;
		FlxG.sound.music.volume = 0;
		cancelMusicFadeTween();
		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;

		#if desktop
		DiscordClient.changePresence("He cheated", null, null, true);
		DiscordClient.resetClientID();
		#end
		
		MusicBeatState.switchState(new CheatState());
	}

	function ebatLoh()
	{
		FlxG.camera.followLerp = 0;
		persistentUpdate = false;
		paused = true;
		cancelMusicFadeTween();

		LohState.videoShow = "brutal-pizdec"; //ЧТО

		if(curSong == "Lore" || curSong == "T-SHORT")
			LohState.videoShow = curSong;

		#if desktop
		DiscordClient.changePresence("DICK SUCKER", null, null, true);
		DiscordClient.resetClientID();
		#end

		MusicBeatState.switchState(new LohState());
	}

	public var isDead:Bool = false; //Don't mess with this on Lua!!!
	function doDeathCheck(?skipHealthCheck:Bool = false) {
		if (((skipHealthCheck && instakillOnMiss) || health <= 0) && !practiceMode && !isDead)
		{
			var ret:Dynamic = callOnScripts('onGameOver', null, true);
			if(ret != FunkinLua.Function_Stop) {
				boyfriend.stunned = true;
				deathCounter++;

				paused = true;

				persistentUpdate = false;
				persistentDraw = false;
				#if LUA_ALLOWED
				for (tween in modchartTweens) {
					tween.active = true;
				}
				for (timer in modchartTimers) {
					timer.active = true;
				}
				#end

				FlxG.camera.setFilters([]);

				vocals.stop();
				FlxG.sound.music.stop();
				if(curStage == 'void')
				{
					FlxTween.cancelTweensOf(dad);
					FlxTween.tween(dad, {alpha: 0}, 0.8);
					FlxTween.tween(camHUD, {alpha: 0}, 2, {onComplete:
						function (twn:FlxTween)
						{
							var achievementName:String = "fnaf";
							Achievements.loadAchievements();
							var achieveID:Int = Achievements.getAchievementIndex(achievementName);
							if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) {
								Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
								ClientPrefs.saveSettings();
								var achievementPop:AchievementPopup = new AchievementPopup(achievementName, camOther);
								FlxG.sound.play(Paths.sound('confirmAch'), 0.7);
								add(achievementPop);
								achievementPop.onFinish = function() {
									deathAch();
								};
							} else {
								deathAch();
							}
						}
					});
				}
				else
				{
					openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0], boyfriend.getScreenPosition().y - boyfriend.positionArray[1], camFollow.x, camFollow.y));
				}

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end
				isDead = true;
				return true;
			}
		}
		return false;
	}

	public function deathAch()
	{
		var achieveID:Int = Achievements.getAchievementIndex("skill");
		Achievements.loadAchievements();
		if(Achievements.getAchievementCurNum("skill") < 10)
			Achievements.setAchievementCurNum("skill", Achievements.getAchievementCurNum("skill") + 1);
		
		if (Achievements.getAchievementCurNum("skill") == Achievements.achievementsStuff[Achievements.getAchievementIndex("skill")][4]) {
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2]))
			{
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				ClientPrefs.saveSettings();
				var achievementPop:AchievementPopup = new AchievementPopup("skill", camOther);
				FlxG.sound.play(Paths.sound('confirmAch'));
				add(achievementPop);
				achievementPop.onFinish = function() {
					MusicBeatState.resetState();
				};
			}
		}
		else
		{
			MusicBeatState.resetState();
		}
	}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var leStrumTime:Float = eventNotes[0].strumTime;
			if(Conductor.songPosition < leStrumTime) {
				return;
			}

			var value1:String = '';
			if(eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if(eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEvent(eventNotes[0].event, value1, value2, leStrumTime);
			eventNotes.shift();
		}
	}

	public function triggerEvent(eventName:String, value1:String, value2:String, strumTime:Float) {
		var flValue1:Null<Float> = Std.parseFloat(value1);
		var flValue2:Null<Float> = Std.parseFloat(value2);
		if(Math.isNaN(flValue1)) flValue1 = null;
		if(Math.isNaN(flValue2)) flValue2 = null;

		switch(eventName) {
			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				if(flValue2 == null || flValue2 <= 0) flValue2 = 0.6;

				if(value != 0) {
					if(dad.curCharacter.startsWith('gf')) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = flValue2;
					} else if (gf != null) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = flValue2;
					}
				}
				if(value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = flValue2;
				}

			case 'CountDown':
				final introAlts:Array<String> = switch(stageUI)
				{
					case "pixel":  ['${stageUI}UI/ready-pixel', '${stageUI}UI/set-pixel', '${stageUI}UI/date-pixel'];
					case "normal": ["ready", "set" ,"go","wave","finalwave"];
					default:       ['${stageUI}UI/ready', '${stageUI}UI/set', '${stageUI}UI/go'];
				};
				final antialias:Bool = (ClientPrefs.data.antialiasing && !isPixelStage);
	
				switch(value1.toLowerCase().trim()) {
					case 'ready': 
						countdownReady = createCountdownSprite(introAlts[0], antialias); 
						if(value2 == 'true') FlxG.sound.play(Paths.sound('bash' + introSoundsSuffix), 0.6);
					case 'set':
						countdownSet = createCountdownSprite(introAlts[1], antialias);
						if(value2 == 'true') FlxG.sound.play(Paths.sound('bash' + introSoundsSuffix), 0.6);
					case 'go':
						countdownGo = createCountdownSprite(introAlts[2], antialias);
						if(value2 == 'true') FlxG.sound.play(Paths.sound('rap' + introSoundsSuffix), 0.6);
					case 'wave':
						countdownGo = createCountdownSprite(introAlts[3], antialias);
					case 'finalwave':
						countdownGo = createCountdownSprite(introAlts[4], antialias);
				}

			case 'Set GF Speed':
				if(flValue1 == null || flValue1 < 1) flValue1 = 1;
				gfSpeed = Math.round(flValue1);

			case 'Set DAD Speed':
				if(flValue1 == null || flValue1 < 1) flValue1 = 1;
				dad.danceEveryNumBeats = Math.round(flValue1);

			case 'Set BF Speed':
				if(flValue1 == null || flValue1 < 1) flValue1 = 1;
				boyfriend.danceEveryNumBeats = Math.round(flValue1);

			case 'Add Camera Zoom':
				if(ClientPrefs.data.camZooms && FlxG.camera.zoom < 1.6) {
					if(flValue1 == null) flValue1 = 0.015;
					if(flValue2 == null) flValue2 = 0.03;

					FlxG.camera.zoom += flValue1;
					camHUD.zoom += flValue2;
				}

			case 'Play Animation':
				//trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						if(flValue2 == null) flValue2 = 0;
						switch(Math.round(flValue2)) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Camera Follow Pos':
				if(camFollow != null)
				{
					isCameraOnForcedPos = false;
					if(flValue1 != null || flValue2 != null)
					{
						isCameraOnForcedPos = true;
						if(flValue1 == null) flValue1 = 0;
						if(flValue2 == null) flValue2 = 0;
						camFollow.x = flValue1;
						camFollow.y = flValue2;
					}
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.idleSuffix = value2;
					char.recalculateDanceIdle();
				}

			case 'Screen Shake':
				if (ClientPrefs.data.screenShake) {
					var valuesArray:Array<String> = [value1, value2];
					var targetsArray:Array<FlxCamera> = [camGame, camHUD];
					for (i in 0...targetsArray.length) {
						var split:Array<String> = valuesArray[i].split(',');
						var duration:Float = 0;
						var intensity:Float = 0;
						if(split[0] != null) duration = Std.parseFloat(split[0].trim());
						if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
						if(Math.isNaN(duration)) duration = 0;
						if(Math.isNaN(intensity)) intensity = 0;

						if(duration > 0 && intensity != 0) {
							targetsArray[i].shake(intensity, duration);
						}
					}
				}


			case 'Change Character':
				var charType:Int = 0;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				switch(charType) {
					case 0:
						if(boyfriend.curCharacter != value2) {
							if(!boyfriendMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							iconP1.changeIcon(boyfriend.healthIcon);
						}
						setOnScripts('boyfriendName', boyfriend.curCharacter);

					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf-') || dad.curCharacter == 'gf';
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							if(!dad.curCharacter.startsWith('gf-') && dad.curCharacter != 'gf') {
								if(wasGf && gf != null) {
									gf.visible = true;
								}
							} else if(gf != null) {
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							iconP2.changeIcon(dad.healthIcon);
						}
						setOnScripts('dadName', dad.curCharacter);

					case 2:
						if(gf != null)
						{
							if(gf.curCharacter != value2)
							{
								if(!gfMap.exists(value2)) {
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
							}
							setOnScripts('gfName', gf.curCharacter);
						}
				}
				reloadHealthBarColors();

			case 'Change Scroll Speed':
				if (songSpeedType != "constant")
				{
					if(flValue1 == null) flValue1 = 1;
					if(flValue2 == null) flValue2 = 0;

					var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed') * flValue1;
					if(flValue2 <= 0)
						songSpeed = newValue;
					else
						songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, flValue2 / playbackRate, {ease: FlxEase.linear, onComplete:
							function (twn:FlxTween)
							{
								songSpeedTween = null;
							}
						});
				}

			case 'Set Property':
				try
				{
					var split:Array<String> = value1.split('.');
					if(split.length > 1) {
						LuaUtils.setVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1], value2);
					} else {
						LuaUtils.setVarInArray(this, value1, value2);
					}
				}
				catch(e:Dynamic)
				{
					addTextToDebug('ERROR ("Set Property" Event) - ' + e.message.substr(0, e.message.indexOf('\n')), FlxColor.RED);
				}
			
			case 'Play Sound':
				if(flValue2 == null) flValue2 = 1;
				FlxG.sound.play(Paths.sound(value1), flValue2);

			case 'go back health':
				FlxTween.tween(this, {health: 1}, 1, {ease: FlxEase.elasticInOut});

			case 'Show Song':
				if (task != null) task.start(); //если хочешь то вот

			case 'Toogle CamZooming':
				camZooming = !camZooming;

			case 'Flash Camera':
				if (!ClientPrefs.data.flashing) return;

				var duration:Float = Std.parseFloat(value1);
				var color:String = value2;
				if (color.length > 1)
				{
					if (!color.startsWith('0x'))
						color = '0xFF$color';
				}
				else
				{
					color = "0xFFFFFFFF";
				}
				camFlash.flash(Std.parseInt(color), Math.isNaN(duration) || value1.length <= 0 ? 1 : duration, null, true);
	
			case 'Camera Fade':
				var args:Array<String> = value2.split(",");

				var color:FlxColor = 0xFFFFFFFF;
	
				if (flValue1 == null) flValue1 = 1;
		
				if (args[0] == null || args[0] == '')
					color = 0xFFFFFFFF;
	
				color = Std.parseInt(args[0]);
	
				var camera:String = args[1];

				switch(camera.toLowerCase().trim()) {
					case 'camhud' | 'HUD' | 'hud':
						camHUD.fade(color, flValue1, direction, null, true);
						direction = !direction;
					default:
						camFlash.fade(color, flValue1, direction, null, true);
						direction = !direction;
				}

			case 'Set Cam Zoom':
				if(flValue1 == null) flValue1 = 1;
				if(flValue2 == null) flValue2 = 1;

				if(sexcameratween != null)
					sexcameratween.cancel();

				sexcameratween = FlxTween.tween(this, {defaultCamZoom: flValue1}, flValue2, {ease: FlxEase.quadInOut,
					onComplete: function(twn:FlxTween)
						{
							sexcameratween = null;
						}});

			case 'Set Cam Zoom Alt': //нужна если camZooming == false
				if(flValue1 == null) flValue1 = 1;
				if(flValue2 == null) flValue2 = 1;

				if(sexcameratween != null)
					sexcameratween.cancel();

				sexcameratween = FlxTween.tween(FlxG.camera, {zoom: flValue1}, flValue2, {ease: FlxEase.quadInOut,
					onComplete: function(twn:FlxTween)
						{
							sexcameratween = null;
						}});

			case 'Camera Follow Pos Tween':
				if(camFollow != null)
				{
					if(followTween != null)
						followTween.cancel();

					var split:Array<String> = value1.split(',');
					var xMove:Float = 0;
					var yMove:Float = 0;
					var time:Float = 0;

					var ease = LuaUtils.getTweenEaseByString(value2);

					isCameraOnForcedPos = false;
					if(split != null || flValue2 != null)
					{
						isCameraOnForcedPos = true;
						if(split[0] != null) xMove = Std.parseInt(split[0].trim());
						if(split[1] != null) yMove = Std.parseInt(split[1].trim());
						if(split[2] != null) time = Std.parseFloat(split[2].trim());

						followTween = FlxTween.tween(camFollow, {x: xMove, y: yMove}, time, {ease: ease,
							onComplete: function(twn:FlxTween)
								{
									followTween = null;
								}});
					}
				}

			case 'Character Color':
				var char:Character = boyfriend;
				var split:Array<String> = value2.split(',');
				var color:Int = 0;
				var time:Float = 0;

				if(split[0] != null) color = Std.parseInt(split[0].trim());
				if(split[1] != null) time = Std.parseFloat(split[1].trim());

				switch (value1.toLowerCase().trim())
				{
					case 'gf' | 'girlfriend':
						char = gf;
					case 'dad':
						char = dad;
					case 'rom':
						char = rom;
					default:
						char = boyfriend;
				}
				trace('dee');
				FlxTween.color(char, time, char.color, color);

			case 'Character Color Transform':
				var char:Character = boyfriend;

				var split:Array<String> = value1.split(',');
				var redOff:Int = 0;
				var greenOff:Int = 0;
				var blueOff:Int = 0;
				var redMult:Int = 0;
				var greenMult:Int = 0;
				var blueMult:Int = 0;
				if(split[0] != null) redOff = Std.parseInt(split[0].trim());
				if(split[1] != null) greenOff = Std.parseInt(split[1].trim());
				if(split[2] != null) blueOff = Std.parseInt(split[2].trim());
				if(split[3] != null) redMult = Std.parseInt(split[3].trim());
				if(split[4] != null) greenMult = Std.parseInt(split[4].trim());
				if(split[5] != null) blueMult = Std.parseInt(split[5].trim());

				var splitSec:Array<String> = value2.split(',');
				var chara:String = '';
				var time:Float = 0;

				if(splitSec[0] != null) chara = splitSec[0].trim();
				if(splitSec[1] != null) time = Std.parseFloat(splitSec[1].trim());

				switch (chara.toLowerCase().trim())
				{
					case 'gf' | 'girlfriend':
						char = gf;
					case 'dad':
						char = dad;
					case 'rom':
						char = rom;
					default:
						char = boyfriend;
				}

				FlxTween.tween(char.colorTransform, {redOffset: redOff, greenOffset: greenOff, blueOffset: blueOff, redMultiplier: redMult, greenMultiplier: greenMult, blueMultiplier: blueMult}, time, {ease: FlxEase.linear});

			case 'Add trail':
				if(ClientPrefs.data.lowQuality) return;

				var split:Array<String> = value1.split(',');
				var length:Int = 0;
				var delay:Int = 0;
				var alpha:Float = 0;
				var diff:Float = 0;

				var splitSec:Array<String> = value2.split(',');
				var chara:String = '';
				var color:Int = 0;
				var blend:Int = 0;
				var yes:String = '';

				if(split[0] != null) length = Std.parseInt(split[0].trim());
				if(split[1] != null) delay = Std.parseInt(split[1].trim());
				if(split[2] != null) alpha = Std.parseFloat(split[2].trim());
				if(split[3] != null) diff = Std.parseFloat(split[3].trim());
				if(Math.isNaN(length)) length = 4;
				if(Math.isNaN(delay)) delay = 24;
				if(Math.isNaN(alpha)) alpha = 0.3;
				if(Math.isNaN(diff)) diff = 0.069;

				if(splitSec[0] != null) chara = splitSec[0].trim();
				if(splitSec[1] != null) blend = Std.parseInt(splitSec[1].trim());
				if(splitSec[2] != null) color = Std.parseInt(splitSec[2].trim());
				if(splitSec[3] != null) yes = splitSec[3].trim();
				if(Math.isNaN(blend)) blend = 0;

				var char:Character = switch (chara.toLowerCase().trim()) {
					case 'gf' | 'girlfriend': gf;
					case 'dad' | 'opponent': dad;

					default: boyfriend;
				};

				trail = new FlxTrail(char, null, length, delay, alpha, diff);

				switch(blend) 
				{
					case 1:
						trail.blend = HARDLIGHT;
					case 2:
						trail.blend = ADD;
					case 3:
						trail.blend = MULTIPLY;
				}

				if(yes == 'yes')
				{
					if(color == 0)
					{
						switch(chara.toLowerCase().trim()) {
							case 'gf' | 'girlfriend':
								var gfcol = gf.healthColorArray;
								trail.color = FlxColor.fromRGB(gfcol[0], gfcol[1], gfcol[2]);
							case 'dad' | 'opponent':
								var dadCol = dad.healthColorArray;
								trail.color = FlxColor.fromRGB(dadCol[0], dadCol[1], dadCol[2]);
							default:
								var bfCol = boyfriend.healthColorArray;
								trail.color = FlxColor.fromRGB(bfCol[0], bfCol[1], bfCol[2]);
						}
					}
					else
						trail.color = color;
				}

				switch(chara.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						addBehindGF(trail);
					case 'dad' | 'opponent':
						addBehindDad(trail);
					default:
						addBehindBF(trail);
				}

			case 'Remove trail':
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						removeBehindGF(trail);
					case 'dad' | 'opponent':
						removeBehindDad(trail);
					default:
						removeBehindBF(trail);
				}

			case 'Camera rotate on': //VS SHAGGY ТОП
				rotCam = true;
				rotCamSpd = flValue1;
				rotCamRange = flValue2;
			case 'Camera rotate off':
				rotCam = false;
				camera.angle = 0;

			case 'Cam lock':
				var split:Array<String> = value1.split(',');
				var xMove:Float = 0;
				var yMove:Float = 0;

				isCameraOnForcedPos = false;
				if(split[0] != null) xMove = Std.parseInt(split[0].trim());
				if(split[1] != null) yMove = Std.parseInt(split[1].trim());

				cameraLocked = true;
				camFollow.setPosition(xMove, yMove);
				FlxG.camera.focusOn(camFollow.getPosition());

				if(flValue2 != null)
				{
					defaultCamZoom = flValue2;
					FlxG.camera.zoom = flValue2;
				}

			case 'cam unlock':
				isCameraOnForcedPos = false;
				cameraLocked = false;

			case 'Play Video':
				if(ClientPrefs.data.optimize) return;

				startVideo(value1, true, false);				

			case 'Play OVERFIRE':
				if(ClientPrefs.data.lowQuality) return;
				startVideo(value1, true, false, true, true, true);

			case 'Stop OVERFIRE':
				if(ClientPrefs.data.lowQuality) return;
				if(videoCutscene != null) videoCutscene.destroy();
		}
		
		stagesFunc(function(stage:BaseStage) stage.eventCalled(eventName, value1, value2, flValue1, flValue2, strumTime));
		callOnScripts('onEvent', [eventName, value1, value2, strumTime]);
	}

	function moveCameraSection(?sec:Null<Int>):Void {
		if(sec == null) sec = curSection;
		if(sec < 0) sec = 0;

		if(SONG.notes[sec] == null) return;

		if (gf != null && SONG.notes[sec].gfSection)
		{
			camFollow.setPosition(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
			camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
			callOnScripts('onMoveCamera', ['gf']);
			return;
		}

		var isDad:Bool = (SONG.notes[sec].mustHitSection != true);
		moveCamera(isDad);
		callOnScripts('onMoveCamera', [isDad ? 'dad' : 'boyfriend']);
	}

	var cameraTwn:FlxTween;
	public function moveCamera(isDad:Bool)
	{
		if(isDad)
		{
			camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
			camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];
		}
		else
		{
			camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
			camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
			camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];
		}
	}

	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();

		if (!FlxG.save.data.playedSongs.contains(CoolUtil.spaceToDash(SONG.song.toLowerCase())))
			FlxG.save.data.playedSongs.push(CoolUtil.spaceToDash(SONG.song.toLowerCase()));

		if(songMisses == 0 && deathCounter == 0 && !cpuControlled)
		{
			if (!FlxG.save.data.playedSongsFC.contains(CoolUtil.spaceToDash(SONG.song.toLowerCase())))
				FlxG.save.data.playedSongsFC.push(CoolUtil.spaceToDash(SONG.song.toLowerCase()));
		}

		if(ClientPrefs.data.noteOffset <= 0 || ignoreNoteOffset) {
			endCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.data.noteOffset / 1000, function(tmr:FlxTimer) {
				endCallback();
			});
		}
	}


	public var transitioning = false;
	public function endSong()
	{
		//Should kill you if you tried to cheat
		if(!startingSong) {
			notes.forEach(function(daNote:Note) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			});
			for (daNote in unspawnNotes) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			}

			if(doDeathCheck()) {
				return false;
			}
		}

		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;
		seenCutscene = false;

		#if ACHIEVEMENTS_ALLOWED
		if(achievementObj != null)
			return false;
		else
		{
			if (isStoryMode)
			{
				var noMissWeek:String = WeekData.getWeekFileName() + '_nomiss';
				var noMissDeathsWeek:String = WeekData.getWeekFileName() + '_nomiss_nodeaths';
				var achieve:String = checkForAchievement([WeekData.getWeekFileName(), noMissWeek, noMissDeathsWeek, 'cum']);
				trace(WeekData.getWeekFileName());
				if(achieve != null) {
					trace(achieve);
					startAchievement(achieve);
					return false;
				}
			} else {
				var noMissSong:String = songName.toLowerCase() + "_freeplay_nomiss";
				var achieve:String = checkForAchievement([noMissSong, 'cum', 'oldweek0', 'allweeks', 'allweeks1']);
				if(achieve != null) {
					trace(achieve);
					startAchievement(achieve);
					return false;
				}
			}
		}
		#end

		deathCounter = 0;

		var ret:Dynamic = callOnScripts('onEndSong', null, true);
		if(ret != FunkinLua.Function_Stop && !transitioning)
		{
			#if !switch
			var percent:Float = ratingPercent;
			if(Math.isNaN(percent)) percent = 0;
			Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
			Highscore.saveMedal(SONG.song, medalStatus, storyDifficulty);
			#end
			playbackRate = 1;

			if (chartingMode)
			{
				//openChartEditor();
				return false;
			}

			if (isStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					#if desktop DiscordClient.resetClientID(); #end

					cancelMusicFadeTween();
					if(FlxTransitionableState.skipNextTransIn) {
						CustomFadeTransition.nextCamera = null;
					}

					if(!ClientPrefs.getGameplaySetting('practice') && !ClientPrefs.getGameplaySetting('botplay')) {
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);
						Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);

						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
						FlxG.save.flush();
					}
					changedDifficulty = false;
					video1Cache = false;
					video2Cache = false;

					if(ClientPrefs.data.ends[0] == 0)
					{
						MusicBeatState.switchState(new EndState());
						EndState.end = 0;
						EndState.gift = true;
					}
					else
					{
						FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);
						MusicBeatState.switchState(new StoryMenuState());
					}
				}
				else
				{
					var difficulty:String = Difficulty.getFilePath();

					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					prevCamFollow = camFollow;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					cancelMusicFadeTween();
					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');
//				Mods.loadTopMod();
				#if desktop DiscordClient.resetClientID(); #end

				cancelMusicFadeTween();
				if(FlxTransitionableState.skipNextTransIn) {
					CustomFadeTransition.nextCamera = null;
				}

				if(ClientPrefs.data.ends[1] == 0 && (curSong == 'Klork' || curSong == 'Anekdot' || curSong == 'T-SHORT' || curSong == 'Monochrome' || curSong == 'Lore'))
				{
					if(FlxG.save.data.playedSongs.contains('klork') && FlxG.save.data.playedSongs.contains('anekdot') && FlxG.save.data.playedSongs.contains('t-short')
						&& FlxG.save.data.playedSongs.contains('monochrome') && FlxG.save.data.playedSongs.contains('lore'))
					{
						EndState.end = 1;
						EndState.gift = false;
						MusicBeatState.switchState(new EndState());
					}
					else
					{
						MusicBeatState.switchState(new FreeplayState());
						FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);	
					}
				}
				else if(ClientPrefs.data.ends[2] == 0 && (curSong == 'S6X BOOM' || curSong == 'Lamar Tut Voobshe Ne Nujen'))
				{
					if(FlxG.save.data.playedSongs.contains('s6x-boom') && FlxG.save.data.playedSongs.contains('lamar-tut-voobshe-ne-nujen'))
					{
						EndState.end = 2;
						EndState.gift = false;
						MusicBeatState.switchState(new EndState());
					}
					else
					{
						MusicBeatState.switchState(new FreeplayState());
						FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);	
					}
				}
				else if(ClientPrefs.data.ends[3] == 0 && (curSong == 'With Cone ORIGINAL' || curSong == 'Klork OLD' || curSong == 'T-SHORT ORIGINAL'))
				{
					if(FlxG.save.data.playedSongs.contains('with-cone-original') && FlxG.save.data.playedSongs.contains('klork-old') && FlxG.save.data.playedSongs.contains('t-short-original'))
					{
						EndState.end = 3;
						EndState.gift = false;
						MusicBeatState.switchState(new EndState());
					}
					else
					{
						MusicBeatState.switchState(new FreeplayState());
						FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);	
					}
				}
				else if(ClientPrefs.data.ends[4] == 0 || ClientPrefs.data.ends[5] == 0)
				{
					if((FlxG.save.data.playedSongsFC.contains('with-cone') && FlxG.save.data.playedSongsFC.contains('boom') && FlxG.save.data.playedSongsFC.contains('overfire') 
						&& FlxG.save.data.playedSongsFC.contains('klork') && FlxG.save.data.playedSongsFC.contains('anekdot') && FlxG.save.data.playedSongsFC.contains('t-short')
						&& FlxG.save.data.playedSongsFC.contains('monochrome') && FlxG.save.data.playedSongsFC.contains('lore')
						&& FlxG.save.data.playedSongsFC.contains('s6x-boom') && FlxG.save.data.playedSongsFC.contains('lamar-tut-voobshe-ne-nujen')
						&&FlxG.save.data.playedSongsFC.contains('with-cone-original') && FlxG.save.data.playedSongsFC.contains('klork-old') && FlxG.save.data.playedSongsFC.contains('t-short-original')))
					{
						EndState.end = 5;
						EndState.gift = true;
						MusicBeatState.switchState(new EndState());
					}
					else if(FlxG.save.data.playedSongs.contains('with-cone') && FlxG.save.data.playedSongs.contains('boom') && FlxG.save.data.playedSongs.contains('overfire') 
						&& FlxG.save.data.playedSongs.contains('klork') && FlxG.save.data.playedSongs.contains('anekdot') && FlxG.save.data.playedSongs.contains('t-short')
						&& FlxG.save.data.playedSongs.contains('monochrome') && FlxG.save.data.playedSongs.contains('lore')
						&& FlxG.save.data.playedSongs.contains('s6x-boom') && FlxG.save.data.playedSongs.contains('lamar-tut-voobshe-ne-nujen')
						&&FlxG.save.data.playedSongs.contains('with-cone-original') && FlxG.save.data.playedSongs.contains('boom-old')
						&& FlxG.save.data.playedSongs.contains('overfire-old') && FlxG.save.data.playedSongs.contains('klork-old') && FlxG.save.data.playedSongs.contains('t-short-original'))
					{
						EndState.end = 4;
						EndState.gift = false;
						MusicBeatState.switchState(new EndState());
					}
					else
					{
						MusicBeatState.switchState(new FreeplayState());
						FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);	
					}
				}
				else
				{
					MusicBeatState.switchState(new FreeplayState());
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);	
				}

				changedDifficulty = false;
				video1Cache = false;
				video2Cache = false;
			}
			transitioning = true;
		}
		return true;
	}

	#if ACHIEVEMENTS_ALLOWED
	var achievementObj:AchievementPopup = null;
	function startAchievement(achieve:String) {
		achievementObj = new AchievementPopup(achieve, camOther);
		achievementObj.onFinish = achievementEnd;
		add(achievementObj);
		trace('Giving achievement ' + achieve);
	}
	function achievementEnd():Void
	{
		achievementObj = null;
		if(endingSong && !inCutscene) {
			endSong();
		}
	}
	#end

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			invalidateNote(daNote);
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;
	public var totalNotes:Int = 0;

	public var showCombo:Bool = false;
	public var showComboNum:Bool = true;
	public var showRating:Bool = true;

	// stores the last judgement object
	var lastRating:FlxSprite;
	// stores the last combo sprite object
	var lastCombo:FlxSprite;
	// stores the last combo score objects in an array
	var lastScore:Array<FlxSprite> = [];

	private function cachePopUpScore()
	{
		for (rating in ratingsData)
			Paths.image(rating.image);
		for (i in 0...10)
			Paths.image('num' + i);
	}

	private function cacheMedals()
	{
		for (i in 1...6)
			Paths.image('medals/medal_' + i);
	}

	function doGhostAnim(char:String, animToPlay:String, mode:String, ?noteNum:Int)
	{
		if(ClientPrefs.data.lowQuality) return;
		
		var ghost:FlxSprite = new FlxSprite();
		var player:Character = dad;
	
		switch(char.toLowerCase().trim())
		{
			case 'bf' | 'boyfriend':
				player = boyfriend;
			case 'dad':
				player = dad;
			case 'gf':
				player = gf;
		}
	
		if (player.animation != null)
		{
			ghost.frames = player.frames;
	
			// Check for null before copying from player.animation
			if (player.animation != null)
				ghost.animation.copyFrom(player.animation);
	
			ghost.x = player.x;
			ghost.y = player.y;
			ghost.animation.play(animToPlay, true, false);
			
			ghost.scale.copyFrom(player.scale);
			ghost.updateHitbox();
	
			// Check for null before accessing animOffsets
			if (player.animOffsets != null && player.animOffsets.exists(animToPlay))
				ghost.offset.set(player.animOffsets.get(animToPlay)[0], player.animOffsets.get(animToPlay)[1]);
	
			ghost.flipX = player.flipX;
			ghost.flipY = player.flipY;

			if(player.blend == '')
				ghost.blend = HARDLIGHT;
			else
				ghost.blend = player.blend;

			ghost.scrollFactor.set(player.scrollFactor.x, player.scrollFactor.y);

			ghost.alpha = player.alpha - 0.3;
			ghost.shader = player.shader;
			ghost.angle = player.angle;
			ghost.antialiasing = ClientPrefs.data.antialiasing ? !player.noAntialiasing : false;
			ghost.visible = true;

			if(curSong == 'Overfire' && mode == 'Note Trail Ascend Mode Anim')
				ghost.color = 0xFFff8c05;
			else
				ghost.color = FlxColor.fromRGB(player.healthColorArray[0] + 50, player.healthColorArray[1] + 50, player.healthColorArray[2] + 50);

			ghost.velocity.x = 0;
			ghost.velocity.y = 0;

			switch (mode)
			{
				case 'Note Trail Arrow Mode' | 'Note Trail Arrow Mode Anim':
					switch(noteNum)
					{
						case 0:
							ghost.velocity.x = -140;
						case 1:
							ghost.velocity.y = 140;
						case 2:
							ghost.velocity.y = -140;
						case 3:
							ghost.velocity.x = 140;
					}
				case 'Note Trail Ascend Mode' | 'Note Trail Ascend Mode Anim':
					ghost.velocity.y = FlxG.random.int(-240, -275);
					ghost.velocity.x = FlxG.random.int(-100, 100);
			}

			switch(char.toLowerCase().trim())
			{
				case 'bf' | 'boyfriend':
					insert(members.indexOf(boyfriendGroup), ghost);
				case 'dad':
					insert(members.indexOf(dadGroup), ghost);
				case 'gf':
					insert(members.indexOf(gfGroup), ghost);
			}
	
			FlxTween.tween(ghost, {alpha: 0}, Conductor.crochet * 0.002, {
				ease: FlxEase.linear,
					onComplete: function(twn:FlxTween)
					{
						ghost.destroy();
					}
			});
		}
	}

	var c_PBOT1_MISS = 160;
	var c_PBOT1_PERFECT = 5;
	var c_PBOT1_SCORING_OFFSET = 54.99;
	var c_PBOT1_SCORING_SLOPE = .08;
	var c_PBOT1_MAX_SCORE = 500;
	var c_PBOT1_MIN_SCORE = 5;
	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.data.ratingOffset);
		vocals.volume = 1;

		var score:Int = 350;

		if(curStage != 'roof-old')
			score = c_PBOT1_MIN_SCORE;

		//tryna do MS based judgment due to popular demand
		var daRating:Rating = Conductor.judgeNote(ratingsData, noteDiff / playbackRate);

		totalNotesHit += daRating.ratingMod;
		note.ratingMod = daRating.ratingMod;
		if(!note.ratingDisabled) daRating.hits++;
		note.rating = daRating.name;
		note.hitHealth = daRating.bonusHealth;
		score = daRating.score;

		if(curStage != 'roof-old')
		{
			if (noteDiff < c_PBOT1_PERFECT) score = c_PBOT1_MAX_SCORE;
			else if (noteDiff < c_PBOT1_MISS) {
				var factor:Float = 1.0 - (1.0 / (1.0 + Math.exp(-c_PBOT1_SCORING_SLOPE * (noteDiff - c_PBOT1_SCORING_OFFSET))));
				score = Std.int(c_PBOT1_MAX_SCORE * factor + c_PBOT1_MIN_SCORE);
			}
		}

		if(daRating.noteSplash && !note.noteSplashData.disabled)
			spawnNoteSplashOnNote(note);

		if(daRating.grayNote)
		{
			combo = 0;
			if(curStage != 'roof-old') grayNoteEarly(note);
		}

		if(!practiceMode && !cpuControlled) {
			songScore += score;
			if(!note.ratingDisabled)
			{
				songHits++;
				totalPlayed++;
				RecalculateRating(false);
			}
		}

		if(curStage == 'roof-old')
		{
			var placement:Float =  FlxG.width * 0.35;
			var rating:FlxSprite = new FlxSprite();
	
			rating.loadGraphic(Paths.image(daRating.image));
			rating.cameras = [camGame];
			rating.screenCenter();
			rating.x = placement - 40;
			rating.y -= 60;
			rating.acceleration.y = 550 * playbackRate * playbackRate;
			rating.velocity.y -= FlxG.random.int(140, 175) * playbackRate;
			rating.velocity.x -= FlxG.random.int(0, 10) * playbackRate;
			rating.visible = (!ClientPrefs.data.hideHud && showRating);
			rating.x += ClientPrefs.data.comboOffset[0];
			rating.y -= ClientPrefs.data.comboOffset[1];
	
			var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('combo'));
			comboSpr.cameras = [camGame];
			comboSpr.screenCenter();
			comboSpr.x = placement;
			comboSpr.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
			comboSpr.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
			comboSpr.visible = (!ClientPrefs.data.hideHud && showCombo);
			comboSpr.x += ClientPrefs.data.comboOffset[0];
			comboSpr.y -= ClientPrefs.data.comboOffset[1];
			comboSpr.y += 60;
			comboSpr.velocity.x += FlxG.random.int(1, 10) * playbackRate;
	
			insert(members.indexOf(strumLineNotes), rating);
			
			if (!ClientPrefs.data.comboStacking)
			{
				if (lastRating != null) lastRating.kill();
				lastRating = rating;
			}
	
			if (!PlayState.isPixelStage)
			{
				rating.setGraphicSize(Std.int(rating.width * 0.7));
				comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			}
			else
			{
				rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.85));
				comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.85));
			}
	
			comboSpr.updateHitbox();
			rating.updateHitbox();
	
			var seperatedScore:Array<Int> = [];
	
			if(combo >= 1000) {
				seperatedScore.push(Math.floor(combo / 1000) % 10);
			}
			seperatedScore.push(Math.floor(combo / 100) % 10);
			seperatedScore.push(Math.floor(combo / 10) % 10);
			seperatedScore.push(combo % 10);
	
			var daLoop:Int = 0;
			var xThing:Float = 0;
			if (showCombo)
			{
				insert(members.indexOf(strumLineNotes), comboSpr);
			}
			if (!ClientPrefs.data.comboStacking)
			{
				if (lastCombo != null) lastCombo.kill();
				lastCombo = comboSpr;
			}
			if (lastScore != null)
			{
				while (lastScore.length > 0)
				{
					lastScore[0].kill();
					lastScore.remove(lastScore[0]);
				}
			}
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('num' + Std.int(i)));
				numScore.cameras = [camGame];
				numScore.screenCenter();
				numScore.x = placement + (43 * daLoop) - 90 + ClientPrefs.data.comboOffset[2];
				numScore.y += 80 - ClientPrefs.data.comboOffset[3];
				
				if (!ClientPrefs.data.comboStacking)
					lastScore.push(numScore);
	
				if (!PlayState.isPixelStage) numScore.setGraphicSize(Std.int(numScore.width * 0.5));
				else numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
				numScore.updateHitbox();
	
				numScore.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
				numScore.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
				numScore.velocity.x = FlxG.random.float(-5, 5) * playbackRate;
				numScore.visible = !ClientPrefs.data.hideHud;
	
				//if (combo >= 10 || combo == 0)
				if(showComboNum)
					insert(members.indexOf(strumLineNotes), numScore);
	
				FlxTween.tween(numScore, {alpha: 0}, 0.2 / playbackRate, {
					onComplete: function(tween:FlxTween)
					{
						numScore.destroy();
					},
					startDelay: Conductor.crochet * 0.002 / playbackRate
				});
	
				daLoop++;
				if(numScore.x > xThing) xThing = numScore.x;
			}
			comboSpr.x = xThing + 50;
			FlxTween.tween(rating, {alpha: 0}, 0.2 / playbackRate, {
				startDelay: Conductor.crochet * 0.001 / playbackRate
			});
	
			FlxTween.tween(comboSpr, {alpha: 0}, 0.2 / playbackRate, {
				onComplete: function(tween:FlxTween)
				{
					comboSpr.destroy();
					rating.destroy();
				},
				startDelay: Conductor.crochet * 0.002 / playbackRate
			});
		}
		else
		{
			FlxTween.cancelTweensOf(ratingTxt);
			FlxTween.cancelTweensOf(ratingTxt.alpha);
			ratingTxt.alpha = 1;
			ratingTxt.text = daRating.image.toUpperCase() + ' x' + combo;
			ratingTxt.y = healthBar.y - 100;
			FlxTween.tween(ratingTxt, {y: healthBar.y - 125}, Conductor.crochet * 0.002, {ease: FlxEase.quadOut});
			FlxTween.tween(ratingTxt, {alpha: 0}, 0.2 / playbackRate, {startDelay: Conductor.crochet * 0.001 / playbackRate});
		}
	}

	public var strumsBlocked:Array<Bool> = [];
	private function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(keysArray, eventKey);
		if (!controls.controllerMode && FlxG.keys.checkStatus(eventKey, JUST_PRESSED)) keyPressed(key);
	}

	private function keyPressed(key:Int)
	{
		if(cpuControlled || paused || key < 0) return;
		if(!generatedMusic || endingSong || boyfriend.stunned) return;

		// had to name it like this else it'd break older scripts lol
		var ret:Dynamic = callOnScripts('preKeyPress', [key], true);
		if(ret == FunkinLua.Function_Stop) return;

		// more accurate hit time for the ratings?
		var lastTime:Float = Conductor.songPosition;
		if(Conductor.songPosition >= 0) Conductor.songPosition = FlxG.sound.music.time;

		// obtain notes that the player can hit
		var plrInputNotes:Array<Note> = notes.members.filter(function(n:Note):Bool {
			var canHit:Bool = !strumsBlocked[n.noteData] && n.canBeHit && n.mustPress && !n.tooLate && !n.wasGoodHit && !n.blockHit;
			return n != null && canHit && !n.isSustainNote && n.noteData == key;
		});
		plrInputNotes.sort(sortHitNotes);

		var shouldMiss:Bool = !ClientPrefs.data.ghostTapping;

		if (plrInputNotes.length != 0) { // slightly faster than doing `> 0` lol
			var funnyNote:Note = plrInputNotes[0]; // front note
			// trace('✡⚐🕆☼ 💣⚐💣');

			if (plrInputNotes.length > 1) {
				var doubleNote:Note = plrInputNotes[1];

				if (doubleNote.noteData == funnyNote.noteData) {
					// if the note has a 0ms distance (is on top of the current note), kill it
					if (Math.abs(doubleNote.strumTime - funnyNote.strumTime) < 1.0)
						invalidateNote(doubleNote);
					else if (doubleNote.strumTime < funnyNote.strumTime)
					{
						// replace the note if its ahead of time (or at least ensure "doubleNote" is ahead)
						funnyNote = doubleNote;
					}
				}
			}

			goodNoteHit(funnyNote);
		}
		else {
			if (shouldMiss && !boyfriend.stunned) {
				callOnScripts('onGhostTap', [key]);
				noteMissPress(key);
			}
		}

		// Needed for the  "Just the Two of Us" achievement.
		//									- Shadow Mario
		if(!keysPressed.contains(key)) keysPressed.push(key);

		//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
		Conductor.songPosition = lastTime;

		var spr:StrumNote = playerStrums.members[key];
		if(strumsBlocked[key] != true && spr != null && spr.animation.curAnim.name != 'confirm')
		{
			var arr:Array<FlxColor> = ClientPrefs.data.arrowRGB[key];
			if(PlayState.isPixelStage) arr = ClientPrefs.data.arrowRGBPixel[key];

			spr.playAnim('pressed', false, arr);
			spr.resetAnim = 0;
		}
		callOnScripts('onKeyPress', [key]);
	}

	public static function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(keysArray, eventKey);

		if(!controls.controllerMode && key > -1) keyReleased(key);
	}

	private function keyReleased(key:Int)
	{
		if(!cpuControlled && startedCountdown && !paused)
		{
			var spr:StrumNote = playerStrums.members[key];
			if(spr != null)
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
			callOnScripts('onKeyRelease', [key]);
		}
	}

	public static function getKeyFromEvent(arr:Array<String>, key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...arr.length)
			{
				var note:Array<FlxKey> = Controls.instance.keyboardBinds[arr[i]];
				for (noteKey in note)
					if(key == noteKey)
						return i;
			}
		}
		return -1;
	}

	// Hold notes
	private function keysCheck():Void
	{
		// HOLDING
		var holdArray:Array<Bool> = [];
		var pressArray:Array<Bool> = [];
		var releaseArray:Array<Bool> = [];
		for (key in keysArray)
		{
			holdArray.push(controls.pressed(key));
			pressArray.push(controls.justPressed(key));
			releaseArray.push(controls.justReleased(key));
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(controls.controllerMode && pressArray.contains(true))
			for (i in 0...pressArray.length)
				if(pressArray[i] && strumsBlocked[i] != true)
					keyPressed(i);

		if (startedCountdown && !boyfriend.stunned && generatedMusic)
		{
			if (notes.length > 0) {
				for (n in notes) { // I can't do a filter here, that's kinda awesome
					var canHit:Bool = (n != null && !strumsBlocked[n.noteData] && n.canBeHit
						&& n.mustPress && !n.tooLate && !n.wasGoodHit && !n.blockHit);

					canHit = canHit && n.parent != null && n.parent.wasGoodHit;

					if (canHit && n.isSustainNote) {
						var released:Bool = !holdArray[n.noteData];

						if (!released)
							goodNoteHit(n);
					}
				}
			}

			if(holdArray.contains(true) && !endingSong)
			{
				//персанаж больше не задерживается когда хажимаешь кнопку, хз как норм починить так что лолол я еблан
			}
			else if (boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.dance();
				//boyfriend.animation.curAnim.finish();
			}
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if((controls.controllerMode || strumsBlocked.contains(true)) && releaseArray.contains(true))
			for (i in 0...releaseArray.length)
				if(releaseArray[i] || strumsBlocked[i] == true)
					keyReleased(i);
	}

	function cameraFromString(cam:String):FlxCamera {
		switch(cam.toLowerCase()) {
			case 'camVideo' | 'video': return camVideo;
			case 'camhud' | 'hud': return camHUD;
			case 'camother' | 'other': return camOther;
		}
		return camGame;
	}

	function createLanes()
	{
		if(ClientPrefs.data.laneUnderlay == 0) return;

		laneE0 = new FlxSprite(0,0).makeGraphic(Std.int(Note.swagWidth) - 5, FlxG.height * 2, FlxColor.BLACK);
		laneE0.alpha = 0;
		laneE1 = new FlxSprite(0,0).makeGraphic(Std.int(Note.swagWidth) - 5, FlxG.height * 2, FlxColor.BLACK);
		laneE1.alpha = 0;
		laneE2 = new FlxSprite(0,0).makeGraphic(Std.int(Note.swagWidth) - 5, FlxG.height * 2, FlxColor.BLACK);
		laneE2.alpha = 0;
		laneE3 = new FlxSprite(0,0).makeGraphic(Std.int(Note.swagWidth) - 5, FlxG.height * 2, FlxColor.BLACK);
		laneE3.alpha = 0;

		laneP0 = new FlxSprite(0,0).makeGraphic(Std.int(Note.swagWidth) - 5, FlxG.height * 2, FlxColor.BLACK);
		laneP0.alpha = 0;
		laneP1 = new FlxSprite(0,0).makeGraphic(Std.int(Note.swagWidth) - 5, FlxG.height * 2, FlxColor.BLACK);
		laneP1.alpha = 0;
		laneP2 = new FlxSprite(0,0).makeGraphic(Std.int(Note.swagWidth) - 5, FlxG.height * 2, FlxColor.BLACK);
		laneP2.alpha = 0;
		laneP3 = new FlxSprite(0,0).makeGraphic(Std.int(Note.swagWidth) - 5, FlxG.height * 2, FlxColor.BLACK);
		laneP3.alpha = 0;

		add(laneE0);
		add(laneE1);
		add(laneE2);
		add(laneE3);

		add(laneP0);
		add(laneP1);
		add(laneP2);
		add(laneP3);

		laneE0.cameras = [camHUD];
		laneE1.cameras = [camHUD];
		laneE2.cameras = [camHUD];
		laneE3.cameras = [camHUD];
		
		laneP0.cameras = [camHUD];
		laneP1.cameras = [camHUD];
		laneP2.cameras = [camHUD];
		laneP3.cameras = [camHUD];
	}

	function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1)
				invalidateNote(note);
		});

		final end:Note = daNote.isSustainNote ? daNote.parent.tail[daNote.parent.tail.length - 1] : daNote.tail[daNote.tail.length - 1];
		if (end != null && end.extraData['holdSplash'] != null) {
			end.extraData['holdSplash'].visible = false;
		}
		
		noteMissCommon(daNote.noteData, daNote);
		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
		var result:Dynamic = callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
		if(result != FunkinLua.Function_Stop && result != FunkinLua.Function_StopHScript && result != FunkinLua.Function_StopAll) callOnHScript('noteMiss', [daNote]);
	}

	function noteMissPress(direction:Int = 1):Void //You pressed a key when there was no notes to press for this key
	{
		if(ClientPrefs.data.ghostTapping) return; //fuck it

		noteMissCommon(direction, null, true);
		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
		callOnScripts('noteMissPress', [direction]);
	}

	function noteMissCommon(direction:Int, note:Note = null, ?ghost:Bool = false)
	{
		// score and data
		var subtract:Float = 0.05;
		if(note != null) subtract = note.missHealth;

		// GUITAR HERO SUSTAIN CHECK LOL!!!!
		if (note != null && note.parent == null) {
			if(note.tail.length != 0) {
				note.alpha = 0.3;
				note.multAlpha = 0.3;
				for(childNote in note.tail) {
					childNote.alpha = 0.3;
					childNote.multAlpha = 0.3;
					childNote.missed = true;
					childNote.canBeHit = false;
					childNote.ignoreNote = true;
					childNote.tooLate = true;
				}
				note.missed = true;
				note.canBeHit = false;

				//subtract += 0.385; // you take more damage if playing with this gameplay changer enabled.
				// i mean its fair :p -Crow
				subtract *= note.tail.length + 1;
				// i think it would be fair if damage multiplied based on how long the sustain is -Tahir
			}

			if (note.missed)
				return;
		}
		if (note != null && note.parent != null && note.isSustainNote) {
			if (note.missed)
				return;

			var parentNote:Note = note.parent;
			if (parentNote.wasGoodHit && parentNote.tail.length != 0) {
				for (child in parentNote.tail) if (child != note) {
					child.missed = true;
					child.canBeHit = false;
					child.ignoreNote = true;
					child.tooLate = true;
				}
			}
		}

		if(instakillOnMiss && !ghost)
		{
			vocals.volume = 0;
			doDeathCheck(true);
		}
		var lastCombo:Int = combo;

		if(!ghost)
		{
			combo = 0;
			if(!endingSong) songMisses++;
			totalPlayed++;
			RecalculateRating(true);
		}

		health -= subtract;
		songScore -= 10;

		// play character anims
		var char:Character = boyfriend;
		if((note != null && note.gfNote) || (SONG.notes[curSection] != null && SONG.notes[curSection].gfSection)) char = gf;
		
		if(char != null && char.hasMissAnimations)
		{
			var suffix:String = '';
			if(note != null) suffix = note.animSuffix;

			var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, direction)))] + 'miss' + suffix;
			char.playAnim(animToPlay, true);
			
			if(char != gf && combo > 5 && gf != null && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
				gf.specialAnim = true;
			}
		}
		vocals.volume = 0;
	}

	function opponentNoteHit(note:Note):Void
	{
		if (Paths.formatToSongPath(SONG.song) != 'tutorial')
			camZooming = true;

		if(curStage != 'roof-old' && note.noteType != 'Mania Note') spawnHoldSplashOnNote(note);

		if(note.noteType == 'Hey!' && dad.animOffsets.exists('hey')) {
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		} else if(!note.noAnimation) {
			var altAnim:String = note.animSuffix;

			if (SONG.notes[curSection] != null)
			{
				if (SONG.notes[curSection].altAnim && !SONG.notes[curSection].gfSection) {
					altAnim = '-alt';
				}
			}

			if(note.noteType == 'Jap Note'){
				FlxG.sound.play(Paths.sound('boom'), 0.4);
				if (health >= 0.4) health -= 0.1;
				fireHalapeno.alpha = 0.5;
				fireHalapeno.animation.play('idle');
			}

			var char:Character = dad;
			var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, note.noteData)))] + altAnim;
			if(note.gfNote) {
				char = gf;
			}
			else if(note.romNote){
				char = rom;
			}

			if(char != null)
			{
				if(curSong == 'Anekdot')
				{
					if(!note.isSustainNote) anekdotHit(note);
				}
				else
				{
					if(!note.ghostNote) 
					{
						char.playAnim(animToPlay, true);
						char.holdTimer = 0;
					}
					if((note.ghostNote || note.ghostAnimNote) && !note.isSustainNote) doGhostAnim('dad', animToPlay, note.noteType, note.noteData);
				}
			}
		}

		if(note.noteType == 'Jap Note no anim') {
			if (health >= 0.4) health -=  0.06;
			fireHalapeno.alpha = 0.8;
			fireHalapeno.animation.play('idle');
		}

		if(note.noteType == 'Jalapeno Note BOOM SOUND') {
			if (health >= 1) health -=  0.1;
			fireHalapeno.alpha = 0.5;
			fireHalapeno.animation.play('idle');
			
			if (ClientPrefs.data.flashing)
				fireFlash.alpha = 0.4;

			if(ClientPrefs.data.camZooms)
			{
				FlxG.camera.zoom += 0.02;
				camHUD.zoom += 0.02;
			}
		}

		if (SONG.needsVoices)
			vocals.volume = 1;

		strumPlayAnim(true, Std.int(Math.abs(note.noteData)), Conductor.stepCrochet * 1.25 / 1000 / playbackRate, note);
		note.hitByOpponent = true;

		stagesFunc(function(stage:BaseStage) stage.opponentNoteHit(note));
		var result:Dynamic = callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);
		if(result != FunkinLua.Function_Stop && result != FunkinLua.Function_StopHScript && result != FunkinLua.Function_StopAll) callOnHScript('opponentNoteHit', [note]);

		if (!note.isSustainNote)
			invalidateNote(note);
	}

	function uniqueMedalChange(medalInt:Int) //почему не LERP? потому что Ease
	{
		FlxTween.cancelTweensOf(medal);
		switch(medalInt)
		{
			case 6:
				//вообще нихуя сосите
				//дебил?
			case 5:
				FlxTween.tween(medal.scale, {x: 0.4, y: 0.4}, Conductor.crochet * 0.002, {ease: FlxEase.quadOut, type: BACKWARD});
			case 4:
				FlxTween.tween(medal.scale, {x: 0.5, y: 0.5}, Conductor.crochet * 0.002, {ease: FlxEase.backOut, type: BACKWARD});
			case 3:
				FlxTween.tween(medal.scale, {x: 0.5, y: 0.5}, Conductor.crochet * 0.002, {ease: FlxEase.bounceOut, type: BACKWARD});
				FlxTween.tween(medal, {angle: 7}, Conductor.crochet * 0.002, {ease: FlxEase.backOut, type: BACKWARD});
			case 2:
				medal.color = 0xff7400ff;
				FlxTween.tween(medal.scale, {x: 0.6, y: 0.6}, Conductor.crochet * 0.002, {ease: FlxEase.expoOut, type: BACKWARD});
				FlxTween.tween(medal, {angle: 12}, Conductor.crochet * 0.002, {ease: FlxEase.bounceOut, type: BACKWARD});
				FlxTween.color(medal, Conductor.crochet * 0.002, medal.color, 0xffFFFFFF);
			case 1:
				medal.colorTransform.redOffset = 134;
				medal.colorTransform.greenOffset = 248;
				medal.colorTransform.blueOffset = 255;

				medal.colorTransform.redMultiplier = 0;
				medal.colorTransform.greenMultiplier = 0;
				medal.colorTransform.blueMultiplier = 0;

				FlxTween.tween(medal.scale, {x: 0.7, y: 0.7}, Conductor.crochet * 0.002, {ease: FlxEase.elasticOut, type: BACKWARD});
				FlxTween.tween(medal, {angle: 23}, Conductor.crochet * 0.002, {ease: FlxEase.expoOut, type: BACKWARD});
				FlxTween.tween(medal.colorTransform, {redOffset: 0, greenOffset: 0, blueOffset: 0, redMultiplier: 1, greenMultiplier: 1, blueMultiplier: 1}, Conductor.crochet * 0.002);

				medal.x -= 50; //ТЫ ЧЕ ОХУЕЛ
		}
	}

	public function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if(cpuControlled && (note.ignoreNote || note.hitCausesMiss)) return;

			note.wasGoodHit = true;
			note.noteWasHit = true; //пиздец что эту переменную не использовали
			if (ClientPrefs.data.hitsoundVolume > 0 && !note.hitsoundDisabled)
				FlxG.sound.play(Paths.sound(note.hitsound), ClientPrefs.data.hitsoundVolume);

			if(note.hitCausesMiss) {
				noteMiss(note);
				if(!note.noteSplashData.disabled && !note.isSustainNote)
					spawnNoteSplashOnNote(note);

				if(!note.noMissAnimation)
				{
					switch(note.noteType) {
						case 'Hurt Note': //Hurt note
							if(boyfriend.animation.getByName('hurt') != null) {
								boyfriend.playAnim('hurt', true);
								boyfriend.specialAnim = true;
							}
							//УДАЛИТЕ УДАЛИТЕ УДАЛИТЕ
						case 'Jap Note': //Hurt note
							FlxG.sound.play(Paths.sound('boom'), 0.6);
							fireHalapeno.alpha = 0.5;

						case 'Jalapeno Note NEW':
							FlxG.sound.play(Paths.sound('boom'), 0.6);

							if(japHit <= 4)
							{
								if(health > 0.1) health -=  0.06;
							}
							else
								health -=  0.06;

							fireHalapeno.alpha = 0.8;
							dropTime = 10;
							healthDrop += 0.00050;
							iconP1.scale.set(1, 1);
							iconP1.changeIcon('hwaw-fire');
							japHit++;

							if (ClientPrefs.data.flashing)
								fireFlash.alpha = 0.6;

							if(ClientPrefs.data.camZooms)
							{
								FlxG.camera.zoom += 0.06;
								camHUD.zoom += 0.06;
							}

							// checking achievement
							Achievements.loadAchievements();
							var kaboom:Int = Achievements.getAchievementCurNum("kaboom");	
							var kaboomMax:Int = Achievements.achievementsStuff[Achievements.getAchievementIndex("kaboom")][4];
							if(kaboom < 10)
								Achievements.setAchievementCurNum("kaboom", kaboom+1);						
							if (kaboom == Achievements.achievementsStuff[Achievements.getAchievementIndex("kaboom")][4]) {
								#if ACHIEVEMENTS_ALLOWED
								var achieveID:Int = Achievements.getAchievementIndex('kaboom');
								if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) {
									Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
									startAchievement('kaboom');
									Achievements.setAchievementCurNum("kaboom", kaboomMax);
									ClientPrefs.saveSettings();
								}
							}
							#end
					}
				}

				if(!note.isSustainNote) invalidateNote(note);
				return;
			}

			if(curStage != 'roof-old') spawnHoldSplashOnNote(note);

			if (!note.isSustainNote)
			{
				combo++;
				if(combo > 9999) combo = 9999;
				popUpScore(note);
			}

			if(!note.isSustainNote) health += note.hitHealth;

			if(!note.noAnimation) {
				var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, note.noteData)))];

				var char:Character = boyfriend;
				var animCheck:String = 'hey';
				if(note.gfNote)
				{
					char = gf;
					animCheck = 'cheer';
				}
				
				if(char != null)
				{
					if(!note.ghostNote)
					{
						char.playAnim(animToPlay + note.animSuffix, true);
						char.holdTimer = 0;	
					}
					
					if(note.noteType == 'Hey!') {
						if(char.animOffsets.exists(animCheck)) {
							char.playAnim(animCheck, true);
							char.specialAnim = true;
							char.heyTimer = 0.6;
						}
					}
				}

				if((note.ghostNote || note.ghostAnimNote) && !note.isSustainNote)
				{
					if(char == gf)
						doGhostAnim('gf', animToPlay + note.animSuffix, note.noteType, note.noteData);
					else
						doGhostAnim('bf', animToPlay + note.animSuffix, note.noteType, note.noteData);
				}
			}

			if(!cpuControlled)
			{
				var spr = playerStrums.members[note.noteData];
				if(spr != null) spr.playAnim('confirm', true, [note.rgbShader.r, note.rgbShader.g, note.rgbShader.b]);
			}
			else strumPlayAnim(false, Std.int(Math.abs(note.noteData)), Conductor.stepCrochet * 1.25 / 1000 / playbackRate, note);
			vocals.volume = 1;

			var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;
			
			var result:Dynamic = callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);
			if(result != FunkinLua.Function_Stop && result != FunkinLua.Function_StopHScript && result != FunkinLua.Function_StopAll) callOnHScript('goodNoteHit', [note]);

			if(!note.isSustainNote && !note.badassed) invalidateNote(note);
		}
	}

	public function invalidateNote(note:Note):Void {
		note.kill();
		notes.remove(note, true);
		note.destroy();
	}

	public function grayNoteEarly(note:Note):Void {
		note.rgbShader.r = 0xFFFFFFFF;
		note.rgbShader.g = 0xFFFFFFFF;
		note.rgbShader.b = 0xFF454545;

		note.alpha = 0.5;
		note.multAlpha = 0.5;
		note.ignoreNote = true;
		note.blockHit = true;
		note.badassed = true;
		note.active = false;
	}

	public function spawnHoldSplashOnNote(note:Note) {
		if (!note.isSustainNote && note.tail.length != 0 && note.tail[note.tail.length - 1].extraData['holdSplash'] == null) {
			spawnHoldSplash(note);
		} else if (note.isSustainNote) {
			final end:Note = StringTools.endsWith(note.animation.curAnim.name, 'end') ? note : note.parent.tail[note.parent.tail.length - 1];
			if (end != null) {
				var leSplash:SustainSplash = end.extraData['holdSplash'];
				if (leSplash == null && !end.parent.wasGoodHit) {
					spawnHoldSplash(end);
				} else if (leSplash != null) {
					leSplash.visible = true;
				}
			}
		}
	}

	public function spawnHoldSplash(note:Note) {
		var end:Note = note.isSustainNote ? note.parent.tail[note.parent.tail.length - 1] : note.tail[note.tail.length - 1];
		var splash:SustainSplash = grpHoldSplashes.recycle(SustainSplash);
		splash.setupSusSplash(strumLineNotes.members[note.noteData + (note.mustPress ? 4 : 0)], note, playbackRate);
		grpHoldSplashes.add(end.extraData['holdSplash'] = splash);
	}

	function anekdotHit(note:Note)
	{
		var player:Character = dad;
		var boxNote:AnekdotNote = new AnekdotNote(player, note.noteData);
		
		boxNote.x = player.x + 250;
		boxNote.y = player.y - 100;
		boxNote.scale.set(0.6, 0.6);
		boxNote.updateHitbox();

		boxNote.blend = ADD;

		boxNote.acceleration.y = -550;
		boxNote.velocity.y = FlxG.random.int(-100, -150);
		boxNote.velocity.x = FlxG.random.int(140, 175);

		add(boxNote);

		FlxTween.tween(boxNote, {alpha: 0}, Conductor.crochet * 0.004, {
			ease: FlxEase.linear,
			onComplete: function(twn:FlxTween)
			{
				boxNote.destroy();
			}
		});
	}

	public function spawnNoteSplashOnNote(note:Note) {
		if(note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if(strum != null)
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, note);
		grpNoteSplashes.add(splash);
	}

	override function destroy() {
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			var lua:FunkinLua = luaArray[0];
			lua.call('onDestroy', []);
			lua.stop();
		}
		luaArray = [];
		FunkinLua.customFunctions.clear();
		#end

		if(videoCutscene != null) videoCutscene.destroy();

		#if HSCRIPT_ALLOWED
		for (script in hscriptArray)
			if(script != null)
			{
				script.call('onDestroy');
				script.destroy();
			}

		while (hscriptArray.length > 0)
			hscriptArray.pop();
		#end

		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		
		FlxG.camera.setFilters([]);

		FlxAnimationController.globalSpeed = 1;
		FlxG.sound.music.pitch = 1;
		Note.globalRgbShaders = [];
		backend.NoteTypesConfig.clearNoteTypesData();
		instance = null;
		super.destroy();
	}

	public static function cancelMusicFadeTween() {
		if(FlxG.sound.music.fadeTween != null) {
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	var lastStepHit:Int = -1;
	override function stepHit()
	{
		if(FlxG.sound.music.time >= -ClientPrefs.data.noteOffset)
		{
			if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate)
				|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate)))
			{
				resyncVocals();
			}
		}

		super.stepHit();

		if(curStep == lastStepHit) {
			return;
		}

		lastStepHit = curStep;
		setOnScripts('curStep', curStep);
		callOnScripts('onStepHit');
	}

	var lastBeatHit:Int = -1;

	override function beatHit()
	{
		if(lastBeatHit >= curBeat) {
			//trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (generatedMusic)
			notes.sort(FlxSort.byY, ClientPrefs.data.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);

		if(curBeat == 1)
		{
			if(ClientPrefs.data.downScroll == true) ohGodNo();
			if(ClientPrefs.data.middleScroll == true) ohGodNo();
		}

		if(dropTime <= 0) iconP1.scale.set(1.2, 1.2);
		if(curSong == 'Lore') iconROM.scale.set(1.2, 1.2);
		if(curSong == 'Lore') iconGF.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);

		if(dropTime <= 0) iconP1.updateHitbox();
		if(curSong == 'Lore') iconROM.updateHitbox();
		if(curSong == 'Lore') iconGF.updateHitbox();
		iconP2.updateHitbox();

		if (gf != null && curBeat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
			gf.dance();
		if (curBeat % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
			boyfriend.dance();
		if (curBeat % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
			dad.dance();

		if(curSong == 'Lore')
		{
			if (curBeat % rom.danceEveryNumBeats == 0 && rom.animation.curAnim != null && !rom.animation.curAnim.name.startsWith('sing') && !rom.stunned)
				rom.dance();
		}

		super.beatHit();
		lastBeatHit = curBeat;

		setOnScripts('curBeat', curBeat);
		callOnScripts('onBeatHit');
	}

	override function sectionHit()
	{
		if (SONG.notes[curSection] != null)
		{
			if (generatedMusic && !endingSong && !isCameraOnForcedPos)
				moveCameraSection();

			if (camZooming && FlxG.camera.zoom < 1.6 && ClientPrefs.data.camZooms)
			{
				FlxG.camera.zoom += 0.015 * camZoomingMult;
				camHUD.zoom += 0.03 * camZoomingMult;
			}

			if (SONG.notes[curSection].changeBPM)
			{
				Conductor.bpm = SONG.notes[curSection].bpm;
				setOnScripts('curBpm', Conductor.bpm);
				setOnScripts('crochet', Conductor.crochet);
				setOnScripts('stepCrochet', Conductor.stepCrochet);
			}
			setOnScripts('mustHitSection', SONG.notes[curSection].mustHitSection);
			setOnScripts('altAnim', SONG.notes[curSection].altAnim);
			setOnScripts('gfSection', SONG.notes[curSection].gfSection);
		}
		super.sectionHit();
		
		setOnScripts('curSection', curSection);
		callOnScripts('onSectionHit');
	}

	#if LUA_ALLOWED
	public function startLuasNamed(luaFile:String)
	{
		#if MODS_ALLOWED
		var luaToLoad:String = Paths.modFolders(luaFile);
		if(!FileSystem.exists(luaToLoad))
			luaToLoad = Paths.getPreloadPath(luaFile);
		
		if(FileSystem.exists(luaToLoad))
		#elseif sys
		var luaToLoad:String = Paths.getPreloadPath(luaFile);
		if(OpenFlAssets.exists(luaToLoad))
		#end
		{
			for (script in luaArray)
				if(script.scriptName == luaToLoad) return false;
	
			new FunkinLua(luaToLoad);
			return true;
		}
		return false;
	}
	#end
	
	#if HSCRIPT_ALLOWED
	public function startHScriptsNamed(scriptFile:String)
	{
		var scriptToLoad:String = Paths.modFolders(scriptFile);
		if(!FileSystem.exists(scriptToLoad))
			scriptToLoad = Paths.getPreloadPath(scriptFile);
		
		if(FileSystem.exists(scriptToLoad))
		{
			if (SScript.global.exists(scriptToLoad)) return false;
	
			initHScript(scriptToLoad);
			return true;
		}
		return false;
	}

	public function initHScript(file:String)
	{
		try
		{
			var newScript:HScript = new HScript(null, file);
			if(newScript.parsingException != null)
			{
				addTextToDebug('ERROR ON LOADING: ${newScript.parsingException.message}', FlxColor.RED);
				newScript.destroy();
				return;
			}

			hscriptArray.push(newScript);
			if(newScript.exists('onCreate'))
			{
				var callValue = newScript.call('onCreate');
				if(!callValue.succeeded)
				{
					for (e in callValue.exceptions)
						if (e != null)
							addTextToDebug('ERROR ($file: onCreate) - ${e.message.substr(0, e.message.indexOf('\n'))}', FlxColor.RED);

					newScript.destroy();
					hscriptArray.remove(newScript);
					trace('failed to initialize sscript interp!!! ($file)');
				}
				else trace('initialized sscript interp successfully: $file');
			}
			
		}
		catch(e)
		{
			addTextToDebug('ERROR ($file) - ' + e.message.substr(0, e.message.indexOf('\n')), FlxColor.RED);
			var newScript:HScript = cast (SScript.global.get(file), HScript);
			if(newScript != null)
			{
				newScript.destroy();
				hscriptArray.remove(newScript);
			}
		}
	}
	#end

	public function callOnScripts(funcToCall:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:Dynamic = psychlua.FunkinLua.Function_Continue;
		if(args == null) args = [];
		if(exclusions == null) exclusions = [];
		if(excludeValues == null) excludeValues = [psychlua.FunkinLua.Function_Continue];

		var result:Dynamic = callOnLuas(funcToCall, args, ignoreStops, exclusions, excludeValues);
		if(result == null || excludeValues.contains(result)) result = callOnHScript(funcToCall, args, ignoreStops, exclusions, excludeValues);
		return result;
	}

	public function callOnLuas(funcToCall:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		if(args == null) args = [];
		if(exclusions == null) exclusions = [];
		if(excludeValues == null) excludeValues = [FunkinLua.Function_Continue];

		var len:Int = luaArray.length;
		var i:Int = 0;
		while(i < len)
		{
			var script:FunkinLua = luaArray[i];
			if(exclusions.contains(script.scriptName))
			{
				i++;
				continue;
			}

			var myValue:Dynamic = script.call(funcToCall, args);
			if((myValue == FunkinLua.Function_StopLua || myValue == FunkinLua.Function_StopAll) && !excludeValues.contains(myValue) && !ignoreStops)
			{
				returnVal = myValue;
				break;
			}
			
			if(myValue != null && !excludeValues.contains(myValue))
				returnVal = myValue;

			if(!script.closed) i++;
			else len--;
		}
		#end
		return returnVal;
	}
	
	public function callOnHScript(funcToCall:String, args:Array<Dynamic> = null, ?ignoreStops:Bool = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:Dynamic = psychlua.FunkinLua.Function_Continue;

		#if HSCRIPT_ALLOWED
		if(exclusions == null) exclusions = new Array();
		if(excludeValues == null) excludeValues = new Array();
		excludeValues.push(psychlua.FunkinLua.Function_Continue);

		var len:Int = hscriptArray.length;
		if (len < 1)
			return returnVal;
		for(i in 0...len)
		{
			var script:HScript = hscriptArray[i];
			if(script == null || !script.exists(funcToCall) || exclusions.contains(script.origin))
				continue;

			var myValue:Dynamic = null;
			try
			{
				var callValue = script.call(funcToCall, args);
				if(!callValue.succeeded)
				{
					var e = callValue.exceptions[0];
					if(e != null)
						FunkinLua.luaTrace('ERROR (${script.origin}: ${callValue.calledFunction}) - ' + e.message.substr(0, e.message.indexOf('\n') + 1), true, false, FlxColor.RED);
				}
				else
				{
					myValue = callValue.returnValue;
					if((myValue == FunkinLua.Function_StopHScript || myValue == FunkinLua.Function_StopAll) && !excludeValues.contains(myValue) && !ignoreStops)
					{
						returnVal = myValue;
						break;
					}
					
					if(myValue != null && !excludeValues.contains(myValue))
						returnVal = myValue;
				}
			}
		}
		#end

		return returnVal;
	}

	public function setOnScripts(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		if(exclusions == null) exclusions = [];
		setOnLuas(variable, arg, exclusions);
		setOnHScript(variable, arg, exclusions);
	}

	public function setOnLuas(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		#if LUA_ALLOWED
		if(exclusions == null) exclusions = [];
		for (script in luaArray) {
			if(exclusions.contains(script.scriptName))
				continue;

			script.set(variable, arg);
		}
		#end
	}

	public function setOnHScript(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		#if HSCRIPT_ALLOWED
		if(exclusions == null) exclusions = [];
		for (script in hscriptArray) {
			if(exclusions.contains(script.origin))
				continue;

			if(!instancesExclude.contains(variable))
				instancesExclude.push(variable);

			script.set(variable, arg);
		}
		#end
	}

	function strumPlayAnim(isDad:Bool, id:Int, time:Float, note:Note) {
		var spr:StrumNote = null;
		if(isDad) {
			spr = opponentStrums.members[id];
		} else {
			spr = playerStrums.members[id];
		}

		if(spr != null) {
			spr.playAnim('confirm', true, [note.rgbShader.r, note.rgbShader.g, note.rgbShader.b]);
			spr.resetAnim = time;
		}
	}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;
	public function RecalculateRating(badHit:Bool = false) {
		setOnScripts('score', songScore);
		setOnScripts('misses', songMisses);
		setOnScripts('hits', songHits);
		setOnScripts('combo', combo);

		var ret:Dynamic = callOnScripts('onRecalculateRating', null, true);
		if(ret != FunkinLua.Function_Stop)
		{
			ratingName = '?';
			if(totalPlayed != 0) //Prevent divide by 0
			{
				// Rating Percent
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
				//trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);

				// Rating Name
				ratingName = medal_system[medalStatus][2];
			}
			fullComboFunction();
		}
		updateScore(badHit); // score will only update after rating is calculated, if it's a badHit, it shouldn't bounce -Ghost
		setOnScripts('rating', ratingPercent);
		setOnScripts('ratingName', ratingName);
		setOnScripts('ratingFC', ratingFC);
	}

	function fullComboUpdate()
	{
		var sicks:Int = ratingsData[0].hits;
		var goods:Int = ratingsData[1].hits;
		var bads:Int = ratingsData[2].hits;
		var shits:Int = ratingsData[3].hits;

		ratingFC = 'Clear';
		if(songMisses < 1)
		{
			if (bads > 0 || shits > 0) ratingFC = 'FC';
			else if (goods > 0) ratingFC = 'GFC';
			else if (sicks > 0) ratingFC = 'SFC';
		}
		else if (songMisses < 10)
			ratingFC = 'SDCB';

		if(cpuControlled && changedDifficulty) 
		{
			medalStatus = 5; //хуй а не фри мани	

			if (medalOldStatus != medalStatus)
			{
				medalOldStatus = medalStatus;
				uniqueMedalChange(medalStatus+1);
				medal.loadGraphic(Paths.image('medals/medal_${medalStatus+1}', 'shared'));
			}
			return;
		}

		if(cpuControlled) 
		{
			medalStatus = 5; //хуй а не фри мани	

			if (medalOldStatus != medalStatus)
			{
				medalOldStatus = medalStatus;
				uniqueMedalChange(medalStatus+1);
				medal.loadGraphic(Paths.image('medals/medal_${medalStatus+1}', 'shared'));
			}
			return;
		}

		if (sicks == totalNotes)
		{
			medalStatus = 0;
			if (medalOldStatus != medalStatus)
			{
				medalOldStatus = medalStatus;
				uniqueMedalChange(medalStatus+1);
				medal.loadGraphic(Paths.image('medals/medal_${medalStatus+1}', 'shared'));
			}
			return;
		}

		// calculate shit
		// Grade % (only good and sick), 1.00 is a full combo
		var grade = (sicks + goods - songMisses) / totalNotes;
		// Clear % (including bad and shit). 1.00 is a full clear but not a full combo
		var clear = (songHits) / totalNotes;

		if (grade == 1.00)
			medalStatus = 1;
		else if (grade >= 0.80)
			medalStatus = 2;
		else if (grade >= 0.60)
			medalStatus = 3;
		else if (grade >= 0.50)
			medalStatus = 4;
		else
			medalStatus = 5;

		if (medalOldStatus != medalStatus)
		{
			medalOldStatus = medalStatus;
			uniqueMedalChange(medalStatus+1);
			medal.loadGraphic(Paths.image('medals/medal_${medalStatus+1}', 'shared'));
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	private function checkForAchievement(achievesToCheck:Array<String> = null):String
	{
		if(chartingMode) return null;
		var usedPractice:Bool = (ClientPrefs.getGameplaySetting('practice') || ClientPrefs.getGameplaySetting('botplay'));
		for (i in 0...achievesToCheck.length) {
			var achievementName:String = achievesToCheck[i];
			Achievements.loadAchievements();
			if(!Achievements.isAchievementUnlocked(achievementName) && Achievements.getAchievementIndex(achievementName) > -1) {
				var unlock:Bool = false;
				if (achievementName == WeekData.getWeekFileName() + '_nomiss' && !cpuControlled) // any FC achievements, name should be "weekFileName_nomiss", e.g: "week3_nomiss";
				{
					if(isStoryMode && campaignMisses + songMisses < 1 && storyPlaylist.length <= 1 && !changedDifficulty && !usedPractice)
						unlock = true;
				}
				else if (achievementName == WeekData.getWeekFileName() + '_nomiss_nodeaths' && !cpuControlled) // any FC achievements, name should be "weekFileName_nomiss", e.g: "week3_nomiss";
				{
					if(isStoryMode && campaignMisses + songMisses < 1 && storyPlaylist.length <= 1 && !changedDifficulty && !usedPractice && deathCounter == 0)
						unlock = true;
				}
				else if (achievementName == songName.toLowerCase() + "_freeplay_nomiss" && !cpuControlled)
				{
					if(!isStoryMode && songMisses < 1 && !changedDifficulty && !usedPractice)
						unlock = true;
				}
				else
				{
					var weekName:String = WeekData.getWeekFileName();
					switch(achievementName)
					{
						case 'cum':
							unlock = (ClientPrefs.data.arrowRGB[0][0] == -1 && ClientPrefs.data.arrowRGB[0][1] == -1 && ClientPrefs.data.arrowRGB[0][2] == -1 &&
								ClientPrefs.data.arrowRGB[1][0] == -1 && ClientPrefs.data.arrowRGB[1][1] == -1 && ClientPrefs.data.arrowRGB[1][2] == -1 &&
								ClientPrefs.data.arrowRGB[2][0] == -1 && ClientPrefs.data.arrowRGB[2][1] == -1 && ClientPrefs.data.arrowRGB[2][2] == -1 &&
								ClientPrefs.data.arrowRGB[3][0] == -1 && ClientPrefs.data.arrowRGB[3][1] == -1 && ClientPrefs.data.arrowRGB[3][2] == -1);
						case 'oldweek0':
							unlock = (FlxG.save.data.playedSongs.contains('with-cone-original') && FlxG.save.data.playedSongs.contains('boom-old') && FlxG.save.data.playedSongs.contains('overfire-old') && FlxG.save.data.playedSongs.contains('klork-old') && FlxG.save.data.playedSongs.contains('t-short-original'));
						case 'allweeks':
							unlock = (FlxG.save.data.playedSongs.contains('with-cone') && FlxG.save.data.playedSongs.contains('boom') && FlxG.save.data.playedSongs.contains('overfire') 
							&& FlxG.save.data.playedSongs.contains('klork') && FlxG.save.data.playedSongs.contains('anekdot') && FlxG.save.data.playedSongs.contains('t-short')
						    && FlxG.save.data.playedSongs.contains('monochrome') && FlxG.save.data.playedSongs.contains('lore')
							&& FlxG.save.data.playedSongs.contains('s6x-boom') && FlxG.save.data.playedSongs.contains('lamar-tut-voobshe-ne-nujen')
							&&FlxG.save.data.playedSongs.contains('with-cone-original') && FlxG.save.data.playedSongs.contains('boom-old')
							&& FlxG.save.data.playedSongs.contains('overfire-old') && FlxG.save.data.playedSongs.contains('klork-old') && FlxG.save.data.playedSongs.contains('t-short-original'));

						case 'allweeks1':
							unlock = (FlxG.save.data.playedSongsFC.contains('with-cone') && FlxG.save.data.playedSongsFC.contains('boom') && FlxG.save.data.playedSongsFC.contains('overfire') 
							&& FlxG.save.data.playedSongsFC.contains('klork') && FlxG.save.data.playedSongsFC.contains('anekdot') && FlxG.save.data.playedSongsFC.contains('t-short')
						    && FlxG.save.data.playedSongsFC.contains('monochrome') && FlxG.save.data.playedSongsFC.contains('lore')
							&& FlxG.save.data.playedSongsFC.contains('s6x-boom') && FlxG.save.data.playedSongsFC.contains('lamar-tut-voobshe-ne-nujen')
							&&FlxG.save.data.playedSongsFC.contains('with-cone-original') && FlxG.save.data.playedSongsFC.contains('klork-old') && FlxG.save.data.playedSongsFC.contains('t-short-original'));
						case weekName:
							if (isStoryMode && storyPlaylist.length <= 1)
							{
								unlock = true;
							}
					}
				}

				if(unlock) {
					Achievements.unlockAchievement(achievementName);
					return achievementName;
				}
			}
		}
		return null;
	}
	#end

	#if (!flash && sys)
	public var runtimeShaders:Map<String, Array<String>> = new Map<String, Array<String>>();
	public function createRuntimeShader(name:String):FlxRuntimeShader
	{
		if(!ClientPrefs.data.shaders) return new FlxRuntimeShader();

		#if (!flash && MODS_ALLOWED && sys)
		if(!runtimeShaders.exists(name) && !initLuaShader(name))
		{
			FlxG.log.warn('Shader $name is missing!');
			return new FlxRuntimeShader();
		}

		var arr:Array<String> = runtimeShaders.get(name);
		return new FlxRuntimeShader(arr[0], arr[1]);
		#else
		FlxG.log.warn("Platform unsupported for Runtime Shaders!");
		return null;
		#end
	}

	public function initLuaShader(name:String, ?glslVersion:Int = 120)
	{
		if(!ClientPrefs.data.shaders) return false;

		#if (MODS_ALLOWED && !flash && sys)
		if(runtimeShaders.exists(name))
		{
			FlxG.log.warn('Shader $name was already initialized!');
			return true;
		}

		var foldersToCheck:Array<String> = [Paths.mods('shaders/')];
		if(Mods.currentModDirectory != null && Mods.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Mods.currentModDirectory + '/shaders/'));

		for(mod in Mods.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/shaders/'));
		
		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				var frag:String = folder + name + '.frag';
				var vert:String = folder + name + '.vert';
				var found:Bool = false;
				if(FileSystem.exists(frag))
				{
					frag = File.getContent(frag);
					found = true;
				}
				else frag = null;

				if(FileSystem.exists(vert))
				{
					vert = File.getContent(vert);
					found = true;
				}
				else vert = null;

				if(found)
				{
					runtimeShaders.set(name, [frag, vert]);
					//trace('Found shader $name!');
					return true;
				}
			}
		}
		FlxG.log.warn('Missing shader $name .frag AND .vert files!');
		#else
		FlxG.log.warn('This platform doesn\'t support Runtime Shaders!', false, false, FlxColor.RED);
		#end
		return false;
	}
	#end
}


/*
  Привет всем читающим. Я рассылаю это сообщение куда только могу. 
  У меня ужасные новости: дело в том, что за одним популярным PvZ ютубером - How, What and Why было замечено много отвратительных действий, таких как грубые ответы фанатам, 
  ужасные действия по отношению к некоторым личностям без причины и многое другое. Я понимаю, что это может быть странно, что я внезапно говорю об этом, но это нужно для того, 
  чтобы как можно больше людей узнали правду и были осведомлены. Я бы хотел попросить о помощи всех вас, кто читает это. Пожалуйста, разошлите этот документ везде, где только можете.
  Ещё, если вы являетесь ютубером, не важно маленьким или большим, вы можете помочь сделав пост в сообществе. И тогда, всем будет известно о том, какой он на самом деле.
  Он не должен остаться безнаказанным.
*/
