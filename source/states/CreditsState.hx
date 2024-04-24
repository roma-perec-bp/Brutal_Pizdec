package states;

import flash.text.TextField;
import flixel.util.FlxTimer;
import flixel.effects.FlxFlicker;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import sys.FileSystem;
import sys.io.File;
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;
import lime.utils.Assets;
import haxe.Json;
import flixel.addons.display.FlxBackdrop;

import flixel.input.mouse.FlxMouseButton;
typedef Socials =
{
    var youtube:String;
    var gamejolt:String;
    var twitter:String;
    var telegram:String;
}

typedef IconInfo =
{
    var picture:String;
    var nickname:String;
    var work:String;
    var wish:String;
    var socialnetwork:Socials;
}
typedef IconsFile =
{
    var icons:Array<IconInfo>;
}

class CreditsState extends MusicBeatState
{
    var all_icons:IconsFile;

    var curSelected:Int = 0;

    var name_text:FlxText;
    var desc_text:FlxText;

    var selectedSites:Bool = false;

    public var sprItemsGroup:FlxTypedGroup<FlxSprite>;
    public var sitesSprGroup:FlxTypedGroup<FlxSprite>;
    var fg_sites:FlxSprite;

    var flashBG:FlxSprite;

    var sites_changable:Array<String> = 
    [
        "y",
        "t1",
        "g",
        "t2"
    ];

    var sites:Array<Dynamic> = 
    [
        ["youtube", 507, 234],
        ["twitter", 654, 234],
        ["gamejolt", 507, 372],
        ["telegram", 654, 372]
    ];

	override function create()
    {
        var bg_2:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFA8A9B7);
        add(bg_2);
        
        all_icons = findJson();

        var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image("credits_pvz/bg"));
        bg.setGraphicSize(FlxG.width, FlxG.height);
        bg.antialiasing = ClientPrefs.data.antialiasing;
        add(bg);

		sprItemsGroup = new FlxTypedGroup<FlxSprite>();
		add(sprItemsGroup);

        for(k in 0...all_icons.icons.length)
        {
            var stupid:IconInfo = all_icons.icons[k];
            var spr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('credits_pvz/icons/${
                stupid.picture
            }'));
            var centX = (FlxG.width/2) - (spr.width /2);
            var centY = (FlxG.height/2) - (spr.height /2);
            spr.screenCenter();
            spr.ID = k;
            spr.antialiasing = ClientPrefs.data.antialiasing;
            spr.x = centX - (curSelected-spr.ID) * 300;
            sprItemsGroup.add(spr);
        }

        FlxG.mouse.visible = true;

        fg_sites = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
        fg_sites.alpha = 0.35;
        add(fg_sites);
        
		sitesSprGroup = new FlxTypedGroup<FlxSprite>();
		add(sitesSprGroup);

        for(w in 0...sites.length)
        {
            var site:FlxSprite = new FlxSprite(sites[w][1], sites[w][2]).loadGraphic(Paths.image('credits_pvz/buttons/${sites[w][0]}'));
            site.frames = Paths.getSparrowAtlas('credits_pvz/buttons/${sites[w][0]}');
            site.animation.addByPrefix('idle', '${sites[w][0]}_button', 24);
            site.animation.addByPrefix('pressed', 'pressed_${sites[w][0]}_button', 24);
            site.animation.play('idle');
            site.antialiasing = ClientPrefs.data.antialiasing;
            site.ID = w;
            sitesSprGroup.add(site);
        }

        var fg:FlxBackdrop = new FlxBackdrop(Paths.image("credits_pvz/fg"), 0, 0);
		fg.scrollFactor.set();
		fg.velocity.set(-35,0);
        fg.alpha = 0.5;
        fg.antialiasing = ClientPrefs.data.antialiasing;
        add(fg);

        name_text = new FlxText(10, 30, 1200, '', 56);
        name_text.setFormat(Paths.font("HouseofTerror.ttf"), 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        name_text.screenCenter(X);
        add(name_text);
                        
        var desc_text2:FlxText = new FlxText(0, FlxG.height-35, 1200, 'Press SPACE to find more information about that person!', 15);
        desc_text2.setFormat(Paths.font("HouseofTerror.ttf"), 15, 0xFF777777, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        desc_text2.screenCenter(X);
        add(desc_text2);

        desc_text = new FlxText(10, 645, 1200, '', 30);
        desc_text.setFormat(Paths.font("HouseofTerror.ttf"), 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        desc_text.screenCenter(X);
        add(desc_text);

        flashBG = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
    
        if(ClientPrefs.data.flashing) 
        {
            name_text.y -= 250;
            desc_text.y += 150;

            add(flashBG);
            new FlxTimer().start(1, function(tmr:FlxTimer)
            {
                FlxFlicker.flicker(flashBG, 1.1, 0.09, false, function(flick:FlxFlicker)
                {
                    FlxTween.tween(name_text, {y: name_text.y + 250 }, 0.4, {
                        ease: FlxEase.sineOut
                    });
                    FlxTween.tween(desc_text, {y: desc_text.y - 150 }, 0.4, {
                        ease: FlxEase.sineOut
                    });
                });
            });
        }

        changeSelection();

        super.create();
    }

    var textlength = 0;
    var chosen:Float = 0;

    function createStar(times:Int)
    {            
        var star:FlxSprite = new FlxSprite(FlxG.mouse.x, FlxG.mouse.y).loadGraphic(Paths.image('credits_pvz/icons/stars/star000' + FlxG.random.int(1,4)));
        star.acceleration.y = 700;
        star.velocity.y -= FlxG.random.int(100, 300);
        star.velocity.x -= FlxG.random.int(-200, 200);
        for(i in 0...times)
        {
            add(star);
        }

    }
    
    override function update(elapsed:Float)
    {
		var leftP = controls.UI_LEFT_P;
		var rightP = controls.UI_RIGHT_P;
        if(!selectedSites)
        {
            if (leftP)
            {
				FlxG.sound.play(Paths.sound('scrollMenu'));
                changeSelection(-1);
            }
            if (rightP)
            {
				FlxG.sound.play(Paths.sound('scrollMenu'));
                changeSelection(1);
            }
        }

        sitesSprGroup.forEach(function(spr:FlxSprite)
        {
            spr.visible = selectedSites;

            for(i in 0...sites_changable.length)
            {
                if(spr.ID == i)
                {
                    if(sites_changable[spr.ID] == null)
                    {
                        spr.color = 0xFF7D7D7D;
                    } else {
                        spr.color = 0xFFFFFFFF;
                        if(FlxG.mouse.justPressed && FlxG.mouse.overlaps(spr) && selectedSites == true)
                        {
                            CoolUtil.browserLoad(sites_changable[spr.ID]);
                        }
                    }
                }
            }

            if(FlxG.mouse.overlaps(spr))
            {
                spr.animation.play('pressed');
                spr.x = sites[spr.ID][1] + 5;
                spr.y = sites[spr.ID][2] + 5;
            } else {
                spr.animation.play('idle');
                spr.x = sites[spr.ID][1];
                spr.y = sites[spr.ID][2];
            }
        });

        if(FlxG.keys.justPressed.SPACE) 
        {
            selectedSites = !selectedSites;
            skufing();
        }
        
        fg_sites.visible = selectedSites;

		FlxG.camera.zoom = (FlxMath.lerp(1, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 8), 0, 1)));
        
        sprItemsGroup.forEach(function(spr:FlxSprite)
        {
            var centX = (FlxG.width/2) - (spr.width /2);
            var centY = (FlxG.height/2) - (spr.width /2);
            spr.x = FlxMath.lerp(spr.x, centX - (curSelected-spr.ID) * 300, CoolUtil.boundTo(elapsed * 10, 0, 1));

            var contrY = centY - Math.abs((curSelected-spr.ID))*150;

            spr.y = FlxMath.lerp(spr.y, 
                -contrY + 550,
            CoolUtil.boundTo(elapsed * 10, 0, 1));

            chosen = FlxG.mouse.overlaps(spr) ? 0.25 : 0;
            if(FlxG.mouse.overlaps(spr) && FlxG.mouse.justPressed && selectedSites == false)
            {
		        FlxG.camera.zoom = 1.025;
                spr.scale.set(3.65, 3.65);
                createStar(2);
                FlxG.sound.play(Paths.sound('credits_pvz/punch'));
            }

            spr.scale.set(
                spr.ID == curSelected ?
                    FlxMath.lerp(spr.scale.x, 3 + chosen, CoolUtil.boundTo(elapsed * 10.2, 0, 1))
                    :
                    FlxMath.lerp(spr.scale.x, 1, CoolUtil.boundTo(elapsed * 10.2, 0, 1)),
                spr.ID == curSelected ?
                    FlxMath.lerp(spr.scale.x, 3 + chosen, CoolUtil.boundTo(elapsed * 10.2, 0, 1))
                    :
                    FlxMath.lerp(spr.scale.x, 1, CoolUtil.boundTo(elapsed * 10.2, 0, 1))
            );

            if(curSelected == spr.ID)
            {
                spr.color = 0xFFFFFFFF;
            } else {
                spr.color = 0xFF7D7D7D;
            }
        });

        if (controls.BACK)
        {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            MusicBeatState.switchState(new MainMenuState());
        }

        super.update(elapsed);
    }
    
    function skufing()
    {
        var stupid:IconInfo = all_icons.icons[curSelected];
        var socials:Socials = stupid.socialnetwork;

        sites_changable = [];

        sites_changable[0] = socials.youtube;
        sites_changable[1] = socials.twitter;
        sites_changable[2] = socials.gamejolt;
        sites_changable[3] = socials.telegram;
    }

    static function findJson():IconsFile
    {
        var rawFile:String = null;
		var path:String = Paths.getPreloadPath('images/credits_pvz/data.json');
        
		if(Assets.exists(path)) {
			rawFile = Assets.getText(path);
		}
		else
		{
			return null;
		}
		return cast Json.parse(rawFile);
    }

    function changeSelection(changeInt:Int=0)
    {
        curSelected += changeInt;
        if(curSelected >= all_icons.icons.length) curSelected = 0;
        if(curSelected < 0) curSelected = all_icons.icons.length - 1;
        
        var stupid:IconInfo = all_icons.icons[curSelected];
        var socials:Socials = stupid.socialnetwork;

        name_text.text = stupid.nickname;
        name_text.screenCenter(X);

        desc_text.text = stupid.wish + " || " + stupid.work;
        desc_text.screenCenter(X);
    }
}