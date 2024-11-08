package options;

import flash.text.TextField;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;
import openfl.Lib;

using StringTools;

class GraphicsSettingsSubState extends BaseOptionsMenu
{
  public function new()
  {
    title = 'Graphics';
    rpcTitle = 'Graphics Settings Menu'; // for Discord Rich Presence

    var option:Option = new Option('Shaders', // Name
      'If unchecked, disables shaders.\nIt\'s used for some visual effects, and also CPU intensive for weaker PCs.', // Description
      'shaders', // Save data variable name
      'bool', // Variable type
      true); // Default value
    addOption(option);

    #if !html5 // Apparently other framerates isn't correctly supported on Browser? Probably it has some V-Sync shit enabled by default, idk
    var option:Option = new Option('Framerate', "Pretty self explanatory, isn't it?", 'framerate', 'int', 60);
    addOption(option);

    option.minValue = 60;
    option.maxValue = 240;
    option.displayFormat = '%v FPS';
    option.onChange = onChangeFramerate;
    #end

    super();
  }

  function onChangeFramerate()
  {
    if (ClientPrefs.framerate > FlxG.drawFramerate)
    {
      FlxG.updateFramerate = ClientPrefs.framerate;
      FlxG.drawFramerate = ClientPrefs.framerate;
    }
    else
    {
      FlxG.drawFramerate = ClientPrefs.framerate;
      FlxG.updateFramerate = ClientPrefs.framerate;
    }
  }
}