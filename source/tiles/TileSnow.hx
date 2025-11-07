package tiles;

import core.tilemap.Tile;

class TileSnow extends Tile {
	public static var namespace = "@";
  public static var id = "snow";

  override public function create() {
    // todo: add variation
    loadGraphic("assets/images/tiles/snow-1.png");
  }
}f