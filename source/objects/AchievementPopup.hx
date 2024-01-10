package objects;

import backend.Achievements;

class AchievementPopup extends FlxSpriteGroup {
	public var onFinish:Void->Void = null;
	var alphaTween:FlxTween;
	public function new(name:String, ?camera:FlxCamera = null)
	{
		super(x, y);
		ClientPrefs.saveSettings();

		var id:Int = Achievements.getAchievementIndex(name);
		var achievementBG:FlxSprite = new FlxSprite(0, FlxG.height - 156).makeGraphic(420, 156, FlxColor.BLACK);
		achievementBG.alpha = 0.6;
		achievementBG.scrollFactor.set();

		var achievementName:FlxText = new FlxText(0, 600, 280, Achievements.achievementsStuff[id][0] + 'Achievement!', 16);
		achievementName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT);
		achievementName.scrollFactor.set();

		add(achievementBG);
		add(achievementName);

		var cam:Array<FlxCamera> = FlxCamera.defaultCameras;
		if(camera != null) {
			cam = [camera];
		}
		achievementBG.cameras = cam;
		achievementName.cameras = cam;
		alphaTween = FlxTween.tween(this, {alpha: 0}, 0.5, {
			startDelay: 2.5,
			onComplete: function(twn:FlxTween) {
				alphaTween = null;
				remove(this);
				if(onFinish != null) onFinish();
			}
		});
	}

	override function destroy() {
		if(alphaTween != null) {
			alphaTween.cancel();
		}
		super.destroy();
	}
}