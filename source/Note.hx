package;

import flixel.FlxSprite;
import editors.ChartingState;

using StringTools;

typedef EventNote =
{
  strumTime:Float,
  event:String,
  value1:String,
  value2:String
}

class Note extends FlxSprite
{
  public var extraData:Map<String, Dynamic> = [];

  public var strumTime:Float = 0;
  public var mustPress:Bool = false;
  public var noteData:Int = 0;
  public var canBeHit:Bool = false;
  public var tooLate:Bool = false;
  public var wasGoodHit:Bool = false;
  public var ignoreNote:Bool = false;
  public var hitByOpponent:Bool = false;
  public var noteWasHit:Bool = false;
  public var prevNote:Note;
  public var nextNote:Note;

  public var spawned:Bool = false;

  public var tail:Array<Note> = []; // for sustains
  public var parent:Note;
  public var blockHit:Bool = false; // only works for player

  public var sustainLength:Float = 0;
  public var isSustainNote:Bool = false;
  public var noteType(default, set):String = null;

  public var eventName:String = '';
  public var eventLength:Int = 0;
  public var eventVal1:String = '';
  public var eventVal2:String = '';

  public var colorSwap:ColorSwap;
  public var inEditor:Bool = false;

  public var animSuffix:String = '';
  public var gfNote:Bool = false;
  public var earlyHitMult:Float = 0.5;
  public var lateHitMult:Float = 1;
  public var lowPriority:Bool = false;

  public static var swagWidth:Float = 160 * 0.7;

  private var colArray:Array<String> = ['purple', 'blue', 'green', 'red'];

  // Lua shit
  public var noteSplashDisabled:Bool = false;
  public var noteSplashTexture:String = null;
  public var noteSplashHue:Float = 0;
  public var noteSplashSat:Float = 0;
  public var noteSplashBrt:Float = 0;

  public var offsetX:Float = 0;
  public var offsetY:Float = 0;
  public var offsetAngle:Float = 0;
  public var multAlpha:Float = 1;
  public var multSpeed(default, set):Float = 1;

  public var copyX:Bool = true;
  public var copyY:Bool = true;
  public var copyAngle:Bool = true;
  public var copyAlpha:Bool = true;

  public var hitHealth:Float = 0.023;
  public var missHealth:Float = 0.0475;
  public var rating:String = 'unknown';
  public var ratingMod:Float = 0; // 9 = unknown, 0.25 = shit, 0.5 = bad, 0.75 = good, 1 = sick
  public var ratingDisabled:Bool = false;

  public var texture(default, set):String = null;

  public var noAnimation:Bool = false;
  public var noMissAnimation:Bool = false;
  public var hitCausesMiss:Bool = false;
  public var distance:Float = 2000; // plan on doing scroll directions soon -bb

  public var hitsoundDisabled:Bool = false;

  private function set_multSpeed(value:Float):Float
  {
    resizeByRatio(value / multSpeed);
    multSpeed = value;
    return value;
  }

  public function resizeByRatio(ratio:Float) // haha funny twitter shit
  {
    if (isSustainNote && !animation.curAnim.name.endsWith('end'))
    {
      scale.y *= ratio;
      updateHitbox();
    }
  }

  private function set_texture(value:String):String
  {
    if (texture != value)
    {
      reloadNote('', value);
    }
    texture = value;
    return value;
  }

  private function set_noteType(value:String):String
  {
    noteSplashTexture = PlayState.SONG.splashSkin;
    if (noteData > -1 && noteData < ClientPrefs.arrowHSV.length)
    {
      colorSwap.hue = ClientPrefs.arrowHSV[noteData][0] / 360;
      colorSwap.saturation = ClientPrefs.arrowHSV[noteData][1] / 100;
      colorSwap.brightness = ClientPrefs.arrowHSV[noteData][2] / 100;
    }

    if (noteData > -1 && noteType != value)
    {
      switch (value)
      {
        case 'Alt Animation':
          animSuffix = '-alt';
        case 'No Animation':
          noAnimation = true;
          noMissAnimation = true;
        case 'GF Sing':
          gfNote = true;
      }
      noteType = value;
    }
    noteSplashHue = colorSwap.hue;
    noteSplashSat = colorSwap.saturation;
    noteSplashBrt = colorSwap.brightness;
    return value;
  }

  public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inEditor:Bool = false)
  {
    super();

    if (prevNote == null) prevNote = this;

    this.prevNote = prevNote;
    isSustainNote = sustainNote;
    this.inEditor = inEditor;

    x += (ClientPrefs.middleScroll ? PlayState.STRUM_X_MIDDLESCROLL : PlayState.STRUM_X) + 50;
    // MAKE SURE ITS DEFINITELY OFF SCREEN?
    y -= 2000;
    this.strumTime = strumTime;
    if (!inEditor) this.strumTime += ClientPrefs.noteOffset;

    this.noteData = noteData;

    if (noteData > -1)
    {
      texture = '';
      colorSwap = new ColorSwap();
      shader = colorSwap.shader;

      x += swagWidth * (noteData);
      if (!isSustainNote && noteData > -1 && noteData < 4)
      {
        var animToPlay:String = '';
        animToPlay = colArray[noteData % 4];
        animation.play(animToPlay + 'Scroll');
      }
    }

    if (prevNote != null) prevNote.nextNote = this;

    if (isSustainNote && prevNote != null)
    {
      setGraphicSize(Std.int(width * 0.7));

      alpha = 0.45;
      multAlpha = 0.45;
      hitsoundDisabled = true;
      if (ClientPrefs.downScroll) flipY = true;

      offsetX += width / 2;
      copyAngle = false;

      animation.play(colArray[noteData % 4] + 'holdend');

      updateHitbox();

      offsetX -= width / 2;

      if (prevNote.isSustainNote)
      {
        prevNote.animation.play(colArray[prevNote.noteData % 4] + 'hold');

        prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.05;
        if (PlayState.instance != null)
        {
          prevNote.scale.y *= PlayState.instance.songSpeed;
        }

        prevNote.updateHitbox();
      }
    }
    else if (!isSustainNote)
    {
      earlyHitMult = 1;
    }
    x += offsetX;
  }

  var lastNoteOffsetXForPixelAutoAdjusting:Float = 0;
  var lastNoteScaleToo:Float = 1;

  public var originalHeightForCalcs:Float = 6;

  function reloadNote(?prefix:String = '', ?texture:String = '', ?suffix:String = '')
  {
    if (prefix == null) prefix = '';
    if (texture == null) texture = '';
    if (suffix == null) suffix = '';

    var skin:String = texture;
    if (texture.length < 1)
    {
      skin = PlayState.SONG.arrowSkin;
      if (skin == null || skin.length < 1)
      {
        skin = 'ui/notes';
      }
    }

    var animName:String = null;
    if (animation.curAnim != null)
    {
      animName = animation.curAnim.name;
    }

    var arraySkin:Array<String> = skin.split('/');
    arraySkin[arraySkin.length - 1] = prefix + arraySkin[arraySkin.length - 1] + suffix;

    var lastScaleY:Float = scale.y;
    var blahblah:String = arraySkin.join('/');

    frames = Paths.getSparrowAtlas(blahblah);
    loadNoteAnims();
    antialiasing = false;

    if (isSustainNote)
    {
      scale.y = lastScaleY;
    }

    updateHitbox();

    if (animName != null) animation.play(animName, true);

    if (inEditor)
    {
      setGraphicSize(ChartingState.GRID_SIZE, ChartingState.GRID_SIZE);
      updateHitbox();
    }
  }

  function loadNoteAnims()
  {
    animation.addByPrefix(colArray[noteData] + 'Scroll', colArray[noteData] + '0');

    if (isSustainNote)
    {
      animation.addByPrefix('purpleholdend', 'pruple end hold'); // ?????
      animation.addByPrefix(colArray[noteData] + 'holdend', colArray[noteData] + ' hold end');
      animation.addByPrefix(colArray[noteData] + 'hold', colArray[noteData] + ' hold piece');
    }

    if (PlayState.SONG.arrowSkin == "ui/yctp_notes")
    {
      setGraphicSize(Std.int(width * 0.6));
    }
    else
    {
      setGraphicSize(Std.int(width * 0.8));
    }

    updateHitbox();
  }

  override function update(elapsed:Float)
  {
    super.update(elapsed);

    if (mustPress)
    {
      // ok river
      if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * lateHitMult)
        && strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult)) canBeHit = true;
      else
        canBeHit = false;

      if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit) tooLate = true;
    }
    else
    {
      canBeHit = false;

      if (strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
      {
        if ((isSustainNote && prevNote.wasGoodHit) || strumTime <= Conductor.songPosition) wasGoodHit = true;
      }
    }

    if (tooLate && !inEditor)
    {
      if (alpha > 0.3) alpha = 0.3;
    }
  }
}