package en.inter;

import mt.MLib;
import mt.heaps.slib.*;
import hxd.Key;

class Litter extends en.Interactive {
	public static var ALL : Array<Litter> = [];
	var max = 7;
	var stock = 0;

	public function new(x,y) {
		super(x,y);
		ALL.push(this);
		//footOffsetY = -10;
		zPrio = -99;
		weight = -1;
	}

	public function isFull() return stock>=max;

	override public function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	override public function onActivate() {
		super.onActivate();
		if( stock>0 ) {
			hero.pick(Trash);
			stock = 0;
		}
	}

	public function addShit(n) {
		stock = MLib.min(stock+n, max);
	}

	override public function postUpdate() {
		super.postUpdate();
		spr.y+=10;
		spr.set("litter", stock>=max ? 3 : stock>=max*0.5 ? 2 : stock>0 ? 1 : 0);
	}

	//override public function update() {
		//super.update();
		//setLabel(stock+"/"+max);
	//}
}