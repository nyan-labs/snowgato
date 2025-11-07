package core;

import core.tilemap.Tilemap;
import flixel.FlxG;
import haxe.Rest;
import ui.DialogMessage;

using StringTools;

typedef ScriptContext = LevelLoader;

typedef ScriptCreate = (BaseLevel)->Void;
typedef ScriptUpdate = (BaseLevel, Float)->Void;

typedef Script = {
  create: ScriptCreate,
  update: ScriptUpdate
}

// rewrite
class LevelLoader extends BaseLevel {
  public var script: Null<Script>;
  final levels_path = 'assets/levels';
  public var level_name: String; 

  public function interpret(): Null<Script> {
    var path = '${levels_path}/${level_name}';
    var script = openfl.Assets.getText('${path}/Level.hxs');

    if(script == null) return null;
    
    var lines = script.split("\n");
    if(lines[0].contains("package")) lines[0] = ""; //hscript cant parse that useless line
    script = lines.join("\n");
    
    var interp = new hscript.Interp();
    var parser = new hscript.Parser();
    parser.allowTypes = true;
    
    interp.variables.set("FlxG", FlxG);
    interp.variables.set("Math", Math);
    interp.variables.set("Std", Std);

    interp.variables.set("Enum", {
      stringify: function(e) {
        return Std.string(e);
      }
    });
    
    var ast = parser.parseString(script);
    interp.execute(ast);

    // yes this is awful
    // yes kill me
    // haxe add spread/unpack arguments PLEASE 
    function pcall(fn: Null<(?Dynamic, ?Dynamic, ?Dynamic)->Dynamic>, args: Array<Dynamic>) {
      try {
        if(fn != null) fn(args[0], args[1], args[2]);
      } catch(e) {
        FlxG.log.error('level "$level_name" failed: $e');
      }
    }

    return {
      create: function(level) pcall(interp.variables.get("create"), [level]),
      update: function(level, elapsed) pcall(interp.variables.get("update"), [level, elapsed])
    };
  }
  
  override public function new(level_name: String) {
    this.level_name = level_name;
    super('$levels_path/$level_name');

    script = interpret();
  }

  function get_context(): ScriptContext {
    return this;
  }

  override public function create() {
    super.create();
    if(script != null) script.create(get_context());
  }

  override public function update(elapsed: Float) {
    super.update(elapsed);
    if(script != null) script.update(get_context(), elapsed);
  }
}