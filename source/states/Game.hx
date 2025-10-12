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
import flixel.util.FlxSignal.FlxTypedSignal;
import ui.ButtonPrimary;
import ui.DialogMessage;
import ui.DirectionalLayout;

class Game extends FlxState {
	public var player: Player;

  public var level: core.TiledLevel;

  public var HUD: DirectionalLayout;
  public var menu_button: ButtonPrimary;

  public var dialog: DialogMessage;

  public final on_update = new FlxTypedSignal<Float->Void>();
  
  override public function create() {
    super.create();

    bgColor = 0xff000000; //0xff0f0915

		var level_name = "tutorial";
		var path = 'assets/levels/${level_name}';

		level = new core.TiledLevel('${path}/level.tmx', this);

		var script = openfl.Assets.getText('${path}/level.hscript');

		var interp = new hscript.Interp();
		var parser = new hscript.Parser();
    parser.allowTypes = true;

		interp.variables.set("FlxG", FlxG);
		interp.variables.set("Math", Math);
		interp.variables.set("Std", Std);
		interp.variables.set("Game", this);

		var ast = parser.parseString(script);

		add(level.tiles);

		add(level.images_layer);

		add(level.object_layer);
		add(level.text_layer);
		add(level.marker_layer);

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
      if(dialog.visible) player.state = DIALOG else player.state = NONE;
      // if(dialog.visible) player.can_move = false else player.can_move = true;
    });

    add(dialog);

		interp.execute(ast);
  }

  override public function update(elapsed) {
    super.update(elapsed);
    on_update.dispatch(elapsed);

		level.collide_with_level(player);

    if(player != null) {
      var object = level.get_sprite_touching_object(player);
      if(object != null) {
        if(player.can_interact(true)) {
          object.on_interact.dispatch(elapsed);
        }
      }
    }
  }
}
