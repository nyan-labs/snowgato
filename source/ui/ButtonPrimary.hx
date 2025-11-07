package ui;

//rewrite plz
import flixel.FlxSprite;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUIButton;
class ButtonPrimary extends FlxUIButton {
  var focus_texture = "assets/images/components/button_primary-focus.9.png";
  var default_texture = "assets/images/components/button_primary.9.png";

  var _focus = false;
  var _graphic_path: Null<String> = null;
  public var focus(get, set): Bool;
  inline function get_focus() {
    return _focus;
  }
  inline function set_focus(focused: Bool) {
    if(focused) {
      _loadGraphic(focus_texture);
    } else {
      _loadGraphic(default_texture);
    }
    _focus = focused;
    return focused;
  }

  override public function new(?X:Float = 0, ?Y:Float = 0, ?Text:String, ?OnClick:Void->Void) {
    super(X, Y, Text, OnClick);

    if(label != null) {
      label.color = 0xffffff;
      label.autoSize = true;
    }

    _loadGraphic(default_texture);

    // loadGraphic(texture, true, 16, 16);
  }

  inline function _loadGraphic(texture: String) {
    if(_graphic_path == texture) return;

    var old_width = width;
    var old_height = height;
    
    loadGraphicSlice9([texture], 0, 0, [[6,6,8,8]], FlxUI9SliceSprite.TILE_NONE, -1, false, 24, 24);
    _graphic_path = texture;

    resize(old_width, old_height);
  }
}