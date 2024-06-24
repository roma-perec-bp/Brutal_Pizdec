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
    var fontSize:Int = 48;
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
            case 't-short':
                color = 0xff1e1d2b;
            case 'klork' | 'klork-old':
                color == 0xff8cd485;
            case 'monochrome':
                color == 0xff3f3f3f;
            case 's6x-boom':
                color == 0xffec0063;
        }

        var text = new FlxText(780, 400, 0, "", 82);
        text.setFormat(Paths.font("HouseofTerror.ttf"), 100, color, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        text.borderSize = 4;

        var text2 = new FlxText(790, 600, 0, "", fontSize);
        text2.setFormat(Paths.font("HouseofTerror.ttf"), fontSize, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

        var text3 = new FlxText(text2.x, text2.y + 60, 0, "", fontSize - 20);
        text3.setFormat(Paths.font("HouseofTerror.ttf"), fontSize, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

        var text4 = new FlxText(text2.x, text3.y + 60, 0, "", fontSize);
        text4.setFormat(Paths.font("HouseofTerror.ttf"), fontSize, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

        text.text = splitText[0];
        text2.text = splitText[1];
        text3.text = splitText[2];
        text4.text = splitText[3];

        var songNameTxt:String = text.text;
        var tooLong:Float = (songNameTxt.length > 9) ? 0.8 : 1;
        text.scale.x = tooLong;

        var composerText:String = text2.text;
        var tooLong2:Float = (composerText.length > 27) ? 0.65 : 1;
        text2.scale.x = tooLong2;

        var charterText:String = text3.text;
        var tooLong3:Float = (charterText.length > 27) ? 0.65 : 1;
        text3.scale.x = tooLong3;

        var scriptsText:String = text4.text;
        var tooLong4:Float = (scriptsText.length > 27) ? 0.65 : 1;
        text4.scale.x = tooLong4;

        text.updateHitbox();
        text2.updateHitbox();
        text3.updateHitbox();
        text4.updateHitbox();
        
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
            FlxTween.tween(this, {x: -2000}, 2, {ease: FlxEase.backInOut, startDelay: 1.5, onComplete: function(twn:FlxTween){ 
                this.destroy(); 
            }});
        }});
    }
}