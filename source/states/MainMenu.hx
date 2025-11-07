package states;

import core.Controls;
import core.StateExt;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.sound.FlxSound;
import flixel.text.FlxText.FlxTextFormat;
import flixel.text.FlxText.FlxTextFormatMarkerPair;
import flixel.util.FlxColor;
import ui.ButtonPrimary;

class MainMenu extends StateExt {

	override public function create() {
		super.create();

		var text = new flixel.text.FlxText(0, 0, 0, "cat game \n&but snow&",32);
		text.applyMarkup(
			text.text,
			[new FlxTextFormatMarkerPair(new FlxTextFormat(0x909090), "&")]
		);

		text.setPosition(20, 20);
		text.scrollFactor.set(0,0);
		
		add(text);

		var gapping = 5;

		var start_button = new ButtonPrimary(text.x, text.y + text.height + gapping, "start", function() {
			switch_state(states.LevelSelect);
		});
		focus.add(start_button, true);

		var level_editor_button = new ButtonPrimary(start_button.x, start_button.y + start_button.height + gapping, "level editor", function() {
			switch_state(states.LevelEditor);
		});
		focus.add(level_editor_button);

		var settings_button = new ButtonPrimary(level_editor_button.x, level_editor_button.y + level_editor_button.height + gapping, "settings", function() {
			switch_substate(states.substates.Settings);
		});
		focus.add(settings_button);

		var credit = new flixel.text.FlxText(-4, -4, 0, "nyanlabs 2025", 8);
		credit.x += FlxG.width - credit.width;
		credit.y += FlxG.height - credit.height;
		credit.color = 0x909090;

		credit.scrollFactor.set(0,0);

		add(credit);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
	}

	function switch_state(state: Class<FlxState>) {
		// FlxG.camera.fade(FlxColor.BLACK, 0.5, false, function() {
			FlxG.switchState(function () { return Type.createInstance(state, []); });
		// });
	}
	function switch_substate(state: Class<FlxSubState>) {
		openSubState(Type.createInstance(state, []));
	}
}
