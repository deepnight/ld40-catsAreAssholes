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

	override public function onActivate() {
		super.onActivate();
		if( game.hero.item!=null )
			game.hero.consumeItem();
	}

	override public function postUpdate() {
		super.postUpdate();
	}
}