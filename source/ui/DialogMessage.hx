package ui;

import core.Controls;
import core.TypeTextExt;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxSignal;
import flixel.util.FlxTimer;

// move to top on mobile/withvirtualpad!!
class DialogMessage extends FlxSpriteGroup {
  public var dialog: Array<String> = [];
  public var index: Int = 0;
  
  public var text: TypeTextExt;

  public var text_finished: Bool;
  public var debounce: Bool;

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
    text.skipKeys = []; // we will not use this, only our own
    text.autoErase = false;

    add(text);

    visible = false;
    text_finished = true;
  }

  public function end(clear: Bool = true) {
    visible = false;
    // little debounce
    text_finished = true;
    FlxTimer.wait(0.25, function() debounce = false);
    
    onvisible.dispatch();

    if(clear) dialog = [];
  }

  public function skip() { text.skip(); }

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
    text.start();
    
    return false;
  }

  public function start() {
    if(!text_finished) return false;
    if(debounce) return false;
    if(dialog.length == 0) return false;

    debounce = true;
    visible = true;
    index = -1;

    onvisible.dispatch();

    // display text
    next();
    return true;
  }


  override public function update(elapsed: Float) {
    super.update(elapsed);

    if(index != -1 && Controls.button.just_pressed.B) {
      skip();
    }

    if(index != -1 && Controls.button.just_pressed.A && !text.typing && !text_finished) {
      next();
    }
  }
} 