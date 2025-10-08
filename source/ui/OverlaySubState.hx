package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;

class OverlaySubState extends FlxSubState {
	override public function create() {
		super.create();

		var bg = new FlxSprite(0, 0);
		bg.makeGraphic(FlxG.width, FlxG.height, 0xac000000);
		add(bg);

		var close_button = new ui.ButtonPrimary(0, 4, "X", function() {
			close();
		});
		
		close_button.resize(22, 22);

		close_button.x = FlxG.width - close_button.width - 4;
		add(close_button);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		if(FlxG.keys.justPressed.ESCAPE) {
			close();
		}
	}
}
