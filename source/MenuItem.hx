package;

import flixel.FlxSprite;
import flixel.math.FlxMath;

class MenuItem extends FlxSprite
{
	public var targetY:Float = 0;
	public var weekName:String;

	public function new(x:Float, y:Float, weekName:String = '')
	{
		super(x, y);
		weekName = this.weekName;
		loadGraphic(Paths.image('storymenu/' + "placeholderN"));
		loadGraphic(Paths.image('storymenu/' + weekName.toLowerCase() + "N"));
		antialiasing = false;
	}

	public function setYes():Void
	{
		loadGraphic(Paths.image('storymenu/' + "placeholderY"));
		loadGraphic(Paths.image('storymenu/' + weekName.toLowerCase() + "Y"));
	}

	public function setNo():Void
	{
		loadGraphic(Paths.image('storymenu/' + "placeholderN"));
		loadGraphic(Paths.image('storymenu/' + weekName.toLowerCase() + "N"));
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		y = FlxMath.lerp(y, (targetY * 256) + 10, CoolUtil.boundTo(elapsed * 10.2, 0, 1));
	}
}