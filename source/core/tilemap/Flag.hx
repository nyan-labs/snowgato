package core.tilemap;

import flixel.group.FlxGroup.FlxTypedGroup;

// the purpose of flags are supposed 
// to be similar to a spawner, for example the player
// you can spawn one, many or continue to spawn 
class Flag extends FlxTypedGroup<Entity> {
  public var id(default, null): String;
  public var type: String;
  public var x: Int;
  public var y: Int;

  override public function new(id: String, x: Int = 0, y: Int = 0) {
    super();

    this.id = id;

    this.x = x;
    this.y = y;
  }

  public function create() {}

  override public function update(elapsed: Float) {
    super.update(elapsed);
  }
}