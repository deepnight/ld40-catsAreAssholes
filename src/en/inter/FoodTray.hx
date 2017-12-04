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
		enableShadow(1.5);
	}

	public static function pickOne() : FoodTray {
		var dh = new DecisionHelper(ALL);
		dh.score( function(e) return e.isEmpty() ? -5 : 0 );
		dh.score( function(e) return e.rnd(0,1) );
		return dh.getBest();
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

		if( isEmpty() && !cd.hasSetS("warning",1) )
			blink();
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

	override public function onActivate(by:Hero) {
		super.onActivate(by);
		if( by.item==FishCan ) {
			by.destroyItem();
			stock = max;
			Tutorial.ME.complete("food");
		}
		else {
			by.emote("eFishCan");
		}
	}


	override public function update() {
		super.update();

		if( cd.has("eating") && !cd.hasSetS("push",rnd(0.2,0.6)) ) {
			dx+=rnd(0,0.03,true);
			dy+=rnd(0,0.03,true);
			spr.rotation = rnd(0,0.2,true);
			jump(rnd(0,0.1));
		}

		if( stock<max )
			Tutorial.ME.tryToStart("food", "Take some food from the FRIDGE to fill your cat food bowls. Or they will eat you.");
	}
}