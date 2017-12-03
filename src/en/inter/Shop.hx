package en.inter;

import mt.MLib;
import mt.heaps.slib.*;
import hxd.Key;

class Shop extends en.Interactive {
	public static var ALL : Array<Shop> = [];
	var door(get,never) : en.inter.Door; inline function get_door() return en.inter.Door.ALL[0];

	public function new(x,y) {
		super(x,y);
		yr = 1;
		ALL.push(this);
		spr.set("foodBox");
		radius = Const.GRID*0.3;
		weight = -1;
		zPrio = -99;
	}

	override public function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	override public function canBeActivated(by:Hero) {
		return super.canBeActivated(by) && !door.hasEvent(FoodDelivery);
	}

	override public function onActivate(by:Hero) {
		super.onActivate(by);
		door.addEvent(FoodDelivery, 20);
	}

	override public function update() {
		super.update();
	}
}