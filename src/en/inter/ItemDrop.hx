package en.inter;

import mt.MLib;
import mt.heaps.slib.*;
import hxd.Key;

class ItemDrop extends en.Interactive {
	public static var ALL : Array<ItemDrop> = [];

	public var k : Data.ItemKind;
	public var skew = 0.;

	public function new(k:Data.ItemKind, x,y) {
		super(x,y);
		ALL.push(this);
		radius = Const.GRID*0.3;
		this.k = k;
		altitude = 10;
		enableShadow(1.5);
		weight = 5;
		zPrio = -8;

		spr.set("empty");
		cd.setS("shake",rnd(1,2.5));

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

	override public function postUpdate() {
		super.postUpdate();
		spr.scaleX = (1-skew)*dir;
		spr.scaleY = (1-skew);
		skew += (0-skew)*0.3;
	}

	override public function onActivate(by:Hero) {
		super.onActivate(by);
		switch( k ) {
			case CatBox :
				var e = new en.Cat(cx,cy);
				e.jump(1);
				e.cd.setS("lock", 0.7);
				e.cd.setS("fear", e.cd.getS("lock"));
				e.flee(this);
				game.moneyMan.trigger(this,NewCat);

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

		if( k==CatBox && !cd.hasSetS("shake",rnd(0.2,0.5)) ) {
			dx+=rnd(0,0.02,true);
			dy+=rnd(0,0.02,true);
			jump(rnd(0.2,0.4));
		}

		if( cd.has("alive") && cd.getS("alive")<=1 && !cd.hasSetS("blink",0.06) )
			spr.alpha = spr.alpha==0.6 ? 0 : 0.6;
		else if( cd.has("alive") && cd.getS("alive")>1 && cd.getS("alive")<=3 && !cd.hasSetS("blink",0.09) )
			spr.alpha = spr.alpha==1 ? 0.3 : 1;
	}
}