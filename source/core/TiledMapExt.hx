package core;

import flixel.addons.editors.tiled.TiledMap;
import haxe.io.Path;
import haxe.xml.Access;
import openfl.utils.Assets;

class TiledMapExt extends TiledMap {
  public var source: Access = null;
  
  override public function new(data: FlxTiledMapAsset, ?rootPath: String) {
    super(data, rootPath);

		if (rootPath != null)
			this.rootPath = rootPath;

		if ((data is String))
		{
			if (this.rootPath == null)
				this.rootPath = Path.directory(data) + "/";
			source = new Access(Xml.parse(Assets.getText(data)));
		}
		else if ((data is Xml))
		{
			if (this.rootPath == null)
				this.rootPath = "";
			var xml:Xml = cast data;
			source = new Access(xml);
		}

		source = source.node.map;
  }
}