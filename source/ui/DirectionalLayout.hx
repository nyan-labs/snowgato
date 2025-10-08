package ui;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxContainer.FlxTypedContainer;

enum Direction {
  HORIZONTAL;
  VERTICAL;
}

class DirectionalLayout extends FlxTypedContainer<FlxSprite> {
  public var x: Float;
  public var y: Float;

  public var direction: Direction;
  public var gap: Int;

  /** left to right */
  public var ltr: Bool;
  /** top to bottom */
  public var ttb: Bool;
  /** forces sprites to stay on screen */
  public var anchor: Bool;

  override public function new(max_size: Int = 0, x: Float = 0.0, y: Float = 0.0, direction: Direction = VERTICAL, gap: Int = 0) {
    super(max_size);

    this.x = x;
    this.y = y;

    this.direction = direction;
    this.gap = gap;
  }

  public function members_width(do_gap: Bool = true) {
    final idx = members.length + 1;

    var accum = 0.0;
    for(member in members) accum += member.width + (do_gap ? (idx * gap) : 0);
    return accum;
  }
  public function members_height(do_gap: Bool = true) {
    final idx = members.length + 1;

    var accum = 0.0;
    for(member in members) accum += member.height + (do_gap ? (idx * gap) : 0);
    return accum;
  }

  public function update_member(member: FlxSprite) {
    final h_modifier = ltr ? -1 : 1;
    final v_modifier = ttb ? -1 : 1;
    
    member.x = x;
    member.y = y;
    if(direction == HORIZONTAL) member.x += (
      members_width()
    ) * h_modifier; else member.x += (ltr ? (-member.width) : 0);
    if(direction == VERTICAL) member.y += (
      members_height()
    ) * v_modifier; else member.y += (ttb ? (-member.width) : 0);

    if(anchor) member.scrollFactor.set(0, 0);
  }
  public function update_members() {
    for(member in members) update_member(member);
  }

	override public function add(sprite: FlxSprite): flixel.FlxSprite {
    final member = super.add(sprite);

    update_member(member);

    return member;
  }
  
	override public function draw() {
    super.draw();
  }
}
