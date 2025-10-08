package ui;


import flixel.FlxSprite;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUIButton;
class ButtonPrimary extends FlxUIButton {
  override public function new(X:Float = 0, Y:Float = 0, ?Text:String, ?OnClick:Void->Void) {
    super(X, Y, Text, OnClick);

    label.color = 0xffffff;
    label.autoSize = true;

    var texture = "assets/images/components/button_primary.9.png";
    loadGraphicSlice9([texture], 0, 0, [[4,4,10,10]], FlxUI9SliceSprite.TILE_NONE, -1, false, 14, 14);

    // loadGraphic(texture, true, 16, 16);
  }
}