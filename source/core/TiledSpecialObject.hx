package core;

import flixel.FlxSprite;
import flixel.util.FlxSignal.FlxTypedSignal;

class TiledSpecialObject extends FlxSprite {
  public var on_interact = new FlxTypedSignal<Float->Void>();
  public var on_step = new FlxTypedSignal<Float->Void>();

  public var name = "unknown";

  public var properties: Map<String, Dynamic> = new Map();

  override public function toString() {
    final old = super.toString();
    return '$name | $old';
  }
}