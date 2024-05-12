package backend;

class Achievements {
	public static var achievementsStuff:Array<Dynamic> = [
		["Explodynamic!","Beat Story Mode.","story0",false],
		["Pizdec","Beat Story Mode on Hard with no Misses.","story1",false],
		["Brutal Pizdec","Beat Story Mode on Hard with no Misses & no Deaths.","story2",false],
		["Feeling peppers in my ass!!","Beat all Weeks ( including Old Week ).","allweeks0",false],
		["Scorching Self-Immolation","Beat ALL Weeks ( including Old Week ) with no Misses & no Deaths.","allweeks1",false],
		["Um excuse me what the actual fuck are you doing in my house???","All Weeks. No misses. No Deaths. All achievements.","allweeks2",false],
		["Life Anecdote",'Die on "Anekdote" song.','anekdote0',false],
		["Daily Anecdote!!",'Beat "Anekdote" song with no Misses.','anekdote1',false],
		["DIMA KUPLINOV",'Beat "KLork" song with no Misses.','klork0',false],
		["RANDOM SHORT IN UNDERWEARS????",'Beat "T-Short" song with no Misses.','tshort0',false],
		["D E A D",'Beat "Monochrome" song with no Misses.','monochrome0',false],
		["Typical 17bucks",'Beat "64rubl" song with no Misses.','64rubl0',false],
		["I have a GAME theory!",'Beat "Lore" song with no Misses.','lore0',false],
		["SEXY",'Beat "S6x-Boom" song with no Misses.','sxbmb0',false],
		["Fully smoked!!",'Beat "lamar tut voobshe ne nujen" song with no Misses.','lamar',false],
		["Oh, China, what are you doing here?",'Press on JinchengZhang in Main Menu.','menu0',true],
		["Skill Issue",'Die 10 times in any song.','skill0',true,10],
		["KA-BOOM",'Hit the Pepper Note 10 times','kaboom',true,10],
		["KA-SEX",'Hit the Pepper Note 69 times','kaboom',true,69],
		["Da old days...",'Beat Old Week.','oldweek0',false],
		["Cum","Play any song with only white color on notes RGB option",'cum',false],
		["Cursed Omlet da fucking shit",'Press 7 on "Lore" song.','cursed0',true],
		["Random Sing",'Press 7 on "T-Short" song.','tshort0',true],
		["FNAF Screamer",'Die on "Monochrome" song.','fnaf0',false]
	];
	public static var achievementsMap:Map<String, Bool> = new Map<String, Bool>();
	public static var map_maxcurVars:Map<String, Int> = new Map<String, Int>();

	public static var henchmenDeath:Int = 0;
	public static function unlockAchievement(name:String):Void {
		FlxG.log.add('Completed achievement "' + name +'"');
		achievementsMap.set(name, true);
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
	}

	public static function isAchievementUnlocked(name:String) {
		if(achievementsMap.exists(name) && achievementsMap.get(name)) {
			return true;
		}
		return false;
	}

	public static function getAchievementIndex(name:String) {
		for (i in 0...achievementsStuff.length) {
			if(achievementsStuff[i][2] == name) {
				return i;
			}
		}
		return -1;
	}

	public static function loadAchievements():Void {
		if(FlxG.save.data != null) {
			if(FlxG.save.data.achievementsMap != null) {
				achievementsMap = FlxG.save.data.achievementsMap;
			}
			if(FlxG.save.data.map_maxcurVars != null) {
				map_maxcurVars = FlxG.save.data.map_maxcurVars;
			}
			if(henchmenDeath == 0 && FlxG.save.data.henchmenDeath != null) {
				henchmenDeath = FlxG.save.data.henchmenDeath;
			}
		}
	}

	// for current and max's variables stuff
	public static function getAchievementCurNum(name:String) {
		if(map_maxcurVars.exists(name)) {
			return map_maxcurVars.get(name);
		} else {
			trace("Returned nothing, but the achievement's name is "+name);
			map_maxcurVars.set(name, 0);
			return 0;
		}
	}

	public static function setAchievementCurNum(name:String, number:Int):Void {
		if(map_maxcurVars.exists(name)) {
			map_maxcurVars.set(name, number);
		}
	}
}