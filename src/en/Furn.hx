package en;

import mt.MLib;
import mt.heaps.slib.*;
import hxd.Key;

class Furn extends Entity {
	public static var ALL : Array<Furn> = [];

	public function new(x,y) {
		super(x,y);
		ALL.push(this);
	}

	override public function dispose() {
		super.dispose();
		ALL.remove(this);
	}
}