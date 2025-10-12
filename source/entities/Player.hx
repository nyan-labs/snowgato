package entities;

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

class Player extends FlxSprite {
  public var state: PlayerState = NONE;

  public var can_move = true;

  public var walk_speed = 100;
  public var sprint_speed = 175;

  public var speed = 0;

	public var pad: FlxVirtualPad;

  public final on_move = new FlxTypedSignal<Float->Void>();

  public function new() {
    super();

    this.speed = walk_speed;

		pad = new FlxVirtualPad(FlxDPadMode.FULL, FlxActionMode.A_B_C);

    // todo: redesign them awful graphics lol
    pad.getButton(UP).loadGraphic("assets/images/virtualpad/up.png", true, 42, 42);
    pad.getButton(DOWN).loadGraphic("assets/images/virtualpad/down.png", true, 42, 42);
    pad.getButton(LEFT).loadGraphic("assets/images/virtualpad/left.png", true, 42, 42);
    pad.getButton(RIGHT).loadGraphic("assets/images/virtualpad/right.png", true, 42, 42);
    pad.getButton(A).loadGraphic("assets/images/virtualpad/a.png", true, 42, 42);
    pad.getButton(B).loadGraphic("assets/images/virtualpad/b.png", true, 42, 42);
    pad.getButton(C).loadGraphic("assets/images/virtualpad/c.png", true, 42, 42);

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
		var interact = just_pressed 
      ? pad.getButton(A).justPressed || FlxG.keys.anyJustPressed([SPACE, Z])
      : pad.getButton(A).pressed || FlxG.keys.anyPressed([SPACE, Z]);

    return interact;
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

		var up = pad.getButton(UP).pressed || FlxG.keys.anyPressed([UP, W]);
		var down = pad.getButton(DOWN).pressed || FlxG.keys.anyPressed([DOWN, S]);
		var left = pad.getButton(LEFT).pressed || FlxG.keys.anyPressed([LEFT, A]);
		var right = pad.getButton(RIGHT).pressed || FlxG.keys.anyPressed([RIGHT, D]);
		var sprint = pad.getButton(B).pressed || FlxG.keys.anyPressed([SHIFT, X]);

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