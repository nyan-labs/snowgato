package states;

import entities.Player;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTileblock;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxTween;
import flixel.ui.FlxVirtualPad;
import ui.ButtonPrimary;
import ui.DialogMessage;
import ui.DirectionalLayout;

class Game extends FlxState {
	public var player: Player;

  public var level: core.TiledLevel;

  public var HUD: DirectionalLayout;
  public var menu_button: ButtonPrimary;

  public var dialog: DialogMessage;

  override public function create() {
    super.create();

    bgColor = 0xff000000; //0xff0f0915

    level = new core.TiledLevel("assets/levels/tutorial.tmx", this); 

		add(level.background_layer);

		add(level.images_layer);

		add(level.objects_layer);

		add(level.foreground_tiles);

    HUD = new DirectionalLayout();
    HUD.anchor = true;
    HUD.ltr = true;
    HUD.x = FlxG.width - 4;
    HUD.y = 4;
    HUD.direction = HORIZONTAL;

    menu_button = new ButtonPrimary(0, 0, "", function() {
      // todo
    });
    menu_button.resize(20, 20);
    menu_button.addIcon(new FlxSprite("assets/images/hamburger.png"));
    HUD.add(menu_button);

    add(HUD);

    #if mobile
		add(player.pad);
    #end

    dialog = new DialogMessage();
    dialog.onvisible.add(function() {
      if(dialog.visible) player.can_move = false else player.can_move = true;
    });

    add(dialog);
  }

  override public function update(elapsed) {
    super.update(elapsed);

		level.collide_with_level(player);

    var object = level.get_touched_object(player);
    if(object != null) {
      if(player.can_interact(true)) {
        object.oninteract.dispatch(elapsed);
      }
    }
  }
}
