package utils;

import flixel.FlxSprite;

class Touching {
  /**
  * checks if your sprites are touching, optionally if it's also looking at it 
  * @param a this should be your tile or whatever
  * @param b player or something (IMPORTANT if you have `face_in_touch_direction` set to `true`)
  */
  public static function is_touching_sprite(a: FlxSprite, b: FlxSprite, ?threshold: Float = 0.0, ?face_in_touch_direction: Bool = false) {
    var a_left = a.x;
    var a_right = a.x + a.width;
    var a_top = a.y;
    var a_bottom = a.y + a.height;
    
    var b_left = b.x;
    var b_right = b.x + b.width;
    var b_top = b.y;
    var b_bottom = b.y + b.height;

    var on_right = Math.abs(a_right - b_left) <= threshold
    && a_bottom > b_top && a_top < b_bottom;
    
    var on_left = Math.abs(a_left - b_right) <= threshold
    && a_bottom > b_top && a_top < b_bottom;
    
    var on_bottom = Math.abs(a_bottom - b_top) <= threshold
    && a_right > b_left && a_left < b_right;
    
    var on_top = Math.abs(a_top - b_bottom) <= threshold
    && a_right > b_left && a_left < b_right;
    
    if(face_in_touch_direction) {
      if(on_left && b.facing == RIGHT) return true;
      if(on_right && b.facing == LEFT) return true;
      if(on_top && b.facing == FLOOR) return true;
      if(on_bottom && b.facing == CEILING) return true;
    } else {
      if(on_left) return true;
      if(on_right) return true;
      if(on_top) return true;
      if(on_bottom) return true;
    }
    return false;
  }
}