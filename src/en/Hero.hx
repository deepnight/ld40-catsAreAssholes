package en;

import mt.MLib;
import mt.heaps.slib.*;

class Hero extends Entity {
	public var item : Null<Data.ItemKind>;
	public var itemIcon : Null<h2d.Bitmap>;

	private function new(x,y) {
		super(x,y);
		weight = -1;
	}

	public function pick(i:Data.ItemKind) {
		dropItem();
		item = i;
		itemIcon = new h2d.Bitmap(Assets.getItem(item), spr);
		itemIcon.tile.setCenterRatio(0.5,1);
		itemIcon.y = -20;
	}

	override function hasCircCollWith(e:Entity) {
		return super.hasCircCollWith(e) && ( e.is(en.f.Ball) || e.is(Hero) );
	}

	public function destroyItem() {
		item = null;
		itemIcon.remove();
		itemIcon = null;
	}

	function getThrowAng() {
		return dir==1 ? 0 : 3.14;
	}

	public function dropItem() {
		if( item==null )
			return;

		switch( item ) {
			case TrayBox :
				var e = new en.inter.FoodTray(cx,cy);
				e.stock = 0;
				destroyItem();

			case LitterBox :
				var e = new en.inter.Litter(cx,cy);
				destroyItem();

			default :
				var a = getThrowAng() + rnd(0,0.1,true);
				var e = new en.inter.ItemDrop(item, cx,cy);
				e.dx = Math.cos(a) * 0.3;
				e.dy = Math.sin(a) * 0.3;

				item = null;
				itemIcon.remove();
				itemIcon = null;
		}
	}

}