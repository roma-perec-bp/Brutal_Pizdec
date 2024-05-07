package states.stages;

import states.stages.objects.*;

class FlipaClip extends BaseStage
{
	public var bg:BGSprite;
	public var grad:BGSprite;
	public var water:BGSprite;

	override function create()
	{
		bg = new BGSprite('Sexy', -200, -200, 0, 0);
		add(bg);

		grad = new BGSprite('sexygradient', -200, -650, 0, 0);
		grad.alpha = 0.001;
		add(grad);
	}

	override function createPost()
	{
		water = new BGSprite('Flipaclip', 0, 550, 0, 0);
		water.scale.set(0.2, 0.2);
		add(water);
		water.cameras = [camHUD];
	}

	override function update(elapsed:Float)
	{
		var mult:Float = FlxMath.lerp(0.2, water.scale.x, FlxMath.bound(1 - (elapsed * 9 ), 0, 1));
		water.scale.set(mult, mult);
		water.updateHitbox();
	}

	override function beatHit()
	{
		water.scale.set(0.25, 0.25);
		water.updateHitbox();
	}

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case 'BBG BG':
				FlxTween.tween(bg, {alpha: 0}, 20);
				FlxTween.tween(grad, {alpha: 1}, 20);
		}
	}
}