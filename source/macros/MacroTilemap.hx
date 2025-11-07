package macros;

import haxe.io.Path;
#if macro 
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.TypeTools;
#end

class MacroTilemap {
  public static macro function get_tile_classes(): Expr {
    var list: Array<Expr> = [];
    final files = sys.FileSystem.readDirectory("source/tiles");

    for(file in files) {
      Context.registerModuleDependency(Context.getLocalModule(), file);
      var path = new Path(file);
      if(path.file == null) continue; 

      final ass = path.file;
      Context.getType('tiles.${ass}');

      list.push(macro tiles.$ass);
    }

    return macro $a{list};
  }

}