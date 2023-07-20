package;

import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.math.FlxMath;

using StringTools;

class MenuItem extends FlxSpriteGroup
{
	public var sparite:FlxSprite;
	public var targetY:Float = 0;
	public var weekNameTwoTheWeekestName:String;
	public var textety:FlxText;

	public function new(x:Float, y:Float, weekName:String = '', weekSongList:Array<String>, weekDescriptiveName:String = '')
	{
		super(x, y);
		sparite = new FlxSprite(0, 0);
		weekNameTwoTheWeekestName = weekName;
		sparite.loadGraphic(Paths.image('storymenu/' + "placeholderN"));
		sparite.loadGraphic(Paths.image('storymenu/' + weekName.toLowerCase() + "N"));
		add(sparite);
		textety = new FlxText(574, 12, 450, weekDescriptiveName + "\nTracklist:\n", 32);
		for(i in 0...weekSongList.length)
		{
			var gahag:String = "\n";
			if(i == weekSongList.length)
			{
				gahag == '';
			}
			textety.text += weekSongList[i].replace("-", " ") + gahag;
		}
		textety.setFormat(Paths.font("comic-bald.ttf"), 32, FlxColor.BLACK, CENTER, NONE);
		add(textety);
		sparite.antialiasing = false;
	}

	public function setYes():Void
	{
		sparite.loadGraphic(Paths.image('storymenu/' + "placeholderY"));
		sparite.loadGraphic(Paths.image('storymenu/' + weekNameTwoTheWeekestName.toLowerCase() + "Y"));
	}

	public function setNo():Void
	{
		sparite.loadGraphic(Paths.image('storymenu/' + "placeholderN"));
		sparite.loadGraphic(Paths.image('storymenu/' + weekNameTwoTheWeekestName.toLowerCase() + "N"));
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		y = FlxMath.lerp(y, (targetY * 256) + 256, CoolUtil.boundTo(elapsed * 10.2, 0, 1));
	}
}