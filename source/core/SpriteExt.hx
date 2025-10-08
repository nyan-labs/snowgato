package core;

import flixel.FlxSprite;
import flixel.util.FlxSignal.FlxTypedSignal;

class SpriteExt extends FlxSprite {
  public var oninteract = new FlxTypedSignal<Float->Void>();
  public var onstep = new FlxTypedSignal<Float->Void>();
}