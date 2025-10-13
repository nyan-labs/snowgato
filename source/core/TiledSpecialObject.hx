package core;

import flixel.FlxSprite;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxSignal.FlxTypedSignal;
import openfl.utils.Assets;

// if you're gonna access the signal, 
// make sure you **ARE** checking what the access type is
enum AccessType {
  READ;
  WRITE;
  SIGNAL;
}

typedef PropertyKey = String;
typedef PropertyValue = Dynamic;
typedef PropertySignalFunc = AccessType->Void;
typedef PropertySignal = FlxTypedSignal<PropertySignalFunc>;

typedef Property = {
  value: PropertyValue,
  signal: FlxTypedSignal<AccessType->Void>
}

class Properties {
  public function new() {}

  private var data: Map<PropertyKey, Property> = new Map();

  public function get(key: PropertyKey): Null<PropertyValue> {
    for(property_key => property in data) {
      if(key != property_key) continue;
      
      property.signal.dispatch(READ);
      return property.value;
    }
    return null;
  }

  public function set(key: PropertyKey, value: PropertyValue, ?signal: PropertySignalFunc): PropertySignal {
    var property = data.get(key);
    if(property != null) {
      property.signal.dispatch(WRITE);
      
      for(property_key => property in data) {
        if(key != property_key) continue;
        property.value = value;
      }

      return property.signal;
    } else {
      property = {
        value: value,
        signal: new FlxTypedSignal()
      };
      data.set(key, property);
      
      return property.signal;
    }
  }

  public function signal(key: PropertyKey): Null<PropertySignal> {
    for(property_key => property in data) {
      if(key != property_key) continue;
      
      property.signal.dispatch(SIGNAL);
      return property.signal;
    }
    return null;
  }
}

class TiledSpecialObject extends FlxSprite {
  public var on_interact = new FlxTypedSignal<Float->Void>();
  public var on_step = new FlxTypedSignal<Float->Void>();

  public var name = "unknown";

  public var properties: Properties = new Properties();
  // public var actions: Map<String, Dynamic->Dynamic> = new Map();

  public var spritesheet_path: FlxGraphicAsset;
  public var tileset: TiledTileSet;
  public var object: TiledObject;

  public var gid: Int = -1;

  override public function new(?spritesheet_path: FlxGraphicAsset, ?tileset: TiledTileSet, ?object: TiledObject) {
    var x = object != null ? object.x : 0;
    var y = object != null ? object.y : 0;
    super(x, y);
    
    this.spritesheet_path = spritesheet_path;
    this.tileset = tileset;
    this.object = object;
  }

  // mixmatch woooooooo
  public function loadGraphic_from_tiled_object() {
    final gid = this.gid != -1 ? this.gid : object.gid;
		final index = (gid - tileset.firstGID);
		final tilesize = tileset.tileWidth;

		var tilex = (index % tileset.numRows) * tilesize;
		var tiley = Math.floor(index / tileset.numCols) * tilesize;
		var spritesheet_image = Assets.getBitmapData(spritesheet_path);

    setPosition(object.x, object.y-object.height);
		makeGraphic(24, 24, 0x00000000, true, 'tm${gid}');
		pixels.copyPixels(spritesheet_image, new openfl.geom.Rectangle(tilex, tiley, tilesize, tilesize), new openfl.geom.Point(0, 0));

		setGraphicSize(object.width, object.height);
		setSize(object.width, object.height);
		offset.x = -(object.width/2 - tilesize/2);
    offset.y = -(object.height/2 - tilesize/2);

		origin.set(0, 0); // rotation :3
  }

  public function tiled_swap_tile(index: Int) {
    this.gid = tileset.firstGID + index;
    loadGraphic_from_tiled_object();
  }
  public function tiled_swap_tile_gid(gid: Int) {
    this.gid = gid;
    loadGraphic_from_tiled_object();
  }

  override public function toString() {
    final old = super.toString();
    return '$name | $old';
  }
}