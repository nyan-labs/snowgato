package core.tilemap;

import core.tilemap.Entity;
import entities.EntityPlayer;
import flags.FlagPlayer;
import flags.FlagSpammer;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import haxe.DynamicAccess;
import haxe.Json;
import haxe.io.Path;
import haxe.iterators.DynamicAccessIterator;
import haxe.iterators.DynamicAccessKeyValueIterator;
import haxe.macro.Context;
import macros.MacroTilemap;
import macros.MacroUtils;
import openfl.Assets;

// this is only for reference and to find bugs easier while parsing
typedef TilemapJSON = {
  type: String,
  ?name: String,

  script: String, // path or raw script
  properties: DynamicAccess<Dynamic>,
  tilesets: Array<String>,

  columns: Int,
  rows: Int,

  width: Int,
  height: Int,

  flags: Array<{
    id: String,
    type: String,
    x: Int,
    y: Int
  }>,
  entities: Array<{
    id: String,
    type: String,
    width: Int,
    height: Int,
    x: Int,
    y: Int
  }>,
  layers: Array<{
    order: Int,
    name: String,
    collide: Bool,
    tiles: Array<Array<String>>
  }>
};

// do more than just data parsing
// do like actual object initialization
class Tilemap {
  public var name(default, null): String;

  // finish serialization for level data 

  public var layers(default, null): FlxTypedGroup<Layer>;
  public var entities(default, null): FlxTypedGroup<Entity>;
  public var flags(default, null): FlagManager;
  
  public var columns(default, null): Int;
  public var rows(default, null): Int;
  
  public var width(default, null): Int;
  public var height(default, null): Int;

  public var source_file(default, null): Null<String>;
  public var source_data(default, null): TilemapJSON;
  
  public function new(data: TilemapJSON, ?file_path: String) {
    this.source_data = data; 
    this.source_file = file_path; 
    this.name = data.name;

    // very shallow test but i dont care!
    if(data.type == null || data.type != "tilemap") throw '"$source_file" is not a tilemap';
    
    layers = new FlxTypedGroup();
    entities = new FlxTypedGroup();
    flags = new FlagManager();
    
    columns = data.columns;
    rows = data.rows;
    
    width = data.width;
    height = data.height;

    data.layers.sort((wa, bwa) -> { 
      return wa.order - bwa.order; 
    });

    final tile_list = MacroTilemap.get_tile_classes();

    for(data in data.layers) {
      final layer = new Layer(data.order, data.name, data.collide);

      if(data.tiles.length < columns) throw 'layer "${data.name}", column count must be $columns';
      for(column => tiles in data.tiles) {
        if(column > columns) throw 'layer "${data.name}", column count cannot exceed $columns';

        if(tiles.length < rows) throw 'layer "${data.name}", column $column row count must be $rows';
        if(tiles.length > rows) throw 'layer "${data.name}", column $column row count cannot exceed $rows';

        for(row => raw_tile_id in tiles) {
          var tile_id_split = raw_tile_id.split(":"); // @namespace:id:variation
          if(tile_id_split.length < 2) {
            FlxG.log.warn('invalid tile id "${raw_tile_id}", ignored'); 
          }

          var tile_namespace = tile_id_split[0];
          var tile_id = tile_id_split[1];
          var tile_variation = tile_id_split.length == 3 ? tile_id_split[2] : "default";

          if(tile_id == "@:air") continue;

          var tile_class: Null<Class<Tile>> = null;
          for(tile_ass in tile_list) {
            // '@namespace:id' == '@namespace:id' 
            if('${tile_ass.namespace}:${tile_ass.id}' == '${tile_namespace}:${tile_id}') {
              tile_class = tile_ass;
              break;
            }
          }

          if(tile_class == null) {
            FlxG.log.warn('unknown tile id "${raw_tile_id}", ignored'); 
            continue;
          }

          final tile = Type.createInstance(tile_class, [tile_variation, row, column]);
          tile.setSize(width, height);
          tile.setPosition(row * width, column * height);

          layer.add(tile);
        }
      }

      layers.add(layer);
    }
    
    MacroUtils.register_import_files("source/entities");
    for(data in data.entities) {
      var arr_class_path = data.type.split(".");
      var class_type = arr_class_path[arr_class_path.length-1];

      final ass = Type.resolveClass('entities.${class_type}');

      if(ass != null) {
        var instance: Entity = Type.createInstance(ass, [data.id]);
        instance.setSize(data.width, data.height);
        instance.setPosition(data.x, data.y);

        entities.add(instance);
      } else {
        FlxG.log.warn('unknown entity class "${class_type}", ignored');
      }
    }

    MacroUtils.register_import_files("source/flags");
    for(data in data.flags) {
      var arr_class_path = data.type.split(".");
      var class_type = arr_class_path[arr_class_path.length-1];

      final ass = Type.resolveClass('flags.${class_type}');

      if(ass != null) {
        var instance: Flag = Type.createInstance(ass, [data.id, data.x, data.y]);

        flags.add(instance);
      } else {
        FlxG.log.warn('unknown flag class "${class_type}", ignored');
      }
    }
    // comfort
    // make this toggleable
    FlxG.camera.setScrollBoundsRect(
      0, 
      0, 
      Math.max(FlxG.width, width*rows), 
      Math.max(FlxG.height, height*columns),
      true
    );
		FlxG.worldBounds.set(0, 0, width*rows, height*columns);
  }

  // public function save(): TilemapJSON {
  //   var layers: Array<TilemapLayerJSON> = [];  
  //   for(_ => layer in this.layers.members) {
  //     var tiles = [];
  //     for(i => tile in layer.members) {
  //       trace(tile.id, tile.column, tile.row);
  //       if(!(tiles[tile.column] is Array)) tiles[tile.column] = [];

  //       tiles[tile.column][tile.row] = tile.id;
  //     }

  //     layers.push({
  //       name: layer.name, 
  //       collide: layer.collide, 
  //       tiles: tiles
  //     });
  //   }

  //   var entities: Array<TilemapEntityJSON> = [];  
  //   for(_ => entity in this.entities.members) {
  //     entities.push({
  //       id: entity.id,
  //       type: Type.getClassName(Type.getClass(entity)),
  //       width: Std.int(entity.width),
  //       height: Std.int(entity.height),
  //       x: Std.int(entity.x),
  //       y: Std.int(entity.y),
  //     });
  //   }

  //   return {
  //     type: "tilemap",
  //     name: this.name,

  //     script: this.source_data.script,
  //     properties: {},
  //     tilesets: [],
    
  //     columns: this.columns,
  //     rows: this.rows,
    
  //     width: this.width,
  //     height: this.height,

      
  //     layers: layers,
  //     entities: entities,
  //     flags: {}
  //   }
  // }


  static public function template(width: Int = 24, height: Int = 24): TilemapJSON {
    return {
      type: "tilemap",
      script: "",
      properties: {},
      tilesets: [],
      
      rows: 24,
      columns: 24,
      
      width: width,
      height: height,

      layers: [],
      entities: [],
      flags: [],
    }
  }

  static public function parse(source_data: String): TilemapJSON {
    return Json.parse(source_data);
  }
  
  static public function from_data(source_data: String): Tilemap {
    var parsed = parse(source_data);

    return new Tilemap(parsed);
  }

  static public function from_file(source_file: String): Tilemap {
    var source_data = Assets.getText(source_file);
    var parsed = parse(source_data);

    return new Tilemap(parsed, source_file);
  }
}