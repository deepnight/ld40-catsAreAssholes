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

	function onActivate(by:Hero) {
	}

	public function canBeActivated(by:Hero) {
		return !cd.has("lock") && ( reqItem==null || by.item==reqItem );
	}

	override public function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	override public function postUpdate() {
		super.postUpdate();
	}

	public function activate(by:Hero) {
		if( reqItem!=null )
			by.destroyItem();
		onActivate(by);
	}

	override public function update() {
		super.update();
	}
}