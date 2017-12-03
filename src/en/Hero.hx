package en;

import mt.MLib;
import mt.heaps.slib.*;

class Hero extends Entity {
	public var item : Null<Data.ItemKind>;
	public var itemIcon : Null<h2d.Bitmap>;

	private function new(x,y) {
		super(x,y);
		enableShadow();
		weight = 2;
	}

	public function pick(i:Data.ItemKind) {
		dropItem();
		item = i;
		itemIcon = new h2d.Bitmap(Assets.getItem(item), spr);
		itemIcon.tile.setCenterRatio(0.5,1);
		itemIcon.y = -20;
		trace("picked "+item);
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

		var a = getThrowAng() + rnd(0,0.1,true);
		var e = new en.inter.ItemDrop(item, cx,cy);
		e.dx = Math.cos(a) * 0.3;
		e.dy = Math.sin(a) * 0.3;

		item = null;
		itemIcon.remove();
		itemIcon = null;
	}

}