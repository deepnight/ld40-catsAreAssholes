package en.inter;

import mt.MLib;
import mt.heaps.slib.*;
import hxd.Key;

class Litter extends en.Interactive {
	public static var ALL : Array<Litter> = [];
	var max = 5;
	var stock = 0;

	public function new(x,y) {
		super(x,y);
		ALL.push(this);
		zPrio = -99;
		weight = -1;
		stock = 3;
	}

	public function isEmpty() return stock==0;
	public function isFull() return stock>=max;

	override public function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	override public function onActivate(by:Hero) {
		super.onActivate(by);
		if( stock>0 ) {
			by.pick(Trash);
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