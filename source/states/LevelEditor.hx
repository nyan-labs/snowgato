package states;

import core.StateExt;
import core.tilemap.Layer;
import core.tilemap.Tile;
import core.tilemap.Tilemap;
import core.tilemap.TilemapInstance;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import ui.ButtonPrimary;

class LevelEditor extends StateExt {
  var tilemap: Tilemap; 

  override public function create() {
		super.create();

    tilemap = new Tilemap(Tilemap.template(24, 24));

    var layer_1 = new Layer(0);
    tilemap.layers.add(layer_1);

    var button = new ButtonPrimary(0, FlxG.height - 24, "penis", function() {
      layer_1.add(new Tile());
    });

    var instance = new TilemapInstance(tilemap);

    // do rendering a little differently ig? idk
    // add(instance);
    add(button);
	}
}