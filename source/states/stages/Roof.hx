package states.stages;

import states.stages.objectMyBalls.*;
import flixel.effects.particles.FlxEmitter.FlxEmitterMode;
import flixel.effects.particles.FlxEmitter.FlxTypedEmitter;
import substates.GameOverSubstate;
import objects.Character;
import cutscenes.CutsceneHandler;
import backend.Achievements;

class Roof extends BaseStage
{
	public var originalY:Float;
	public var originalHeight:Int = 2000;
	public var intendedAlpha:Float = 1;
	public var lavaEmitter:FlxTypedEmitter<LavaParticle>;
	public var grad:FlxSprite;

	public var flames:FlxSprite;
	public var smoke:FlxSprite;

	public var fire:Bool = false;
	public var vibing:Bool = false;
	var canRain:Bool = false;

	var rain:FlxSprite;
	var splash:FlxSprite;

	var day:BGSprite;

	var bg:BGSprite;
	var roof:BGSprite;

	var lightning:BGSprite;
	var nword:FlxSprite;
	var lightningTimer:Float = 3.0;
	var additionalLighten:FlxSprite;
	var dadbattleLight:BGSprite;

	var toogledLight:Bool = false;

	var phillyLightsColors:Array<FlxColor>;
	var curLight:Int = -1;

	override function create()
	{
		var _song = PlayState.SONG;
		GameOverSubstate.deathSoundName = 'fnf_loss_sfx_notBf';
		GameOverSubstate.characterName = 'hwaw-death';

		function setupScale(spr:BGSprite)
		{
			spr.scale.set(4.75, 4.75);
			spr.updateHitbox();
		}

		bg = new BGSprite('sky', 0, 0, 0.75, 0.75);
		bg.setGraphicSize(Std.int(bg.width * 3));
		add(bg);

		if(PlayState.SONG.song == 'Overfire')
		{
			if(!ClientPrefs.data.lowQuality)
			{
				lightning = new BGSprite('lightning', -50, -550, 0.75, 0.75, ['lightning0'], false);
				setupScale(lightning);
				lightning.visible = false;
				add(lightning);
			}
		}

		if(!ClientPrefs.data.lowQuality)
		{		
			additionalLighten = new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
			additionalLighten.scrollFactor.set();
			additionalLighten.updateHitbox();
			additionalLighten.blend = ADD;
			additionalLighten.visible = false;
			additionalLighten.scale.set(5, 5);
			add(additionalLighten);
		}

		flames = new FlxSprite(200, 3000);
		flames.frames = Paths.getSparrowAtlas('Starman_BG_Fire_Assets');
		flames.animation.addByPrefix('flames', 'fire', 24);
		flames.animation.play('flames');
		flames.setGraphicSize(Std.int(flames.width * 3));
		flames.alpha = 0.001;
		add(flames);

		smoke = new FlxSprite(0, 0).loadGraphic(Paths.image('smoke'));
		smoke.alpha = 0.001;
		smoke.cameras = [camHUD];

		grad = new FlxSprite(-1000, -400).loadGraphic(Paths.image('gradient'));
		grad.scrollFactor.set(0, 1);
		grad.setGraphicSize(3000, originalHeight);
		grad.updateHitbox();
		grad.visible = false;
		add(grad);

		roof = new BGSprite('home', 0, 0);
		roof.setGraphicSize(Std.int(roof.width * 3));
		add(roof);

		if(PlayState.SONG.song == 'Overfire')
		{
			if(!ClientPrefs.data.lowQuality) {
				splash = new FlxSprite(0, 1000);
				splash.frames = Paths.getSparrowAtlas('splash');
				splash.animation.addByPrefix('loop', 'splash loop', 15, true);
				splash.animation.play('loop');
				splash.visible = false;
				add(splash);

				for (i in 1...4)
				{
					//trace('Lightning$i');
					Paths.sound('Lightning$i');
				}
			}
			day = new BGSprite('day', -150, 130);
			day.visible = false;
			day.setGraphicSize(Std.int(day.width * 1.5));
			day.updateHitbox();
			add(day);
		}

		originalY = grad.y;
		phillyLightsColors = [0xFF31A2FD, 0xFF31FD8C, 0xFFFB33F5, 0xFFFD4531, 0xFFFBA633];

		if (isStoryMode && !seenCutscene)
		{
			if(PlayState.SONG.song == 'Overfire')
			{
				setStartCallback(overfireIntro);
			}
		}
	}

	override function createPost()
	{
		if(PlayState.SONG.song == 'Overfire')
		{
			nword = new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
			nword.scrollFactor.set(0, 0);
			nword.alpha = 0.0001;
			nword.scale.set(5, 5);
			add(nword);

			if(!ClientPrefs.data.lowQuality) {
				rain = new FlxSprite(-250, 0);
				rain.frames = Paths.getSparrowAtlas('rain');
				rain.animation.addByPrefix('loop', 'rain loop', 16, true);
				rain.animation.play('loop');
				rain.scrollFactor.set(0.3, 0.3);
				rain.scale.set(2.1, 2.1);
				rain.visible = false;
				add(rain);

				lavaEmitter = new FlxTypedEmitter<LavaParticle>(FlxG.width * -0.5, 3400);
				lavaEmitter.particleClass = LavaParticle;
				lavaEmitter.launchMode = FlxEmitterMode.SQUARE;
				lavaEmitter.width = Std.int(FlxG.width * 2);
				lavaEmitter.velocity.set(0, -150, 0, -300, 0, -10, 0, -50);
				lavaEmitter.alpha.set(1, 0);
				add(lavaEmitter);
				lavaEmitter.start(false);
			}
		}
	}

	override function update(elapsed:Float)
	{
		if(vibing)
		{
			var newHeight:Int = Math.round(grad.height - 1000 * elapsed);
			if(newHeight > 0)
			{
				grad.alpha = intendedAlpha;
				grad.setGraphicSize(3000, newHeight);
				grad.updateHitbox();
				grad.y = originalY + (originalHeight - grad.height);
			}
			else
			{
				grad.alpha = 0;
				grad.y = -5000;
			}
		}

		if(fire)
			game.health -= 0.001;

		if(canRain)
		{
			lightningTimer -= elapsed;
			if (lightningTimer <= 0)
			{
				applyLightning();
				lightningTimer = FlxG.random.float(7, 15);
			}
		}

		super.update(elapsed);
	}

	function applyLightning():Void
	{
		if(ClientPrefs.data.lowQuality || game.endingSong) return;

		final LIGHTNING_FULL_DURATION = 1.5;
		final LIGHTNING_FADE_DURATION = 0.3;

		nword.alpha = 0;
		FlxTween.tween(nword, {alpha: 0.6}, LIGHTNING_FULL_DURATION, {onComplete: function(_)
		{
			lightning.visible = false;
			additionalLighten.visible = false;
		}});

		additionalLighten.visible = true;
		additionalLighten.alpha = 0.3;
		FlxTween.tween(additionalLighten, {alpha: 0.0}, LIGHTNING_FADE_DURATION);

		lightning.visible = true;
		lightning.animation.play('lightning0', true);

		if(FlxG.random.bool(65))
			lightning.x = FlxG.random.int(-250, 280);
		else
			lightning.x = FlxG.random.int(780, 900);

		// Sound
		FlxG.sound.play(Paths.soundRandom('Lightning', 1, 3));
	}

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case 'burn with cone':
				FlxG.camera.flash(0xffff4d00, 1, null, true);
				FlxG.sound.play(Paths.sound('boom'), 0.6);
				game.health -= 0.5;
				fire = !fire;

			case 'vibe time':
				vibing = !vibing;
				grad.visible = vibing;
			
			case 'fire boom':
				add(smoke);
				FlxTween.tween(flames, {y: 800}, 10, {ease: FlxEase.sineOut});

				FlxTween.tween(smoke, {alpha: 1}, 10);
				FlxTween.tween(flames, {alpha: 1}, 10);

				if(PlayState.SONG.song == 'Overfire')
				{
					FlxTween.color(roof, 10, 0xFFFFFFFF, 0xffff6300);
					FlxTween.color(bg, 10, 0xFFFFFFFF, 0xffff6300);
					FlxTween.color(game.dadGroup, 10, 0xFFFFFFFF, 0xffff6300);
					FlxTween.color(game.boyfriendGroup, 10, 0xFFFFFFFF, 0xffff6300);
					if(!ClientPrefs.data.lowQuality) FlxTween.tween(lavaEmitter, {y: 1200}, 6, {ease: FlxEase.sineOut});
				}

			case 'rain':
				nword.alpha = 0.6;
				if(ClientPrefs.data.lowQuality) return;
					
				rain.visible = true;
				splash.visible = true;
				canRain = true;
			case 'trans overfire':
				nword.visible = false;
				day.visible = true;
				if(ClientPrefs.data.lowQuality) return;
					
				rain.visible = false;
				splash.visible = false;
				canRain = false;
			case 'night cum':
				game.camHUD.flash(0xffFFFFFF, 3);
				day.visible = false;
				game.boyfriendGroup.color = 0xFF44145f;
				roof.color = 0xFF44145f;
				bg.color = 0xFF44145f;
			case 'oh well':
				game.boyfriendGroup.color = 0xFFFFFFFF;
				roof.color = 0xFFFFFFFF;
				bg.color = 0xFFFFFFFF;
			case "Dadbattle Spotlight":
				toogledLight = !toogledLight;

				if(toogledLight == true)
				{
					dadbattleLight.visible = true;
					dadbattleLight.setPosition(dad.x - 50, dad.y + dad.height - dadbattleLight.height + 250);
				}
				else
				{
					dadbattleLight.visible = false;
				}
			case "end":
				smoke.alpha = 0;
				if(!ClientPrefs.data.lowQuality) lavaEmitter.y = 5000;
		}
	}

	override function eventPushed(event:objects.Note.EventNote)
	{
		// used for preloading assets used on events that doesn't need different assets based on its values
		switch(event.event)
		{
			case "Dadbattle Spotlight":
				dadbattleLight = new BGSprite('spotlight', 400, -400);
				dadbattleLight.alpha = 0.375;
				dadbattleLight.blend = ADD;
				dadbattleLight.visible = false;
				add(dadbattleLight);
		}
	}

	override function beatHit()
	{
		if(vibing)
		{
			grad.setGraphicSize(3000, originalHeight);
			grad.updateHitbox();
			grad.y = originalY;
			grad.alpha = intendedAlpha;
			if(PlayState.SONG.song == 'Overfire')
			{
				grad.color = 0xFF44145f;
			}
			else
			{
				curLight = FlxG.random.int(0, phillyLightsColors.length - 1, [curLight]);
				grad.color = phillyLightsColors[curLight];
			}
		}
	}

	// Cutscenes
	var cutsceneHandler:CutsceneHandler;
	var grave:FlxSprite;
	var hwaw:FlxSprite;
	var blackFlashs:FlxSprite;
	function prepareCutscene()
	{
		cutsceneHandler = new CutsceneHandler();
		camHUD.visible = false;
		dadGroup.alpha = 0.00001;

		grave = new FlxSprite(dad.x + 200, dad.y + 210);
		grave.frames = Paths.getSparrowAtlas('GRAVE');
		grave.antialiasing = ClientPrefs.data.antialiasing;
		addBehindDad(grave);

		hwaw = new FlxSprite(boyfriend.x, boyfriend.y);
		hwaw.antialiasing = ClientPrefs.data.antialiasing;

		blackFlashs = new FlxSprite(0, 0).makeGraphic(1280, 720, FlxColor.BLACK);
		blackFlashs.cameras = [camOther];
		blackFlashs.alpha = 0.0001;
		add(blackFlashs);

		cutsceneHandler.push(grave);
		cutsceneHandler.push(hwaw);
		cutsceneHandler.push(blackFlashs);

		cutsceneHandler.finishCallback = function()
		{
			var timeForStuff:Float = Conductor.crochet / 1000 * 4.5;
			FlxG.sound.music.fadeOut(timeForStuff);
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, timeForStuff, {ease: FlxEase.quadInOut});
			startCountdown();

			dadGroup.alpha = 1;
			boyfriendGroup.alpha = 1;
			camHUD.visible = true;
			remove(blackFlashs);
			blackFlashs.destroy();
			boyfriend.animation.finishCallback = null;
		};
		camFollow.setPosition(boyfriend.x - 480, boyfriend.y - 70);
	}

	function overfireIntro()
	{
		prepareCutscene();
		cutsceneHandler.endTime = 18;
		precacheSound('ambienceSlendy');
		precacheSound('onoIdet');
		boyfriendGroup.alpha = 0.00001;

		var amb:FlxSound = new FlxSound().loadEmbedded(Paths.sound('ambienceSlendy'));
		FlxG.sound.list.add(amb);

		grave.animation.addByPrefix('grave', 'grave', 24, true);
		grave.animation.addByPrefix('kirill', 'ono idet', 24, false);
		grave.animation.play('grave', true);
		FlxG.camera.zoom = 0.4;

		hwaw.frames = Paths.getSparrowAtlas('characters/HWAW_ASS');
		hwaw.animation.addByPrefix('idle', 'idle', 24, true);
		hwaw.animation.play('idle', true);
		addBehindBF(hwaw);

		// Играет амбиент из следни табис и камера приближается
		cutsceneHandler.timer(0.1, function()
		{
			amb.play(true);
			FlxTween.tween(FlxG.camera, {zoom: 0.6}, 5, {ease: FlxEase.quadInOut});
		});

		// Камера идет к могиле
		cutsceneHandler.timer(6, function()
		{
			camFollow.x = 750;
			camFollow.y = 900;
			FlxTween.tween(FlxG.camera, {zoom: 0.8}, 1, {ease: FlxEase.quadInOut});
		});

		// Ох бля
		cutsceneHandler.timer(9, function()
		{
			camFollow.y -= 100;
			grave.animation.play('kirill', true);
			grave.y -= 315;
			FlxG.sound.play(Paths.sound('onoIdet'));
			FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);
			FlxG.camera.shake(0.0025, 7);
		});

		cutsceneHandler.timer(12, function()
		{
			camFollow.x += 400;
			camFollow.y -= 50;
			FlxTween.tween(FlxG.camera, {zoom: 0.7}, 5, {ease: FlxEase.quadInOut});
		});

		cutsceneHandler.timer(14, function()
		{
			FlxTween.tween(blackFlashs, {alpha: 1}, 3);
		});
	}
}