package states.stages;

import states.stages.objectMyBalls.*;
import flixel.effects.particles.FlxEmitter.FlxEmitterMode;
import flixel.effects.particles.FlxEmitter.FlxTypedEmitter;
import objects.Character;
import objects.Note;

class Void extends BaseStage
{
	public var jumpScare:FlxSprite;

	var alt:Bool = false;
	var noteStar:Bool = false;

	public var grad:FlxSprite;
	public var lavaEmitter:FlxTypedEmitter<LavaParticle>;

	public var strum1:FlxSprite;
	public var strum2:FlxSprite;
	public var strum3:FlxSprite;
	public var strum4:FlxSprite;

	override function create()
	{
		game.skipCountdown = true;
		setStartCallback(startCut);

		strum1 = new FlxSprite(150, 225);
		strum1.frames = Paths.getSparrowAtlas('dead_sturm');
		strum1.animation.addByPrefix('left', 'left confirm0', 24, false);
		strum1.animation.addByPrefix('left alt', 'left confirm red', 24, false);
		strum1.antialiasing = ClientPrefs.data.antialiasing;
		strum1.scrollFactor.set();
		strum1.blend = HARDLIGHT;
		strum1.alpha = 0.0001;
		add(strum1);

		strum2 = new FlxSprite(strum1.x + 250, strum1.y);
		strum2.frames = Paths.getSparrowAtlas('dead_sturm');
		strum2.animation.addByPrefix('down', 'down confirm0', 24, false);
		strum2.animation.addByPrefix('down alt', 'down confirm red', 24, false);
		strum2.antialiasing = ClientPrefs.data.antialiasing;
		strum2.scrollFactor.set();
		strum2.blend = HARDLIGHT;
		strum2.alpha = 0.0001;
		add(strum2);

		strum3 = new FlxSprite(strum2.x + 250, strum2.y);
		strum3.frames = Paths.getSparrowAtlas('dead_sturm');
		strum3.animation.addByPrefix('up', 'up confirm0', 24, false);
		strum3.animation.addByPrefix('up alt', 'up confirm red', 24, false);
		strum3.antialiasing = ClientPrefs.data.antialiasing;
		strum3.scrollFactor.set();
		strum3.blend = HARDLIGHT;
		strum3.alpha = 0.0001;
		add(strum3);

		strum4 = new FlxSprite(strum3.x + 250, strum3.y);
		strum4.frames = Paths.getSparrowAtlas('dead_sturm');
		strum4.animation.addByPrefix('right', 'right confirm0', 24, false);
		strum4.animation.addByPrefix('right alt', 'right confirm red', 24, false);
		strum4.antialiasing = ClientPrefs.data.antialiasing;
		strum4.scrollFactor.set();
		strum4.blend = HARDLIGHT;
		strum4.alpha = 0.0001;
		add(strum4);
	}

	override function createPost()
	{
		PlayState.instance.dad.alpha = 0.001;

		if(!ClientPrefs.data.lowQuality)
		{
			lavaEmitter = new FlxTypedEmitter<LavaParticle>(0, 3400);
			lavaEmitter.particleClass = LavaParticle;
			lavaEmitter.launchMode = FlxEmitterMode.SQUARE;
			lavaEmitter.width = FlxG.width;
			lavaEmitter.velocity.set(0, -150, 0, -300, 0, -10, 0, -50);
			lavaEmitter.alpha.set(1, 0);
			add(lavaEmitter);
			lavaEmitter.start(false);
		}

		grad = new FlxSprite(-1000, 2700).loadGraphic(Paths.image('gradient'));
		grad.scrollFactor.set(0, 1);
		grad.setGraphicSize(8000, 2000);
		grad.updateHitbox();
		grad.color = 0xffFF0000;
		grad.alpha = 0.7;
		add(grad);

		jumpScare = new FlxSprite().loadGraphic(Paths.image('aaaaaa'));
		jumpScare.setGraphicSize(Std.int(FlxG.width * jumpscareSizeInterval), Std.int(FlxG.height * jumpscareSizeInterval));
		jumpScare.updateHitbox();
		jumpScare.screenCenter();
		jumpScare.visible = false;
		jumpScare.cameras = [camHUD];
		add(jumpScare);
	}

	function startCut()
	{
		FlxG.sound.play(Paths.sound('dead' + FlxG.random.int(0, 69)), 1, false, null, true, function() {
			FlxTween.tween(PlayState.instance.dad, {alpha: 1}, 0.8);
			startCountdown();
		});
	}

	override function opponentNoteHit(note:Note)
	{
		if(noteStar == false) return;

		switch(note.noteData)
		{
			case 0:
				if(alt)
				{
					strum1.alpha = 1;
					strum1.animation.play('left alt');
				}
				else
				{
					strum1.alpha = 0.8;
					strum1.animation.play('left');
				}
			case 1:
				if(alt)
				{
					strum2.alpha = 1;
					strum2.animation.play('down alt');
				}
				else
				{
					strum2.alpha = 0.8;
					strum2.animation.play('down');
				}
			case 2:
				if(alt)
				{
					strum3.alpha = 1;
					strum3.animation.play('up alt');
				}
				else
				{
					strum3.alpha = 0.8;
					strum3.animation.play('up');
				}
			case 3:
				if(alt)
				{
					strum4.alpha = 1;
					strum4.animation.play('right alt');
				}
				else
				{
					strum4.alpha = 0.8;
					strum4.animation.play('right');
				}
		}
	}

	override function update(elapsed:Float)
	{
		if (strum1.alpha >= 0)
			strum1.alpha -= 0.05;
		if (strum2.alpha >= 0)
			strum2.alpha -= 0.05;
		if (strum3.alpha >= 0)
			strum3.alpha -= 0.05;
		if (strum4.alpha >= 0)
			strum4.alpha -= 0.05;
	}

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case "dead jumpscare":
				var flValue1:Null<Float> = Std.parseFloat(value1);
				jumpscare(flValue1);
			
			case 'boom dead':
				PlayState.instance.dad.alpha = 0.6;
				FlxTween.tween(PlayState.instance.dad, {alpha: 1}, 0.8);
				FlxG.camera.shake(0.03, 0.1);
				if(game.health > 0.7) game.health -= FlxG.random.float(0.2, 0.7);

				FlxG.camera.zoom += 0.069;
				camHUD.zoom += 0.07;
			case 'monochrome pizdec':
				alt = !alt;

				if(alt)
				{
					strum1.blend = ADD;
					strum2.blend = ADD;
					strum3.blend = ADD;
					strum4.blend = ADD;
				}
				else
				{
					strum1.blend = HARDLIGHT;
					strum2.blend = HARDLIGHT;
					strum3.blend = HARDLIGHT;
					strum4.blend = HARDLIGHT;
				}
			case 'start notes':
				noteStar = !noteStar;
			case 'hi gradient':
				FlxTween.tween(grad, {y: 700}, 6, {ease: FlxEase.sineOut});
				if(!ClientPrefs.data.lowQuality) FlxTween.tween(lavaEmitter, {y: 1400}, 6, {ease: FlxEase.sineOut});

			case 'bye gradient':
				FlxTween.tween(grad, {y: 2700}, 1, {ease: FlxEase.sineIn});
				if(!ClientPrefs.data.lowQuality) FlxTween.tween(lavaEmitter, {y: 3400}, 1, {ease: FlxEase.sineIn});
		}
	}

	var jumpscareSizeInterval:Float = 1.323;

	function jumpscare(duration:Float) {
		if (ClientPrefs.data.flashing) {
				jumpScare.visible = true;
				jumpScare.alpha = FlxG.random.float(0.6, 0.9);
				camOther.shake(0.0125 * (jumpscareSizeInterval / 2), (((!Math.isNaN(duration)) ? duration : 1) * Conductor.stepCrochet) / 1000, 
					function(){
						jumpScare.visible = false;
						jumpScare.setGraphicSize(Std.int(FlxG.width * jumpscareSizeInterval), Std.int(FlxG.height * jumpscareSizeInterval));
						jumpScare.updateHitbox();
						jumpScare.screenCenter();
					}, true
				);
				camHUD.shake(0.0125 * (jumpscareSizeInterval / 2), (((!Math.isNaN(duration)) ? duration : 1) * Conductor.stepCrochet) / 1000);

			FlxG.camera.zoom += 0.069;
			camHUD.zoom += 0.07;
		}
		else
		{
			jumpScare.visible = true;
			jumpScare.alpha = 0.4;
			new FlxTimer().start((((!Math.isNaN(duration)) ? duration : 1) * Conductor.stepCrochet) / 1000, function(tmr:FlxTimer)
				{
					jumpScare.visible = false;
					jumpScare.setGraphicSize(Std.int(FlxG.width * jumpscareSizeInterval), Std.int(FlxG.height * jumpscareSizeInterval));
					jumpScare.updateHitbox();
					jumpScare.screenCenter();
				}
			);
		}
	}
}