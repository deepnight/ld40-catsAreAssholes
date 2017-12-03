package en.inter;

import mt.MLib;
import mt.heaps.slib.*;
import hxd.Key;

class Fridge extends en.Interactive {
	public static var ALL : Array<Fridge> = [];
	public function new(x,y) {
		super(x,y);
		ALL.push(this);
		spr.set("foodBox");
		radius = Const.GRID*0.3;
		weight = 999;
		footOffsetY = -4;
		zPrio = -99;
	}

	override public function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	override public function onActivate(by:Hero) {
		super.onActivate(by);
		by.pick(Fish);
		cd.setS("lock", 6);
	}
}