package flags;

import core.tilemap.Entity;
import core.tilemap.Flag;
import flixel.FlxG;
import flixel.util.FlxTimer;

class FlagSpammer extends Flag {
	override public function create() {
		FlxTimer.loop(0.2, function(loop) {
			var entity = new Entity();
			entity.x = x + loop;
			entity.y = y;
	
			add(entity);
		}, 0);
	}
}
