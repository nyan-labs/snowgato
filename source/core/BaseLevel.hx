package core;

import core.tilemap.Tile;
import core.tilemap.Tilemap;
import core.tilemap.TilemapInstance;
import entities.EntityPlayer;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTileblock;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxTween;
import flixel.ui.FlxVirtualPad;
import flixel.util.FlxCollision;
import flixel.util.FlxSignal.FlxTypedSignal;
import haxe.EnumTools;
import haxe.io.Path;
import ui.ButtonPrimary;
import ui.DialogMessage;

class BaseLevel extends FlxState {
  public var tilemap: Tilemap;
  public var instance: TilemapInstance;

	public var player: EntityPlayer;

  // public var HUD: DirectionalLayout;

  // public var menu_button: ButtonPrimary;

  public var dialog: DialogMessage;

  public var path: String;
  
  override public function new(path: String) {
    super();

    this.path = path;
  }

  override public function create() {
    super.create();

    bgColor = 0xff000000; //0xff0f0915

    var level_file = Path.join([path, "level.json"]);

		tilemap = Tilemap.from_file(level_file);
    instance = new TilemapInstance(tilemap);

    add(instance);

    instance.run();

    dialog = new DialogMessage();
    dialog.onvisible.add(function() {
      if(dialog.visible) {
        player.state = DIALOG; 
      } else {
        player.state = NONE;
      }
    });

    add(dialog);


    FlxG.signals.preStateSwitch.addOnce(function() {
		  FlxG.state.remove(Controls.virtualpad);
      FlxG.state.remove(Controls.menu_button);
    });

    FlxG.state.add(Controls.virtualpad);

    Controls.menu_button.onUp.callback = function() {
      openSubState(new states.substates.Menu());
    }
    FlxG.state.add(Controls.menu_button);
  }

  override public function update(elapsed) {
    super.update(elapsed);

    if(Controls.button.just_pressed.START) Controls.menu_button.onUp.fire();

		// tilemap.collide_wi_level(player);

    // if(player != null) {
    //   {
    //     var object = tilemap.get_sprite_touching_object(player);
    //     if(object != null) {
    //       if(player.can_interact(true)) {
    //         object.on_interact.dispatch(elapsed);
    //       }
    //     }
    //   }
    //   {
    //     var object = tilemap.get_sprite_on_object(player);
    //     if(object != null) object.on_step.dispatch(elapsed);
    //   }
    // }
  }
}