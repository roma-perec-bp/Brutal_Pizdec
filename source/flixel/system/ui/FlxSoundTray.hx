package flixel.system.ui;

import openfl.Assets;
#if FLX_SOUND_SYSTEM
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.system.FlxAssets;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
#if flash
import openfl.text.AntiAliasType;
import openfl.text.GridFitType;
#end

/**
 * The flixel sound tray, the little volume meter that pops down sometimes.
 * Accessed via `FlxG.game.soundTray` or `FlxG.sound.soundTray`.
 */
class FlxSoundTray extends Sprite
{
	/**
	 * Because reading any data from DisplayObject is insanely expensive in hxcpp, keep track of whether we need to update it or not.
	 */
	public var active:Bool;

	/**
	 * Helps us auto-hide the sound tray after a volume change.
	 */
	var _timer:Float;

	/**
	 * Helps display the volume bars on the sound tray.
	 */
	var _bars:Array<Bitmap>;

	/**
	 * How wide the sound tray background is.
	 */
	var _width:Int = 80;

	var _defaultScale:Float = 2.0;

	/**The sound used when increasing the volume.**/
	public var volumeUpSound:String = "assets/sounds/volume";

	/**The sound used when decreasing the volume.**/
	public var volumeDownSound:String = 'assets/sounds/volume';

	/**Whether or not changing the volume should make noise.**/
	public var silent:Bool = false;

	/**Yeah i can pretend i document my code too -lunar**/
	public var visual:Bool = true;

	var lerpYPos:Float = 0;
	var alphaTarget:Float = 0;

	var volumeMaxSound:String;

	/**
	 * Sets up the "sound tray", the little volume meter that pops down sometimes.
	 */
	@:keep
	public function new()
	{
		super();

		visible = false;
		scaleX = _defaultScale;
		scaleY = _defaultScale;

		var tmp:Bitmap = new Bitmap(new BitmapData(_width, 36, true, 0x7F000000));
		addChild(tmp);

		y = -height;
		visible = false;

		var text:TextField = new TextField();
		text.width = tmp.width;
		text.height = tmp.height;
		text.multiline = true;
		text.wordWrap = true;
		text.selectable = false;

		#if flash
		text.embedFonts = true;
		text.antiAliasType = AntiAliasType.NORMAL;
		text.gridFitType = GridFitType.PIXEL;
		#else
		#end
		
		var dtf:TextFormat = new TextFormat(Assets.getFont(Paths.font("HouseofTerror.ttf")).fontName, 7, 0xff61e31b);
		dtf.align = TextFormatAlign.CENTER;
		text.defaultTextFormat = dtf;
		addChild(text);
		text.text = "VOLUME";
		text.y = 20;

		var bx:Int = 10;
		var by:Int = 18;
		_bars = new Array();

		for (i in 0...10)
		{
			tmp = new Bitmap(FlxGradient.createGradientBitmapData(4, i + 1, [0xff00ff00, 0xff3ec60e, 0xff459310, 0xff3b670f, 0xff32450d]));
			tmp.x = bx;
			tmp.y = by;
			addChild(tmp);
			_bars.push(tmp);
			bx += 6;
			by--;
		}

		y = -height;
		screenCenter();

		volumeUpSound = 'Volup';
		volumeDownSound = 'Voldown';
		volumeMaxSound = 'VolMAX';
	}

	/**
	 * This function updates the soundtray object.
	 */
	public function update(MS:Float):Void
	{
		y = CoolUtil.coolLerp(y, lerpYPos, 0.1);
		alpha = CoolUtil.coolLerp(alpha, alphaTarget, 0.25);

		// Animate sound tray thing
		if (_timer > 0)
		{
			_timer -= (MS / 1000);
			alphaTarget = 1;
		}
		else if (y >= -height)
		{
			lerpYPos = -height - 10;
			alphaTarget = 0;
		}

		if (y <= -height)
		{
			visible = false;
			active = false;

			#if FLX_SAVE
			// Save sound preferences
			if (FlxG.save.isBound)
			{
				FlxG.save.data.mute = FlxG.sound.muted;
				FlxG.save.data.volume = FlxG.sound.volume;
				FlxG.save.flush();
			}
			#end
		}
	}

	/**
	 * Makes the little volume tray slide out.
	 *
	 * @param	up Whether the volume is increasing.
	 */
	public function show(up:Bool = false):Void
	{
		_timer = 1;
		lerpYPos = 10;
		visible = true;
		active = true;
		var globalVolume:Int = Math.round(FlxG.sound.volume * 10);

		if (FlxG.sound.muted)
		{
			globalVolume = 0;
		}

		if (!silent)
		{
			var sound = null;
			#if MODS_ALLOWED
			sound = getSound((up ? volumeUpSound : volumeDownSound)); // Paths.returnSound('sounds', 'sounds/soundtray/${up ? volumeUpSound : volumeDownSound}');
			#else
			sound = FlxAssets.getSound(up ? volumeUpSound : volumeDownSound);
			#end

			if (globalVolume == 10)
				sound = getSound(volumeMaxSound); // Paths.returnSound('sounds/soundtray/$volumeMaxSound');

			if (sound != null)
				FlxG.sound.load(sound).play();
		}

		for (i in 0..._bars.length)
		{
			if (i < globalVolume)
			{
				_bars[i].visible = true;
			}
			else
			{
				_bars[i].visible  = false;
			}
		}
	}

	// see the probl;em
	function getSound(path):openfl.media.Sound
	{
		final currentPsychEngineVersion:Int = Std.parseInt(states.MainMenuState.psychEngineVersion);

		final key:String = 'soundtray/$path';
		return Paths.returnSound('sounds', key);

		// make sure the engine version doesn't have any letters in it.
	}

	public function screenCenter():Void
	{
		scaleX = _defaultScale;
		scaleY = _defaultScale;

		x = (0.5 * (Lib.current.stage.stageWidth - _width * _defaultScale) - FlxG.game.x);
	}
}
#end