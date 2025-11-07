package core;

import flixel.FlxState;
import flixel.FlxSubState;
import flixel.util.FlxColor;

class StateExt extends FlxState {
  public var focus: FocusManager;

  override public function new() {
    super();

    focus = new FocusManager(this);
    add(focus);
  }
}

class SubStateExt extends FlxSubState {
  public var focus: FocusManager;

	override public function new(bg_color: FlxColor) {
    super(bg_color);

    focus = new FocusManager(this);
    add(focus);
  }
}