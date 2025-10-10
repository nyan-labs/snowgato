package core;

import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.editors.tiled.TiledImageLayer;
import flixel.addons.editors.tiled.TiledImageTile;
import flixel.addons.editors.tiled.TiledLayer.TiledLayerType;
import flixel.addons.editors.tiled.TiledLayer;
import flixel.addons.editors.tiled.TiledMap.FlxTiledMapAsset;
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
class TiledLevel extends TiledMapExt {
	public var tiles: FlxGroup;
	/** special objects that do a specific function depending on their `class`/`type`, doesn't follow a strict grid */
	public var objects_layer: FlxGroup;

	public var collidable_tile_layers:Array<FlxTilemap>;
	public var collidable_objects:FlxTypedGroup<SpriteExt>;

	/** images, doesn't follow a strict grid */
	public var images_layer:FlxGroup;

	public function new(tiled_level:FlxTiledMapAsset, state: states.Game) {
		super(tiled_level);
		tiles = new FlxGroup();

		images_layer = new FlxGroup();
		objects_layer = new FlxGroup();

		collidable_tile_layers = new Array<FlxTilemap>();
		collidable_objects = new FlxTypedGroup<SpriteExt>();

		FlxG.camera.setScrollBoundsRect(0, 0, fullWidth, fullHeight, true);

		load_images();

		for(layer in layers) {
			if(layer.type != TiledLayerType.TILE) continue;
			var tile_layer: TiledTileLayer = cast layer;
			
			var tilemaps: Map<Int, FlxTilemapExt> = new Map();

			for(tile_i => tile in tile_layer.tileArray) {
				// its air anyways
				if(tile == 0) continue;
				// trace(tile, tile_i);
				
				var tileset: TiledTileSet = null; 
				for(ts in tile_layer.map.tilesets) {
					//ts pmo
					// trace(tile >= ts.firstGID, tile < (ts.firstGID + ts.numTiles));
					// trace(ts.firstGID, tile);
					if(tile >= ts.firstGID && tile < (ts.firstGID + ts.numTiles)) {
						tileset = ts;
						break;
					}
					continue;
				}

				var source_tileset: haxe.xml.Access = null;
				for(ts in source.nodes.tileset) {
					if(Std.parseInt(ts.att.firstgid) == tileset.firstGID) {
						source_tileset = ts;
						break;
					}
					continue;
				}

				if(tileset == null || source_tileset == null || tileset.imageSource == null) continue;
				var tsx_path = new Path(source_tileset.att.source);
				var image_path = new Path(tileset.imageSource);
				var spritesheet_path = Path.join([Path.directory(Path.normalize(layer.map.rootPath + tsx_path)), image_path.file + "." + image_path.ext]);
				
				var tilemap: FlxTilemapExt = tilemaps.get(tileset.firstGID);
				if(tilemap == null) {
					tilemap = new FlxTilemapExt();
					tilemap.loadMapFromArray([for(i in 0...(width * height)) 0], width, height, spritesheet_path, tileset.tileWidth, tileset.tileHeight, OFF, tileset.firstGID, 1, 1);
				}
				
				tilemap.setTileIndex(tile_i, tile);
				
				// could be a regular FlxTilemap if there are no animated tiles
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

				tilemaps.set(tileset.firstGID, tilemap);
			}
				
			for(tilemap in tilemaps) {
				tiles.add(tilemap);
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
        load_collidable_object(layer, o, state);
			}
		}
	}

	function load_collidable_object(layer: TiledLayer, object: TiledObject, state: states.Game) {    
    if(object.gid == -1) return;
		
		var tileset: TiledTileSet = this.getGidOwner(object.gid);

		var source_tileset: haxe.xml.Access = null;
		for(ts in source.nodes.tileset) {
			if(Std.parseInt(ts.att.firstgid) == tileset.firstGID) {
				source_tileset = ts;
				break;
			}
			continue;
		}

		if(tileset == null || source_tileset == null || tileset.imageSource == null) return;
		var tsx_path = new Path(source_tileset.att.source);
		var image_path = new Path(tileset.imageSource);
		var spritesheet_path = Path.join([Path.directory(Path.normalize(layer.map.rootPath + tsx_path)), image_path.file + "." + image_path.ext]);

    var rect = tileset.getRect(object.gid);
    if(rect == null) return;

		var index = (object.gid - tileset.firstGID);

		var tilesize = tileset.tileWidth;

		var tilex = (index % tileset.numRows) * tilesize;
		var tiley = Math.floor(index / tileset.numCols) * tilesize;
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

    tiles.add(sprite);
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
			var sprite = new FlxSprite(image.x, image.y, layer.map.rootPath + image.imagePath);
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

	public function get_object_by_id(id: String) {
		for(object in objects_layer) {
			object;
		}
	}
}
