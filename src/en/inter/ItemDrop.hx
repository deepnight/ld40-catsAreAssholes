package en.inter;

import mt.MLib;
import mt.heaps.slib.*;
import hxd.Key;

class ItemDrop extends en.Interactive {
	public static var ALL : Array<ItemDrop> = [];

	public var k : Data.ItemKind;

	public function new(k:Data.ItemKind, x,y) {
		super(x,y);
		ALL.push(this);
		radius = Const.GRID*0.3;
		this.k = k;
		altitude = 10;
		enableShadow(1.5);
		weight = -1;
		zPrio = -8;

		spr.set("empty");

		var icon = new h2d.Bitmap(Assets.getItem(k), spr);
		icon.tile.setCenterRatio(0.5,1);

		if( Data.item.get(k).decayS>0 )
			cd.setS("alive", Data.item.get(k).decayS, function() {
				destroy();
			});
	}

	override public function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	public static function countNearby(k:Data.ItemKind, x,y, d) {
		var n = 0;
		for(e in ALL)
			if( e.k==k && mt.deepnight.Lib.distanceSqr(e.cx,e.cy,x,y)<=d*d )
				n++;
		return n;
	}

	override function canBeActivated(by:Hero) {
		return super.canBeActivated(by) && by.item!=k;
	}

	override public function onActivate(by:Hero) {
		super.onActivate(by);
		switch( k ) {
			case Shit :
				by.pick(Trash);

			default :
				by.pick(k);
		}
		destroy();
	}

	override public function update() {
		super.update();
		if( !onGround )
			frict = 0.92;
		else
			frict = 0.75;

		if( cd.has("alive") &&  cd.getS("alive")<=1 && !cd.hasSetS("blink",0.06) )
			spr.alpha = spr.alpha==1 ? 0.1 : 1;
	}
}