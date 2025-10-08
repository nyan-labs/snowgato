package states;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.sound.FlxSound;
import flixel.text.FlxText.FlxTextFormat;
import flixel.text.FlxText.FlxTextFormatMarkerPair;
import flixel.util.FlxColor;
import ui.DirectionalLayout;

class MainMenu extends FlxState {
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

		var list = new DirectionalLayout();
		list.x = 20;
		list.y = Math.round(text.height) + 5;
		list.gap = 1;

		var start_button = new ui.ButtonPrimary(0, 0, "start", function() {
			switch_state(states.Game);
		});

		list.add(start_button);

		var settings_button = new ui.ButtonPrimary(0, 0, "settings", function() {
			switch_substate(states.MainMenuSettings);
		});

		list.add(settings_button);

		add(list);

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
		FlxG.camera.fade(FlxColor.BLACK, 0.5, false, function() {
			FlxG.switchState(function () { return Type.createInstance(state, []); });
		});
	}
	function switch_substate(state: Class<FlxSubState>) {
		openSubState(Type.createInstance(state, []));
	}
}
