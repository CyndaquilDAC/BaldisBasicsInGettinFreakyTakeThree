package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.keyboard.FlxKey;
import flixel.addons.transition.FlxTransitionableState;
import haxe.Json;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.Assets;

using StringTools;

typedef TitleData =
{
  titlex:Float,
  titley:Float,
  startx:Float,
  starty:Float,
  gfx:Float,
  gfy:Float,
  backgroundSprite:String,
  bpm:Int
}

class TitleState extends MusicBeatState
{
  public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
  public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
  public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

  public static var initialized:Bool = false;

  var blackScreen:FlxSprite;
  var credGroup:FlxGroup;
  var credTextShit:Alphabet;
  var textGroup:FlxGroup;
  var ngSpr:FlxSprite;

  var titleTextColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
  var titleTextAlphas:Array<Float> = [1, .64];

  var curWacky:Array<String> = [];

  var wackyImage:FlxSprite;

  var mustUpdate:Bool = false;

  var titleJSON:TitleData;

  public static var updateVersion:String = '';

  override public function create():Void
  {
    Paths.clearStoredMemory();
    Paths.clearUnusedMemory();

    WeekData.loadTheFirstEnabledMod();

    FlxG.game.focusLostFramerate = 60;
    FlxG.sound.muteKeys = muteKeys;
    FlxG.sound.volumeDownKeys = volumeDownKeys;
    FlxG.sound.volumeUpKeys = volumeUpKeys;
    FlxG.keys.preventDefaultKeys = [TAB];

    PlayerSettings.init();

    curWacky = FlxG.random.getObject(getIntroTextShit());

    swagShader = new ColorSwap();

    super.create();

    FlxG.save.bind('funkin', CoolUtil.getSavePath());

    ClientPrefs.loadPrefs();

    Highscore.load();

    titleJSON = Json.parse(Paths.getTextFromFile('images/gfDanceTitle.json'));

    if (!initialized)
    {
      if (FlxG.save.data != null && FlxG.save.data.fullscreen)
      {
        FlxG.fullscreen = FlxG.save.data.fullscreen;
      }
      persistentUpdate = true;
      persistentDraw = true;
    }

    if (FlxG.save.data.weekCompleted != null)
    {
      StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
    }

    FlxG.mouse.visible = false;

    if (FlxG.save.data.flashing == null && !FlashingState.leftState)
    {
      FlxTransitionableState.skipNextTransIn = true;
      FlxTransitionableState.skipNextTransOut = true;
      MusicBeatState.switchState(new FlashingState());
    }
    else
    {
      if (initialized) startIntro();
      else
      {
        new FlxTimer().start(1, function(tmr:FlxTimer) {
          startIntro();
        });
      }
    }
  }

  var logoBl:FlxSprite;
  var gfDance:FlxSprite;
  var danceLeft:Bool = false;
  var titleText:FlxSprite;
  var swagShader:ColorSwap = null;

  function startIntro()
  {
    if (!initialized)
    {
      if (FlxG.sound.music == null)
      {
        FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
      }
    }

    Conductor.changeBPM(titleJSON.bpm);
    persistentUpdate = true;

    var bg:FlxSprite = new FlxSprite();

    if (titleJSON.backgroundSprite != null && titleJSON.backgroundSprite.length > 0 && titleJSON.backgroundSprite != "none")
    {
      bg.loadGraphic(Paths.image(titleJSON.backgroundSprite));
    }
    else
    {
      bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
    }

    add(bg);

    logoBl = new FlxSprite(titleJSON.titlex, titleJSON.titley);
    logoBl.frames = Paths.getSparrowAtlas('logoBumpin');

    logoBl.antialiasing = false;
    logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
    logoBl.animation.play('bump');
    logoBl.updateHitbox();

    swagShader = new ColorSwap();
    gfDance = new FlxSprite(titleJSON.gfx, titleJSON.gfy);

    gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
    gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
    gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
    gfDance.antialiasing = false;

    add(gfDance);
    gfDance.shader = swagShader.shader;
    add(logoBl);
    logoBl.shader = swagShader.shader;

    titleText = new FlxSprite(titleJSON.startx, titleJSON.starty);
    titleText.frames = Paths.getSparrowAtlas('titleEnter');

    var animFrames:Array<FlxFrame> = [];
    @:privateAccess {
      titleText.animation.findByPrefix(animFrames, "ENTER IDLE");
      titleText.animation.findByPrefix(animFrames, "ENTER FREEZE");
    }

    if (animFrames.length > 0)
    {
      newTitle = true;

      titleText.animation.addByPrefix('idle', "ENTER IDLE", 24);
      titleText.animation.addByPrefix('press', ClientPrefs.flashing ? "ENTER PRESSED" : "ENTER FREEZE", 24);
    }
    else
    {
      newTitle = false;

      titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
      titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
    }

    titleText.antialiasing = false;
    titleText.animation.play('idle');
    titleText.updateHitbox();
    add(titleText);

    var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
    logo.screenCenter();
    logo.antialiasing = false;

    credGroup = new FlxGroup();
    add(credGroup);
    textGroup = new FlxGroup();

    blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
    credGroup.add(blackScreen);

    credTextShit = new Alphabet(0, 0, "", true);
    credTextShit.screenCenter();

    credTextShit.visible = false;

    ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
    add(ngSpr);
    ngSpr.visible = false;
    ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
    ngSpr.updateHitbox();
    ngSpr.screenCenter(X);
    ngSpr.antialiasing = false;

    FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

    if (initialized) skipIntro();
    else
      initialized = true;
  }

  function getIntroTextShit():Array<Array<String>>
  {
    var fullText:String = Assets.getText(Paths.txt('introText'));

    var firstArray:Array<String> = fullText.split('\n');
    var swagGoodArray:Array<Array<String>> = [];

    for (i in firstArray)
    {
      swagGoodArray.push(i.split('--'));
    }

    return swagGoodArray;
  }

  var transitioning:Bool = false;

  private static var playJingle:Bool = false;

  var newTitle:Bool = false;
  var titleTimer:Float = 0;

  override function update(elapsed:Float)
  {
    if (FlxG.sound.music != null) Conductor.songPosition = FlxG.sound.music.time;

    var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

    var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

    if (gamepad != null)
    {
      if (gamepad.justPressed.START) pressedEnter = true;
    }

    if (newTitle)
    {
      titleTimer += CoolUtil.boundTo(elapsed, 0, 1);
      if (titleTimer > 2) titleTimer -= 2;
    }

    if (initialized && !transitioning && skippedIntro)
    {
      if (newTitle && !pressedEnter)
      {
        var timer:Float = titleTimer;
        if (timer >= 1) timer = (-timer) + 2;

        timer = FlxEase.quadInOut(timer);

        titleText.color = FlxColor.interpolate(titleTextColors[0], titleTextColors[1], timer);
        titleText.alpha = FlxMath.lerp(titleTextAlphas[0], titleTextAlphas[1], timer);
      }

      if (pressedEnter)
      {
        titleText.color = FlxColor.WHITE;
        titleText.alpha = 1;

        if (titleText != null) titleText.animation.play('press');

        FlxG.camera.flash(ClientPrefs.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);
        FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

        transitioning = true;

        new FlxTimer().start(1, function(tmr:FlxTimer) {
          MusicBeatState.switchState(new MainMenuState());
          closedState = true;
        });
      }
    }

    if (initialized && pressedEnter && !skippedIntro)
    {
      skipIntro();
    }

    if (swagShader != null)
    {
      if (controls.UI_LEFT) swagShader.hue -= elapsed * 0.1;
      if (controls.UI_RIGHT) swagShader.hue += elapsed * 0.1;
    }

    super.update(elapsed);
  }

  function createCoolText(textArray:Array<String>, ?offset:Float = 0)
  {
    for (i in 0...textArray.length)
    {
      var money:Alphabet = new Alphabet(0, 0, textArray[i], true);
      money.screenCenter(X);
      money.y += (i * 60) + 200 + offset;
      if (credGroup != null && textGroup != null)
      {
        credGroup.add(money);
        textGroup.add(money);
      }
    }
  }

  function addMoreText(text:String, ?offset:Float = 0)
  {
    if (textGroup != null && credGroup != null)
    {
      var coolText:Alphabet = new Alphabet(0, 0, text, true);
      coolText.screenCenter(X);
      coolText.y += (textGroup.length * 60) + 200 + offset;
      credGroup.add(coolText);
      textGroup.add(coolText);
    }
  }

  function deleteCoolText()
  {
    while (textGroup.members.length > 0)
    {
      credGroup.remove(textGroup.members[0], true);
      textGroup.remove(textGroup.members[0], true);
    }
  }

  private var sickBeats:Int = 0;

  public static var closedState:Bool = false;

  override function beatHit()
  {
    super.beatHit();

    if (logoBl != null) logoBl.animation.play('bump', true);

    if (gfDance != null)
    {
      danceLeft = !danceLeft;
      if (danceLeft) gfDance.animation.play('danceRight');
      else
        gfDance.animation.play('danceLeft');
    }

    if (!closedState)
    {
      sickBeats++;
      switch (sickBeats)
      {
        case 1:
          FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
          FlxG.sound.music.fadeIn(4, 0, 0.7);
        case 2:
          createCoolText(["An FNF mod by"]);
        case 4:
          addMoreText('Cynda', 15);
          addMoreText('Regular Dumbass', 15);
          addMoreText('PhoneyX', 15);
          addMoreText('Spook', 15);
        case 5:
          deleteCoolText();
        case 6:
          createCoolText(['NOT ACTUALLY ASSOCIATED', 'WITH'], -40);
        case 8:
          addMoreText('BASICALLY GAMES', -40);
          ngSpr.visible = true;
        case 9:
          deleteCoolText();
          ngSpr.visible = false;
        case 10:
          createCoolText([curWacky[0]]);
        case 12:
          addMoreText(curWacky[1]);
        case 13:
          deleteCoolText();
        case 14:
          addMoreText("Baldi's Basics");
        case 15:
          addMoreText('in');
        case 16:
          addMoreText("Gettin' Freaky");
        case 17:
          skipIntro();
      }
    }
  }

  var skippedIntro:Bool = false;
  var increaseVolume:Bool = false;

  function skipIntro():Void
  {
    if (!skippedIntro)
    {
      remove(ngSpr);
      remove(credGroup);
      FlxG.camera.flash(FlxColor.WHITE, 4);
      skippedIntro = true;
    }
  }
}