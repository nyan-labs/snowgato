package;

import core.Controls;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.sound.FlxSound;
import flixel.system.scaleModes.RatioScaleMode;
import flixel.util.FlxColor;
import openfl.display.Sprite;

class Main extends Sprite {
	public function new() {
		super();

		addChild(new FlxGame(320, 240, states.MainMenu, 60, 60, true));
		Controls.init();

		openfl.Lib.current.stage.color = 0x000000;

		FlxG.scaleMode = new RatioScaleMode();

		FlxG.mouse.useSystemCursor = true;
		FlxG.autoPause = false;
	}
}
