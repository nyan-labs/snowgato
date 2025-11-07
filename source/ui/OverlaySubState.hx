package ui;

import core.Controls;
import core.StateExt.SubStateExt;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;

class OverlaySubState extends SubStateExt {
	public var close_button: ButtonPrimary;
	public var title: FlxText;

	public function new() {
    super(0xDA000000);
  }
    
	override public function create() {
		super.create();

    title = new FlxText();
		title.autoSize = false;
		title.wordWrap = false;

    title.text = ""; 
    title.size = 16;
		title.x = 5;
		title.y = 5;
		title.fieldHeight = 24;

		close_button = new ui.ButtonPrimary(0, 5, "x", function() {
			close();
		});
		close_button.resize(24, 24);
		close_button.x = FlxG.width - close_button.width - 5;
		
		title.fieldWidth = FlxG.width - close_button.width - 5*2;

    add(title);
		add(close_button);
		focus.add(close_button);
	}

	override public function add(member: FlxBasic) {
		if(member is FlxSprite) {
			var casted_member = cast (member, FlxSprite);
			casted_member.scrollFactor.set(0,0);
		}
		return super.add(member);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		if(FlxG.keys.justPressed.ESCAPE) {
			close();
		}
	}
}
