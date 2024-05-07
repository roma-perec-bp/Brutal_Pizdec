package states.stages;

import states.stages.objects.*;
import objects.Character;

class Void extends BaseStage
{
	public var jumpScare:FlxSprite;

	override function create()
	{
		game.skipCountdown = true;
		setStartCallback(startCut);
	}

	override function createPost()
	{
		jumpScare = new FlxSprite().loadGraphic(Paths.image('aaaaaa'));
		jumpScare.setGraphicSize(Std.int(FlxG.width * jumpscareSizeInterval), Std.int(FlxG.height * jumpscareSizeInterval));
		jumpScare.updateHitbox();
		jumpScare.screenCenter();
		jumpScare.visible = false;
		add(jumpScare);
		jumpScare.cameras = [camOther];

		PlayState.instance.dad.alpha = 0.001;
	}

	function startCut()
	{
		/*FlxG.sound.play(Paths.sound('dead' + FlxG.random.int(0, 69)), 1, false, null, true, function() {
			startCountdown();
		});*/

		FlxG.sound.play(Paths.sound('dead'), 1, false, null, true, function() {
			FlxTween.tween(PlayState.instance.dad, {alpha: 1}, 0.8);
			startCountdown();
		});
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
				game.health -= FlxG.random.float(0.2, 0.7);

				FlxG.camera.zoom += 0.069;
				camHUD.zoom += 0.07;
		}
	}

	var jumpscareSizeInterval:Float = 0.879;

	function jumpscare(duration:Float) {
		// jumpscare
		if (ClientPrefs.data.flashing) {
				jumpScare.visible = true;
				jumpScare.alpha = FlxG.random.float(0.6, 1);
				camOther.shake(0.0125 * (jumpscareSizeInterval / 2), (((!Math.isNaN(duration)) ? duration : 1) * Conductor.stepCrochet) / 1000, 
					function(){
						jumpScare.visible = false;
						jumpScare.setGraphicSize(Std.int(FlxG.width * jumpscareSizeInterval), Std.int(FlxG.height * jumpscareSizeInterval));
						jumpScare.updateHitbox();
						jumpScare.screenCenter();
					}, true
				);
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