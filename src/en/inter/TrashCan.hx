package en.inter;

import mt.MLib;
import mt.heaps.slib.*;
import hxd.Key;

class TrashCan extends en.Interactive {
	public static var ALL : Array<TrashCan> = [];
	public function new(x,y) {
		super(x,y);
		ALL.push(this);
		radius = Const.GRID*0.3;
		footOffsetY = -4;
		enableShadow(2);
		zPrio = -99;
		weight = 15;
		spr.set("trashCan");
	}

	override public function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	function canBeTrashed(k:Data.ItemKind) {
		return switch( k ) {
			case Trash, Shit, Vomit : true;
			case FishCan : false;
			case Heal : false;
			case Kid : false;
			case TrayBox, FoodBox, CatBox, FridgeUp, LitterBox : false;
		}
	}

	override public function canBeActivated(by:Hero) {
		return super.canBeActivated(by) && by.item!=null;
	}

	override public function onActivate(by:Hero) {
		super.onActivate(by);
		if( by.item!=null && canBeTrashed(by.item) ) {
			jump(0.2);
			cd.setS("shake",2);
			by.destroyItem();
		}
	}

	override function onTouch(e:Entity) {
		super.onTouch(e);
		if( e.is(en.inter.ItemDrop) ) {
			var e = e.as(en.inter.ItemDrop);
			if( canBeTrashed(e.k) )
				e.destroy();
		}

	}

	override public function postUpdate() {
		super.postUpdate();
		if( cd.has("shake") )
			spr.x+=cd.getRatio("shake")*Math.cos(game.ftime*0.5)*1;
	}
}