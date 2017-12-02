package en;

import mt.MLib;
import mt.heaps.slib.*;
import hxd.Key;

class Hero extends Entity {
	public function new() {
		super(1,2);
		spr.set("ghost");
	}

	override public function update() {
		super.update();
		var spd = 0.03;
		if( Key.isDown(Key.RIGHT) ) {
			dir = 1;
			dx += dir*spd;
		}
		else if( Key.isDown(Key.LEFT) ) {
			dir = -1;
			dx += dir*spd;
		}

		if( Key.isDown(Key.UP) ) {
			dy -= spd;
		}
		else if( Key.isDown(Key.DOWN) ) {
			dy += spd;
		}
	}
}