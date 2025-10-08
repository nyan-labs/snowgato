package ui;

import core.TypeTextExt;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxSignal;
import flixel.util.FlxTimer;

class DialogMessage extends FlxSpriteGroup {
  public var dialog: Array<String> = [];
  public var index: Int = 0;
  
  public var text: TypeTextExt;
  public var text_typing: Bool;
  public var text_finished: Bool;

  public var onvisible = new FlxSignal();

  override public function new() {
    super();

		scrollFactor.set(0,0);

    var gap = 5;
    var height = 40;

    y = FlxG.height - height - gap;
    x = gap;

    var bg = new FlxSprite();
    bg.setSize(FlxG.width - gap * 2, height);
    bg.makeGraphic(FlxG.width - gap * 2, height, 0xff515151);

    add(bg);

    text = new TypeTextExt(0, 0, -1, "");
    text.skipKeys = [X];
    text.autoErase = false;
    text.completeCallback = function() {
      text_typing = false;
    };

    add(text);

    visible = false;
    text_finished = true;
  }

  public function end(clear: Bool = true) {
    visible = false;
    // little debounce
    FlxTimer.wait(0.2, function() {
      text_finished = true;
    });
    
    onvisible.dispatch();

    if(clear) dialog = [];
  }

  // add reading the dialog and processing it,
  // (delay:100) for 100ms delay
  // <tiny>hey im really tiny</tiny>
  public function next() {
    if(index >= dialog.length-1) {
      end();
      return true;
    }
    text_finished = false;
    index += 1;
    text.applyMarkup(dialog[index], text.rules);
    text_typing = true;
    text.start();
    
    return false;
  }

  public function start() {
    if(!text_finished) return false;
    if(dialog.length == 0) return false;

    visible = true;
    index = -1;

    onvisible.dispatch();

    // display text
    next();
    return true;
  }


  override public function update(elapsed: Float) {
    super.update(elapsed);

    //actual stuf
    if(index != -1 && FlxG.keys.justPressed.Z && !text_typing && !text_finished) {
      next();
    }
  }
} 