package states;

import flixel.group.FlxGroup;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import lime.app.Application;
import flixel.util.FlxColor;
import flixel.input.keyboard.FlxKey;
import flixel.group.FlxGroup.FlxTypedGroup;

import backend.Achievements;
import objects.AttachedAchievement;
import flixel.addons.display.FlxBackdrop;


class AchievementsStatePVZ extends MusicBeatState
{
    var bgScroll:FlxBackdrop;
    var amountText:FlxText;

	var options:Array<String> = [];
	private var achievementIndex:Array<Int> = [];

	private var achievementArray:Array<Dynamic> = [];

	var iconsAchievementsGroup:FlxTypedGroup<Dynamic>;
	var attachedTextGroup:FlxTypedGroup<FlxOffsetText>;

	var upArrow:FlxSprite;
	var downArrow:FlxSprite;

	var allsum:Int = 0;
	var unlockedSum:Int = 0;

	override function create()
    {
		bgScroll = new FlxBackdrop(Paths.image('achieve_PVZ/bg'), 0, 0);
		bgScroll.screenCenter();
		add(bgScroll);
		
		iconsAchievementsGroup = new FlxTypedGroup<Dynamic>();
		add(iconsAchievementsGroup);

		attachedTextGroup = new FlxTypedGroup<FlxOffsetText>();
		add(attachedTextGroup);
        
		for (i in 0...Achievements.achievementsStuff.length) {
			if(!Achievements.achievementsStuff[i][3] || Achievements.achievementsMap.exists(Achievements.achievementsStuff[i][2])) {
				options.push(Achievements.achievementsStuff[i]);
				achievementIndex.push(i);
			}
		}

		for (i in 0...options.length) {
			var achieveName:String = Achievements.achievementsStuff[achievementIndex[i]][2];
			var achieveNameIcon:String = Achievements.achievementsStuff[achievementIndex[i]][0];
			var achieveDescIcon:String = Achievements.achievementsStuff[achievementIndex[i]][1];

			var black:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 200, 0xFF000000);
			black.y = (FlxG.height/2 - (200 / 2)) + (FlxG.height * i);
			black.ID = i;
			black.alpha = 0.5;
			iconsAchievementsGroup.add(black);

			var icon:AttachedAchievement = new AttachedAchievement(100, 0, achieveName);
			icon.ID = i;
			icon.scale.x = 1.1;
			icon.scale.y = 1.1;

			var centY = FlxG.height/2 - (icon.height / 2);
			icon.y = centY + (FlxG.height * i);
			iconsAchievementsGroup.add(icon);

			var nameText = new FlxOffsetText(0, 0, 800, achieveNameIcon, 56, 0, -70, true);
			nameText.setFormat(Paths.font("HouseofTerror.ttf"), 56, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			nameText.screenCenter(X);
			nameText.x += 45;
			nameText.y = FlxG.height/2 + (FlxG.height * i) + nameText.offsetY;
			nameText.ID = i;
			attachedTextGroup.add(nameText);

			var descText = new FlxOffsetText(0, 0, 800, achieveDescIcon, 56, 0, 20);
			descText.setFormat(Paths.font("HouseofTerror.ttf"), 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			descText.screenCenter(X);
			descText.x += 45;
			descText.y = FlxG.height/2 + (FlxG.height * i) + descText.offsetY;
			descText.ID = i;
			attachedTextGroup.add(descText);

			var scoreNumberText = new FlxOffsetText(FlxG.width - 5, 0, 800, achieveDescIcon, 56, 0, 20);
			scoreNumberText.setFormat(Paths.font("HouseofTerror.ttf"), 40, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			scoreNumberText.y = FlxG.height/2 + (FlxG.height * i) + scoreNumberText.offsetY;
			scoreNumberText.ID = i;
			attachedTextGroup.add(scoreNumberText);
		}

		upArrow = new FlxSprite(1136, 15).loadGraphic(Paths.image("achieve_PVZ/up_arrow"));
		upArrow.frames = Paths.getSparrowAtlas("achieve_PVZ/up_arrow");
		upArrow.animation.addByPrefix('idle', "up_arrow_idle", 24);
		upArrow.animation.addByPrefix('pressed', "up_arrow_pressed", 24, false);
		upArrow.animation.play('idle');
		add(upArrow);
		
		downArrow = new FlxSprite(1136, 569).loadGraphic(Paths.image("achieve_PVZ/up_arrow"));
		downArrow.frames = Paths.getSparrowAtlas("achieve_PVZ/up_arrow");
		downArrow.animation.addByPrefix('idle', "up_arrow_idle", 24);
		downArrow.animation.addByPrefix('pressed', "up_arrow_pressed", 24, false);
		downArrow.animation.play('idle');
		downArrow.flipY = true;
		add(downArrow);

        amountText = new FlxText(6, FlxG.height - 46, 0, '', 35);
        amountText.setFormat(Paths.font("HouseofTerror.ttf"), 35, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(amountText);

		for(j in 0...Achievements.achievementsStuff.length)
		{
			allsum ++;
			if(Achievements.isAchievementUnlocked(Achievements.achievementsStuff[j][2])) unlockedSum++;
		}

		amountText.text = Std.string(unlockedSum)+'/'+Std.string(allsum);

        super.create();
    }
    var yAdd = 0;

    override function update(elapsed:Float)
    {
        bgScroll.y = FlxMath.lerp(bgScroll.y, -(bgScroll.height * yAdd), CoolUtil.boundTo(elapsed * 10.2, 0, 1));

		upArrow.animation.play('idle');
		downArrow.animation.play('idle');

		if (controls.UI_UP_P || FlxG.mouse.wheel > 0) {
            FlxG.sound.play(Paths.sound('scrollMenu'));
			upArrow.animation.play('pressed');
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P || FlxG.mouse.wheel < 0) {
            FlxG.sound.play(Paths.sound('scrollMenu'));
			downArrow.animation.play('pressed');
			changeSelection(1);
		}

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

        
        iconsAchievementsGroup.forEach(function(icon:Dynamic)
		{	
			var centY = FlxG.height/2 - (icon.height / 2);
			icon.y = FlxMath.lerp(icon.y, centY - (yAdd-icon.ID) * FlxG.height, CoolUtil.boundTo(elapsed * 10.2, 0, 1));
		});

		attachedTextGroup.forEach(function(t:FlxOffsetText)
		{
			var centY = FlxG.height/2;
			t.y = FlxMath.lerp(t.y, 
				centY - (yAdd-t.ID) * FlxG.height + t.offsetY, 
			CoolUtil.boundTo(elapsed * 10.2, 0, 1));
		});
	

        super.update(elapsed);
    }
	
    function changeSelection(changeInt:Int=0)
    {
        yAdd += changeInt;
		if (yAdd < 0)
			yAdd = 0;
		if (yAdd >= options.length)
			yAdd = options.length - 1;
    }
}

class FlxOffsetText extends FlxText
{
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var type:Bool = false;
	public function new(x:Float, y:Float, length:Float, text:String = "", size:Int, ?offsetX:Float = 0, ?offsetY:Float = 0, ?type:Bool = false)
	{
		super(x, y, length, text, size);
		this.offsetX = offsetX;
		this.offsetY = offsetY;
		this.type = type;
	}

	override function update(el:Float)
	{
		if(type == true)
		{
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[this.ID][2]))
			{
				var curText = this.text;
				this.text = "";
				for(j in 0...curText.length)
				{
					if(curText.charAt(j) != " ")
					{
						this.text += "?";
					} else {
						this.text += " ";
					}
				}
			} else {
				this.color = 0xFFFFDD00;
			}
		}
		super.update(el);
	}
}