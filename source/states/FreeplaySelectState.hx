package states;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.effects.FlxFlicker;
import states.MainMenuState;
import states.FreeplayState;

class FreeplaySelectState extends MusicBeatState{
    public static var freeplayCats:Array<String> = ['story', 'bonus', 'cover', 'old'];
	var grpCats:FlxTypedGroup<Alphabet>;
	static var curSelected:Int = 0;
	public var sprItemsGroup:FlxTypedGroup<FlxSprite>;
	var BG:FlxSprite;

	var leftArrows:FlxSprite;
	var rightArrows:FlxSprite;

	var disableInput:Bool = false;

	var cantTouchYet:Bool = false;
    override function create(){
		final ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');

        BG = new FlxSprite().loadGraphic(Paths.image('freeplay/bg'));
		BG.updateHitbox();
		BG.screenCenter();
		BG.scale.set(0.75, 0.75);
		BG.y = -450;
		add(BG);

		sprItemsGroup = new FlxTypedGroup<FlxSprite>();
		add(sprItemsGroup);

		var curID:Int = -1;
		for(lmol in 0...freeplayCats.length)
        {
			curID += 1;
			var spr:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('freeplay/'+ freeplayCats[lmol]));
			spr.scale.set(0.5, 0.5);
            spr.screenCenter(X);
			spr.updateHitbox();
			spr.alpha = 0;
			spr.ID = curID;
			sprItemsGroup.add(spr);
		}

		if (leftArrows == null){
			leftArrows = new FlxSprite(10, 300);
			leftArrows.antialiasing = ClientPrefs.data.antialiasing;
			leftArrows.frames = ui_tex;
			leftArrows.animation.addByPrefix('idle', "arrow left");
			leftArrows.animation.addByPrefix('press', "arrow push left");
			leftArrows.animation.play('idle');
		}
		add(leftArrows);

		if (rightArrows == null){
			rightArrows = new FlxSprite(leftArrows.x + 1210, leftArrows.y);
			rightArrows.antialiasing = ClientPrefs.data.antialiasing;
			rightArrows.frames = ui_tex;
			rightArrows.animation.addByPrefix('idle', 'arrow right');
			rightArrows.animation.addByPrefix('press', "arrow push right", 24, false);
			rightArrows.animation.play('idle');
		}
		add(rightArrows);

        changeSelection();
        super.create();

		FlxG.camera.zoom = 3;
		FlxTween.tween(FlxG.camera, {zoom: 1}, 1, {ease: FlxEase.expoInOut});
    }

    override public function update(elapsed:Float){
        
		if (!disableInput)
		{
			FlxG.camera.scroll.x = FlxMath.lerp(FlxG.camera.scroll.x, (FlxG.mouse.screenX-(FlxG.width/2)) * 0.015, (1/30)*240*elapsed);
			FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, (FlxG.mouse.screenY-6-(FlxG.height/2)) * 0.015, (1/30)*240*elapsed);
			
			if (controls.UI_LEFT_P || FlxG.mouse.overlaps(leftArrows) && FlxG.mouse.justPressed)
				changeSelection(-1);
			if (controls.UI_RIGHT_P || FlxG.mouse.overlaps(rightArrows) && FlxG.mouse.justPressed) 
				changeSelection(1);
			if (controls.BACK) {
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}
			if(FlxG.mouse.wheel != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
				changeSelection(-FlxG.mouse.wheel);
			}

			if (controls.ACCEPT && !cantTouchYet){
				pressed();
			}

			sprItemsGroup.forEach(function(spr:FlxSprite)
			{
				if(FlxG.mouse.overlaps(spr) && spr.ID == curSelected && FlxG.mouse.justPressed && !cantTouchYet)
					pressed();
			});

			if (controls.UI_RIGHT || FlxG.mouse.overlaps(rightArrows))
				rightArrows.animation.play('press')
			else
				rightArrows.animation.play('idle');
	
			if (controls.UI_LEFT || FlxG.mouse.overlaps(leftArrows))
				leftArrows.animation.play('press');
			else
				leftArrows.animation.play('idle');
		}

		sprItemsGroup.forEach(function(spr:FlxSprite)
        {
            var cent = (FlxG.width/2) - (spr.width /2);
            spr.x = FlxMath.lerp(spr.x, cent - (curSelected-spr.ID) * 500, CoolUtil.boundTo(elapsed * 10, 0, 1));
            spr.scale.set(
                spr.ID == curSelected ?
                    FlxMath.lerp(spr.scale.x, 0.35, CoolUtil.boundTo(elapsed * 10.2, 0, 1))
                    :
                    FlxMath.lerp(spr.scale.x, 0.25, CoolUtil.boundTo(elapsed * 10.2, 0, 1)),
                spr.ID == curSelected ?
                    FlxMath.lerp(spr.scale.x, 0.35, CoolUtil.boundTo(elapsed * 10.2, 0, 1))
                    :
                    FlxMath.lerp(spr.scale.x, 0.25, CoolUtil.boundTo(elapsed * 10.2, 0, 1))
            );
            spr.alpha = (
                spr.ID == curSelected ?
                    FlxMath.lerp(spr.alpha, 1, CoolUtil.boundTo(elapsed * 5, 0, 1))
                    :
                    FlxMath.lerp(spr.alpha, 0.6, CoolUtil.boundTo(elapsed * 5, 0, 1))
            );
        });
		BG.x = FlxMath.lerp(BG.x, -650 - curSelected * 500, CoolUtil.boundTo(elapsed * 5, 0, 1));
        FreeplayState.freeplayType = curSelected;

        super.update(elapsed);
    }

	function pressed()
	{
		disableInput = true;
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		if(ClientPrefs.data.camZooms) FlxTween.tween(FlxG.camera, {zoom:1.2}, 0.3, {ease: FlxEase.quadOut});
		FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);
		FlxFlicker.flicker(sprItemsGroup.members[curSelected], 1, 0.06, true, false, function(flick:FlxFlicker)
		{
			MusicBeatState.switchState(new FreeplayState());
		});
	}

    function changeSelection(change:Int = 0) {
		cantTouchYet = true;
		curSelected += change;
		if (curSelected < 0)
			curSelected = freeplayCats.length - 1;
		if (curSelected >= freeplayCats.length)
			curSelected = 0;

		var bullShit:Int = 0;

		new FlxTimer().start(0.5, function(tmr:FlxTimer) {
			cantTouchYet = false;
		});

		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}