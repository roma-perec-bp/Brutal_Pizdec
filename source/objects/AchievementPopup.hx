package objects;

import backend.Achievements;
import states.EndState;

class AchievementPopup extends FlxSpriteGroup {
	public var onFinish:Void->Void = null;
	public function new(name:String, ?camera:FlxCamera = null)
	{
		super(x, y);
		
		Achievements.achDone++;
		ClientPrefs.saveSettings();

		var id:Int = Achievements.getAchievementIndex(name);
		var achievementBG:FlxSprite = new FlxSprite(0, FlxG.height - 200).makeGraphic(FlxG.width, 150, FlxColor.BLACK);
		achievementBG.alpha = 0.6;
		achievementBG.scrollFactor.set();

		var achievementName:FlxText = new FlxText(0, 565, 0, Achievements.achievementsStuff[id][0] + ' Achievement!', 42);
		achievementName.setFormat(Paths.font("HouseofTerror.ttf"), 42, 0xffdfd383, CENTER);
		achievementName.screenCenter(X);
		achievementName.scrollFactor.set();

		add(achievementBG);
		add(achievementName);

		FlxTween.tween(achievementName, {alpha: 0.6}, 0.3, {type: FlxTweenType.PINGPONG});

		var cam:Array<FlxCamera> = FlxCamera.defaultCameras;
		if(camera != null) {
			cam = [camera];
		}
		achievementBG.cameras = cam;
		achievementName.cameras = cam;

		new FlxTimer().start(4, function(tmr:FlxTimer)
		{
			FlxTween.cancelTweensOf(achievementName);
			this.alpha = 0;
			remove(this);
			if(onFinish != null) onFinish();

			if(Achievements.achDone == 23)
			{
				if(ClientPrefs.data.ends[6] == 0)
				{
					EndState.end = 6;
					EndState.gift = true;
					MusicBeatState.switchState(new EndState());
				}
			}
		});
	}
}