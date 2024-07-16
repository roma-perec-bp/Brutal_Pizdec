package backend;

class Achievements {
	public static var achievementsStuff:Array<Dynamic> = [
		// story mode
		["Explodynamic!","Beat Story Mode.","main",false], // done
		["Pizdec","Beat Story Mode with no Misses.","main_nomiss",false], // done
		["Brutal Pizdec","Beat Story Mode with no Misses & no Deaths.","main_nomiss_nodeaths",false], // done, i think
		["Feeling jalapenos in my ass!!","Beat every Songs.","allweeks",false], // НЕТУ
		["Scorching Self-Immolation","Beat every Songs with no Misses & no Deaths.","allweeks1",false], // НЕТУ
		["Um excuse me what the actual fuck are you doing in my house???","All Songs. No Misses. No Deaths. All achievements.","allweeks2",false], // НЕТУ
		// freeplay no miss
		["Daily Anekdot!!",'Beat \"Anekdot\" song with no Misses.', 'anekdot_freeplay_nomiss',false], // done
		["DIMA KUPLINOV",'Beat \"Klork\" song with no Misses.','klork_freeplay_nomiss',false], // done
		["D E A D",'Beat \"Monochrome\" song with no Misses.','monochrome_freeplay_nomiss',false], // done
		["I have a GAME theory!",'Beat \"Lore\" song with no Misses.','lore_freeplay_nomiss',false], // done
		["SEXY",'Beat \"S6x-Boom\" song with no Misses.','s6x-boom_freeplay_nomiss',false], // done
		["Fully smoked!!",'Beat \"lamar tut voobshe ne nujen\" song with no Misses.','lamar-tut-voobshe-ne-nujen_freeplay_nomiss',false], // idk? is it done?
		// misc
		["Anekdot is for real",'Die on \"Anekdot\" song.','anekdot_death',false], // done
		["Oh, China, what are you doing here?",'Press on JinchengZhang in Main Menu.','menu0',true], // done
		["Skill Issue",'Die 10 times in any song.','skill',true,10], // done
		["KA-BOOM",'Hit the Jalapeno Note 10 times','kaboom',true,10], // done
		["Da old days...",'Beat Every Old Songs.','oldweek0',false], // НЕТУ
		["Cum","Play any song with only white color on notes RGB option",'cum',false], // ah hell naw
		["Cursed Omlet da fucking shit",'Press 7 on "Lore" song.','Lore',true], // done
		["Random Sing",'Press 7 on "T-Short" song.','T-SHORT',true], // done // НЕТУ
		["FNAF Jumpscare",'Die on "Monochrome" song.','fnaf',false], // done
		["How",'Die on with BotPlay turned on.','bot',false], // done
		// that one
		["Freaky on a Friday Night","Play on a Friday... Night.",'friday_night_play',false] // done
	];
	public static var achievementsMap:Map<String, Bool> = new Map<String, Bool>();
	public static var map_maxcurVars:Map<String, Int> = new Map<String, Int>();

	public static var henchmenDeath:Int = 0;
	public static function unlockAchievement(name:String):Void {
		FlxG.log.add('Completed achievement "' + name +'"');
		achievementsMap.set(name, true);
		FlxG.sound.play(Paths.sound('confirmAch'), 0.7);
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