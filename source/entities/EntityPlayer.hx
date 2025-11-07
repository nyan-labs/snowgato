package entities;

import core.Controls;
import core.tilemap.Entity;
import core.tilemap.Tile;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxVirtualPad;
import flixel.util.FlxCollision;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.util.FlxSpriteUtil;
import openfl.Memory;

enum PlayerState {
  NONE;

  MENU;
  DIALOG;
}

class EntityPlayer extends Entity {
  public var state: PlayerState = NONE;
  
  public var can_move = true;

  public var walk_speed = 100;
  public var sprint_speed = 175;

  public var speed = 0;

	public var pad: FlxVirtualPad;

  public final on_move = new FlxTypedSignal<Float->Void>();

  public function new(?id: String) {
    super(id);

    collidable = true;
    pad = Controls.virtualpad;

    this.speed = walk_speed;

    loadGraphic("assets/images/him.png", true, 28, 42);

    animation.add("idle-up", [0], 0, false);
    animation.add("idle-down", [1], 0, false);
    animation.add("idle-left", [2], 0, false);
    animation.add("idle-right", [3], 0, false);

    animation.add("walk-up", [4, 8], 7, true);
    animation.add("walk-down", [5, 9], 7, true);
    animation.add("walk-left", [2, 6], 7, true);
    animation.add("walk-right", [3, 7], 7, true);

    animation.play("idle-down");

    height = 20;
    width = 20;
    offset.set(4, 22);
  }

  public function can_interact(just_pressed: Bool = false): Bool {
		var interact = just_pressed ? Controls.button.just_pressed.A : Controls.button.pressed.A;

    return state != DIALOG && interact;
  }
  
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    switch(state) {
      case DIALOG:
        can_move = false;
      case NONE:
        can_move = true;
      default:
    }

		// if(FlxG.collide(collision, this)) return;

    // flash has a bug with shift + key..
    //   if you press it and release it and with shift,
    //   the key will continue to be pressed for some reason 

		var up = Controls.dpad.pressed.UP;
		var down = Controls.dpad.pressed.DOWN;
		var left = Controls.dpad.pressed.LEFT;
		var right = Controls.dpad.pressed.RIGHT;
		var sprint = Controls.button.pressed.B;

    if(sprint) speed = sprint_speed; else speed = walk_speed;

    //anim speed stuff for sprint
    if(animation.curAnim != null) animation.curAnim.frameRate = 7 * speed / walk_speed;

    if(can_move) {
      if(up) {
        facing = UP;
        velocity.y = -speed; 
      } else if(down) { 
        facing = DOWN;
        velocity.y = speed; 
      }
      if(left) {
        facing = LEFT;
        velocity.x = -speed; 
      } else if(right) {
        facing = RIGHT;
        velocity.x = speed;
      }
    }
      
    var direction = "none";
    switch(facing) {
      case UP: 
        direction = "up";
      case DOWN: 
        direction = "down";
      case LEFT: 
        direction = "left";
      case RIGHT: 
        direction = "right";
      default:
        direction = "none";
    }
    if((velocity.x != 0 || velocity.y != 0)) {
      animation.play('walk-${direction}'); 
    } else {
      animation.play('idle-${direction}'); 
    }

    if(can_move && (velocity.x != 0 || velocity.y != 0)) {
      on_move.dispatch(elapsed);
    }
    
    drag.set(speed*8, speed*8);
  }
}