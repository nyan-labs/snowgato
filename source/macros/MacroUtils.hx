package macros;

import haxe.io.Path;
#if macro 
import haxe.macro.Context;
import haxe.macro.Expr;
#end

// things that i cant really put under a specific class name
class MacroUtils {
  public static macro function get_file_list(folder: String): Expr {
    var list: Array<Expr> = [];
    final files = sys.FileSystem.readDirectory(folder);

    for(file in files) {
      list.push(macro $v{file});
    }

    return macro $a{list};
  }

  public static macro function register_import_files(dir_path: String, callback: Null<(path: String)->Void> = null): Expr {
    final files = sys.FileSystem.readDirectory(dir_path);
    for(path_str in files) {
      Context.registerModuleDependency(Context.getLocalModule(), path_str);
      if(callback != null) callback(path_str);
    }
    return macro null;
  }

  //https://code.haxe.org/category/macros/add-git-commit-hash-in-build.html
  public static macro function get_commit_hash(short: Bool = false):haxe.macro.Expr.ExprOf<String> {
    #if !display
    var args = ['rev-parse'];
    if(short) args.push('--short');

    args.push('HEAD');
    var process = new sys.io.Process('git', args);
    if (process.exitCode() != 0) {
      var message = process.stderr.readAll().toString();
      var pos = haxe.macro.Context.currentPos();
      haxe.macro.Context.error("Cannot execute `git rev-parse HEAD`. " + message, pos);
    }
    
    // read the output of the process
    var commitHash:String = process.stdout.readLine();
    
    // Generates a string expression
    return macro $v{commitHash};
    #else 
    // `#if display` is used for code completion. In this case returning an
    // empty string is good enough; We don't want to call git on every hint.
    var commitHash:String = "";
    return macro $v{commitHash};
    #end
  }

  public static macro function get_date() {
    var date = Date.now();

    return macro $v{date.toString()};
  }
}