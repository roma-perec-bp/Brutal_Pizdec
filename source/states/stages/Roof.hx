package states.stages;

import states.stages.objects.*;
import substates.GameOverSubstate;
import objects.Character;

class Roof extends BaseStage
{
	public var originalY:Float;
	public var originalHeight:Int = 2000;
	public var intendedAlpha:Float = 1;

	public var grad:FlxSprite;

	public var flames:FlxSprite;
	public var smoke:FlxSprite;

	public var fire:Bool = false;
	public var vibing:Bool = false;
	var canRain:Bool = false;

	var rain:FlxSprite;
	var splash:FlxSprite;

	var day:BGSprite;

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

		var bg:BGSprite = new BGSprite('sky', 0, 0, 0.75, 0.75);
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
			additionalLighten = new FlxSprite(-1000, -1000).makeGraphic(FlxG.width * 8, FlxG.height * 8, FlxColor.WHITE);
			additionalLighten.scrollFactor.set();
			additionalLighten.updateHitbox();
			additionalLighten.blend = ADD;
			additionalLighten.visible = false;
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

		var roof:BGSprite = new BGSprite('home', 0, 0);
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
			day = new BGSprite('day', 0, 0);
			day.screenCenter();
			day.visible = false;
			day.setGraphicSize(Std.int(day.width * 1.5));
			add(day);
		}

		originalY = grad.y;
		phillyLightsColors = [0xFF31A2FD, 0xFF31FD8C, 0xFFFB33F5, 0xFFFD4531, 0xFFFBA633];
	}

	override function createPost()
	{
		if(PlayState.SONG.song == 'Overfire')
		{
			nword = new FlxSprite(-1000, -1000).makeGraphic(FlxG.width * 8, FlxG.height * 8, FlxColor.BLACK);
			nword.scrollFactor.set(0, 0);
			nword.alpha = 0.0001;
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

			case 'rain':
				nword.alpha = 0.6;
				if(ClientPrefs.data.lowQuality) return;
					
				rain.visible = true;
				splash.visible = true;
				canRain = true;
			case 'trans overfire':
				nword.alpha = 0;
				day.visible = true;
				if(ClientPrefs.data.lowQuality) return;
					
				rain.visible = false;
				splash.visible = false;
				canRain = false;
			case "Dadbattle Spotlight":
				toogledLight = !toogledLight;

				if(toogledLight == true)
				{
					dadbattleLight.visible = true;
					dadbattleLight.setPosition(dad.getGraphicMidpoint().x - dadbattleLight.width / 2, dad.y + dad.height - dadbattleLight.height + 250);
				}
				else
				{
					dadbattleLight.visible = false;
				}
		}
	}

	override function eventPushed(event:objects.Note.EventNote)
	{
		// used for preloading assets used on events that doesn't need different assets based on its values
		switch(event.event)
		{
			case "burn with cone":
				precacheSound('boom');
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
			curLight = FlxG.random.int(0, phillyLightsColors.length - 1, [curLight]);
			grad.color = phillyLightsColors[curLight];
		}
	}
}