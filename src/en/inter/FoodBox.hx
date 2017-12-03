package en.inter;

import mt.MLib;
import mt.heaps.slib.*;
import hxd.Key;

class FoodBox extends en.Interactive {
	public function new(x,y) {
		super(x,y);
		spr.set("foodBox");
		radius = Const.GRID*0.3;
		weight = 999;
		footOffsetY = -4;
		zPrio = -99;
	}

	override public function dispose() {
		super.dispose();
	}

	override public function onActivate(by:Hero) {
		super.onActivate(by);
		trace("activate box");
		by.pick(Fish);
		cd.setS("lock", 6);
	}
}