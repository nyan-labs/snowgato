package core;

import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.editors.tiled.TiledImageLayer;
import flixel.addons.editors.tiled.TiledImageTile;
import flixel.addons.editors.tiled.TiledLayer.TiledLayerType;
import flixel.addons.editors.tiled.TiledLayer;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledTilePropertySet;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.addons.tile.FlxTileSpecial;
import flixel.addons.tile.FlxTilemapExt;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.math.FlxVelocity;
import flixel.tile.FlxTile;
import flixel.tile.FlxTilemap;
import flixel.util.FlxCollision;
import flixel.util.FlxSpriteUtil;
import haxe.Timer;
import haxe.io.Path;
import openfl.display.BitmapData;
import openfl.utils.Assets;
import utils.IsTouching.Touching;

/**
 * @author Samuel Batista
 * @edit qzip
*/
class TiledLevel extends TiledMap {
	// For each "Tile Layer" in the map, you must define a "tileset" property which contains the name of a tile sheet image
	// used to draw tiles in that layer (without file extension). The image file must be located in the directory specified bellow.
	inline static var c_PATH_LEVEL_TILESHEETS = "assets/spritesheets/";

	// Array of tilemaps used for collision
	public var foreground_tiles:FlxGroup;
	public var objects_layer:FlxGroup;
	public var background_layer:FlxGroup;

	public var collidable_tile_layers:Array<FlxTilemap>;
	public var collidable_objects:FlxTypedGroup<SpriteExt>;

	// Sprites of images layers
	public var images_layer:FlxGroup;

	public function new(tiled_level:FlxTiledMapAsset, state: states.Game) {
		super(tiled_level);

		images_layer = new FlxGroup();
		foreground_tiles = new FlxGroup();
		objects_layer = new FlxGroup();
		background_layer = new FlxGroup();

		collidable_tile_layers = new Array<FlxTilemap>();
		collidable_objects = new FlxTypedGroup<SpriteExt>();

		FlxG.camera.setScrollBoundsRect(0, 0, fullWidth, fullHeight, true);

		load_images();

		for(layer in layers) {
			if(layer.type != TiledLayerType.TILE) continue;
			var tile_layer: TiledTileLayer = cast layer;

			var tile_sheetname: String = tile_layer.properties.get("tileset");

			if(tile_sheetname == null) throw '"tileset" property not defined for the "${tile_layer.name}" layer. Please add the property to the layer.';

			var tile_set: TiledTileSet = null;
			for(ts in tilesets) {
				if(ts.name == tile_sheetname) {
					tile_set = ts;
					break;
				}
			}

			if(tile_set == null) throw 'tileset "${tile_sheetname}" not found. Did you misspell the "${tile_set}" property in "${tile_layer.name}" layer?';

			var image_path = new Path(tile_set.imageSource);
			var stylesheet_path = c_PATH_LEVEL_TILESHEETS + image_path.file + "." + image_path.ext;

			// could be a regular FlxTilemap if there are no animated tiles
			var tilemap = new FlxTilemapExt();
			tilemap.loadMapFromArray(tile_layer.tileArray, width, height, stylesheet_path, tile_set.tileWidth, tile_set.tileHeight, OFF, tile_set.firstGID, 1, 1);

			if(tile_layer.properties.contains("animated")) {
				var tileset = tilesets["level"];
				var special_tiles: Map<Int, TiledTilePropertySet> = new Map();
				for(tile_prop in tileset.tileProps) {
					if(tile_prop != null && tile_prop.animationFrames.length > 0) {
						special_tiles[tile_prop.tileID + tileset.firstGID] = tile_prop;
					}
				}
				var tile_layer: TiledTileLayer = cast layer;
				tilemap.setSpecialTiles([
					for(tile in tile_layer.tiles)
						if(tile != null && special_tiles.exists(tile.tileID))
							get_animated_tile(special_tiles[tile.tileID], tileset)
						else
							null
				]);
			}

			if(
        !tile_layer.properties.contains("cancollide") || 
        tile_layer.properties.get("cancollide") == "true"
      ) {
				collidable_tile_layers.push(tilemap);
      }

      if(tile_layer.properties.get("zone") == "front") {
				foreground_tiles.add(tilemap);
      } else {
				background_layer.add(tilemap);
      }
		}
		load_objects(state);
	}

	function get_animated_tile(props: TiledTilePropertySet, tileset: TiledTileSet): FlxTileSpecial {
		var special = new FlxTileSpecial(1, false, false, 0);
		var n = props.animationFrames.length;
		var offset = Std.random(n);
		special.addAnimation([
			for(i in 0...n) props.animationFrames[(i + offset) % n].tileID + tileset.firstGID
		], (1000 / props.animationFrames[0].duration));
		return special;
	}

	public function load_objects(state: states.Game) {
		for(layer in layers) {
			if(layer.type != TiledLayerType.OBJECT) continue;
			var object_layer: TiledObjectLayer = cast layer;

			for(o in object_layer.objects) {
        load_object(state, o, object_layer, objects_layer);
        load_image_object(layer, o, state);
			}
		}
	}

	function load_image_object(layer: TiledLayer, object: TiledObject, state: states.Game) {    
    if(object.gid == -1) return;
		
		var owner: TiledTileSet = this.getGidOwner(object.gid);
    if(owner == null) return;

		var image_path = new Path(owner.imageSource);
		var spritesheet_path = c_PATH_LEVEL_TILESHEETS + image_path.file + "." + image_path.ext;

		trace(spritesheet_path);
		
    var rect = owner.getRect(object.gid);
    if(rect == null) return;

		var index = (object.gid - owner.firstGID);

		var tilesize = owner.tileWidth;

		var tilex = (index % owner.numRows) * tilesize;
		var tiley = Math.floor(index / owner.numCols) * tilesize;
		var tile_image = Assets.getBitmapData(spritesheet_path);

    var sprite = new SpriteExt(object.x, object.y-object.height);
		sprite.makeGraphic(24, 24, 0x00000000, true, 'tm${object.gid}');
		sprite.pixels.copyPixels(tile_image, new openfl.geom.Rectangle(tilex, tiley, tilesize, tilesize), new openfl.geom.Point(0, 0));

		sprite.setGraphicSize(object.width, object.height);
		sprite.setSize(object.width, object.height);
		sprite.offset.x = -(object.width/2 - tilesize/2);
		sprite.offset.y = -(object.height/2 - tilesize/2);

    if(object.flippedHorizontally) sprite.flipX = true;
    if(object.flippedVertically) sprite.flipY = true;
    if(object.angle != 0) {
      sprite.angle = object.angle;
      sprite.antialiasing = true;
    }

    if(object.properties.contains("depth")) {
      var depth = Std.parseFloat(object.properties.get("depth"));
      sprite.scrollFactor.set(depth, depth);
    }

		if(object.properties.get("cancollide") == "true") {
			collidable_objects.add(sprite);
		}
		if(object.properties.get("anchored") == "true") {
			sprite.immovable = true;
		}
		if(object.properties.contains("dialog")) {
			var dialog_string = object.properties.get("dialog");
			var dialog_array = dialog_string.split(";");

			sprite.oninteract.add(function(_) {
				state.dialog.dialog = dialog_array;
				state.dialog.start();
			});
		}

    background_layer.add(sprite);
	}

	function load_object(state:states.Game, o:TiledObject, g:TiledObjectLayer, group:FlxGroup) {
		var x:Int = o.x;
		var y:Int = o.y;

		// objects in tiled are aligned bottom-left (top-left in flixel)
		if(o.gid != -1)
			y -= g.map.getGidOwner(o.gid).tileHeight;

		switch (o.type.toLowerCase()) {
			case "player_start":
        var player = new entities.Player();
        player.setPosition(x, y);

        FlxG.camera.follow(player, FlxCameraFollowStyle.NO_DEAD_ZONE, 0.25);

        state.player = player;

				group.add(player);
		}
	}

	public function load_images() {
		for(layer in layers) {
			if(layer.type != TiledLayerType.IMAGE) continue;

			var image: TiledImageLayer = cast layer;
			var sprite = new FlxSprite(image.x, image.y, c_PATH_LEVEL_TILESHEETS + image.imagePath);
			images_layer.add(sprite);
		}
	}

	public function get_touched_object(sprite: FlxSprite): Null<SpriteExt> {
		for(object in collidable_objects) {
			var touching = Touching.is_touching_sprite(object, sprite, 5.0, true);

			if(touching) return object;
		}
		return null;
	}
	public function collide_with_level(obj: FlxObject, ?notifyCallback: FlxObject->FlxObject->Void, ?processCallback: FlxObject->FlxObject->Bool):Bool {
		if(collidable_tile_layers == null)
			return false;

		for(map in collidable_tile_layers) {
			// IMPORTANT: Always collide the map with objects, not the other way around.
			//            This prevents odd collision errors (collision separation code off by 1 px).
			if(FlxG.overlap(map, obj, notifyCallback, processCallback != null ? processCallback : FlxObject.separate)) {
				return true;
			}
		}
		if(FlxG.overlap(collidable_objects, obj, notifyCallback, processCallback != null ? processCallback : FlxObject.separate)) {
			return true;
		}
		return false;
	}
}
