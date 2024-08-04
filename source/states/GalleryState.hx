package states;

import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import lime.app.Application;
import states.editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;
import openfl.utils.Assets;
import sys.FileSystem;
import sys.io.File;

import flixel.addons.display.FlxBackdrop;

class GalleryState extends MusicBeatState
{
    var images = [];
    var paths = ["Arts", "Memes", "Other"];
    var name:FlxText; 
    var author:FlxText;
    var pathname:FlxText;

    var debug:FlxText;

    var mouseWheel:Float = 0;

    var curSelected:Int = 0;
    public var sprItemsGroup:FlxTypedGroup<FlxSprite>;

	override function create()
    {
        var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image("gallery_pvz/bg"));
        add(bg);

        for(j in 0...paths.length)
        {
            for (i in FileSystem.readDirectory(FileSystem.absolutePath('assets/images/gallery_pvz/${
                paths[j].toLowerCase()
            }')))
            {
                var text:String = i.substring(0, i.indexOf('.png'));
                images.push(text);
            }
        }

        FlxG.mouse.visible = true;

		sprItemsGroup = new FlxTypedGroup<FlxSprite>();
		add(sprItemsGroup);

        var curID:Int = -1;
        
        for(j in 0...paths.length)
        {
            for(k in 0...images.length)
            {
                var image:String = images[k];
                var delimiterIndex:Int = image.indexOf("$");
                if (FileSystem.exists(Paths.getPath('images/gallery_pvz/${paths[j].toLowerCase()}/' +image+'.png')))
                {
                    curID += 1;
                    var spr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gallery_pvz/${paths[j].toLowerCase()}/' + 
                        image
                    ));
                    spr.scale.set(0.5, 0.5);
                    spr.updateHitbox();
                    spr.screenCenter();
                    spr.alpha = 0;
                    spr.ID = curID;
                    sprItemsGroup.add(spr);
                }

            }
        };

        name = new FlxText(0, 25, 0, "", 55);
		name.text = "Hello";
		name.setFormat(Paths.font("HouseofTerror.ttf"), 45, 0xFFFFFF, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		name.borderSize = 3;
		name.screenCenter(X);
		add(name);
        
        author = new FlxText(0, 65, 0, "", 35);
		author.text = "Hello";
		author.setFormat(Paths.font("HouseofTerror.ttf"), 30, 0xFFFFFF, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		author.borderSize = 3;
		author.screenCenter(X);
		add(author);
        
        pathname = new FlxText(0, FlxG.height - 85, 0, "", 35);
		pathname.text = "Hello";
		pathname.setFormat(Paths.font("HouseofTerror.ttf"), 45, 0xFFFFFF, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		pathname.borderSize = 3;
		pathname.screenCenter(X);
		add(pathname);

        debug = new FlxText(5, 5, 0, "You can use the mouse wheel to zoom in and out of the picture!", 55);
		debug.setFormat(Paths.font("HouseofTerror.ttf"), 15, 0xFFFFFF, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        debug.alpha = 0.7;
        debug.screenCenter(X);
		debug.borderSize = 1.5;
		add(debug);
        
        changeButtons();
        name.screenCenter(X);
        author.screenCenter(X);
        pathname.screenCenter(X);

        
		FlxG.sound.playMusic(Paths.music('gallerymenu'), 1, true);

        super.create();
    }

    override function update(elapsed:Float) 
    {
        if(controls.UI_LEFT_P) 
        {
            changeButtons(-1);
            name.screenCenter(X);
            author.screenCenter(X);
            pathname.screenCenter(X);
            FlxG.sound.play(Paths.sound('scrollMenu'));
        }
        
        if(controls.UI_RIGHT_P) 
        {
            changeButtons(1);
            name.screenCenter(X);
            author.screenCenter(X);
            pathname.screenCenter(X);
            FlxG.sound.play(Paths.sound('scrollMenu'));
        }

        sprItemsGroup.forEach(function(spr:FlxSprite)
        {
            var centX = (FlxG.width/2) - (spr.width /2);
            var centY = (FlxG.height/2) - (spr.height /2);
            spr.x = FlxMath.lerp(spr.x, centX - (curSelected-spr.ID) * 800, CoolUtil.boundTo(elapsed * 10, 0, 1));
            spr.scale.set(
                spr.ID == curSelected ?
                    FlxMath.lerp(spr.scale.x, 0.75 + mouseWheel, CoolUtil.boundTo(elapsed * 10.2, 0, 1))
                    :
                    FlxMath.lerp(spr.scale.x, 0.3, CoolUtil.boundTo(elapsed * 10.2, 0, 1)),
                spr.ID == curSelected ?
                    FlxMath.lerp(spr.scale.x, 0.75 + mouseWheel, CoolUtil.boundTo(elapsed * 10.2, 0, 1))
                    :
                    FlxMath.lerp(spr.scale.x, 0.3, CoolUtil.boundTo(elapsed * 10.2, 0, 1))
            );
            spr.alpha = (
                spr.ID == curSelected ?
                    FlxMath.lerp(spr.alpha, 1, CoolUtil.boundTo(elapsed * 5, 0, 1))
                    :
                    FlxMath.lerp(spr.alpha, 0.25, CoolUtil.boundTo(elapsed * 5, 0, 1))
            );
        });

        mouseWheel += (FlxG.mouse.wheel / 10);

        if(controls.BACK)
        {
            FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7, true);
            MusicBeatState.switchState(new MainMenuState());
        }

        super.update(elapsed);
    }

    function changeButtons(index:Int = 0)
    {
        curSelected += index;

        if (curSelected >= images.length)
            curSelected = 0;
        if (curSelected < 0)
            curSelected = images.length - 1;

        restartText(images[curSelected]);

        mouseWheel -= mouseWheel;
    }

    function restartText(image:String)
    {
        var delimiterIndex:Int = image.indexOf("$");
        var delimiterIndex2:Int = image.indexOf(".png");

        var picturename:String = image.substring(0, delimiterIndex);
        var authorname:String = image.substring(delimiterIndex + 1);

        name.text = picturename;
        author.text = "By: " + authorname;

        for(j in 0...paths.length)
        {
            if (FileSystem.exists(Paths.getPath('images/gallery_pvz/${paths[j].toLowerCase()}/'+image+'.png')))
            {
                pathname.text = paths[j];
            }
        }
    }
}