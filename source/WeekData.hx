package;

import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;
import haxe.Json;

using StringTools;

typedef WeekFile =
{
  // JSON variables
  var songs:Array<Dynamic>;
  var weekCharacters:Array<String>;
  var weekBackground:String;
  var weekBefore:String;
  var storyName:String;
  var weekName:String;
  var weekNameCode:String;
  var freeplayColor:Array<Int>;
  var startUnlocked:Bool;
  var hiddenUntilUnlocked:Bool;
  var hideStoryMode:Bool;
  var hideFreeplay:Bool;
  var difficulties:String;
}

class WeekData
{
  public static var weeksLoaded:Map<String, WeekData> = new Map<String, WeekData>();
  public static var weeksList:Array<String> = [];
  public static var weeksListCode:Array<String> = [];

  public var folder:String = '';

  // JSON variables
  public var songs:Array<Dynamic>;
  public var weekCharacters:Array<String>;
  public var weekBackground:String;
  public var weekBefore:String;
  public var storyName:String;
  public var weekName:String;
  public var weekNameCode:String;
  public var freeplayColor:Array<Int>;
  public var startUnlocked:Bool;
  public var hiddenUntilUnlocked:Bool;
  public var hideStoryMode:Bool;
  public var hideFreeplay:Bool;
  public var difficulties:String;

  public var fileName:String;

  public static function createWeekFile():WeekFile
  {
    var weekFile:WeekFile =
      {
        songs: [
          ["Bopeebo", "dad", [146, 113, 253]],
          ["Fresh", "dad", [146, 113, 253]],
          ["Dad Battle", "dad", [146, 113, 253]]
        ],
        weekCharacters: ['dad', 'bf', 'gf'],
        weekBackground: 'stage',
        weekBefore: 'tutorial',
        storyName: 'Your New Week',
        weekName: 'Custom Week',
        weekNameCode: "custom",
        freeplayColor: [146, 113, 253],
        startUnlocked: true,
        hiddenUntilUnlocked: false,
        hideStoryMode: false,
        hideFreeplay: false,
        difficulties: ''
      };

    return weekFile;
  }

  public function new(weekFile:WeekFile, fileName:String)
  {
    songs = weekFile.songs;
    weekCharacters = weekFile.weekCharacters;
    weekBackground = weekFile.weekBackground;
    weekBefore = weekFile.weekBefore;
    storyName = weekFile.storyName;
    weekName = weekFile.weekName;
    weekNameCode = weekFile.weekNameCode;
    freeplayColor = weekFile.freeplayColor;
    startUnlocked = weekFile.startUnlocked;
    hiddenUntilUnlocked = weekFile.hiddenUntilUnlocked;
    hideStoryMode = weekFile.hideStoryMode;
    hideFreeplay = weekFile.hideFreeplay;
    difficulties = weekFile.difficulties;

    this.fileName = fileName;
  }

  public static function reloadWeekFiles(isStoryMode:Null<Bool> = false)
  {
    weeksList = [];
    weeksLoaded.clear();
    var directories:Array<String> = [Paths.getPreloadPath()];
    var originalLength:Int = directories.length;

    var sexList:Array<String> = CoolUtil.coolTextFile(Paths.getPreloadPath('weeks/weekList.txt'));
    for (i in 0...sexList.length)
    {
      for (j in 0...directories.length)
      {
        var fileToCheck:String = directories[j] + 'weeks/' + sexList[i] + '.json';
        if (!weeksLoaded.exists(sexList[i]))
        {
          var week:WeekFile = getWeekFile(fileToCheck);
          if (week != null)
          {
            var weekFile:WeekData = new WeekData(week, sexList[i]);

            if (weekFile != null
              && (isStoryMode == null || (isStoryMode && !weekFile.hideStoryMode) || (!isStoryMode && !weekFile.hideFreeplay)))
            {
              weeksLoaded.set(sexList[i], weekFile);
              weeksList.push(sexList[i]);
              weeksListCode.push(weekFile.weekNameCode);
            }
          }
        }
      }
    }
  }

  private static function addWeek(weekToCheck:String, path:String, directory:String, i:Int, originalLength:Int)
  {
    if (!weeksLoaded.exists(weekToCheck))
    {
      var week:WeekFile = getWeekFile(path);
      if (week != null)
      {
        var weekFile:WeekData = new WeekData(week, weekToCheck);
        if ((PlayState.isStoryMode && !weekFile.hideStoryMode) || (!PlayState.isStoryMode && !weekFile.hideFreeplay))
        {
          weeksLoaded.set(weekToCheck, weekFile);
          weeksList.push(weekToCheck);
        }
      }
    }
  }

  private static function getWeekFile(path:String):WeekFile
  {
    var rawJson:String = null;
    if (OpenFlAssets.exists(path))
    {
      rawJson = Assets.getText(path);
    }

    if (rawJson != null && rawJson.length > 0)
    {
      return cast Json.parse(rawJson);
    }
    return null;
  }

  public static function getWeekFileName():String
  {
    return weeksList[PlayState.storyWeek];
  }

  public static function getCurrentWeek():WeekData
  {
    return weeksLoaded.get(weeksList[PlayState.storyWeek]);
  }

  public static function setDirectoryFromWeek(?data:WeekData = null)
  {
    Paths.currentModDirectory = '';
    if (data != null && data.folder != null && data.folder.length > 0)
    {
      Paths.currentModDirectory = data.folder;
    }
  }

  public static function loadTheFirstEnabledMod()
  {
    Paths.currentModDirectory = '';
  }
}