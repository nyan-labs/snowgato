package core.tilemap;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxContainer.FlxTypedContainer;
import flixel.group.FlxGroup.FlxTypedGroup;

typedef Layers = FlxTypedGroup<Layer>;

typedef Entities = FlxTypedGroup<Entity>;

class TilemapInstance extends FlxTypedGroup<FlxBasic> {
  public var running(default, null): Bool = false;
  public var ran(default, null): Bool = false;

  public var tilemap(default, null): Tilemap;

  public var layers(default, null): Layers;
  public var entities(default, default): Entities;
  public var flags(default, null): FlagManager;

  override public function new(tilemap: Tilemap) {
    super();

    this.tilemap = tilemap;
    this.layers = tilemap.layers;
    this.entities = tilemap.entities;
    this.flags = tilemap.flags;

    add(layers);
    add(entities);
    add(flags);
  }

  public function run() {
    if(!this.ran) {
      this.ran = true;
      flags.create();
    }

    this.running = true; 
  }

  public function reset() {
    flags.reset();
  }

  public function pause() {
    this.running = false; 
  }

  override public function update(elapsed: Float) {
    if(!this.running) return;

    super.update(elapsed);

    /// these look ugly, not sure how to make em pretty tho.
    for(layer in layers) {
      if(layer.collide) {
        FlxG.overlap(layer, flags, 
          (d1: Tile, d2: Entity) -> {
            if(d2.collidable) d2.collision(d1, elapsed);
          }, 

          (d1: Tile, d2: Entity) -> {
            if(d2.collidable) return FlxObject.separate(d1, d2);
            return false;
          }
        );
      }
    }

    FlxG.overlap(entities, flags, 
      (d1: Entity, d2: Entity) -> {
        if(d1.collidable) {
          d1.collision(d2, elapsed);
        }
        if(d2.collidable) {
          d2.collision(d1, elapsed);
        }
      }, 

      (d1: Entity, d2: Entity) -> {
        if(d1.collidable && d2.collidable) return FlxObject.separate(d1, d2);
        return false;
      }
    );

    FlxG.overlap(flags, flags, 
      (d1: Entity, d2: Entity) -> {
        if(d1.collidable) {
          d1.collision(d2, elapsed);
        }
        if(d2.collidable) {
          d2.collision(d1, elapsed);
        }
      }, 

      (d1: Entity, d2: Entity) -> {
        if(d1.collidable && d2.collidable) return FlxObject.separate(d1, d2);
        return false;
      }
    );
  }
}