package;

typedef SwagSection =
{
  var sectionNotes:Array<Dynamic>;
  var sectionBeats:Float;
  var typeOfSection:Int;
  var mustHitSection:Bool;
  var gfSection:Bool;
  var bpm:Float;
  var changeBPM:Bool;
  var coolDuetCam:Bool;
  var altAnim:Bool;
}

class Section
{
  public var sectionNotes:Array<Dynamic> = [];

  public var sectionBeats:Float = 4;
  public var gfSection:Bool = false;
  public var typeOfSection:Int = 0;
  public var mustHitSection:Bool = true;
  public var coolDuetCam:Bool = false;

  public function new(sectionBeats:Float = 4)
  {
    this.sectionBeats = sectionBeats;
  }
}