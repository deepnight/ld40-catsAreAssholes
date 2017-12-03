package en.inter;

import mt.MLib;
import mt.heaps.slib.*;
import hxd.Key;

class ItemDrop extends en.Interactive {
	var k : Data.ItemKind;
	public function new(k:Data.ItemKind, x,y) {
		super(x,y);
		radius = Const.GRID*0.3;
		this.k = k;
		altitude = 20;
		enableShadow(1.5);
		weight = 0.2;
		zPrio = -4;

		spr.set("empty");

		var icon = new h2d.Bitmap(Assets.getItem(k), spr);
		icon.tile.setCenterRatio(0.5,1);
		cd.setS("lock",0.3);
	}

	override public function dispose() {
		super.dispose();
	}
	override function canBeActivated() {
		return super.canBeActivated() && hero.item!=k;
	}

	override public function onActivate() {
		super.onActivate();
		hero.pick(k);
		destroy();
	}

	override public function update() {
		super.update();
		if( !onGround )
			frict = 0.92;
		else
			frict = 0.75;
	}
}