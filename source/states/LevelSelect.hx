package states;

import core.BaseLevel;
import core.LevelLoader;
import core.StateExt;
import flixel.FlxG;
import flixel.FlxState;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import ui.ButtonPrimary;

using StringTools;

class LevelSelect extends StateExt {
  override public function create() {
    var level_1 = new ButtonPrimary(20, 20, "level 1", function() {
      switch_level("tutorial");
    });

    focus.add(level_1, true);
  } 

  public function switch_level(level_name: String) {
    FlxG.camera.fade(FlxColor.BLACK, 0.5, false, function() { 
      var level = new LevelLoader(level_name); 

			FlxG.switchState(function() {
        return level;
      });
    });
  }
}