package states;

import flixel.FlxSubState;

import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.input.keyboard.FlxKey;

import backend.Achievements;

class TestState extends MusicBeatState
{
	var amountText:FlxText;
	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);
		
        amountText = new FlxText(6, 50, 0, '', 20);
        add(amountText);
	}

	function press()
	{
		Achievements.setAchievementCurNum('test123', 
			Achievements.getAchievementCurNum('test123') + 1
		);
		if(Achievements.getAchievementCurNum('test123') >= Achievements.achievementsStuff[Achievements.getAchievementIndex('test123')][4])
		{
			Achievements.unlockAchievement('test123');
			ClientPrefs.saveSettings();
		}
	}

	override function update(elapsed:Float)
	{
		amountText.text = Std.string(Achievements.getAchievementCurNum('test123')) + "/" + Std.string(
			Achievements.achievementsStuff[Achievements.getAchievementIndex('test123')][4]
		);	

		if(FlxG.keys.justPressed.SPACE) press();
		
		super.update(elapsed);
	}
}
