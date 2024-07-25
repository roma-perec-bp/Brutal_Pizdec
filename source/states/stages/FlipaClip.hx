package states.stages;

import states.stages.objects.*;
import substates.GameOverSubstate;

class FlipaClip extends BaseStage
{
	public var bg:BGSprite;
	public var grad:BGSprite;
	public var water:BGSprite;

	override function create()
	{
		var _song = PlayState.SONG;
		GameOverSubstate.deathSoundName = 'fnf_loss_sfx_notBf';
		
		bg = new BGSprite('Sexy', -200, -200, 0, 0);
		add(bg);

		grad = new BGSprite('sexygradient', -200, -1600, 0, 0);
		grad.alpha = 0.001;
		add(grad);
	}

	override function createPost()
	{
		if(!ClientPrefs.data.lowQuality) { // у меня с этим лагает
		water = new BGSprite('Flipaclip', 0, 550, 0, 0);
		water.setGraphicSize(Std.int(water.width * 0.22));
		water.scale.set(0.2, 0.2);
		add(water);
		water.cameras = [camHUD];
		}
	}

	override function update(elapsed:Float)
	{
		//var mult:Float = FlxMath.lerp(0.22, flipaclip.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * game.playbackRate), 0, 1));
		var mult:Float = FlxMath.lerp(0.2, water.scale.x, FlxMath.bound(1 - (elapsed * 9 ), 0, 1));
		water.scale.set(mult, mult);
		water.updateHitbox();
	}

	override function beatHit()
	{
		water.scale.set(0.25, 0.25);
		water.updateHitbox();
		water.setPosition(-415 - ((276 * water.scale.x - 276) * 2), 350 - ((138 * water.scale.y - 138) * 2));
	}

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case 'BBG BG':
				FlxTween.tween(bg, {alpha: 0}, 20);
				FlxTween.tween(grad, {alpha: 1, y: -200}, 20);
		}
	}
}