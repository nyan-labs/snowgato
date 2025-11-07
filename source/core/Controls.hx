package core;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadManager;
import flixel.ui.FlxButton;
import flixel.ui.FlxVirtualPad;
import flixel.util.FlxSignal;
import ui.ButtonPrimary;

typedef Dpad = {
  pressed: {
    UP: Bool,
    DOWN: Bool,
    LEFT: Bool,
    RIGHT: Bool,
  },
  just_pressed: {
    UP: Bool,
    DOWN: Bool,
    LEFT: Bool,
    RIGHT: Bool,
  },
}
typedef Button = {
  pressed: {
    B: Bool,
    A: Bool,
    X: Bool,
    Y: Bool,

    START: Bool,
    SELECT: Bool,
  },
  just_pressed: {
    B: Bool,
    A: Bool,
    X: Bool,
    Y: Bool,

    START: Bool,
    SELECT: Bool,
  },
};

typedef Joystick = {
  x: Float,
  y: Float
} 

class Controls {
  static public var menu_button: ButtonPrimary;
  
  static public var virtualpad: FlxVirtualPad;
  // flixel has horrible gamepad support :p
  static public var gamepad: FlxGamepad;
  
  static public var ui_alpha: Float = 0.4;

  static public var button(get, never): Button;
  
  static inline function get_button() {
    var b = get_button_state(B, [X], [B]);
    var a = get_button_state(A, [Z], [A]);
    var x = get_button_state(X, [C], [X]);
    var y = get_button_state(Y, [V], [Y]);

    // this doesnt make sense! RIGHT_SHOULDER is.. not a start button? yet its treated as such?
    // i will not question flixel
    // ill go along with its delusions...
    //   - tested on a xbox one controller
    // https://groups.google.com/g/haxeflixel/c/zgT3xXUGCy4
    var start = get_button_state(null, [ENTER], [START, RIGHT_SHOULDER]);
    var select = get_button_state(null, [SHIFT], [BACK, LEFT_SHOULDER]);
  
    return {
      pressed: { 
        B: b.pressed, 
        A: a.pressed, 
        X: x.pressed,
        Y: y.pressed,

        START: start.pressed,
        SELECT: select.pressed,
      },
      just_pressed: { 
        B: b.just_pressed, 
        A: a.just_pressed, 
        X: x.just_pressed, 
        Y: y.just_pressed,

        START: start.just_pressed,
        SELECT: select.just_pressed,
      }
    };
  }
  
  static inline function get_button_state(
    vb_id: Null<FlxVirtualInputID>, 
    kb_keys: Array<flixel.input.keyboard.FlxKey>,
    gb_keys: Array<flixel.input.gamepad.FlxGamepadInputID>
  ): {pressed: Bool, just_pressed: Bool} {
    var vb = vb_id != null ? virtualpad.getButton(vb_id) : null;
    return {
      pressed: (vb != null && vb.pressed) || FlxG.keys.anyPressed(kb_keys) || (gamepad != null && gamepad.anyPressed(gb_keys)),
      just_pressed: (vb != null && vb.justPressed) || FlxG.keys.anyJustPressed(kb_keys)|| (gamepad != null && gamepad.anyJustPressed(gb_keys)),
    };
  }

  static public var dpad(get, never): Dpad;
  static inline function get_dpad(): Dpad {
    var up = get_button_state(UP, [UP], [DPAD_UP]);
    var down = get_button_state(DOWN, [DOWN], [DPAD_DOWN]);
    var left = get_button_state(LEFT, [LEFT], [DPAD_LEFT]);
    var right = get_button_state(RIGHT, [RIGHT], [DPAD_RIGHT]);

    return {
      pressed: { 
        UP: up.pressed, 
        DOWN: down.pressed, 
        LEFT: left.pressed,
        RIGHT: right.pressed,
      },
      just_pressed: { 
        UP: up.just_pressed, 
        DOWN: down.just_pressed, 
        LEFT: left.just_pressed,
        RIGHT: right.just_pressed,
      }
    };
  }

  static public function init() {
    menu_button = new ButtonPrimary(0,0, "");
    menu_button.resize(24, 24);
    menu_button.addIcon(new FlxSprite("assets/images/hamburger.png"));
    menu_button.alpha = ui_alpha;
    menu_button.x = FlxG.width - menu_button.width - 4;
    menu_button.y = 4;

		virtualpad = new FlxVirtualPad(FlxDPadMode.FULL, FlxActionMode.A_B_X_Y);

    virtualpad.alpha = ui_alpha;
    virtualpad.x = 4;
    virtualpad.y += 4;

    var up = virtualpad.getButton(UP);
    button_style(up, ">", 0x8981a4);
    up.label.angle = -90;
    
    var down = virtualpad.getButton(DOWN);
    button_style(down, "<", 0x8981a4);
    down.label.angle = -90;

    var left = virtualpad.getButton(LEFT);
    button_style(left, "<", 0x8981a4);
    
    var right = virtualpad.getButton(RIGHT);
    button_style(right, ">", 0x8981a4);

    var a = virtualpad.getButton(A);
    button_style(a, "a", 0xdc7c7c);

    var b = virtualpad.getButton(B);
    button_style(b, "b", 0xe5ca5f);

    var x = virtualpad.getButton(X);
    button_style(x, "x", 0x818add);

    var y = virtualpad.getButton(Y);
    button_style(y, "y", 0x7dd292);

		gamepad = FlxG.gamepads.lastActive;
    FlxG.signals.preUpdate.add(function() {
		  if(FlxG.gamepads.lastActive == null) gamepad = null else gamepad = FlxG.gamepads.lastActive;
    });
  }

  static function button_style(button: FlxVirtualPadButton, name: String, color: Int) {
    button.text = name;
    button.label.autoSize = false;
    button.label.size = 16;
    button.label.color = 0xffffffff;
    button.label.offset.x -= 7;
    button.label.offset.y -= 3;
    button.label.alpha = ui_alpha;
    button.loadGraphic("assets/images/virtualpad/button.png", true, 24, 24);
    button.color = color;
    button.setGraphicSize(36, 36);
    button.updateHitbox();
  }
}