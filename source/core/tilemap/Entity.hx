package core.tilemap;

import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.system.FlxAssets.FlxGraphicAsset;
import openfl.utils.Assets;

//refactor
class Entity extends FlxSprite {
  public var collidable: Bool = true;

  public var id(default, null): String;

	override public function new(?id: String) {
    super();

    this.id = id;
  }

  // public function loadTile(graphic: FlxGraphicAsset, animated = false, frameWidth = 0, frameHeight = 0, unique = false, ?key: String) {
  //   super.loadGraphic(graphic, animated, frameWidth, frameHeight, unique, key);

	// 	origin.set(0, 0); // rotation :3


  //   if(object.flippedHorizontally) flipX = true;
  //   if(object.flippedVertically) flipY = true;
  //   if(object.angle != 0) {
  //     angle = object.angle;
  //   }

  //   if(object.properties.contains("depth")) {
  //     var depth = Std.parseFloat(object.properties.get("depth"));
  //     scrollFactor.set(depth, depth);
  //   } 

	// 	if(object.properties.get("cancollide") == "true") {
	// 		// properties.set("cancollide", true);
	// 		// add(sprite);
	// 	}
	// 	if(object.properties.get("anchored") == "true") {
	// 		// properties.set("anchored", true);
	// 		immovable = true;
	// 	}
  // }


  public function overlap(basic: FlxBasic, elapsed: Float) {}

  public function collision(basic: FlxBasic, elapsed: Float) {}
}