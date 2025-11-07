package core.tilemap;

import flixel.group.FlxGroup.FlxTypedGroup;

class FlagManager extends FlxTypedGroup<Flag> {
  override public function new() {
    super();
  }

  public function create() {
    for(flag in members) {
      flag.create();
    }  
  }

  public function reset() {
    for(flag in members) {
      flag.clear();
      flag.create();
    }  
  }
}