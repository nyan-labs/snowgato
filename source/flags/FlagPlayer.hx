package flags;

import core.tilemap.Flag;
import entities.EntityPlayer;
import flixel.FlxG;

class FlagPlayer extends Flag {
	override public function create() {
		var player = new EntityPlayer();
		player.x = x;
		player.y = y;

		FlxG.camera.follow(player, LOCKON, 0.25);

		add(player);
	}
}
