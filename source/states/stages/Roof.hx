package states.stages;

import states.stages.objects.*;
import objects.Character;

class Roof extends BaseStage
{
	public var originalY:Float;
	public var originalHeight:Int = 2000;
	public var intendedAlpha:Float = 1;

	public var grad:FlxSprite;

	public var flames:FlxSprite;
	public var flames2:FlxSprite;
	public var smoke:FlxSprite;

	public var fire:Bool = false;
	public var vibing:Bool = false;

	var phillyLightsColors:Array<FlxColor>;
	var curLight:Int = -1;

	override function create()
	{
		var bg:BGSprite = new BGSprite('sky', 0, 0, 0.75, 0.75);
		bg.setGraphicSize(Std.int(bg.width * 3));
		add(bg);

		flames = new FlxSprite(-600, 2000);
		flames.frames = Paths.getSparrowAtlas('Starman_BG_Fire_Assets');
		flames.animation.addByPrefix('flames', 'fire anim effects', 24);
		flames.animation.play('flames');
		flames.alpha = 0.001;
		add(flames);

		flames2 = new FlxSprite(600, 2000);
		flames2.frames = Paths.getSparrowAtlas('Starman_BG_Fire_Assets');
		flames2.animation.addByPrefix('flames', 'fire anim effects', 24);
		flames2.animation.play('flames');
		flames2.alpha = 0.001;
		flames2.flipX = true;
		add(flames2);

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

		originalY = grad.y;
		phillyLightsColors = [0xFF31A2FD, 0xFF31FD8C, 0xFFFB33F5, 0xFFFD4531, 0xFFFBA633];
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

		super.update(elapsed);
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
				FlxTween.tween(flames, {y: -350}, 10, {ease: FlxEase.sineOut});
				FlxTween.tween(flames2, {y: -350}, 10, {ease: FlxEase.sineOut});

				FlxTween.tween(smoke, {alpha: 1}, 10);
				FlxTween.tween(flames, {alpha: 1}, 10);
				FlxTween.tween(flames2, {alpha: 1}, 10);
		}
	}

	override function eventPushed(event:objects.Note.EventNote)
	{
		// used for preloading assets used on events that doesn't need different assets based on its values
		switch(event.event)
		{
			case "burn with cone":
				precacheSound('boom');
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