/*
 * WARNING: USES PSYCH ENGINE 0.7.1 / 0.7.1h ONLY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 * Author: TheLeerName
 * Description: script for fix bug with runHaxeCode bugs
 * 
 * To use: just put it in your scripts folder and it will automatically fix all loaded lua files
 *   - if you add it in mods/data/<songname>, it will fix scripts only in this folder (cuz load scripts order: mods/scripts -> mods/data/<songname> -> mods/characters)
 *   - will fix script even if added with addLuaScript
 *   - not use your runHaxeCode's in onCreate() callback (otherwise it will return only nil)
 *   - not change name of script (it need for load order)
 */

import states.MainMenuState;

import psychlua.HScript;
import psychlua.LuaUtils;
import psychlua.FunkinLua;

import tea.SScript;

import backend.CoolUtil;

// ignoring fix for other versions
if (!StringTools.startsWith(MainMenuState.psychEngineVersion, "0.7.1")) return;

var changeHandler:Int = 0;
function onCreate() {
	changeHandler = game.luaArray.length;
	for (i in CoolUtil.numberArray(game.luaArray.length, 0)) // wtf?????? for cycle not working normally
		runHaxeCodeFix(i);
}

// fixing rhc for scripts which was added with addLuaScript
function onUpdate(elapsed:Float) {
	if (changeHandler != game.luaArray.length) {
		changeHandler = game.luaArray.length;
		runHaxeCodeFix(game.luaArray.length - 1);
	}
}

// welcome to ctrl+c ctrl+v dimension
function runHaxeCodeFix(index:Int) {
	var funk = game.luaArray[index];

	funk.addLocalCallback("runHaxeCode", function(codeToRun:String, ?varsToBring:Any = null, ?funcToRun:String = null, ?funcArgs:Array<Dynamic> = null) {
		var retVal = null;
		HScript.initHaxeModule(funk);
		funk.hscript.doString(codeToRun);
		if(varsToBring != null)
		{
			for (key in Reflect.fields(varsToBring))
			{
				//trace('Key $key: ' + Reflect.field(varsToBring, key));
				funk.hscript.set(key, Reflect.field(varsToBring, key));
			}
		}
		retVal = funk.hscript.executeCode(funcToRun, funcArgs);
		if (retVal != null)
		{
			if(retVal.succeeded)
				return (retVal.returnValue == null || LuaUtils.isOfTypes(retVal.returnValue, [Bool, Int, Float, String, Array])) ? retVal.returnValue : null;

			var e = retVal.exceptions[0];
			if (e != null)
				FunkinLua.luaTrace(funk.hscript.origin + ":" + funk.lastCalledFunction + " - " + e, false, false, FlxColor.RED);
			return null;
		}
		else if (funk.hscript.returnValue != null)
			return funk.hscript.returnValue;

		return null;
	});
}