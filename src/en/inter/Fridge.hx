package en.inter;

import mt.MLib;
import mt.heaps.slib.*;
import hxd.Key;

class Fridge extends en.Interactive {
	public static var ALL : Array<Fridge> = [];
	var max = 5;
	var stock = 0;

	public function new(x,y) {
		super(x,y);
		ALL.push(this);
		spr.set("foodBox");
		radius = Const.GRID*0.3;
		weight = 999;
		footOffsetY = -4;
		zPrio = -99;
		stock = max;
	}

	override public function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	public function isEmpty() return stock==0;

	override public function canBeActivated(by:Hero) {
		return super.canBeActivated(by) && ( by.item==null && stock>0 || by.item==FoodBox && stock<max ) ;
	}

	override public function onActivate(by:Hero) {
		super.onActivate(by);
		if( by.item==FoodBox ) {
			stock = max;
			by.destroyItem();
		}
		else {
			by.pick(Fish);
			stock--;
		}
	}
	override public function update() {
		super.update();
		setLabel(stock+"/"+max);
	}
}