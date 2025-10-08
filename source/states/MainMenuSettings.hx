package states;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.sound.FlxSound;
import flixel.text.FlxText.FlxTextFormat;
import flixel.text.FlxText.FlxTextFormatMarkerPair;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class MainMenuSettings extends ui.OverlaySubState {
	override public function create() {
		super.create();

		var title = new FlxText(12, 12, FlxG.width, "settings", 32);

		add(title);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
	}
}
