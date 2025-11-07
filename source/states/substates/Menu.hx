package states.substates;

import core.Controls;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import ui.ButtonPrimary;

class Menu extends ui.OverlaySubState {
  var debounce = true;
  override function create() {
    super.create();

		title.text = "paused";

    final gap = 5;
    final button_width = FlxG.width / 2;

    // how icky, isn't it?
    close_button.label.text = "resume";
    close_button.y = title.y + title.height + gap + 5;
    close_button.resize(button_width, 24);
    close_button.screenCenter(X);

    var settings_button = new ButtonPrimary(0, close_button.y + close_button.height + gap, "settings", function() {
      openSubState(new states.substates.Settings());
    });
    settings_button.resize(button_width, 24);
    settings_button.screenCenter(X);


    var levels_button = new ButtonPrimary(0, settings_button.y + settings_button.height + gap, "level select", function() {
      FlxG.switchState(function() {
        return new states.LevelSelect();
      });
    });
    levels_button.resize(button_width, 24);
    levels_button.screenCenter(X);

    var main_menu_button = new ButtonPrimary(0, 0, "main menu", function() {
      FlxG.switchState(function() {
        return new states.MainMenu();
      });
    });
    main_menu_button.resize(button_width, 24);
    main_menu_button.screenCenter(X);
    main_menu_button.y = FlxG.height - main_menu_button.height - gap;

    focus.add(levels_button);
    focus.add(settings_button);
    focus.add(main_menu_button);
    
    // sigh
    FlxTimer.wait(0.05, () -> debounce = false);
  }
  
  override function update(elapsed: Float) {
    super.update(elapsed);
    if(Controls.button.just_pressed.START && !debounce) {
      close();
    } 
  }

  override function close(): Void {
    super.close();
  }
}