// CODE FROM IMPOSTOR VE FOUR AA

package objects;

#if sys
import sys.io.File;
#end

import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import lime.utils.Assets;

class SongIntro extends FlxSpriteGroup
{
    var meta:Array<Array<String>> = [];
    var size:Float = 0;
    var fontSize:Int = 42;
    var colorText:FlxColor = 0xFFFFFFFF;

    public function new(_x:Float, _y:Float, _song:String, ?_numberThing:Int = -1) {

        super(_x, _y);


        var addToPath = "";
        if(_numberThing != -1){
            addToPath = "" + _numberThing;
        }

        var pulledText:String = Assets.getText(Paths.txt(_song.toLowerCase().replace(' ', '-') + "/info" + addToPath));
        pulledText += '\n';
        var splitText:Array<String> = [];
        
        splitText = pulledText.split('\n');
        splitText.resize(4);

        switch(_song)
        {
            case 'boom':
                color = 0xffff0000;
            case 'overfire':
                color = 0xffff7a00;
        }

        var text = new FlxText(850, 400, 0, "", 82);
        text.setFormat(Paths.font("HouseofTerror.ttf"), 100, color, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        text.borderSize = 4;

        var text2 = new FlxText(850, 650, 0, "", fontSize);
        text2.setFormat(Paths.font("HouseofTerror.ttf"), fontSize, FlxColor.WHITE, FlxTextAlign.RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

        var text3 = new FlxText(text2.x, text2.y + 60, 0, "", fontSize);
        text3.setFormat(Paths.font("HouseofTerror.ttf"), fontSize, FlxColor.WHITE, FlxTextAlign.RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

        var text4 = new FlxText(text2.x, text3.y + 60, 0, "", fontSize);
        text4.setFormat(Paths.font("HouseofTerror.ttf"), fontSize, FlxColor.WHITE, FlxTextAlign.RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

        text.text = splitText[0];
        text2.text = splitText[1];
        text3.text = splitText[2];
        text4.text = splitText[3];

        text.updateHitbox();
        text2.updateHitbox();
        text3.updateHitbox();
        text4.updateHitbox();

        size = text2.fieldWidth;
        
		var bg = new FlxSprite();
        bg.loadGraphic(Paths.image('song_credits', 'shared'));

        text.text += "\n";

        add(bg);
        add(text);
        add(text2);
        add(text3);
        add(text4);

        x -= 2000;
    }

    public function start(){
        FlxTween.tween(this, {x: -200}, 2, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween){
            FlxTween.tween(this, {x: -2000}, 2, {ease: FlxEase.backInOut, startDelay: 2, onComplete: function(twn:FlxTween){ 
                this.destroy(); 
            }});
        }});
    }
}