package en;

import mt.MLib;
import mt.heaps.slib.*;
import hxd.Key;

class Interactive extends Entity {
	public static var ALL : Array<Interactive> = [];
	var reqItem : Null<Data.ItemKind>;

	public function new(x,y) {
		super(x,y);
		ALL.push(this);
		weight = -1;
	}

	function onActivate() {
	}

	public function canBeActivated() {
		return !cd.has("lock") && ( reqItem==null || hero.item==reqItem );
	}

	override public function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	override public function postUpdate() {
		super.postUpdate();
	}

	public function activate() {
		if( reqItem!=null )
			hero.consumeItem();
		onActivate();
	}

	override public function update() {
		super.update();
	}
}