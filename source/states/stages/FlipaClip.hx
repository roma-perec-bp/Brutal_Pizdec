package states.stages;

import states.stages.objects.*;

class FlipaClip extends BaseStage
{
	public var grad:BGSprite;
	public var water:BGSprite;

	override function create()
	{
		var bg:BGSprite = new BGSprite('Sexy', -200, -200, 0, 0);
		add(bg);

		grad = new BGSprite('sexygradient', -200, 0, 0, 0);
		grad.alpha = 0.001;
		add(grad);
	}

	override function createPost()
	{
		water = new BGSprite('Flipaclip', 0, 600, 0, 0);
		water.scale.set(0.2, 0.2);
		add(water);
		water.cameras = [camHUD];
	}

	override function update(elapsed:Float)
	{
		var mult:Float = FlxMath.lerp(0.4, water.scale.x, FlxMath.bound(1 - (elapsed * 9 ), 0, 1));
		water.scale.set(mult, mult);
		water.updateHitbox();
	}

	override function beatHit()
	{
		water.scale.set(0.3, 0.3);
		water.updateHitbox();
	}
}