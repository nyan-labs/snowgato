package states.substates;

import core.Controls;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.sound.FlxSound;
import flixel.text.FlxText.FlxTextFormat;
import flixel.text.FlxText.FlxTextFormatMarkerPair;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class Settings extends ui.OverlaySubState {
	override public function create() {
		super.create();

		var date = macros.MacroUtils.get_date();
		var commit_hash = macros.MacroUtils.get_commit_hash(true);

		var version = new flixel.text.FlxText(-4, -4, 0, 'built at ${date}, commit ${commit_hash}', 8);
		version.x += FlxG.width - version.width;
		version.y += FlxG.height - version.height;
		version.color = 0x414141;
		version.scrollFactor.set(0,0);
		add(version);

		title.text = 'settings';
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
	}
}
