package en.inter;

import mt.MLib;
import mt.heaps.slib.*;
import hxd.Key;

class TrashCan extends en.Interactive {
	public function new(x,y) {
		super(x,y);
		radius = Const.GRID*0.3;
		footOffsetY = -4;
		zPrio = -99;
		weight = 15;
		spr.set("trashCan");
	}

	override public function onActivate(by:Hero) {
		super.onActivate(by);
		if( by.item!=null )
			by.destroyItem();
	}

	override public function postUpdate() {
		super.postUpdate();
	}
}