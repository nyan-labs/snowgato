package core;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import haxe.ds.Vector;
import ui.ButtonPrimary;

typedef Focusable = ButtonPrimary;
typedef Focusables = Array<Focusable>;

var input_focus: Bool = false;

class FocusManager extends FlxBasic {
  public var state: FlxState;

  public var show: Bool = true;
  
  /** set by input activation */
  static var input_focus: Bool = false;

  public var focus: Null<Focusable>;
  public var members: Focusables;

  public function new(state: FlxState) {
    super();
    this.state = state;
    this.members = new Array();
  }

  public function add(member: Focusable, focus: Bool = false) {
    members.push(member);
    state.add(member);

    if(focus) this.focus = member;
  }

  public function remove(member: Focusable) {
    members.remove(member);
    state.remove(member);
  }

  override public function update(elapsed: Float) {
    var move_x = 0;
    var move_y = 0;
  
    if(Controls.dpad.just_pressed.UP) move_y = -1;
    if(Controls.dpad.just_pressed.DOWN) move_y = 1;
    if(Controls.dpad.just_pressed.LEFT) move_x = -1;
    if(Controls.dpad.just_pressed.RIGHT) move_x = 1;

    if(FlxG.keys.firstJustPressed() != -1 || (Controls.gamepad != null && Controls.gamepad.firstJustPressedID() != -1)) {
      if(
        Controls.dpad.pressed.UP ||
        Controls.dpad.pressed.DOWN ||
        Controls.dpad.pressed.LEFT ||
        Controls.dpad.pressed.RIGHT
      ) {
        FocusManager.input_focus = true;
      };
    }
    if(FlxG.mouse.justPressed) {
      FocusManager.input_focus = false;
    }

    if(move_x != 0 || move_y != 0) {
      if(focus != null && !focus.focus) { focus.focus = true; return; } // :3

      var best_item: Focusable = null;
      var best_dist = Math.POSITIVE_INFINITY;
  
      if(members.length == 1) {
        best_item = members[0];
      } else {
        for(member in members) {
          if(member == focus) continue;
          var mx = member.x;
          var my = member.y;
  
          var fx = if(focus != null) focus.x else 0;
          var fy = if(focus != null) focus.y else 0;
  
          var dx = mx - fx;
          var dy = my - fy;
    
          if(move_x == 1 && dx <= 0) continue;
          if(move_x == -1 && dx >= 0) continue;
          if(move_y == 1 && dy <= 0) continue;
          if(move_y == -1 && dy >= 0) continue;
    
          // i hate math so much 
          var dist = dx * dx + dy * dy;
          if(dist < best_dist) {
            best_dist = dist;
            best_item = member;
          }
        }
      }
  
      if(best_item != null) {
        for(member in members) {
          member.focus = false;
        }
        best_item.focus = true;
        focus = best_item;
      }
    }
    if(focus != null) {
      if(show) {
        if(FocusManager.input_focus) focus.focus = true;
        if(!FocusManager.input_focus) focus.focus = false;
      } else {
        focus.focus = false;
      }

      // we should wait for input yk
      if(focus.focus && focus.onUp != null) {
        if(FocusManager.input_focus && Controls.button.just_pressed.A) focus.onUp.fire();
      }
    }
  }
}