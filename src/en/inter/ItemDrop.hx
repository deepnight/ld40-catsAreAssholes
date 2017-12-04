package en.inter;

import mt.MLib;
import mt.heaps.slib.*;
import hxd.Key;

class ItemDrop extends en.Interactive {
	public static var ALL : Array<ItemDrop> = [];

	public var itemUid : Int;
	public var k : Data.ItemKind;
	public var skew = 0.;

	public function new(?iid:Int, k:Data.ItemKind, x,y) {
		super(x,y);

		itemUid = iid!=null ? iid : Const.UNIQ++;
		ALL.push(this);
		radius = Const.GRID*0.3;
		this.k = k;
		altitude = 10;
		if( k!=Vomit )
			enableShadow(1.5);
		weight = k==Vomit ? -1 : 5;
		zPrio = -8;

		if( k==Trash )
			cd.setS("loss",20);

		if( k==Vomit )
			cd.setS("loss",15);

		spr.set("empty");
		cd.setS("shake",rnd(1,2.5));

		var icon = new h2d.Bitmap(Assets.getItem(k), spr);
		icon.tile.setCenterRatio(0.5,1);
		icon.colorAdd = cAdd;

		if( k==CatBox )
			cd.setS("autoOpen", 5, onActivate.bind(hero));

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
		if( k==Heal && hero.life>=hero.maxLife )
			return false;
		return super.canBeActivated(by) && by.item!=k;
	}

	override public function postUpdate() {
		super.postUpdate();
		spr.scaleX = (1-skew)*dir;
		spr.scaleY = (1-skew);
		skew += (0-skew)*0.3;

		//if( k==Shit && !cd.hasSetS("warning",1) )
			//blink();
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
				hero.gainFollowers(1000);
				game.moneyMan.trigger(this,NewCat);
				fx.dirt(footX, footY, 80, 0xA2BDCA, 0x85562C);

			case Heal :
				hero.life = hero.maxLife;
				ui.Life.ME.blink();

			case Shit, Vomit :
				by.pick(itemUid, Trash);

			default :
				by.pick(itemUid, k);
		}
		destroy();
	}


	override public function update() {
		super.update();
		if( !onGround )
			frict = 0.92;
		else
			frict = 0.75;

		switch( k ) {
			case Shit :
				if( !cd.hasSetS("loss",10) ) {
					blink();
					game.hero.loseMoney(this,50);
				}

			case Vomit :
				if( !cd.hasSetS("loss",10) ) {
					blink();
					game.hero.loseMoney(this,15);
				}

			case Trash :
				if( !cd.hasSetS("loss",10) ) {
					blink();
					game.hero.loseMoney(this,15);
				}
			default :
		}

		if( cd.has("loss") && cd.getS("loss")<=3 && !cd.hasSetS("blinkLoss",0.33) )
			blink();

		if( k==CatBox && !cd.hasSetS("shake",rnd(0.2,0.5)) ) {
			dx+=rnd(0,0.02,true);
			dy+=rnd(0,0.02,true);
			jump(rnd(0.2,0.4));
		}

		if( cd.has("alive") && cd.getS("alive")<=1 && !cd.hasSetS("blink",0.06) )
			spr.alpha = spr.alpha==0.6 ? 0 : 0.6;
		else if( cd.has("alive") && cd.getS("alive")>1 && cd.getS("alive")<=3 && !cd.hasSetS("blink",0.09) )
			spr.alpha = spr.alpha==1 ? 0.3 : 1;

		#if debug
		setLabel("uid="+itemUid);
		#end
	}
}