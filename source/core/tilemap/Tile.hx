package core.tilemap;

import flixel.FlxSprite;
import flixel.util.FlxStringUtil.LabelValuePair;
import flixel.util.FlxStringUtil;

class Tile extends FlxSprite {
  public static var namespace(default, null): String = "@";
  public static var id(default, null): String = "unknown";
  public var variation: String;

  public var row: Int;
  public var column: Int;

  public function new(variation: String = "default", row: Null<Int> = 0, column: Null<Int> = 0) {
    super();

    this.variation = variation;

    if(row != null) this.row = row;
    if(column != null) this.column = column;

    this.immovable = true;

    this.create();
  }

  public function create() {
    loadGraphic("assets/images/tiles/unknown.png");
  }
}