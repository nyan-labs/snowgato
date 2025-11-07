package core.tilemap;

import flixel.group.FlxGroup.FlxTypedGroup;

class Layer extends FlxTypedGroup<Tile> {
  public var order: Int;
  public var name: String;
  public var collide: Bool;

  public function new(order: Int, name: Null<String> = null, collide: Bool = true) {
    if(name == null) name = 'layer #${order}';
    this.order = order;
    this.name = name;
    this.collide = collide;
    super();
  }
}