package objects;

class AnekdotNote extends FlxSprite
{
	public function new(char:Character, dataNote:Int) {
		super(x, y);
		frames = Paths.getSparrowAtlas('noteAnekdot/note_'+FlxG.random.int(0, 5));
		animation.addByPrefix('hit', 'hitNote', 24, false);
		antialiasing = ClientPrefs.data.antialiasing;
		color = Std.parseInt(char.arrowColor[dataNote][FlxG.random.int(0,2,[1])]);

		angle = -4;
		new FlxTimer().start(0.01, function(tmr:FlxTimer)
		{
			if (angle == -4) FlxTween.angle(this, angle, 4, 0.4, {ease: FlxEase.quartInOut});
			if (angle == 4) FlxTween.angle(this, angle, -4, 0.4, {ease: FlxEase.quartInOut});
		}, 0);

		animation.play('hit');
	}

	override public function destroy()
	{
		FlxTween.cancelTweensOf(this);
		super.destroy();
	}
}