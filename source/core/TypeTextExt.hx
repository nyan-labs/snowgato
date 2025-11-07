package core;

import flixel.addons.text.FlxTypeText;
import flixel.text.FlxText.FlxTextFormat;
import flixel.text.FlxText.FlxTextFormatMarkerPair;
import flixel.util.FlxColor;
import openfl.text.TextFormat;

class TypeTextExt extends FlxTypeText {
  public var typing(get, never): Bool;
  inline function get_typing() {
    return _typing;
  }

  public var rules: Array<FlxTextFormatMarkerPair>;
	override public function new(X:Float, Y:Float, Width:Int, Text:String, Size:Int = 8, EmbeddedFont:Bool = true) {
    super(X, Y, Width, Text, Size, EmbeddedFont);

    rules = [
      new FlxTextFormatMarkerPair(
        new FlxTextFormat(null, true, null, null, null),
        "<b>"
      ),
      new FlxTextFormatMarkerPair(
        new FlxTextFormat(null, null, null, null, true),
        "<u>"
      ),
      new FlxTextFormatMarkerPair(
        new FlxTextFormat(null, null, true, null, null),
        "<i>"
      )
    ];

    applyMarkup(Text, rules);
  }
}