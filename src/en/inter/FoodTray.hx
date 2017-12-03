package en.inter;

import mt.MLib;
import mt.heaps.slib.*;
import hxd.Key;

class FoodTray extends en.Interactive {
	public static var ALL : Array<FoodTray> = [];

	var max = 4;
	public var stock : Int;
	public function new(x,y) {
		super(x,y);
		radius = Const.GRID*0.3;
		zPrio = -6;
		ALL.push(this);
		stock = max;
		weight = 6;
		reqItem = FishCan;
		enableShadow(1.5);
	}

	public static function pickOne() : Null<FoodTray> {
		var all = ALL.filter( function(e) return !e.isEmpty() );
		if( all.length==0 )
			return null;
		return all[Std.random(all.length)];
	}

	override public function dispose() {
		super.dispose();
		ALL.remove(this);
	}
	override public function postUpdate() {
		super.postUpdate();

		if( isEmpty() )
			spr.set("foodEmpty");
		else if( stock==max )
			spr.set("foodFull",0);
		else if( stock>=2 )
			spr.set("foodFull",1);
		else
			spr.set("foodFull",2);

		spr.rotation+=(0-spr.rotation)*0.15;
	}

	public function isEmpty() return stock<=0;
	public function isFull() return stock==max;

	public function eat() {
		if( stock>0 ) {
			stock--;
			cd.setS("eating",rnd(1,1.5));
			return true;
		}
		else
			return false;
	}

	override function canBeActivated(by:Hero) {
		return super.canBeActivated(by) && !isFull();
	}

	override public function onActivate(by) {
		super.onActivate(by);
		stock = max;
	}

	override public function update() {
		super.update();

		if( cd.has("eating") && !cd.hasSetS("push",rnd(0.2,0.6)) ) {
			dx+=rnd(0,0.03,true);
			dy+=rnd(0,0.03,true);
			spr.rotation = rnd(0,0.2,true);
			jump(rnd(0,0.1));
		}
	}
}